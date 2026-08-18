package identity

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type authService interface {
	RequestCode(ctx context.Context, phone string) error
	VerifyCode(ctx context.Context, phone, code string) (Session, error)
	Refresh(ctx context.Context, refreshToken string) (Tokens, error)
	Logout(ctx context.Context, refreshToken string) error
}

// Handler exposes the authentication endpoints.
type Handler struct{ service authService }

// NewHandler creates an identity handler.
func NewHandler(service authService) *Handler { return &Handler{service: service} }

// Mount registers the authentication routes.
func (h *Handler) Mount(r chi.Router) {
	r.Post("/auth/otp/request", h.requestCode)
	r.Post("/auth/otp/verify", h.verifyCode)
	r.Post("/auth/refresh", h.refresh)
	r.Post("/auth/logout", h.logout)
}

type phoneBody struct {
	Phone string `json:"phone"`
}

type verifyBody struct {
	Phone string `json:"phone"`
	Code  string `json:"code"`
}

type refreshBody struct {
	RefreshToken string `json:"refresh_token"`
}

// tokenResponse is the issued session.
type tokenResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int64  `json:"expires_in"`
}

// sessionResponse is a verification, which is a token pair plus the one thing
// only verification can report.
type sessionResponse struct {
	tokenResponse
	IsNewUser bool `json:"is_new_user"`
}

func (h *Handler) requestCode(w http.ResponseWriter, r *http.Request) {
	var body phoneBody
	if !decode(w, r, &body) {
		return
	}
	if err := h.service.RequestCode(r.Context(), body.Phone); err != nil {
		writeError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusAccepted)
}

func (h *Handler) verifyCode(w http.ResponseWriter, r *http.Request) {
	var body verifyBody
	if !decode(w, r, &body) {
		return
	}
	session, err := h.service.VerifyCode(r.Context(), body.Phone, body.Code)
	if err != nil {
		writeError(w, r, err)
		return
	}
	writeJSON(w, sessionResponse{
		tokenResponse: tokens(session.Tokens),
		IsNewUser:     session.IsNewUser,
	})
}

func (h *Handler) refresh(w http.ResponseWriter, r *http.Request) {
	var body refreshBody
	if !decode(w, r, &body) {
		return
	}
	rotated, err := h.service.Refresh(r.Context(), body.RefreshToken)
	if err != nil {
		writeError(w, r, err)
		return
	}
	writeJSON(w, tokens(rotated))
}

func (h *Handler) logout(w http.ResponseWriter, r *http.Request) {
	var body refreshBody
	if !decode(w, r, &body) {
		return
	}
	if err := h.service.Logout(r.Context(), body.RefreshToken); err != nil {
		writeError(w, r, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// tokens renders an issued pair for the wire.
func tokens(t Tokens) tokenResponse {
	return tokenResponse{
		AccessToken:  t.AccessToken,
		RefreshToken: t.RefreshToken,
		TokenType:    "Bearer",
		ExpiresIn:    t.ExpiresIn,
	}
}

func writeJSON(w http.ResponseWriter, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(body)
}

func decode(w http.ResponseWriter, r *http.Request, target any) bool {
	if err := json.NewDecoder(r.Body).Decode(target); err != nil {
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Unprocessable Entity",
			http.StatusUnprocessableEntity, "Unprocessable Entity", err))
		return false
	}
	return true
}

const problemType = "https://binno.uz/problems/identity"

// writeError maps service errors to responses.
func writeError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, ErrCooldown):
		w.Header().Set("Retry-After", otp.RetryAfterSeconds(otp.Cooldown))
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Too Many Requests",
			http.StatusTooManyRequests, "a code was already sent recently", err))
	case errors.Is(err, ErrInvalidPhone), errors.Is(err, ErrInvalidCode):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Unprocessable Entity",
			http.StatusUnprocessableEntity, "Unprocessable Entity", err))
	case errors.Is(err, ErrInvalidSession):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Unauthorized",
			http.StatusUnauthorized, "invalid session", err))
	case errors.Is(err, ErrBlocked):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Forbidden",
			http.StatusForbidden, "account is blocked", err))
	default:
		httpx.WriteProblem(w, r, err)
	}
}
