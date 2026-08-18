package billing

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/dedup"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

const commissionPageSize = 50

// Repository reads and writes the billing schema.
type Repository struct{ pool *postgres.Pool }

// NewRepository returns a billing repository over pool.
func NewRepository(pool *postgres.Pool) *Repository { return &Repository{pool: pool} }

// GetPaymentInvoice returns the current issued invoice for an order.
func (r *Repository) GetPaymentInvoice(ctx context.Context, orderID string) (Invoice, error) {
	id, ok := parseUUID(orderID)
	if !ok {
		return Invoice{}, ErrInvalid
	}
	invoice, err := store.New(r.pool).GetCurrentPaymentInvoice(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return Invoice{}, ErrNotFound
	}
	if err != nil {
		return Invoice{}, fmt.Errorf("billing: get invoice: %w", err)
	}
	return Invoice{Number: invoice.Number, TotalAmount: invoice.TotalAmount}, nil
}

// SubmitRefundEvidence attaches settlement evidence to the order's open refund.
func (r *Repository) SubmitRefundEvidence(ctx context.Context, in RefundEvidence, at time.Time) error {
	orderID, ok := parseUUID(in.OrderID)
	if !ok {
		return ErrInvalid
	}
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("billing: begin refund evidence: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(orderID.Bytes), at)
	if err != nil {
		if errors.Is(err, dedup.ErrKeyReuse) {
			return fmt.Errorf("%w: %s", ErrConflict, err)
		}
		return err
	}
	if replay {
		return nil
	}

	queries := store.New(tx)
	refund, err := queries.GetRefundForUpdate(ctx, orderID)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return fmt.Errorf("billing: get refund: %w", err)
	}
	if refund.Status != "requested" || refund.Amount != in.Amount {
		return ErrConflict
	}
	evidence := in.EvidenceURL
	if _, err := queries.SubmitRefundEvidence(ctx, &store.SubmitRefundEvidenceParams{
		EvidenceUrl: &evidence, ID: refund.ID,
	}); errors.Is(err, pgx.ErrNoRows) {
		return ErrConflict
	} else if err != nil {
		return fmt.Errorf("billing: submit refund evidence: %w", err)
	}
	return tx.Commit(ctx)
}

// ListCommissionInvoices returns one keyset page of an owner's statements.
func (r *Repository) ListCommissionInvoices(ctx context.Context, ownerID, cursor string) ([]CommissionInvoice, error) {
	id, ok := parseUUID(ownerID)
	if !ok {
		return nil, ErrInvalid
	}
	var before pgtype.Date
	if cursor != "" {
		value, err := time.Parse(time.DateOnly, cursor)
		if err != nil {
			return nil, ErrInvalid
		}
		before = pgtype.Date{Time: value, Valid: true}
	}
	rows, err := store.New(r.pool).ListCommissionInvoicesByOwner(ctx, &store.ListCommissionInvoicesByOwnerParams{
		OwnerID: id, BeforePeriodStart: before, PageSize: commissionPageSize,
	})
	if err != nil {
		return nil, fmt.Errorf("billing: list commission invoices: %w", err)
	}
	out := make([]CommissionInvoice, 0, len(rows))
	for _, row := range rows {
		out = append(out, CommissionInvoice{
			ID:             uuidString(row.ID),
			PeriodStart:    row.PeriodStart.Time.Format(time.DateOnly),
			PeriodEnd:      row.PeriodEnd.Time.Format(time.DateOnly),
			AccruedAmount:  row.AccruedAmount,
			DiscountAmount: row.DiscountAmount,
			Amount:         row.Amount,
			DueAt:          row.DueAt.Time.UTC().Format(time.RFC3339),
			Status:         row.Status,
		})
	}
	return out, nil
}

func parseUUID(value string) (pgtype.UUID, bool) {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}, false
	}
	return pgtype.UUID{Bytes: id, Valid: true}, true
}

func uuidString(value pgtype.UUID) string {
	if !value.Valid {
		return ""
	}
	return uuid.UUID(value.Bytes).String()
}
