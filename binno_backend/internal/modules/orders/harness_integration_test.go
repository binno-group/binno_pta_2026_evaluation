//go:build integration

package orders_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"

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

// stack wires the real module graph — catalog reservations, the location sale
// gate and billing settlement — over the test database, exactly as
// api.Module does in production, minus HTTP and SMS.
type stack struct {
	pool *postgres.Pool
	repo *orders.Repository
}

func newStack(t *testing.T) *stack {
	t.Helper()
	return newStackOn(t, pgtest.Pool(t))
}

func newStackOn(t *testing.T, pool *postgres.Pool) *stack {
	t.Helper()
	clk := clock.New()
	loc := location.New(pool)
	cat := catalog.New(pool, loc.Guard(), clk)
	repo := orders.NewRepository(pool, cat.OrderLines(), loc.SaleGate(), billing.NewSettlementPort(), nil, clk)
	return &stack{pool: pool, repo: repo}
}

// opCtx returns a context carrying a fresh operation key, the way the
// idempotency middleware does for each HTTP mutation.
func opCtx() context.Context {
	return httpx.WithOperationKey(context.Background(), uuid.NewString())
}

// placeOrder reserves stock and creates an order for qty units of productID.
func placeOrder(t *testing.T, s *stack, w seed.World, productID, qty string) string {
	t.Helper()
	created, err := s.repo.Create(opCtx(), orders.CreateCommand{
		CreateInput: orders.CreateInput{
			StoreID:     w.StoreID,
			BuyerType:   "individual",
			Fulfillment: "pickup",
			Items:       []orders.ItemInput{{ProductID: productID, Qty: qty}},
		},
		BuyerID: w.BuyerUserID,
		At:      time.Now().UTC(),
	})
	if err != nil {
		t.Fatalf("place order: %v", err)
	}
	return created.OrderID
}

// applyTrigger runs one transition with the payload its edge requires.
func applyTrigger(s *stack, orderID string, trigger orders.Trigger) error {
	cmd := orders.TransitionCommand{OrderID: orderID, Trigger: trigger, At: time.Now().UTC()}
	switch trigger {
	case orders.TriggerSubmitReceipt:
		cmd.ReceiptURL = "https://storage.example/receipts/transfer.pdf"
	case orders.TriggerRejectPayment, orders.TriggerRefundRequest,
		orders.TriggerBuyerCancel, orders.TriggerOperatorCancel:
		cmd.Reason = "suite"
	case orders.TriggerConfirmPickup:
		cmd.PickupCode = "0000"
	}
	return s.repo.Apply(opCtx(), cmd)
}

// walkTo drives a freshly created order along real transitions to a resting
// state. States the machine only passes through (accepted, delivered,
// picked_up_by_buyer) are not listed; tests teleport into those.
var walkTo = map[orders.Status][]orders.Trigger{
	orders.StatusCreated:              {},
	orders.StatusBuyerDecisionPending: {orders.TriggerSupplierDecline},
	orders.StatusAwaitingPayment:      {orders.TriggerSupplierConfirm},
	orders.StatusPaymentReview:        {orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt},
	orders.StatusPaid: {
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
	},
	orders.StatusPreparing: {
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
		orders.TriggerStartPreparing,
	},
	orders.StatusReady: {
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
		orders.TriggerStartPreparing, orders.TriggerMarkReady,
	},
	orders.StatusRefundRequested: {
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
		orders.TriggerRefundRequest,
	},
	orders.StatusRefundOverdue: {
		orders.TriggerSupplierConfirm, orders.TriggerSubmitReceipt, orders.TriggerConfirmPayment,
		orders.TriggerRefundRequest, orders.TriggerRefundOverdue,
	},
}

func mustWalk(t *testing.T, s *stack, orderID string, path []orders.Trigger) {
	t.Helper()
	for _, step := range path {
		if err := applyTrigger(s, orderID, step); err != nil {
			t.Fatalf("walk step %s: %v", step, err)
		}
	}
}

// teleport moves an order into a state the machine never rests in, keeping its
// items and reservation intact so the transition under test sees a real order.
func teleport(t *testing.T, s *stack, orderID, status string) {
	t.Helper()
	if _, err := s.pool.Exec(context.Background(),
		`UPDATE orders.orders SET status = $1 WHERE id = $2`, status, orderID); err != nil {
		t.Fatalf("teleport to %s: %v", status, err)
	}
}

func orderStatus(t *testing.T, pool *postgres.Pool, orderID string) string {
	t.Helper()
	var status string
	if err := pool.QueryRow(context.Background(),
		`SELECT status FROM orders.orders WHERE id = $1`, orderID).Scan(&status); err != nil {
		t.Fatalf("read order status: %v", err)
	}
	return status
}
