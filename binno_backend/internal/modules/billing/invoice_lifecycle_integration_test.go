//go:build integration

package billing_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// The invoice is a document with a lifecycle: issued -> paid -> refunded on the
// settled path, issued -> voided on the cancellation path. These tests pin that
// every settlement verdict moves the document in the same transaction.

// inTx runs fn inside one committed transaction, the way the order state
// machine drives the settlement port.
func inTx(t *testing.T, pool *postgres.Pool, fn func(tx pgx.Tx) error) error {
	t.Helper()
	ctx := context.Background()
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()
	if err := fn(tx); err != nil {
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatalf("commit: %v", err)
	}
	return nil
}

func invoiceStatus(t *testing.T, pool *postgres.Pool, orderID string) string {
	t.Helper()
	var status string
	if err := pool.QueryRow(context.Background(),
		`SELECT status FROM billing.invoices WHERE order_id = $1 ORDER BY version DESC LIMIT 1`,
		orderID).Scan(&status); err != nil {
		t.Fatalf("read invoice status: %v", err)
	}
	return status
}

func cleanupBillingRows(t *testing.T, pool *postgres.Pool, orderID string) {
	t.Helper()
	t.Cleanup(func() {
		ctx := context.Background()
		_, _ = pool.Exec(ctx, `DELETE FROM billing.refunds WHERE order_id = $1`, orderID)
		_, _ = pool.Exec(ctx, `DELETE FROM billing.payments WHERE order_id = $1`, orderID)
		_, _ = pool.Exec(ctx, `DELETE FROM billing.invoices WHERE order_id = $1`, orderID)
	})
}

func issueTestInvoice(t *testing.T, pool *postgres.Pool, port orders.SettlementPort, orderID string) {
	t.Helper()
	now := time.Now().UTC()
	if err := inTx(t, pool, func(tx pgx.Tx) error {
		_, err := port.IssueInvoice(context.Background(), tx, orders.InvoiceRequest{
			OrderID:     orderID,
			TotalAmount: 100_000,
			Payee:       orders.Payee{OwnerID: "owner", StoreID: "store", StoreName: "Store"},
			Payer:       orders.Payer{BuyerID: "buyer", BuyerType: "individual"},
			IssuedAt:    now,
			ExpiresAt:   now.Add(72 * time.Hour),
		})
		return err
	}); err != nil {
		t.Fatalf("issue invoice: %v", err)
	}
}

func TestInvoiceSettledPathIssuedPaidRefunded(t *testing.T) {
	pool := testPool(t)
	f := newFixture(t, pool, 1)
	orderID := f.orders[0]
	cleanupBillingRows(t, pool, orderID)
	port := billing.NewSettlementPort()
	ctx := context.Background()
	now := time.Now().UTC()

	issueTestInvoice(t, pool, port, orderID)
	if got := invoiceStatus(t, pool, orderID); got != "issued" {
		t.Fatalf("after issue: invoice status = %q, want issued", got)
	}

	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.RecordPaymentReceipt(ctx, tx, orders.ReceiptRequest{
			OrderID: orderID, ReceiptURL: "https://bank.example/receipt.pdf",
			GoodsAmount: 100_000, DeliveryFee: 0, At: now,
		})
	}); err != nil {
		t.Fatalf("record receipt: %v", err)
	}

	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.SettlePayment(ctx, tx, orders.PaymentDecision{
			OrderID: orderID, Accepted: true, At: now,
		})
	}); err != nil {
		t.Fatalf("settle payment: %v", err)
	}
	if got := invoiceStatus(t, pool, orderID); got != "paid" {
		t.Errorf("after accepted verdict: invoice status = %q, want paid", got)
	}

	// The buyer's document survives payment: the repository still serves it.
	repo := billing.NewRepository(pool)
	if _, err := repo.GetPaymentInvoice(ctx, orderID); err != nil {
		t.Errorf("GetPaymentInvoice after payment: %v, want the paid invoice served", err)
	}

	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.OpenRefund(ctx, tx, orders.RefundRequest{
			OrderID: orderID, Amount: 100_000, Reason: "operator decision",
			At: now, DueAt: now.Add(72 * time.Hour),
		})
	}); err != nil {
		t.Fatalf("open refund: %v", err)
	}
	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.CompleteRefund(ctx, tx, orderID, now)
	}); err != nil {
		t.Fatalf("complete refund: %v", err)
	}
	if got := invoiceStatus(t, pool, orderID); got != "refunded" {
		t.Errorf("after completed refund: invoice status = %q, want refunded", got)
	}
	var paymentStatus string
	if err := pool.QueryRow(ctx,
		`SELECT status FROM billing.payments WHERE order_id = $1`, orderID).Scan(&paymentStatus); err != nil {
		t.Fatalf("read payment status: %v", err)
	}
	if paymentStatus != "reversed" {
		t.Errorf("after completed refund: payment status = %q, want reversed", paymentStatus)
	}
}

func TestInvoiceCancellationPathVoidsOnlyUnpaid(t *testing.T) {
	pool := testPool(t)
	f := newFixture(t, pool, 2)
	port := billing.NewSettlementPort()
	ctx := context.Background()
	now := time.Now().UTC()

	// Unpaid invoice: cancellation voids it.
	unpaid := f.orders[0]
	cleanupBillingRows(t, pool, unpaid)
	issueTestInvoice(t, pool, port, unpaid)
	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.CancelSettlement(ctx, tx, unpaid, now)
	}); err != nil {
		t.Fatalf("cancel settlement: %v", err)
	}
	if got := invoiceStatus(t, pool, unpaid); got != "voided" {
		t.Errorf("cancelled unpaid order: invoice status = %q, want voided", got)
	}
	repo := billing.NewRepository(pool)
	if _, err := repo.GetPaymentInvoice(ctx, unpaid); !errors.Is(err, billing.ErrNotFound) {
		t.Errorf("GetPaymentInvoice on voided invoice: err = %v, want ErrNotFound", err)
	}

	// Paid invoice: a later CancelSettlement replay must not void the receipt.
	paid := f.orders[1]
	cleanupBillingRows(t, pool, paid)
	issueTestInvoice(t, pool, port, paid)
	if err := inTx(t, pool, func(tx pgx.Tx) error {
		if err := port.RecordPaymentReceipt(ctx, tx, orders.ReceiptRequest{
			OrderID: paid, ReceiptURL: "https://bank.example/receipt.pdf",
			GoodsAmount: 100_000, DeliveryFee: 0, At: now,
		}); err != nil {
			return err
		}
		return port.SettlePayment(ctx, tx, orders.PaymentDecision{OrderID: paid, Accepted: true, At: now})
	}); err != nil {
		t.Fatalf("pay invoice: %v", err)
	}
	if err := inTx(t, pool, func(tx pgx.Tx) error {
		return port.CancelSettlement(ctx, tx, paid, now)
	}); err != nil {
		t.Fatalf("cancel settlement replay: %v", err)
	}
	if got := invoiceStatus(t, pool, paid); got != "paid" {
		t.Errorf("cancel on a paid order: invoice status = %q, want paid untouched", got)
	}
}
