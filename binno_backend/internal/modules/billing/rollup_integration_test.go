//go:build integration

package billing_test

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// The commission statement job must be safe to run twice — after a crashed
// pass, a replayed cron tick, or a second instance racing the first. Its two
// guarantees come from different mechanisms and are pinned separately: the
// per-owner advisory lock serialises writers, and UNIQUE(owner_id,
// period_start) makes a duplicate statement impossible even without the lock.

// ledgerRow files one unbilled commission entry for a closed order dated into
// the given month.
func ledgerRow(t *testing.T, pool *postgres.Pool, w seed.World, payable int64, at time.Time) {
	t.Helper()
	orderID := seed.OrderRow(t, pool, w, "closed", payable*40, 0)
	if _, err := pool.Exec(context.Background(), `
		INSERT INTO billing.commission_ledger
		  (id, order_id, owner_id, base_amount, rate_bps, accrued, discount, payable, created_at)
		VALUES ($1, $2, $3, $4, 250, $5, 0, $5, $6)`,
		uuid.NewString(), orderID, w.OwnerID, payable*40, payable, at); err != nil {
		t.Fatalf("seed ledger row: %v", err)
	}
}

func newRollup(pool *postgres.Pool) *billing.Rollup {
	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	return billing.NewRollup(pool, clock.New(), logger, billing.RollupConfig{Batch: 500})
}

// previousMonth returns the first instant of last month and its period date.
func previousMonth() (time.Time, time.Time) {
	now := time.Now().UTC()
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	prev := monthStart.AddDate(0, -1, 0)
	return prev.Add(2 * time.Hour), prev
}

type ownerInvoice struct {
	id                        string
	accrued, discount, amount int64
	status                    string
}

func invoicesForOwner(t *testing.T, pool *postgres.Pool, ownerID string, period time.Time) []ownerInvoice {
	t.Helper()
	rows, err := pool.Query(context.Background(), `
		SELECT id::text, accrued_amount, discount_amount, amount, status
		  FROM billing.commission_invoices
		 WHERE owner_id = $1 AND period_start = $2::date`,
		ownerID, period)
	if err != nil {
		t.Fatalf("list invoices: %v", err)
	}
	defer rows.Close()
	var out []ownerInvoice
	for rows.Next() {
		var inv ownerInvoice
		if err := rows.Scan(&inv.id, &inv.accrued, &inv.discount, &inv.amount, &inv.status); err != nil {
			t.Fatalf("scan invoice: %v", err)
		}
		out = append(out, inv)
	}
	return out
}

func TestRollupRunTwiceProducesOneInvoice(t *testing.T) {
	pool := pgtest.Pool(t)
	w := seed.Marketplace(t, pool, seed.Config{})
	entryAt, period := previousMonth()
	for range 3 {
		ledgerRow(t, pool, w, 500, entryAt)
	}

	rollup := newRollup(pool)
	if _, err := rollup.RunOnce(context.Background()); err != nil {
		t.Fatalf("first run: %v", err)
	}
	if _, err := rollup.RunOnce(context.Background()); err != nil {
		t.Fatalf("second run: %v", err)
	}

	invoices := invoicesForOwner(t, pool, w.OwnerID, period)
	if len(invoices) != 1 {
		t.Fatalf("invoices for period = %d, want exactly 1", len(invoices))
	}
	if invoices[0].amount != 1_500 || invoices[0].accrued != 1_500 || invoices[0].discount != 0 {
		t.Errorf("invoice accrued/discount/amount = %d/%d/%d, want 1500/0/1500",
			invoices[0].accrued, invoices[0].discount, invoices[0].amount)
	}
	if invoices[0].status != "issued" {
		t.Errorf("invoice status = %q, want issued", invoices[0].status)
	}

	var attached, total int
	if err := pool.QueryRow(context.Background(), `
		SELECT count(*) FILTER (WHERE invoice_id::text = $2), count(*)
		  FROM billing.commission_ledger WHERE owner_id = $1`,
		w.OwnerID, invoices[0].id).Scan(&attached, &total); err != nil {
		t.Fatalf("count attached rows: %v", err)
	}
	if attached != 3 || total != 3 {
		t.Errorf("ledger rows attached to the invoice = %d of %d, want 3 of 3", attached, total)
	}

	// Even a writer that skips the job entirely cannot duplicate a statement:
	// the unique constraint holds on its own.
	_, err := pool.Exec(context.Background(), `
		INSERT INTO billing.commission_invoices
		  (id, owner_id, period_start, period_end, accrued_amount, discount_amount,
		   amount, due_at, status)
		VALUES ($1, $2, $3::date, $3::date + interval '27 days', 0, 0, 0, now(), 'issued')`,
		uuid.NewString(), w.OwnerID, period)
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) || pgErr.Code != "23505" {
		t.Errorf("manual duplicate statement: err = %v, want unique violation 23505", err)
	}
}

// Layer 2: two instances started at the same moment. The advisory lock makes
// one wait; the conflict-as-read upsert turns the waiter's insert into a read.
// Both finish cleanly and the owner still has one statement.
func TestConcurrentRollupsProduceOneInvoice(t *testing.T) {
	pool := pgtest.Pool(t)
	w := seed.Marketplace(t, pool, seed.Config{})
	entryAt, period := previousMonth()
	ledgerRow(t, pool, w, 700, entryAt)
	ledgerRow(t, pool, w, 800, entryAt)

	start := make(chan struct{})
	errs := make(chan error, 2)
	var wg sync.WaitGroup
	for range 2 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-start
			_, err := newRollup(pool).RunOnce(context.Background())
			errs <- err
		}()
	}
	close(start)
	wg.Wait()
	close(errs)
	for err := range errs {
		if err != nil {
			t.Errorf("concurrent rollup run: %v", err)
		}
	}

	invoices := invoicesForOwner(t, pool, w.OwnerID, period)
	if len(invoices) != 1 {
		t.Fatalf("invoices for period = %d, want exactly 1", len(invoices))
	}
	if invoices[0].amount != 1_500 {
		t.Errorf("invoice amount = %d, want 1500", invoices[0].amount)
	}
	var attached int
	if err := pool.QueryRow(context.Background(), `
		SELECT count(*) FROM billing.commission_ledger
		 WHERE owner_id = $1 AND invoice_id::text = $2`,
		w.OwnerID, invoices[0].id).Scan(&attached); err != nil {
		t.Fatalf("count attached rows: %v", err)
	}
	if attached != 2 {
		t.Errorf("attached ledger rows = %d, want 2", attached)
	}
}
