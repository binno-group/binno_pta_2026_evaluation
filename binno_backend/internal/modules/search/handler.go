package search

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type searchService interface {
	SearchOffers(context.Context, Query) (OfferPage, error)
	GetComplexAggregate(context.Context, ComplexQuery) (ComplexAggregate, error)
}
type Handler struct{ service searchService }

func NewHandler(service searchService) *Handler { return &Handler{service: service} }
func (h *Handler) Mount(r chi.Router) {
	r.Get("/search", h.searchOffers)
	r.Get("/complexes/{id}/aggregate", h.getComplexAggregate)
}

func (h *Handler) searchOffers(w http.ResponseWriter, r *http.Request) {
	point, pointErr := geo.ParsePoint(r.URL.Query().Get("lat"), r.URL.Query().Get("lng"))
	district, districtErr := strconv.ParseInt(r.URL.Query().Get("district_id"), 10, 32)
	radius, radiusErr := parseRadius(r.URL.Query().Get("radius_m"))
	if pointErr != nil || districtErr != nil || radiusErr != nil {
		httpx.WriteProblem(w, r, searchError(ErrInvalid))
		return
	}
	result, err := h.service.SearchOffers(r.Context(), Query{
		Location: point, DistrictID: int32(district), RadiusMeters: radius,
		ProductID: r.URL.Query().Get("product_id"), Cursor: r.URL.Query().Get("cursor"),
	})
	if err != nil {
		httpx.WriteProblem(w, r, searchError(err))
		return
	}
	writeJSON(w, result)
}

func (h *Handler) getComplexAggregate(w http.ResponseWriter, r *http.Request) {
	result, err := h.service.GetComplexAggregate(r.Context(), ComplexQuery{
		ID:        chi.URLParam(r, "id"),
		ProductID: r.URL.Query().Get("product_id"), Cursor: r.URL.Query().Get("cursor"),
	})
	if err != nil {
		httpx.WriteProblem(w, r, searchError(err))
		return
	}
	writeJSON(w, result)
}

// parseRadius reads the optional radius_m parameter.
func parseRadius(raw string) (int32, error) {
	if raw == "" {
		return 0, nil
	}
	value, err := strconv.ParseInt(raw, 10, 32)
	if err != nil {
		return 0, ErrInvalid
	}
	return int32(value), nil
}

func searchError(err error) error {
	status, title := http.StatusInternalServerError, "Internal Server Error"
	switch {
	case errors.Is(err, ErrInvalid):
		status, title = http.StatusUnprocessableEntity, "Unprocessable Entity"
	case errors.Is(err, ErrNotFound):
		status, title = http.StatusNotFound, "Not Found"
	case errors.Is(err, ErrUnavailable):
		status, title = http.StatusServiceUnavailable, "Service Unavailable"
	}
	return httpx.NewAppError("https://binno.uz/problems/search", title, status, title, err)
}

func writeJSON(w http.ResponseWriter, body any) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(body)
}
