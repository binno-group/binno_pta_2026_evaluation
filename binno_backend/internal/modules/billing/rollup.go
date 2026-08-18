package billing

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// commissionDueGrace is how long after a period closes its statement stays
// payable before becoming overdue.
const commissionDueGrace = 10 * 24 * time.Hour

// RollupConfig tunes the commission statement job.
type RollupConfig struct {
	// Batch caps how many (owner, month) periods one pass settles.
	Batch int32
}

// Rollup turns each owner's unbilled ledger months into commission invoices.
// Replays are harmless: the invoice upsert is a read on conflict and the
// ledger attach only touches rows still unlinked.
type Rollup struct {
	pool   *postgres.Pool
	clock  clock.Clock
	logger *slog.Logger
	cfg    RollupConfig
}

// NewRollup returns the commission rollup job.
func NewRollup(pool *postgres.Pool, clk clock.Clock, logger *slog.Logger, cfg RollupConfig) *Rollup {
	if cfg.Batch <= 0 {
		cfg.Batch = 50
	}
	return &Rollup{pool: pool, clock: clk, logger: logger, cfg: cfg}
}

// RunOnce invoices every completed month that still has unbilled ledger rows.
func (r *Rollup) RunOnce(ctx context.Context) (int, error) {
	now := r.clock.Now().UTC()
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)

	periods, err := store.New(r.pool).ListUnbilledCommissionPeriods(ctx,
		&store.ListUnbilledCommissionPeriodsParams{
			Before: pgtype.Timestamptz{Time: monthStart, Valid: true}, PageSize: r.cfg.Batch,
		})
	if err != nil {
		return 0, fmt.Errorf("billing: list unbilled periods: %w", err)
	}

	var issued int
	var failures []error
	for _, period := range periods {
		if err := r.invoicePeriod(ctx, period); err != nil {
			failures = append(failures, fmt.Errorf(
				"invoice owner %s period %s: %w",
				uuidString(period.OwnerID), period.PeriodStart.Time.Format(time.DateOnly), err))
			continue
		}
		issued++
	}
	return issued, errors.Join(failures...)
}

// invoicePeriod settles one (owner, month) pair in one transaction.
func (r *Rollup) invoicePeriod(ctx context.Context, period *store.ListUnbilledCommissionPeriodsRow) error {
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("begin: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	queries := store.New(tx)
	if err := queries.LockOwnerCommissionLedger(ctx, uuidString(period.OwnerID)); err != nil {
		return fmt.Errorf("lock owner ledger: %w", err)
	}

	periodStart := period.PeriodStart.Time
	periodEnd := periodStart.AddDate(0, 1, -1)
	invoiceID, err := queries.CreateCommissionInvoice(ctx, &store.CreateCommissionInvoiceParams{
		ID:             uuidValue(uuid.New()),
		OwnerID:        period.OwnerID,
		PeriodStart:    period.PeriodStart,
		PeriodEnd:      pgtype.Date{Time: periodEnd, Valid: true},
		AccruedAmount:  period.AccruedAmount,
		DiscountAmount: period.DiscountAmount,
		Amount:         period.Amount,
		DueAt:          timeValue(periodStart.AddDate(0, 1, 0).Add(commissionDueGrace)),
	})
	if err != nil {
		return fmt.Errorf("create invoice: %w", err)
	}
	if _, err := queries.AttachLedgerToInvoice(ctx, &store.AttachLedgerToInvoiceParams{
		InvoiceID:   invoiceID,
		OwnerID:     period.OwnerID,
		PeriodStart: period.PeriodStart,
	}); err != nil {
		return fmt.Errorf("attach ledger rows: %w", err)
	}
	return tx.Commit(ctx)
}

// Run rolls up every interval until ctx is canceled.
func (r *Rollup) Run(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			issued, err := r.RunOnce(ctx)
			if err != nil && !errors.Is(err, context.Canceled) {
				r.logger.ErrorContext(ctx, "commission rollup failed", "err", err)
			}
			if issued > 0 {
				r.logger.InfoContext(ctx, "commission statements issued", "periods", issued)
			}
		}
	}
}
