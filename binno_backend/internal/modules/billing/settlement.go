package billing

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing/store"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
)

// foundingFreeOrders is how many completed orders an owner trades before
// commission is charged.
const foundingFreeOrders = 10

// settlementPort implements orders.SettlementPort.
type settlementPort struct{}

func newSettlementPort() *settlementPort { return &settlementPort{} }

var _ orders.SettlementPort = (*settlementPort)(nil)

// IssueInvoice creates the payment document an accepted order is paid against.
func (p *settlementPort) IssueInvoice(
	ctx context.Context, tx pgx.Tx, request orders.InvoiceRequest,
) (orders.IssuedInvoice, error) {
	orderID, ok := parseUUID(request.OrderID)
	if !ok {
		return orders.IssuedInvoice{}, orders.ErrSettlementInvalid
	}
	if request.TotalAmount < 0 {
		return orders.IssuedInvoice{}, orders.ErrSettlementInvalid
	}

	payee, err := json.Marshal(request.Payee)
	if err != nil {
		return orders.IssuedInvoice{}, fmt.Errorf("billing: encode payee: %w", err)
	}
	payer, err := json.Marshal(request.Payer)
	if err != nil {
		return orders.IssuedInvoice{}, fmt.Errorf("billing: encode payer: %w", err)
	}

	invoice, err := store.New(tx).IssueInvoice(ctx, &store.IssueInvoiceParams{
		ID:            uuidValue(uuid.New()),
		OrderID:       orderID,
		OwnerSnapshot: payee,
		BuyerSnapshot: payer,
		TotalAmount:   request.TotalAmount,
		ExpiresAt:     timeValue(request.ExpiresAt),
		CreatedAt:     timeValue(request.IssuedAt),
	})
	if err != nil {
		return orders.IssuedInvoice{}, fmt.Errorf("billing: issue invoice: %w", err)
	}
	return orders.IssuedInvoice{
		Number:      invoice.Number,
		Version:     invoice.Version,
		TotalAmount: invoice.TotalAmount,
		ExpiresAt:   invoice.ExpiresAt.Time,
	}, nil
}

// RecordPaymentReceipt files the buyer's bank receipt against the order.
func (p *settlementPort) RecordPaymentReceipt(
	ctx context.Context, tx pgx.Tx, request orders.ReceiptRequest,
) error {
	orderID, ok := parseUUID(request.OrderID)
	if !ok {
		return orders.ErrSettlementInvalid
	}
	if request.ReceiptURL == "" || request.GoodsAmount < 0 || request.DeliveryFee < 0 {
		return orders.ErrSettlementInvalid
	}

	receipt := request.ReceiptURL
	raw, err := json.Marshal(map[string]any{
		"channel":     "bank_transfer",
		"receipt_url": request.ReceiptURL,
		"submitted":   request.At,
	})
	if err != nil {
		return fmt.Errorf("billing: encode payment raw: %w", err)
	}

	_, err = store.New(tx).CreateManualPayment(ctx, &store.CreateManualPaymentParams{
		ID:           uuidValue(uuid.New()),
		OrderID:      orderID,
		GoodsAmount:  request.GoodsAmount,
		DeliveryFee:  request.DeliveryFee,
		SellerAmount: request.GoodsAmount + request.DeliveryFee,
		ReceiptUrl:   &receipt,
		Raw:          raw,
		CreatedAt:    timeValue(request.At),
	})
	if err != nil {
		if isUniqueViolation(err) {
			return orders.ErrSettlementConflict
		}
		return fmt.Errorf("billing: record receipt: %w", err)
	}
	return nil
}

// SettlePayment applies the seller's verdict to the order's live payment.
func (p *settlementPort) SettlePayment(
	ctx context.Context, tx pgx.Tx, decision orders.PaymentDecision,
) error {
	orderID, ok := parseUUID(decision.OrderID)
	if !ok {
		return orders.ErrSettlementInvalid
	}
	status := "failed"
	if decision.Accepted {
		status = "paid"
	}
	queries := store.New(tx)
	_, err := queries.SettleManualPayment(ctx, &store.SettleManualPaymentParams{
		Status: status, DecidedAt: timeValue(decision.At), OrderID: orderID,
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return orders.ErrSettlementConflict
	}
	if err != nil {
		return fmt.Errorf("billing: settle payment: %w", err)
	}
	// An accepted payment settles the document too; the invoice stops being
	// payable in the same transaction as the verdict.
	if decision.Accepted {
		if _, err := queries.MarkInvoicePaid(ctx, orderID); err != nil {
			return fmt.Errorf("billing: mark invoice paid: %w", err)
		}
	}
	return nil
}

// CancelSettlement voids the order's issued invoice and fails its undecided
// payment, so a cancelled order leaves nothing payable behind.
func (p *settlementPort) CancelSettlement(
	ctx context.Context, tx pgx.Tx, orderIDValue string, at time.Time,
) error {
	orderID, ok := parseUUID(orderIDValue)
	if !ok {
		return orders.ErrSettlementInvalid
	}
	queries := store.New(tx)
	if _, err := queries.VoidCurrentInvoice(ctx, orderID); err != nil {
		return fmt.Errorf("billing: void invoice: %w", err)
	}
	if _, err := queries.FailLivePayment(ctx, orderID); err != nil {
		return fmt.Errorf("billing: fail live payment: %w", err)
	}
	return nil
}

// OpenRefund records the seller's debt for a refunded order.
func (p *settlementPort) OpenRefund(
	ctx context.Context, tx pgx.Tx, request orders.RefundRequest,
) error {
	orderID, ok := parseUUID(request.OrderID)
	if !ok || request.Amount <= 0 {
		return orders.ErrSettlementInvalid
	}
	var reason *string
	if request.Reason != "" {
		reason = &request.Reason
	}
	if _, err := store.New(tx).CreateRefund(ctx, &store.CreateRefundParams{
		ID:        uuidValue(uuid.New()),
		OrderID:   orderID,
		Amount:    request.Amount,
		Reason:    reason,
		DueAt:     timeValue(request.DueAt),
		CreatedAt: timeValue(request.At),
	}); err != nil {
		return fmt.Errorf("billing: open refund: %w", err)
	}
	return nil
}

// CompleteRefund closes the open refund and reverses the settled payment.
func (p *settlementPort) CompleteRefund(
	ctx context.Context, tx pgx.Tx, orderIDValue string, at time.Time,
) error {
	orderID, ok := parseUUID(orderIDValue)
	if !ok {
		return orders.ErrSettlementInvalid
	}
	queries := store.New(tx)
	if _, err := queries.CompleteRefund(ctx, &store.CompleteRefundParams{
		ConfirmedAt: timeValue(at), OrderID: orderID,
	}); errors.Is(err, pgx.ErrNoRows) {
		return orders.ErrSettlementConflict
	} else if err != nil {
		return fmt.Errorf("billing: complete refund: %w", err)
	}
	if _, err := queries.ReversePaidPayment(ctx, orderID); err != nil {
		return fmt.Errorf("billing: reverse paid payment: %w", err)
	}
	if _, err := queries.MarkInvoiceRefunded(ctx, orderID); err != nil {
		return fmt.Errorf("billing: mark invoice refunded: %w", err)
	}
	return nil
}

// AccrueCommission writes the owner's ledger entry for a closed order and
// applies the founding allowance.
func (p *settlementPort) AccrueCommission(
	ctx context.Context, tx pgx.Tx, request orders.CommissionRequest,
) (orders.CommissionAccrued, error) {
	orderID, orderOK := parseUUID(request.OrderID)
	ownerID, ownerOK := parseUUID(request.OwnerID)
	if !orderOK || !ownerOK {
		return orders.CommissionAccrued{}, orders.ErrSettlementInvalid
	}
	if request.BaseAmount < 0 || request.Accrued < 0 || request.RateBps < 0 {
		return orders.CommissionAccrued{}, orders.ErrSettlementInvalid
	}
	if request.Accrued > request.BaseAmount {
		return orders.CommissionAccrued{}, orders.ErrSettlementInvalid
	}

	queries := store.New(tx)
	if err := queries.LockOwnerCommissionLedger(ctx, request.OwnerID); err != nil {
		return orders.CommissionAccrued{}, fmt.Errorf("billing: lock owner ledger: %w", err)
	}
	completed, err := queries.CountOwnerCommissionEntries(ctx, ownerID)
	if err != nil {
		return orders.CommissionAccrued{}, fmt.Errorf("billing: count owner ledger: %w", err)
	}

	sequence := completed + 1
	var discount int64
	if sequence <= foundingFreeOrders {
		discount = request.Accrued
	}
	payable := request.Accrued - discount

	if _, err := queries.CreateCommissionLedgerEntry(ctx, &store.CreateCommissionLedgerEntryParams{
		ID:         uuidValue(uuid.New()),
		OrderID:    orderID,
		OwnerID:    ownerID,
		BaseAmount: request.BaseAmount,
		RateBps:    request.RateBps,
		Accrued:    request.Accrued,
		Discount:   discount,
		Payable:    payable,
		CreatedAt:  timeValue(request.At),
	}); err != nil {
		if isUniqueViolation(err) {
			return orders.CommissionAccrued{}, orders.ErrSettlementConflict
		}
		return orders.CommissionAccrued{}, fmt.Errorf("billing: accrue commission: %w", err)
	}

	return orders.CommissionAccrued{
		Accrued:   request.Accrued,
		Discount:  discount,
		Payable:   payable,
		FreeOrder: discount == request.Accrued && request.Accrued > 0,
		Sequence:  sequence,
	}, nil
}

func uuidValue(id uuid.UUID) pgtype.UUID { return pgtype.UUID{Bytes: id, Valid: true} }

func timeValue(value time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: value, Valid: true}
}

// isUniqueViolation reports a 23505.
func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == "23505"
}
