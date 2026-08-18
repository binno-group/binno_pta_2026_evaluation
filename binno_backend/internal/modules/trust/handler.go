package trust

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type trustService interface {
	CreateOrderFeedback(context.Context, FeedbackInput) error
}

// Handler translates feedback HTTP requests into service calls.
type Handler struct{ service trustService }

// NewHandler creates a trust handler.
func NewHandler(service trustService) *Handler { return &Handler{service: service} }

// Mount registers trust routes.
func (h *Handler) Mount(r chi.Router) {
	r.Post("/orders/{id}/feedback", httpx.Mutating("trust", "create_feedback", h.createOrderFeedback))
}

func (h *Handler) createOrderFeedback(w http.ResponseWriter, r *http.Request) {
	var body struct {
		HadProblem bool     `json:"had_problem"`
		Tags       []string `json:"tags"`
		Comment    string   `json:"comment"`
		Channel    string   `json:"channel"`
	}
	decoder := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&body); err != nil {
		httpx.WriteProblem(w, r, appError(ErrInvalid))
		return
	}
	err := h.service.CreateOrderFeedback(r.Context(), FeedbackInput{
		OrderID: chi.URLParam(r, "id"), HadProblem: body.HadProblem, Tags: body.Tags,
		Comment: body.Comment, Channel: body.Channel,
	})
	if err != nil {
		if errors.Is(err, authz.ErrForbidden) || errors.Is(err, authz.ErrUnauthenticated) {
			httpx.WriteProblem(w, r, err)
			return
		}
		httpx.WriteProblem(w, r, appError(err))
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func appError(err error) error {
	status, title := http.StatusInternalServerError, "Internal Server Error"
	switch {
	case errors.Is(err, ErrInvalid):
		status, title = http.StatusUnprocessableEntity, "Unprocessable Entity"
	case errors.Is(err, ErrConflict):
		status, title = http.StatusConflict, "Conflict"
	case errors.Is(err, ErrNotFound):
		status, title = http.StatusNotFound, "Not Found"
	}
	return httpx.NewAppError("https://binno.uz/problems/feedback", title, status, title, err)
}
