package orders

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type orderService interface {
	CreateOrder(context.Context, CreateInput) (Created, error)
	SupplierConfirm(context.Context, string) error
	TokenConfirm(context.Context, string, string) error
	Decline(context.Context, string) error
	Alternatives(context.Context, string, string) (AlternativePage, error)
	Cancel(context.Context, string, string) error
	ConfirmPickup(context.Context, string, PickupInput) error
	SubmitPaymentReceipt(context.Context, string, string) error
	ConfirmPayment(context.Context, string) error
	RejectPayment(context.Context, string, string) error
	StartPreparing(context.Context, string) error
	MarkReady(context.Context, string) error
	ConfirmDelivery(context.Context, string) error
	RequestRefund(context.Context, string, string) error
	ConfirmRefund(context.Context, string) error
	ListMyOrders(context.Context, string) (OrderPage, error)
	ListStoreOrders(context.Context, string, string) (OrderPage, error)
	GetOrder(context.Context, string) (OrderDetail, error)
}

// Handler translates order HTTP requests into service calls.
type Handler struct{ service orderService }

// NewHandler creates an order handler.
func NewHandler(service orderService) *Handler { return &Handler{service: service} }

// Mount registers order routes.
func (h *Handler) Mount(r chi.Router) {
	r.Get("/orders", h.listMine)
	r.Get("/orders/{id}", h.getOrder)
	r.Get("/stores/{id}/orders", h.listStoreOrders)
	r.Post("/orders", httpx.Mutating("orders", "create_order", h.create(false)))
	r.Post("/orders/{id}/supplier-confirm", httpx.Mutating("orders", "supplier_confirm", h.supplierConfirm))
	r.Post("/orders/{id}/confirm", httpx.Mutating("orders", "token_confirm", h.tokenConfirm))
	r.Post("/orders/{id}/decline", httpx.Mutating("orders", "decline_order", h.decline))
	r.Get("/orders/{id}/alternatives", h.alternatives)
	r.Post("/orders/{id}/cancel", httpx.Mutating("orders", "cancel_order", h.cancel))
	r.Post("/orders/{id}/pickup-confirm", httpx.Mutating("orders", "confirm_pickup", h.pickup))
	r.Post("/orders/urgent", httpx.Mutating("orders", "create_urgent_order", h.create(true)))

	r.Post("/orders/{id}/payment-receipt", httpx.Mutating("orders", "submit_payment_receipt", h.paymentReceipt))
	r.Post("/orders/{id}/payment-confirm", httpx.Mutating("orders", "confirm_payment", h.paymentConfirm))
	r.Post("/orders/{id}/payment-reject", httpx.Mutating("orders", "reject_payment", h.paymentReject))
	r.Post("/orders/{id}/preparing", httpx.Mutating("orders", "start_preparing", h.preparing))
	r.Post("/orders/{id}/ready", httpx.Mutating("orders", "mark_ready", h.ready))
	r.Post("/orders/{id}/delivery-confirm", httpx.Mutating("orders", "confirm_delivery", h.deliveryConfirm))

	r.Post("/orders/{id}/refund-request", httpx.Mutating("orders", "refund_request", h.refundRequest))
	r.Post("/orders/{id}/refund-confirm", httpx.Mutating("orders", "refund_confirm", h.refundConfirm))
}

func (h *Handler) listMine(w http.ResponseWriter, r *http.Request) {
	page, err := h.service.ListMyOrders(r.Context(), r.URL.Query().Get("cursor"))
	if writeError(w, r, err) {
		return
	}
	writeJSON(w, http.StatusOK, page)
}

func (h *Handler) getOrder(w http.ResponseWriter, r *http.Request) {
	detail, err := h.service.GetOrder(r.Context(), chi.URLParam(r, "id"))
	if writeError(w, r, err) {
		return
	}
	writeJSON(w, http.StatusOK, detail)
}

func (h *Handler) listStoreOrders(w http.ResponseWriter, r *http.Request) {
	page, err := h.service.ListStoreOrders(r.Context(), chi.URLParam(r, "id"), r.URL.Query().Get("cursor"))
	if writeError(w, r, err) {
		return
	}
	writeJSON(w, http.StatusOK, page)
}

func (h *Handler) refundRequest(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Reason string `json:"reason"`
	}
	if !decode(w, r, &body) {
		return
	}
	done(w, r, h.service.RequestRefund(r.Context(), chi.URLParam(r, "id"), body.Reason))
}

func (h *Handler) refundConfirm(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.ConfirmRefund(r.Context(), chi.URLParam(r, "id")))
}

func (h *Handler) paymentReceipt(w http.ResponseWriter, r *http.Request) {
	var body struct {
		ReceiptURL string `json:"receipt_url"`
	}
	if !decode(w, r, &body) {
		return
	}
	done(w, r, h.service.SubmitPaymentReceipt(r.Context(), chi.URLParam(r, "id"), body.ReceiptURL))
}

func (h *Handler) paymentConfirm(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.ConfirmPayment(r.Context(), chi.URLParam(r, "id")))
}

func (h *Handler) paymentReject(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Reason string `json:"reason"`
	}
	if !decode(w, r, &body) {
		return
	}
	done(w, r, h.service.RejectPayment(r.Context(), chi.URLParam(r, "id"), body.Reason))
}

func (h *Handler) preparing(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.StartPreparing(r.Context(), chi.URLParam(r, "id")))
}

func (h *Handler) ready(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.MarkReady(r.Context(), chi.URLParam(r, "id")))
}

func (h *Handler) deliveryConfirm(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.ConfirmDelivery(r.Context(), chi.URLParam(r, "id")))
}

type createBody struct {
	StoreID     string `json:"store_id"`
	BuyerType   string `json:"buyer_type"`
	BuyerTIN    string `json:"buyer_tin"`
	Fulfillment string `json:"fulfillment"`
	DistrictID  int32  `json:"district_id"`
	Dropoff     *struct {
		geo.Point
		Address string `json:"address"`
	} `json:"dropoff"`
	Items []struct {
		ProductID string `json:"product_id"`
		Qty       string `json:"qty"`
	} `json:"items"`
}

func (h *Handler) create(urgent bool) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var body createBody
		if !decode(w, r, &body) {
			return
		}
		in := CreateInput{
			StoreID: body.StoreID, BuyerType: body.BuyerType, BuyerTIN: body.BuyerTIN,
			Fulfillment: body.Fulfillment, DistrictID: body.DistrictID, Urgent: urgent,
		}
		if body.Dropoff != nil {
			in.DropoffAddress = body.Dropoff.Address
			in.Dropoff = &body.Dropoff.Point
		}
		for _, item := range body.Items {
			in.Items = append(in.Items, ItemInput{ProductID: item.ProductID, Qty: item.Qty})
		}
		result, err := h.service.CreateOrder(r.Context(), in)
		if writeError(w, r, err) {
			return
		}
		writeJSON(w, http.StatusCreated, result)
	}
}

func (h *Handler) supplierConfirm(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.SupplierConfirm(r.Context(), chi.URLParam(r, "id")))
}

// tokenConfirm is the one order route with no principal: the single-use SMS
// token is the credential.
func (h *Handler) tokenConfirm(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.TokenConfirm(r.Context(), chi.URLParam(r, "id"), r.URL.Query().Get("token")))
}

func (h *Handler) decline(w http.ResponseWriter, r *http.Request) {
	done(w, r, h.service.Decline(r.Context(), chi.URLParam(r, "id")))
}

func (h *Handler) alternatives(w http.ResponseWriter, r *http.Request) {
	page, err := h.service.Alternatives(r.Context(), chi.URLParam(r, "id"), r.URL.Query().Get("cursor"))
	if writeError(w, r, err) {
		return
	}
	writeJSON(w, http.StatusOK, page)
}

func (h *Handler) cancel(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Reason string `json:"reason"`
	}
	if !decode(w, r, &body) {
		return
	}
	done(w, r, h.service.Cancel(r.Context(), chi.URLParam(r, "id"), body.Reason))
}

func (h *Handler) pickup(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Code         string `json:"code"`
		SignatureURL string `json:"signature_url"`
	}
	if !decode(w, r, &body) {
		return
	}
	done(w, r, h.service.ConfirmPickup(r.Context(), chi.URLParam(r, "id"),
		PickupInput{Code: body.Code, SignatureURL: body.SignatureURL}))
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

func done(w http.ResponseWriter, r *http.Request, err error) {
	if writeError(w, r, err) {
		return
	}
	w.WriteHeader(http.StatusOK)
}

func writeError(w http.ResponseWriter, r *http.Request, err error) bool {
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
	case errors.Is(err, ErrConflict):
		status, title = http.StatusConflict, "Conflict"
	case errors.Is(err, ErrNotFound):
		status, title = http.StatusNotFound, "Not Found"
	case errors.Is(err, ErrGone):
		status, title = http.StatusGone, "Gone"
	case errors.Is(err, ErrUnavailable):
		status, title = http.StatusServiceUnavailable, "Service Unavailable"
		w.Header().Set("Retry-After", "1")
	}
	httpx.WriteProblem(w, r, httpx.NewAppError("https://binno.uz/problems/orders", title, status, title, err))
	return true
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
