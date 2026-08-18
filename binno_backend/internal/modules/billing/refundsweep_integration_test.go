//go:build integration

package billing_test

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// The refund SLA sweep is a two-transaction saga: the order flips in one
// transaction, the refund and its queue event in another. These tests pin the
// property the ordering was chosen for: a failure of either step leaves the
// pair in a state the next pass converges from, and the queue event is
// published exactly once.

// refundFixture puts one order into refund_requested with a refund already due.
func refundFixture(t *testing.T, pool *postgres.Pool) (orderID, refundID string) {
	t.Helper()
	ctx := context.Background()
	f := newFixture(t, pool, 1)
	orderID = f.orders[0]
	refundID = uuid.NewString()

	if _, err := pool.Exec(ctx,
		`UPDATE orders.orders SET status = 'refund_requested' WHERE id = $1`, orderID); err != nil {
		t.Fatalf("set order status: %v", err)
	}
	if _, err := pool.Exec(ctx,
		`INSERT INTO billing.refunds (id, order_id, amount, status, due_at, created_at)
		 VALUES ($1, $2, 100000, 'requested', now() - interval '1 hour', now() - interval '2 hour')`,
		refundID, orderID); err != nil {
		t.Fatalf("insert refund: %v", err)
	}
	t.Cleanup(func() {
		_, _ = pool.Exec(ctx, `DELETE FROM billing.refunds WHERE id = $1`, refundID)
		_, _ = pool.Exec(ctx, `DELETE FROM platform.outbox WHERE aggregate_id = $1`, orderID)
		_, _ = pool.Exec(ctx,
			`DELETE FROM platform.mutation_receipts WHERE operation_key LIKE 'billing:refund_overdue:' || $1 || ':%'`,
			refundID)
	})
	return orderID, refundID
}

func refundStatus(t *testing.T, pool *postgres.Pool, refundID string) string {
	t.Helper()
	var status string
	if err := pool.QueryRow(context.Background(),
		`SELECT status FROM billing.refunds WHERE id = $1`, refundID).Scan(&status); err != nil {
		t.Fatalf("read refund status: %v", err)
	}
	return status
}

func overdueEvents(t *testing.T, pool *postgres.Pool, orderID string) int64 {
	t.Helper()
	var count int64
	if err := pool.QueryRow(context.Background(),
		`SELECT count(*) FROM platform.outbox
		  WHERE event_name = 'refund.became_overdue' AND aggregate_id = $1`, orderID).Scan(&count); err != nil {
		t.Fatalf("count outbox events: %v", err)
	}
	return count
}

func newSweeper(pool *postgres.Pool, onOverdue func(context.Context, string, time.Time) error) *billing.RefundSweeper {
	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	return billing.NewRefundSweeper(pool, clock.New(), logger, billing.RefundSweepConfig{
		Batch: 10, OnOverdue: onOverdue,
	})
}

func TestRefundSweepRetriesAfterOrderCallbackFailure(t *testing.T) {
	pool := testPool(t)
	orderID, refundID := refundFixture(t, pool)
	ctx := context.Background()

	// Pass 1: the order-side flip fails. Nothing on the billing side may move,
	// or the pair is stranded: an overdue refund is never listed again.
	failing := newSweeper(pool, func(context.Context, string, time.Time) error {
		return errors.New("injected: orders unavailable")
	})
	overdue, err := failing.RunOnce(ctx)
	if err == nil {
		t.Fatal("RunOnce with failing callback: err = nil, want the injected failure surfaced")
	}
	if overdue != 0 {
		t.Errorf("RunOnce with failing callback: overdue = %d, want 0", overdue)
	}
	if got := refundStatus(t, pool, refundID); got != "requested" {
		t.Errorf("after failed callback: refund status = %q, want %q (still sweepable)", got, "requested")
	}
	if got := overdueEvents(t, pool, orderID); got != 0 {
		t.Errorf("after failed callback: %d refund.became_overdue events, want 0", got)
	}

	// Pass 2: the callback recovers (here it applies the order flip directly,
	// standing in for orders.Module.RefundOverdue). Both sides converge.
	var callbackOrders []string
	recovered := newSweeper(pool, func(ctx context.Context, gotOrderID string, _ time.Time) error {
		callbackOrders = append(callbackOrders, gotOrderID)
		_, err := pool.Exec(ctx,
			`UPDATE orders.orders SET status = 'refund_overdue'
			  WHERE id = $1 AND status = 'refund_requested'`, gotOrderID)
		return err
	})
	overdue, err = recovered.RunOnce(ctx)
	if err != nil {
		t.Fatalf("RunOnce after recovery: %v", err)
	}
	if overdue != 1 {
		t.Errorf("RunOnce after recovery: overdue = %d, want 1", overdue)
	}
	if len(callbackOrders) != 1 || callbackOrders[0] != orderID {
		t.Errorf("callback saw orders %v, want exactly [%s]", callbackOrders, orderID)
	}
	if got := refundStatus(t, pool, refundID); got != "overdue" {
		t.Errorf("after recovery: refund status = %q, want %q", got, "overdue")
	}
	if got := overdueEvents(t, pool, orderID); got != 1 {
		t.Errorf("after recovery: %d refund.became_overdue events, want exactly 1", got)
	}

	// Pass 3: the flipped refund is no longer listed; nothing repeats.
	overdue, err = recovered.RunOnce(ctx)
	if err != nil {
		t.Fatalf("RunOnce after convergence: %v", err)
	}
	if overdue != 0 {
		t.Errorf("RunOnce after convergence: overdue = %d, want 0", overdue)
	}
	if len(callbackOrders) != 1 {
		t.Errorf("callback ran %d times after convergence, want 1 (refund no longer listed)", len(callbackOrders))
	}
	if got := overdueEvents(t, pool, orderID); got != 1 {
		t.Errorf("after convergence: %d refund.became_overdue events, want exactly 1", got)
	}
}

func TestRefundSweepSurvivesBillingFlipFailure(t *testing.T) {
	pool := testPool(t)
	orderID, refundID := refundFixture(t, pool)
	ctx := context.Background()

	// The order flip succeeds, then the process dies before the billing flip:
	// modelled by a callback that flips the order and a canceled context that
	// stops markOverdue from committing.
	flip := func(ctx context.Context, gotOrderID string, _ time.Time) error {
		_, err := pool.Exec(context.WithoutCancel(ctx),
			`UPDATE orders.orders SET status = 'refund_overdue'
			  WHERE id = $1 AND status = 'refund_requested'`, gotOrderID)
		return err
	}
	interrupted, cancel := context.WithCancel(ctx)
	sweeper := newSweeper(pool, func(c context.Context, id string, due time.Time) error {
		if err := flip(c, id, due); err != nil {
			return err
		}
		cancel() // the crash window between the two transactions
		return nil
	})
	if _, err := sweeper.RunOnce(interrupted); err == nil {
		t.Fatal("interrupted RunOnce: err = nil, want the aborted billing flip surfaced")
	}
	if got := refundStatus(t, pool, refundID); got != "requested" {
		t.Fatalf("after interrupt: refund status = %q, want %q (still sweepable)", got, "requested")
	}

	// The next pass replays the (now no-op) order flip and completes billing.
	steady := newSweeper(pool, flip)
	overdue, err := steady.RunOnce(ctx)
	if err != nil {
		t.Fatalf("RunOnce after interrupt: %v", err)
	}
	if overdue != 1 {
		t.Errorf("RunOnce after interrupt: overdue = %d, want 1", overdue)
	}
	if got := refundStatus(t, pool, refundID); got != "overdue" {
		t.Errorf("converged refund status = %q, want %q", got, "overdue")
	}
	if got := overdueEvents(t, pool, orderID); got != 1 {
		t.Errorf("%d refund.became_overdue events, want exactly 1", got)
	}
}
