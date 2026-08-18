package orders

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// DueOrder is an order whose supplier confirmation window has elapsed.
type DueOrder struct {
	OrderID string
	StoreID string
	BuyerID string
	DueAt   time.Time
}

// SweeperConfig tunes the supplier-confirmation SLA sweep.
type SweeperConfig struct {
	// Batch caps how many overdue orders one pass handles.
	Batch int32
	// ExpiryGrace is how long after the deadline an unconfirmed order is expired.
	ExpiryGrace time.Duration
}

type sweeperRepository interface {
	AwaitingConfirmation(ctx context.Context, deadline time.Time, limit int32) ([]DueOrder, error)
	PaymentOverdue(ctx context.Context, deadline time.Time, limit int32) ([]DueOrder, error)
	RecordEscalation(ctx context.Context, order DueOrder, at time.Time) (bool, error)
	Apply(ctx context.Context, cmd TransitionCommand) error
}

// Sweeper enforces the supplier confirmation SLA.
type Sweeper struct {
	repository sweeperRepository
	clock      clock.Clock
	logger     *slog.Logger
	cfg        SweeperConfig
}

// NewSweeper returns the SLA sweeper.
func NewSweeper(repository sweeperRepository, clk clock.Clock, logger *slog.Logger, cfg SweeperConfig) *Sweeper {
	if cfg.Batch <= 0 {
		cfg.Batch = 100
	}
	if cfg.ExpiryGrace <= 0 {
		cfg.ExpiryGrace = 2 * time.Hour
	}
	return &Sweeper{repository: repository, clock: clk, logger: logger, cfg: cfg}
}

// SweepResult reports what one pass did.
type SweepResult struct {
	Escalated      int
	Expired        int
	PaymentExpired int
}

// RunOnce escalates every overdue order, expires those past the grace period,
// and expires invoiced orders whose payment window elapsed.
func (s *Sweeper) RunOnce(ctx context.Context) (SweepResult, error) {
	now := s.clock.Now()
	due, err := s.repository.AwaitingConfirmation(ctx, now, s.cfg.Batch)
	if err != nil {
		return SweepResult{}, err
	}

	var result SweepResult
	var failures []error
	for _, order := range due {
		escalateCtx := httpx.WithOperationKey(ctx, escalationKey(order))
		escalated, err := s.repository.RecordEscalation(escalateCtx, order, now)
		if err != nil {
			failures = append(failures, fmt.Errorf("escalate %s: %w", order.OrderID, err))
			continue
		}
		if escalated {
			result.Escalated++
		}

		if now.Before(order.DueAt.Add(s.cfg.ExpiryGrace)) {
			continue
		}
		expireCtx := httpx.WithOperationKey(ctx, expiryKey(order.OrderID, order.DueAt))
		err = s.repository.Apply(expireCtx, TransitionCommand{
			OrderID: order.OrderID,
			Trigger: TriggerExpire,
			Reason:  "supplier confirmation window elapsed",
			At:      now,
		})
		switch {
		case err == nil:
			result.Expired++
		case errors.Is(err, ErrConflict), errors.Is(err, ErrNotFound):
		default:
			failures = append(failures, fmt.Errorf("expire %s: %w", order.OrderID, err))
		}
	}

	unpaid, err := s.repository.PaymentOverdue(ctx, now, s.cfg.Batch)
	if err != nil {
		return result, errors.Join(append(failures, err)...)
	}
	for _, order := range unpaid {
		expireCtx := httpx.WithOperationKey(ctx, paymentExpiryKey(order.OrderID, order.DueAt))
		err := s.repository.Apply(expireCtx, TransitionCommand{
			OrderID: order.OrderID,
			Trigger: TriggerPaymentExpire,
			Reason:  "payment window elapsed",
			At:      now,
		})
		switch {
		case err == nil:
			result.PaymentExpired++
		case errors.Is(err, ErrConflict), errors.Is(err, ErrNotFound):
		default:
			failures = append(failures, fmt.Errorf("payment-expire %s: %w", order.OrderID, err))
		}
	}
	return result, errors.Join(failures...)
}

// Run sweeps every interval until ctx is canceled.
func (s *Sweeper) Run(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			result, err := s.RunOnce(ctx)
			if err != nil && !errors.Is(err, context.Canceled) {
				s.logger.ErrorContext(ctx, "order SLA sweep failed", "err", err)
			}
			if result.Escalated > 0 || result.Expired > 0 || result.PaymentExpired > 0 {
				s.logger.InfoContext(ctx, "order SLA sweep",
					"escalated", result.Escalated, "expired", result.Expired,
					"payment_expired", result.PaymentExpired)
			}
		}
	}
}

// escalationKey is the deterministic operation key for one order's escalation.
func escalationKey(order DueOrder) string {
	return fmt.Sprintf("orders:sla_escalate:%s:%d", order.OrderID, order.DueAt.Unix())
}

// expiryKey is the deterministic operation key for one order's expiry.
func expiryKey(orderID string, dueAt time.Time) string {
	return fmt.Sprintf("orders:expire:%s:%d", orderID, dueAt.Unix())
}

// paymentExpiryKey is the deterministic operation key for one order's payment
// expiry.
func paymentExpiryKey(orderID string, dueAt time.Time) string {
	return fmt.Sprintf("orders:payment_expire:%s:%d", orderID, dueAt.Unix())
}
