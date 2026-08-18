package location

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/location/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/tin"
)

// Seller registration errors.
var (
	ErrInvalidRegistration = errors.New("location: invalid seller registration")
	ErrAlreadyRegistered   = errors.New("location: user already has an owner account")
	ErrTINTaken            = errors.New("location: TIN already registered")
)

// SellerRegistration is an application to sell.
type SellerRegistration struct {
	TIN         string
	LegalName   string
	LegalForm   string
	BankAccount string
	MFO         string
}

// RegisterSeller creates a pending owner account for the calling user.
func (r *Repository) RegisterSeller(
	ctx context.Context, userID string, in SellerRegistration, now time.Time,
) (string, error) {
	row, err := store.New(r.pool).RegisterOwner(ctx, &store.RegisterOwnerParams{
		ID:          uuidValue(uuid.NewString()),
		UserID:      uuidValue(userID),
		Tin:         in.TIN,
		LegalName:   in.LegalName,
		LegalForm:   &in.LegalForm,
		BankAccount: &in.BankAccount,
		Mfo:         &in.MFO,
		Now:         pgtype.Timestamptz{Time: now, Valid: true},
	})
	if err != nil {
		switch {
		case isUniqueViolation(err, "owners_user_id_key"):
			return "", ErrAlreadyRegistered
		case isUniqueViolation(err, "owners_tin_key"):
			return "", ErrTINTaken
		}
		return "", fmt.Errorf("location: register seller: %w", err)
	}
	return row.ID.String(), nil
}

// OwnerForUser returns the caller's owner account, if any.
func (r *Repository) OwnerForUser(ctx context.Context, userID string) (string, string, error) {
	row, err := store.New(r.pool).GetOwnerForUser(ctx, uuidValue(userID))
	if errors.Is(err, pgx.ErrNoRows) {
		return "", "", pgx.ErrNoRows
	}
	if err != nil {
		return "", "", fmt.Errorf("location: owner for user: %w", err)
	}
	return row.ID.String(), row.Status, nil
}

func isUniqueViolation(err error, constraint string) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505" && pgErr.ConstraintName == constraint
}

func uuidValue(value string) pgtype.UUID {
	var id pgtype.UUID
	_ = id.Scan(value)
	return id
}

// SellerHandler exposes seller onboarding.
type SellerHandler struct {
	repository *Repository
	verifier   tin.Verifier
	now        func() time.Time
}

// Mount registers the seller routes.
func (h *SellerHandler) Mount(r chi.Router) {
	r.Post("/sellers/register", httpx.Mutating("location", "register_seller", h.register))
	r.Get("/sellers/me", h.me)
}

type registerBody struct {
	TIN         string `json:"tin"`
	LegalName   string `json:"legal_name"`
	LegalForm   string `json:"legal_form"`
	BankAccount string `json:"bank_account"`
	MFO         string `json:"mfo"`
}

const problemType = "https://binno.uz/problems/seller"

func (h *SellerHandler) register(w http.ResponseWriter, r *http.Request) {
	principal, err := authz.Require(r.Context())
	if err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	var body registerBody
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		writeSellerError(w, r, fmt.Errorf("%w: malformed body", ErrInvalidRegistration))
		return
	}
	if strings.TrimSpace(body.LegalName) == "" {
		writeSellerError(w, r, fmt.Errorf("%w: legal_name is required", ErrInvalidRegistration))
		return
	}
	if err := h.verifier.Verify(r.Context(), body.TIN); err != nil {
		writeSellerError(w, r, fmt.Errorf("%w: %v", ErrInvalidRegistration, err))
		return
	}

	ownerID, err := h.repository.RegisterSeller(
		r.Context(), principal.UserID, SellerRegistration(body), h.now())
	if err != nil {
		writeSellerError(w, r, err)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	_ = json.NewEncoder(w).Encode(map[string]string{
		"owner_id": ownerID,
		"status":   "pending",
	})
}

func (h *SellerHandler) me(w http.ResponseWriter, r *http.Request) {
	principal, err := authz.Require(r.Context())
	if err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	ownerID, status, err := h.repository.OwnerForUser(r.Context(), principal.UserID)
	if errors.Is(err, pgx.ErrNoRows) {
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Not Found",
			http.StatusNotFound, "no seller account", err))
		return
	}
	if err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{"owner_id": ownerID, "status": status})
}

func writeSellerError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, ErrInvalidRegistration):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Unprocessable Entity",
			http.StatusUnprocessableEntity, "Unprocessable Entity", err))
	case errors.Is(err, ErrAlreadyRegistered):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Conflict",
			http.StatusConflict, "this account already has a seller registration", err))
	case errors.Is(err, ErrTINTaken):
		httpx.WriteProblem(w, r, httpx.NewAppError(problemType, "Conflict",
			http.StatusConflict, "this TIN is already registered", err))
	default:
		httpx.WriteProblem(w, r, err)
	}
}
