package billing

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/dedup"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// RefundSweepConfig tunes the refund SLA sweep.
type RefundSweepConfig struct {
	// Batch caps how many overdue refunds one pass handles.
	Batch int32
	// OnOverdue moves the owning order to refund_overdue; wired by cmd
	// composition so billing never calls into orders directly.
	OnOverdue func(ctx context.Context, orderID string, dueAt time.Time) error
}

// RefundSweeper marks refunds overdue past their due date and opens the
// operator queue item for each.
type RefundSweeper struct {
	pool   *postgres.Pool
	clock  clock.Clock
	logger *slog.Logger
	outbox *outbox.Writer
	cfg    RefundSweepConfig
}

// NewRefundSweeper returns the refund SLA sweeper.
func NewRefundSweeper(pool *postgres.Pool, clk clock.Clock, logger *slog.Logger, cfg RefundSweepConfig) *RefundSweeper {
	if cfg.Batch <= 0 {
		cfg.Batch = 100
	}
	return &RefundSweeper{
		pool: pool, clock: clk, logger: logger,
		outbox: outbox.NewWriter(clk), cfg: cfg,
	}
}

// RunOnce marks every due refund overdue and publishes its queue event.
func (s *RefundSweeper) RunOnce(ctx context.Context) (int, error) {
	now := s.clock.Now()
	due, err := store.New(s.pool).ListRefundsDue(ctx, &store.ListRefundsDueParams{
		Deadline: timeValue(now), PageSize: s.cfg.Batch,
	})
	if err != nil {
		return 0, fmt.Errorf("billing: list due refunds: %w", err)
	}

	var overdue int
	var failures []error
	for _, refund := range due {
		// The order moves first. Its transition is idempotent (deterministic
		// operation key) and tolerates an order that already moved on, so a
		// replay is harmless. Flipping billing first would strand the pair on a
		// callback failure: an overdue refund is no longer listed, and the
		// order-side flip would never be retried.
		if s.cfg.OnOverdue != nil {
			if err := s.cfg.OnOverdue(ctx, uuidString(refund.OrderID), refund.DueAt.Time); err != nil {
				failures = append(failures, fmt.Errorf(
					"order transition for refund %s: %w", uuidString(refund.ID), err))
				continue
			}
		}
		if err := s.markOverdue(ctx, refund, now); err != nil {
			failures = append(failures, fmt.Errorf("refund %s: %w", uuidString(refund.ID), err))
			continue
		}
		overdue++
	}
	return overdue, errors.Join(failures...)
}

// markOverdue flips one refund and writes its queue event atomically.
func (s *RefundSweeper) markOverdue(ctx context.Context, refund *store.BillingRefund, at time.Time) error {
	tx, err := s.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	key := fmt.Sprintf("billing:refund_overdue:%s:%d", uuidString(refund.ID), refund.DueAt.Time.Unix())
	replay, err := dedup.ReserveFor(ctx, tx, key, uuid.UUID(refund.ID.Bytes), at)
	if err != nil {
		return err
	}
	if replay {
		return nil
	}

	changed, err := store.New(tx).MarkRefundOverdue(ctx, refund.ID)
	if err != nil {
		return fmt.Errorf("mark overdue: %w", err)
	}
	if changed == 0 {
		// The refund settled or was already flipped between listing and locking.
		return nil
	}
	if err := s.outbox.Write(ctx, tx, "billing", uuidString(refund.OrderID),
		eventcatalog.RefundBecameOverduePayload{
			OrderID: uuidString(refund.OrderID),
			Amount:  refund.Amount,
			DueAt:   refund.DueAt.Time,
		}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

// Run sweeps every interval until ctx is canceled.
func (s *RefundSweeper) Run(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			overdue, err := s.RunOnce(ctx)
			if err != nil && !errors.Is(err, context.Canceled) {
				s.logger.ErrorContext(ctx, "refund SLA sweep failed", "err", err)
			}
			if overdue > 0 {
				s.logger.InfoContext(ctx, "refunds marked overdue", "count", overdue)
			}
		}
	}
}
