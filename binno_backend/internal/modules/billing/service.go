package billing

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Service errors.
var (
	ErrInvalid  = errors.New("invalid billing input")
	ErrConflict = errors.New("billing state conflict")
	ErrNotFound = errors.New("billing resource not found")
)

// Invoice is the payment document issued for an order.
type Invoice struct {
	Number      string
	TotalAmount int64
}

// RefundEvidence is a seller's proof that a refund was settled off-platform.
type RefundEvidence struct {
	OrderID, EvidenceURL string
	Amount               int64
}

// CommissionInvoice is one billing period's commission charge for an owner.
type CommissionInvoice struct {
	ID             string `json:"id"`
	PeriodStart    string `json:"period_start"`
	PeriodEnd      string `json:"period_end"`
	AccruedAmount  int64  `json:"accrued_amount"`
	DiscountAmount int64  `json:"discount_amount"`
	Amount         int64  `json:"amount"`
	DueAt          string `json:"due_at"`
	Status         string `json:"status"`
}

type repository interface {
	GetPaymentInvoice(context.Context, string) (Invoice, error)
	SubmitRefundEvidence(context.Context, RefundEvidence, time.Time) error
	ListCommissionInvoices(context.Context, string, string) ([]CommissionInvoice, error)
}

// Service applies billing policy.
type Service struct {
	repository repository
	orders     orders.SummaryPort
	guard      authz.Guard
	clock      clock.Clock
}

// NewService creates a billing service.
func NewService(repository repository, summaries orders.SummaryPort, guard authz.Guard, clk clock.Clock) *Service {
	return &Service{repository: repository, orders: summaries, guard: guard, clock: clk}
}

// GetPaymentInvoice returns the current invoice for an order.
func (s *Service) GetPaymentInvoice(ctx context.Context, orderID string) (Invoice, error) {
	if _, err := s.authorizeOrderParty(ctx, orderID); err != nil {
		return Invoice{}, err
	}
	return s.repository.GetPaymentInvoice(ctx, orderID)
}

// SubmitRefundEvidence records the selling store's proof of a settled refund.
func (s *Service) SubmitRefundEvidence(ctx context.Context, in RefundEvidence) error {
	if uuid.Validate(in.OrderID) != nil || in.Amount <= 0 || in.EvidenceURL == "" {
		return ErrInvalid
	}
	summary, err := s.orderSummary(ctx, in.OrderID)
	if err != nil {
		return err
	}
	if err := s.guard.EnsureOwnsStore(ctx, summary.StoreID); err != nil {
		return err
	}
	return s.repository.SubmitRefundEvidence(ctx, in, s.clock.Now())
}

// ListCommissionInvoices returns an owner's commission statements.
func (s *Service) ListCommissionInvoices(ctx context.Context, ownerID, cursor string) ([]CommissionInvoice, error) {
	if uuid.Validate(ownerID) != nil {
		return nil, ErrInvalid
	}
	if err := s.guard.EnsureOwner(ctx, ownerID); err != nil {
		return nil, err
	}
	return s.repository.ListCommissionInvoices(ctx, ownerID, cursor)
}

// authorizeOrderParty accepts the order's buyer or its selling store.
func (s *Service) authorizeOrderParty(ctx context.Context, orderID string) (orders.Summary, error) {
	summary, err := s.orderSummary(ctx, orderID)
	if err != nil {
		return orders.Summary{}, err
	}
	if authz.EnsureSelf(ctx, summary.BuyerID) == nil {
		return summary, nil
	}
	if err := s.guard.EnsureOwnsStore(ctx, summary.StoreID); err != nil {
		if errors.Is(err, authz.ErrForbidden) {
			return orders.Summary{}, ErrNotFound
		}
		return orders.Summary{}, err
	}
	return summary, nil
}

func (s *Service) orderSummary(ctx context.Context, orderID string) (orders.Summary, error) {
	if uuid.Validate(orderID) != nil {
		return orders.Summary{}, ErrInvalid
	}
	if _, err := authz.Require(ctx); err != nil {
		return orders.Summary{}, err
	}
	summary, err := s.orders.GetOrderSummary(ctx, orderID)
	if err != nil {
		if errors.Is(err, orders.ErrNotFound) || errors.Is(err, orders.ErrInvalid) {
			return orders.Summary{}, ErrNotFound
		}
		return orders.Summary{}, err
	}
	return summary, nil
}
