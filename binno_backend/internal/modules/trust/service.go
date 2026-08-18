package trust

import (
	"context"
	"errors"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Service errors.
var (
	ErrInvalid  = errors.New("invalid feedback")
	ErrConflict = errors.New("feedback conflict")
	ErrNotFound = errors.New("order not found")
)

// feedbackTags is the closed vocabulary mirrored by the order_feedback CHECK. It
// is a function rather than a package variable so the vocabulary cannot be
// mutated at runtime by another package in this process.
func feedbackTags() []string {
	return []string{"late", "qty_short", "quality", "price_mismatch", "no_response"}
}

// feedbackChannels is the closed set of channels feedback can arrive through.
func feedbackChannels() []string { return []string{"push", "sms", "app"} }

const maxFeedbackComment = 2000

// FeedbackInput is a buyer's verdict on a completed order.
type FeedbackInput struct {
	OrderID, Comment, Channel string
	HadProblem                bool
	Tags                      []string
}

// Feedback is the persisted record, carrying the store resolved from the order.
type Feedback struct {
	FeedbackInput
	StoreID string
	BuyerID string
}

type repository interface {
	CreateOrderFeedback(context.Context, Feedback, time.Time) error
}

// Service applies feedback policy: only the buyer of a closed order may leave
// it.
type Service struct {
	repository repository
	orders     orders.SummaryPort
	clock      clock.Clock
}

// NewService creates a trust service.
func NewService(repository repository, summaries orders.SummaryPort, clk clock.Clock) *Service {
	return &Service{repository: repository, orders: summaries, clock: clk}
}

// CreateOrderFeedback records feedback for one order.
func (s *Service) CreateOrderFeedback(ctx context.Context, in FeedbackInput) error {
	if err := validate(&in); err != nil {
		return err
	}
	if _, err := authz.Require(ctx); err != nil {
		return err
	}

	summary, err := s.orders.GetOrderSummary(ctx, in.OrderID)
	if err != nil {
		if errors.Is(err, orders.ErrNotFound) || errors.Is(err, orders.ErrInvalid) {
			return ErrNotFound
		}
		return err
	}
	if err := authz.EnsureSelf(ctx, summary.BuyerID); err != nil {
		if errors.Is(err, authz.ErrForbidden) {
			return ErrNotFound
		}
		return err
	}
	if !summary.IsClosed() {
		return ErrConflict
	}

	return s.repository.CreateOrderFeedback(ctx, Feedback{
		FeedbackInput: in,
		StoreID:       summary.StoreID,
		BuyerID:       summary.BuyerID,
	}, s.clock.Now())
}

func validate(in *FeedbackInput) error {
	seen := make(map[string]bool, len(in.Tags))
	for _, tag := range in.Tags {
		if !slices.Contains(feedbackTags(), tag) || seen[tag] {
			return ErrInvalid
		}
		seen[tag] = true
	}
	in.Comment = strings.TrimSpace(in.Comment)
	if uuid.Validate(in.OrderID) != nil ||
		len(in.Comment) > maxFeedbackComment ||
		!slices.Contains(feedbackChannels(), in.Channel) {
		return ErrInvalid
	}
	return nil
}
