package catalog

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type catalogService interface {
	CreateCatalogRequest(context.Context, CatalogRequestInput) (string, error)
	ResolveCatalogRequest(context.Context, CatalogResolution) error
	CreateOffer(context.Context, OfferInput) (string, error)
	UpdateOffer(context.Context, OfferUpdate) error
}

// Handler translates catalogue HTTP requests into service calls.
type Handler struct{ service catalogService }

// NewHandler creates a catalog handler.
func NewHandler(service catalogService) *Handler { return &Handler{service: service} }

// Mount registers catalog routes.
func (h *Handler) Mount(r chi.Router) {
	r.Post("/catalog/requests", httpx.Mutating("catalog", "create_request", h.createCatalogRequest))
	r.Patch("/catalog/requests/{id}", httpx.Mutating("catalog", "resolve_request", h.resolveCatalogRequest))
	r.Post("/offers", httpx.Mutating("catalog", "create_offer", h.createOffer))
	r.Patch("/offers/{id}", httpx.Mutating("catalog", "update_offer", h.updateOffer))
}

func (h *Handler) createCatalogRequest(w http.ResponseWriter, r *http.Request) {
	var body struct {
		StoreID     string `json:"store_id"`
		Name        string `json:"name"`
		Unit        string `json:"unit"`
		Description string `json:"description"`
		ImageURL    string `json:"image_url"`
	}
	if !decode(w, r, &body) {
		return
	}
	id, err := h.service.CreateCatalogRequest(r.Context(), CatalogRequestInput{
		StoreID: body.StoreID, Name: body.Name, Unit: body.Unit,
		Description: body.Description, ImageURL: body.ImageURL,
	})
	if handle(w, r, err) {
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"id": id})
}

func (h *Handler) resolveCatalogRequest(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Status       string `json:"status"`
		ProductID    string `json:"product_id"`
		RejectReason string `json:"reject_reason"`
	}
	if !decode(w, r, &body) {
		return
	}
	err := h.service.ResolveCatalogRequest(r.Context(), CatalogResolution{
		ID: chi.URLParam(r, "id"), Status: body.Status,
		ProductID: body.ProductID, RejectReason: body.RejectReason,
	})
	if handle(w, r, err) {
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": body.Status})
}

func (h *Handler) createOffer(w http.ResponseWriter, r *http.Request) {
	var body struct {
		StoreID     string `json:"store_id"`
		ProductID   string `json:"product_id"`
		DeclaredQty string `json:"declared_qty"`
		Price       int64  `json:"price"`
	}
	if !decode(w, r, &body) {
		return
	}
	id, err := h.service.CreateOffer(r.Context(), OfferInput{
		StoreID: body.StoreID, ProductID: body.ProductID,
		DeclaredQty: body.DeclaredQty, Price: body.Price,
	})
	if handle(w, r, err) {
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"id": id})
}

func (h *Handler) updateOffer(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Price       *int64  `json:"price"`
		DeclaredQty *string `json:"declared_qty"`
		Status      *string `json:"status"`
	}
	if !decode(w, r, &body) {
		return
	}
	err := h.service.UpdateOffer(r.Context(), OfferUpdate{
		ID: chi.URLParam(r, "id"), Price: body.Price, DeclaredQty: body.DeclaredQty,
		Status: body.Status,
	})
	if handle(w, r, err) {
		return
	}
	w.WriteHeader(http.StatusOK)
}

func decode(w http.ResponseWriter, r *http.Request, dst any) bool {
	decoder := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(dst); err != nil {
		httpx.WriteProblem(w, r, httpx.NewAppError(
			"https://binno.uz/problems/validation", "Unprocessable Entity",
			http.StatusUnprocessableEntity, "invalid JSON body", err))
		return false
	}
	return true
}

func handle(w http.ResponseWriter, r *http.Request, err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, authz.ErrForbidden) || errors.Is(err, authz.ErrUnauthenticated) {
		httpx.WriteProblem(w, r, err)
		return true
	}
	status, title := http.StatusInternalServerError, "Internal Server Error"
	switch {
	case errors.Is(err, ErrInvalid):
		status, title = http.StatusUnprocessableEntity, "Unprocessable Entity"
	case errors.Is(err, ErrNotFound):
		status, title = http.StatusNotFound, "Not Found"
	case errors.Is(err, ErrConflict):
		status, title = http.StatusConflict, "Conflict"
	}
	httpx.WriteProblem(w, r, httpx.NewAppError("https://binno.uz/problems/catalog", title, status, title, err))
	return true
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
