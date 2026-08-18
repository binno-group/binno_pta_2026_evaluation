package operator

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type queueReader interface {
	ListQueue(ctx context.Context, queueType, cursor string, pageSize int32) (QueuePage, error)
	Resolve(context.Context, Resolution) error
}

// Handler translates operator queue HTTP requests into service calls.
type Handler struct {
	reader queueReader
}

// NewHandler creates an operator queue handler.
func NewHandler(reader queueReader) *Handler {
	return &Handler{reader: reader}
}

// Mount registers the operator queue contract.
func (h *Handler) Mount(r chi.Router) {
	r.Get("/operator/queues/{type}", h.listQueue)
	r.Post("/operator/queues/{type}/{id}/resolve", httpx.Mutating("operator", "resolve", h.resolve))
}

func (h *Handler) listQueue(w http.ResponseWriter, r *http.Request) {
	if _, err := authz.RequireRole(r.Context(), authz.RoleOperator); err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	pageSize, err := parsePageSize(r.URL.Query().Get("limit"))
	if err != nil {
		httpx.WriteProblem(w, r, httpx.NewAppError(
			"https://binno.uz/problems/validation",
			"Unprocessable Entity",
			http.StatusUnprocessableEntity,
			"limit must be an integer",
			err,
		))
		return
	}

	page, err := h.reader.ListQueue(
		r.Context(),
		chi.URLParam(r, "type"),
		r.URL.Query().Get("cursor"),
		pageSize,
	)
	if err != nil {
		if errors.Is(err, ErrInvalidQueueType) {
			httpx.WriteProblem(w, r, httpx.NewAppError(
				"https://binno.uz/problems/invalid-queue-type",
				"Unprocessable Entity",
				http.StatusUnprocessableEntity,
				"unknown operator queue type",
				err,
			))
			return
		}
		httpx.WriteProblem(w, r, err)
		return
	}

	response := queueResponse{
		Type:       page.Type,
		Items:      make([]queueItemResponse, 0, len(page.Items)),
		NextCursor: page.NextCursor,
	}
	for _, item := range page.Items {
		response.Items = append(response.Items, queueItemResponse{
			ID:       item.ID,
			RefID:    item.RefID,
			OpenedAt: item.OpenedAt.Format(time.RFC3339Nano),
			DueAt:    item.DueAt.Format(time.RFC3339Nano),
		})
	}
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(response); err != nil {
		httpx.WriteProblem(w, r, err)
	}
}

func (h *Handler) resolve(w http.ResponseWriter, r *http.Request) {
	principal, err := authz.RequireRole(r.Context(), authz.RoleOperator)
	if err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	var body struct {
		Action string `json:"action"`
		Note   string `json:"note"`
	}
	decoder := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&body); err != nil {
		httpx.WriteProblem(w, r, httpx.NewAppError(
			"https://binno.uz/problems/validation", "Unprocessable Entity",
			http.StatusUnprocessableEntity, "invalid JSON body", err))
		return
	}
	err = h.reader.Resolve(r.Context(), Resolution{
		QueueType: chi.URLParam(r, "type"), QueueEventID: chi.URLParam(r, "id"),
		Action: body.Action, Note: body.Note, ActorID: principal.UserID,
		OperationKey: httpx.OperationKey(r.Context()),
	})
	if errors.Is(err, ErrInvalidResolution) || errors.Is(err, ErrInvalidQueueType) {
		httpx.WriteProblem(w, r, httpx.NewAppError(
			"https://binno.uz/problems/validation", "Unprocessable Entity",
			http.StatusUnprocessableEntity, "invalid queue resolution", err))
		return
	}
	if err != nil {
		httpx.WriteProblem(w, r, err)
		return
	}
	w.WriteHeader(http.StatusOK)
}

func parsePageSize(value string) (int32, error) {
	if value == "" {
		return 0, nil
	}
	parsed, err := strconv.ParseInt(value, 10, 32)
	if err != nil {
		return 0, err
	}
	return int32(parsed), nil
}

type queueResponse struct {
	Type       string              `json:"type"`
	Items      []queueItemResponse `json:"items"`
	NextCursor *string             `json:"next_cursor"`
}

type queueItemResponse struct {
	ID       string `json:"id"`
	RefID    string `json:"ref_id"`
	OpenedAt string `json:"opened_at"`
	DueAt    string `json:"due_at"`
}
