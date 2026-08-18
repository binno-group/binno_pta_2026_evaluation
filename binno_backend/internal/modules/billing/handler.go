package billing

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type billingService interface {
	GetPaymentInvoice(context.Context, string) (Invoice, error)
	SubmitRefundEvidence(context.Context, RefundEvidence) error
	ListCommissionInvoices(context.Context, string, string) ([]CommissionInvoice, error)
}

// Handler translates billing HTTP requests into service calls.
type Handler struct{ service billingService }

// NewHandler creates a billing handler.
func NewHandler(service billingService) *Handler { return &Handler{service: service} }

// Mount registers billing routes.
func (h *Handler) Mount(r chi.Router) {
	r.Get("/orders/{id}/payment-invoice", h.invoice)
	r.Post("/orders/{id}/refund", httpx.Mutating("billing", "submit_refund_evidence", h.refund))
	r.Get("/owners/{id}/commission-invoices", h.commissions)
}

func (h *Handler) invoice(w http.ResponseWriter, r *http.Request) {
	invoice, err := h.service.GetPaymentInvoice(r.Context(), chi.URLParam(r, "id"))
	if billingError(w, r, err) {
		return
	}
	w.Header().Set("Content-Type", "application/pdf")
	w.Header().Set("Content-Disposition", fmt.Sprintf(`inline; filename="%s.pdf"`, invoice.Number))
	_, _ = w.Write(invoiceDocument(invoice))
}

func (h *Handler) refund(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Amount      int64  `json:"amount"`
		EvidenceURL string `json:"evidence_url"`
	}
	decoder := json.NewDecoder(http.MaxBytesReader(w, r.Body, 1<<20))
	decoder.DisallowUnknownFields()
	if decoder.Decode(&body) != nil {
		httpx.WriteProblem(w, r, appError(ErrInvalid))
		return
	}
	err := h.service.SubmitRefundEvidence(r.Context(), RefundEvidence{
		OrderID: chi.URLParam(r, "id"), Amount: body.Amount, EvidenceURL: body.EvidenceURL,
	})
	if billingError(w, r, err) {
		return
	}
	w.WriteHeader(http.StatusOK)
}

func (h *Handler) commissions(w http.ResponseWriter, r *http.Request) {
	invoices, err := h.service.ListCommissionInvoices(
		r.Context(), chi.URLParam(r, "id"), r.URL.Query().Get("cursor"))
	if billingError(w, r, err) {
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(invoices)
}

func billingError(w http.ResponseWriter, r *http.Request, err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, authz.ErrForbidden) || errors.Is(err, authz.ErrUnauthenticated) {
		httpx.WriteProblem(w, r, err)
		return true
	}
	httpx.WriteProblem(w, r, appError(err))
	return true
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
	return httpx.NewAppError("https://binno.uz/problems/billing", title, status, title, err)
}
