package orders

import (
	"context"
	"errors"
	"net/url"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/money"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Service errors.
var (
	ErrInvalid  = errors.New("invalid order input")
	ErrConflict = errors.New("order state conflict")
	ErrNotFound = errors.New("order not found")
	ErrGone     = errors.New("confirmation token expired or used")
	// ErrUnavailable reports that the request could not be served because the
	// database was too contended, not because anything about it was wrong.
	ErrUnavailable = errors.New("order service temporarily unavailable")
)

// Buyer types and fulfilment modes accepted on creation.
const (
	buyerIndividual  = "individual"
	buyerLegalEntity = "legal_entity"
	fulfilDelivery   = "delivery"
	fulfilPickup     = "pickup"

	maxOrderItems     = 100
	maxCancelReason   = 500
	maxReceiptURL     = 2048
	legalEntityTINLen = 9
)

// ItemInput is one requested product line.
type ItemInput struct{ ProductID, Qty string }

// CreateInput is a buyer's order request.
type CreateInput struct {
	StoreID, BuyerType, BuyerTIN, Fulfillment, DropoffAddress string
	DistrictID                                                int32
	Items                                                     []ItemInput
	Dropoff                                                   *geo.Point
	Urgent                                                    bool
}

// Created is the result of a successful order placement.
type Created struct {
	OrderID                      string    `json:"order_id"`
	Status                       string    `json:"status"`
	GoodsAmount                  int64     `json:"goods_amount"`
	DeliveryFee                  int64     `json:"delivery_fee"`
	TotalAmount                  int64     `json:"total_amount"`
	SupplierConfirmationDeadline time.Time `json:"supplier_confirmation_deadline"`
}

// PickupInput carries the buyer's proof of collection: exactly one of a code or
// a signature.
type PickupInput struct{ Code, SignatureURL string }

// Alternative is a substitute offer shown after a supplier declines.
type Alternative struct {
	OfferID     string `json:"id"`
	StoreID     string `json:"store_id"`
	ProductID   string `json:"product_id"`
	Price       int64  `json:"price"`
	DeclaredQty string `json:"declared_qty"`
	FreshnessAt string `json:"freshness_at"`
}

// AlternativePage is a keyset page of substitutes.
type AlternativePage struct {
	Items      []Alternative `json:"items"`
	NextCursor *string       `json:"next_cursor"`
}

// CreateCommand is the validated order placement handed to persistence.
type CreateCommand struct {
	CreateInput
	BuyerID string
	At      time.Time
}

// TransitionCommand is a validated state-machine step.
type TransitionCommand struct {
	OrderID    string
	Trigger    Trigger
	Reason     string
	ReceiptURL string
	// PickupCode and PickupSignatureURL carry the buyer's proof of collection
	// into the audit log.
	PickupCode         string
	PickupSignatureURL string
	At                 time.Time
}

type repository interface {
	Create(context.Context, CreateCommand) (Created, error)
	Apply(context.Context, TransitionCommand) error
	ConfirmToken(context.Context, string, string, time.Time) error
	Summary(context.Context, string) (Summary, error)
	Alternatives(context.Context, string, string) (AlternativePage, error)
	ListByBuyer(ctx context.Context, buyerID, cursor string) (OrderPage, error)
	ListStoreOpen(ctx context.Context, storeID, cursor string) (OrderPage, error)
	Detail(ctx context.Context, id string) (OrderDetail, error)
}

// Service owns order policy: what a request must look like, who may make it, and
// which lifecycle step it corresponds to.
type Service struct {
	repository repository
	guard      authz.Guard
	clock      clock.Clock
}

// NewService creates an order service.
func NewService(repository repository, guard authz.Guard, clk clock.Clock) *Service {
	return &Service{repository: repository, guard: guard, clock: clk}
}

var _ SummaryPort = (*Service)(nil)

// GetOrderSummary implements SummaryPort for other modules.
func (s *Service) GetOrderSummary(ctx context.Context, orderID string) (Summary, error) {
	if uuid.Validate(orderID) != nil {
		return Summary{}, ErrInvalid
	}
	return s.repository.Summary(ctx, orderID)
}

// CreateOrder places an order for the authenticated buyer.
func (s *Service) CreateOrder(ctx context.Context, in CreateInput) (Created, error) {
	principal, err := authz.RequireRole(ctx, authz.RoleBuyer)
	if err != nil {
		return Created{}, err
	}
	if err := validateCreate(in); err != nil {
		return Created{}, err
	}
	return s.repository.Create(ctx, CreateCommand{
		CreateInput: in,
		BuyerID:     principal.UserID,
		At:          s.clock.Now(),
	})
}

func validateCreate(in CreateInput) error {
	switch {
	case uuid.Validate(in.StoreID) != nil,
		in.DistrictID <= 0,
		len(in.Items) == 0 || len(in.Items) > maxOrderItems,
		in.BuyerType != buyerIndividual && in.BuyerType != buyerLegalEntity,
		in.Fulfillment != fulfilDelivery && in.Fulfillment != fulfilPickup:
		return ErrInvalid
	}
	if in.Fulfillment == fulfilDelivery &&
		(in.Dropoff == nil || !in.Dropoff.Valid() || strings.TrimSpace(in.DropoffAddress) == "") {
		return ErrInvalid
	}
	if in.BuyerType == buyerLegalEntity &&
		(len(in.BuyerTIN) != legalEntityTINLen || !isDigits(in.BuyerTIN)) {
		return ErrInvalid
	}
	seen := make(map[string]bool, len(in.Items))
	for _, item := range in.Items {
		if uuid.Validate(item.ProductID) != nil ||
			!money.IsPositiveDecimal(item.Qty) ||
			seen[item.ProductID] {
			return ErrInvalid
		}
		seen[item.ProductID] = true
	}
	return nil
}

// ListMyOrders returns the calling buyer's orders, newest first.
func (s *Service) ListMyOrders(ctx context.Context, cursor string) (OrderPage, error) {
	principal, err := authz.Require(ctx)
	if err != nil {
		return OrderPage{}, err
	}
	return s.repository.ListByBuyer(ctx, principal.UserID, cursor)
}

// ListStoreOrders returns a store's open orders for its owner, newest first.
func (s *Service) ListStoreOrders(ctx context.Context, storeID, cursor string) (OrderPage, error) {
	if uuid.Validate(storeID) != nil {
		return OrderPage{}, ErrInvalid
	}
	if err := s.guard.EnsureOwnsStore(ctx, storeID); err != nil {
		return OrderPage{}, err
	}
	return s.repository.ListStoreOpen(ctx, storeID, cursor)
}

// GetOrder returns one order to its buyer or its selling store.
func (s *Service) GetOrder(ctx context.Context, id string) (OrderDetail, error) {
	if uuid.Validate(id) != nil {
		return OrderDetail{}, ErrInvalid
	}
	if _, err := authz.Require(ctx); err != nil {
		return OrderDetail{}, err
	}
	summary, err := s.repository.Summary(ctx, id)
	if err != nil {
		return OrderDetail{}, err
	}
	if authz.EnsureSelf(ctx, summary.BuyerID) != nil {
		if err := s.guard.EnsureOwnsStore(ctx, summary.StoreID); err != nil {
			if errors.Is(err, authz.ErrForbidden) {
				return OrderDetail{}, ErrNotFound
			}
			return OrderDetail{}, err
		}
	}
	return s.repository.Detail(ctx, id)
}

// SupplierConfirm accepts an order on behalf of the selling store.
func (s *Service) SupplierConfirm(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerSupplierConfirm, "")
}

// Decline rejects an order and moves the buyer to alternatives.
func (s *Service) Decline(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerSupplierDecline, "")
}

// Cancel withdraws an order on the buyer's behalf.
func (s *Service) Cancel(ctx context.Context, id, reason string) error {
	if strings.TrimSpace(reason) == "" || len(reason) > maxCancelReason {
		return ErrInvalid
	}
	return s.buyerTransition(ctx, id, TriggerBuyerCancel, reason)
}

// ConfirmPickup records that the buyer collected the goods, carrying the
// presented proof into the order's audit log.
func (s *Service) ConfirmPickup(ctx context.Context, id string, in PickupInput) error {
	if (in.Code == "") == (in.SignatureURL == "") {
		return ErrInvalid
	}
	if _, err := s.authorizeBuyer(ctx, id); err != nil {
		return err
	}
	return s.repository.Apply(ctx, TransitionCommand{
		OrderID: id, Trigger: TriggerConfirmPickup,
		PickupCode: in.Code, PickupSignatureURL: in.SignatureURL,
		At: s.clock.Now(),
	})
}

// SubmitPaymentReceipt files the buyer's proof of a bank transfer.
func (s *Service) SubmitPaymentReceipt(ctx context.Context, id, receiptURL string) error {
	if err := validateReceiptURL(receiptURL); err != nil {
		return err
	}
	if _, err := s.authorizeBuyer(ctx, id); err != nil {
		return err
	}
	return s.repository.Apply(ctx, TransitionCommand{
		OrderID: id, Trigger: TriggerSubmitReceipt, ReceiptURL: receiptURL, At: s.clock.Now(),
	})
}

// ConfirmPayment records that the seller found the money in their account.
func (s *Service) ConfirmPayment(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerConfirmPayment, "")
}

// RejectPayment records that the submitted receipt did not check out.
func (s *Service) RejectPayment(ctx context.Context, id, reason string) error {
	if len(reason) > maxCancelReason {
		return ErrInvalid
	}
	return s.sellerTransition(ctx, id, TriggerRejectPayment, reason)
}

// StartPreparing records that the seller began assembling the order.
func (s *Service) StartPreparing(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerStartPreparing, "")
}

// MarkReady records that the goods are ready for handover.
func (s *Service) MarkReady(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerMarkReady, "")
}

// ConfirmDelivery records that the goods reached the buyer's address.
func (s *Service) ConfirmDelivery(ctx context.Context, id string) error {
	return s.sellerTransition(ctx, id, TriggerConfirmDelivery, "")
}

// validateReceiptURL accepts an absolute http(s) URL within the column's reach.
func validateReceiptURL(value string) error {
	if value == "" || len(value) > maxReceiptURL {
		return ErrInvalid
	}
	parsed, err := url.Parse(value)
	if err != nil || !parsed.IsAbs() || parsed.Host == "" {
		return ErrInvalid
	}
	if parsed.Scheme != "https" && parsed.Scheme != "http" {
		return ErrInvalid
	}
	return nil
}

// RequestRefund opens a refund on a paid order on an operator's decision.
func (s *Service) RequestRefund(ctx context.Context, id, reason string) error {
	if _, err := authz.RequireRole(ctx, authz.RoleOperator); err != nil {
		return err
	}
	if uuid.Validate(id) != nil ||
		strings.TrimSpace(reason) == "" || len(reason) > maxCancelReason {
		return ErrInvalid
	}
	return s.repository.Apply(ctx, TransitionCommand{
		OrderID: id, Trigger: TriggerRefundRequest, Reason: reason, At: s.clock.Now(),
	})
}

// ConfirmRefund records the buyer's confirmation that the money came back.
func (s *Service) ConfirmRefund(ctx context.Context, id string) error {
	return s.buyerTransition(ctx, id, TriggerConfirmRefund, "")
}

// TokenConfirm accepts an order through the SMS confirmation link.
func (s *Service) TokenConfirm(ctx context.Context, id, token string) error {
	if uuid.Validate(id) != nil || strings.TrimSpace(token) == "" {
		return ErrInvalid
	}
	return s.repository.ConfirmToken(ctx, id, token, s.clock.Now())
}

// Alternatives lists substitute offers for a declined order.
func (s *Service) Alternatives(ctx context.Context, id, cursor string) (AlternativePage, error) {
	summary, err := s.authorizeBuyer(ctx, id)
	if err != nil {
		return AlternativePage{}, err
	}
	if summary.Status != StatusBuyerDecisionPending {
		return AlternativePage{}, ErrConflict
	}
	return s.repository.Alternatives(ctx, id, cursor)
}

// sellerTransition authorises the caller as the selling store, then applies the
// trigger.
func (s *Service) sellerTransition(ctx context.Context, id string, trigger Trigger, reason string) error {
	if uuid.Validate(id) != nil {
		return ErrInvalid
	}
	summary, err := s.repository.Summary(ctx, id)
	if err != nil {
		return err
	}
	if err := s.guard.EnsureOwnsStore(ctx, summary.StoreID); err != nil {
		return err
	}
	return s.repository.Apply(ctx, TransitionCommand{
		OrderID: id, Trigger: trigger, Reason: reason, At: s.clock.Now(),
	})
}

func (s *Service) buyerTransition(ctx context.Context, id string, trigger Trigger, reason string) error {
	if _, err := s.authorizeBuyer(ctx, id); err != nil {
		return err
	}
	return s.repository.Apply(ctx, TransitionCommand{
		OrderID: id, Trigger: trigger, Reason: reason, At: s.clock.Now(),
	})
}

// authorizeBuyer loads the order and confirms the caller placed it.
func (s *Service) authorizeBuyer(ctx context.Context, id string) (Summary, error) {
	if uuid.Validate(id) != nil {
		return Summary{}, ErrInvalid
	}
	if _, err := authz.Require(ctx); err != nil {
		return Summary{}, err
	}
	summary, err := s.repository.Summary(ctx, id)
	if err != nil {
		return Summary{}, err
	}
	if err := authz.EnsureSelf(ctx, summary.BuyerID); err != nil {
		if errors.Is(err, authz.ErrForbidden) {
			return Summary{}, ErrNotFound
		}
		return Summary{}, err
	}
	return summary, nil
}

func isDigits(value string) bool {
	for _, r := range value {
		if r < '0' || r > '9' {
			return false
		}
	}
	return true
}
