//go:build integration

package billing_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// Payment truth in this system is the settlement flow driven by the order
// state machine: a filed receipt, then the seller's verdict. These tests pin
// the invariants a payment-provider callback endpoint would also have to
// satisfy: one live payment per order, no state regression from stale
// deliveries, late money recorded but never applied, and unknown or duplicate
// references refused by the schema itself. See docs/test-plan.md D2.

type paymentDriver struct {
	pool *postgres.Pool
	repo *orders.Repository
}

func newPaymentDriver(t *testing.T) *paymentDriver {
	t.Helper()
	pool := pgtest.Pool(t)
	clk := clock.New()
	loc := location.New(pool)
	cat := catalog.New(pool, loc.Guard(), clk)
	repo := orders.NewRepository(pool, cat.OrderLines(), loc.SaleGate(), billing.NewSettlementPort(), nil, clk)
	return &paymentDriver{pool: pool, repo: repo}
}

func driverCtx() context.Context {
	return httpx.WithOperationKey(context.Background(), uuid.NewString())
}

func (d *paymentDriver) place(t *testing.T, w seed.World, qty string) string {
	t.Helper()
	created, err := d.repo.Create(driverCtx(), orders.CreateCommand{
		CreateInput: orders.CreateInput{
			StoreID: w.StoreID, BuyerType: "individual", Fulfillment: "pickup",
			Items: []orders.ItemInput{{ProductID: w.ProductID, Qty: qty}},
		},
		BuyerID: w.BuyerUserID,
		At:      time.Now().UTC(),
	})
	if err != nil {
		t.Fatalf("place order: %v", err)
	}
	return created.OrderID
}

func (d *paymentDriver) step(orderID string, trigger orders.Trigger) error {
	cmd := orders.TransitionCommand{OrderID: orderID, Trigger: trigger, At: time.Now().UTC()}
	switch trigger {
	case orders.TriggerSubmitReceipt:
		cmd.ReceiptURL = "https://storage.example/receipts/transfer.pdf"
	case orders.TriggerRejectPayment, orders.TriggerBuyerCancel, orders.TriggerOperatorCancel:
		cmd.Reason = "suite"
	case orders.TriggerConfirmPickup:
		cmd.PickupCode = "0000"
	}
	return d.repo.Apply(driverCtx(), cmd)
}

func (d *paymentDriver) mustStep(t *testing.T, orderID string, triggers ...orders.Trigger) {
	t.Helper()
	for _, trigger := range triggers {
		if err := d.step(orderID, trigger); err != nil {
			t.Fatalf("step %s: %v", trigger, err)
		}
	}
}

func (d *paymentDriver) status(t *testing.T, orderID string) string {
	t.Helper()
	var status string
	if err := d.pool.QueryRow(context.Background(),
		`SELECT status FROM orders.orders WHERE id = $1`, orderID).Scan(&status); err != nil {
		t.Fatalf("read order status: %v", err)
	}
	return status
}

func TestDuplicateReceiptKeepsOneLivePaymentRow(t *testing.T) {
	d := newPaymentDriver(t)
	w := seed.Marketplace(t, d.pool, seed.Config{})
	orderID := d.place(t, w, "1")
	d.mustStep(t, orderID, orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt)

	// The same receipt delivered again, straight at the settlement port the
	// way a replayed webhook would arrive: the partial unique index on live
	// payments turns it into a domain conflict, not a second row.
	port := billing.NewSettlementPort()
	err := inTx(t, d.pool, func(tx pgx.Tx) error {
		return port.RecordPaymentReceipt(context.Background(), tx, orders.ReceiptRequest{
			OrderID: orderID, ReceiptURL: "https://storage.example/receipts/transfer.pdf",
			GoodsAmount: 10_000, DeliveryFee: 0, At: time.Now().UTC(),
		})
	})
	if !errors.Is(err, orders.ErrSettlementConflict) {
		t.Fatalf("duplicate receipt: err = %v, want ErrSettlementConflict", err)
	}

	var live int
	if err := d.pool.QueryRow(context.Background(),
		`SELECT count(*) FROM billing.payments WHERE order_id = $1 AND status IN ('created', 'paid')`,
		orderID).Scan(&live); err != nil {
		t.Fatalf("count live payments: %v", err)
	}
	if live != 1 {
		t.Errorf("live payment rows = %d, want exactly 1", live)
	}
}

func TestLateVerdictCannotRegressOrderState(t *testing.T) {
	d := newPaymentDriver(t)
	w := seed.Marketplace(t, d.pool, seed.Config{})
	orderID := d.place(t, w, "1")
	d.mustStep(t, orderID,
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment)

	// A rejection arriving after the payment settled must bounce off the
	// machine, not pull the order back to awaiting_payment.
	if err := d.step(orderID, orders.TriggerRejectPayment); !errors.Is(err, orders.ErrConflict) {
		t.Fatalf("late reject: err = %v, want ErrConflict", err)
	}
	// So must a second confirmation.
	if err := d.step(orderID, orders.TriggerConfirmPayment); !errors.Is(err, orders.ErrConflict) {
		t.Fatalf("second confirm: err = %v, want ErrConflict", err)
	}

	if got := d.status(t, orderID); got != string(orders.StatusPaid) {
		t.Errorf("order status = %q, want paid untouched", got)
	}
	var paymentStatus string
	if err := d.pool.QueryRow(context.Background(),
		`SELECT status FROM billing.payments WHERE order_id = $1`, orderID).Scan(&paymentStatus); err != nil {
		t.Fatalf("read payment: %v", err)
	}
	if paymentStatus != "paid" {
		t.Errorf("payment status = %q, want paid untouched", paymentStatus)
	}
	if got := invoiceStatus(t, d.pool, orderID); got != "paid" {
		t.Errorf("invoice status = %q, want paid untouched", got)
	}
}

func TestReceiptAfterCancellationIsRecordedNotApplied(t *testing.T) {
	d := newPaymentDriver(t)
	w := seed.Marketplace(t, d.pool, seed.Config{})
	orderID := d.place(t, w, "1")
	d.mustStep(t, orderID, orders.TriggerSupplierConfirm, orders.TriggerBuyerCancel)

	if got := invoiceStatus(t, d.pool, orderID); got != "voided" {
		t.Fatalf("invoice after cancel = %q, want voided", got)
	}

	// Money that arrives late is still evidence: filing it must succeed and
	// leave a row, but nothing may move the cancelled order.
	port := billing.NewSettlementPort()
	if err := inTx(t, d.pool, func(tx pgx.Tx) error {
		return port.RecordPaymentReceipt(context.Background(), tx, orders.ReceiptRequest{
			OrderID: orderID, ReceiptURL: "https://storage.example/receipts/late.pdf",
			GoodsAmount: 10_000, DeliveryFee: 0, At: time.Now().UTC(),
		})
	}); err != nil {
		t.Fatalf("record late receipt: %v", err)
	}

	if err := d.step(orderID, orders.TriggerSubmitReceipt); !errors.Is(err, orders.ErrConflict) {
		t.Fatalf("submit receipt on cancelled order: err = %v, want ErrConflict", err)
	}
	if got := d.status(t, orderID); got != string(orders.StatusCancelledByBuyerSLA) {
		t.Errorf("order status = %q, want cancellation kept", got)
	}
	var recorded string
	if err := d.pool.QueryRow(context.Background(),
		`SELECT status FROM billing.payments WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1`,
		orderID).Scan(&recorded); err != nil {
		t.Fatalf("read late payment: %v", err)
	}
	if recorded != "created" {
		t.Errorf("late payment status = %q, want created (recorded, never applied)", recorded)
	}
}

func TestPaymentRowsRejectUnknownOrderAndDuplicateProviderTxn(t *testing.T) {
	d := newPaymentDriver(t)
	w := seed.Marketplace(t, d.pool, seed.Config{})
	ctx := context.Background()

	insert := func(orderID, provider, txn string) error {
		_, err := d.pool.Exec(ctx, `
			INSERT INTO billing.payments
			  (id, order_id, provider, provider_txn_id, mode, goods_amount, delivery_fee,
			   commission_amount, seller_amount, status, raw, created_at)
			VALUES ($1, $2, $3, $4, 'split', 10000, 0, 0, 10000, 'created', '{}', now())`,
			uuid.NewString(), orderID, provider, txn)
		return err
	}
	pgCode := func(err error) string {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			return pgErr.Code
		}
		return ""
	}

	// A reference to an order that does not exist is refused outright.
	if code := pgCode(insert(uuid.NewString(), "payme", "TXN-"+uuid.NewString())); code != "23503" {
		t.Errorf("unknown order reference: pg code = %q, want 23503 (fk violation)", code)
	}

	// The same provider transaction delivered twice keeps one row. This is the
	// dedup a PSP callback writer will inherit from the schema.
	orderA := seed.OrderRow(t, d.pool, w, "paid", 10_000, 0)
	orderB := seed.OrderRow(t, d.pool, w, "paid", 10_000, 0)
	txn := "TXN-" + uuid.NewString()
	if err := insert(orderA, "payme", txn); err != nil {
		t.Fatalf("first provider txn: %v", err)
	}
	if code := pgCode(insert(orderB, "payme", txn)); code != "23505" {
		t.Errorf("duplicate provider txn: pg code = %q, want 23505 (unique violation)", code)
	}
}

// The offline path: no PSP is involved, the buyer pays the bank directly and
// the order still closes, marked with the manual provider. This is the closest
// implemented equivalent of a cash sale — see docs/test-plan.md D5.
func TestManualReceiptPathClosesOrderWithoutProviderTxn(t *testing.T) {
	d := newPaymentDriver(t)
	w := seed.Marketplace(t, d.pool, seed.Config{})
	orderID := d.place(t, w, "2")
	d.mustStep(t, orderID,
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
		orders.TriggerStartPreparing, orders.TriggerMarkReady, orders.TriggerConfirmPickup)

	if got := d.status(t, orderID); got != string(orders.StatusClosed) {
		t.Fatalf("order status = %q, want closed", got)
	}

	var count int
	var provider, txnID, id string
	var receiptURL *string
	var paidAt *time.Time
	if err := d.pool.QueryRow(context.Background(),
		`SELECT count(*) OVER (), id::text, provider, provider_txn_id, receipt_url, paid_at
		   FROM billing.payments WHERE order_id = $1 AND status = 'paid'`,
		orderID).Scan(&count, &id, &provider, &txnID, &receiptURL, &paidAt); err != nil {
		t.Fatalf("read paid payment: %v", err)
	}
	if count != 1 {
		t.Errorf("paid payment rows = %d, want exactly 1", count)
	}
	if provider != "manual" {
		t.Errorf("payment provider = %q, want manual", provider)
	}
	if txnID != id {
		t.Errorf("provider txn id = %q, want the self-generated %q (no external PSP reference)", txnID, id)
	}
	if receiptURL == nil || *receiptURL == "" {
		t.Error("manual payment has no receipt_url; chk_payments_manual_receipt should have refused it")
	}
	if paidAt == nil {
		t.Error("paid payment has no paid_at")
	}
	if got := invoiceStatus(t, d.pool, orderID); got != "paid" {
		t.Errorf("invoice status = %q, want paid", got)
	}
}
