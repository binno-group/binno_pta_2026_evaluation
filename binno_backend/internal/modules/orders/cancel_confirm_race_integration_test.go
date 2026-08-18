//go:build integration

package orders_test

import (
	"context"
	"errors"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// A seller confirming the payment and an operator cancelling the order can
// arrive in the same instant. The row lock taken by the transition serialises
// them: exactly one commits, the other gets a clean domain conflict, and the
// billing rows always match whichever verdict won.
func TestPaymentConfirmationRacingCancellationHasOneWinner(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{})

	orderID := placeOrder(t, s, w, w.ProductID, "1")
	mustWalk(t, s, orderID, walkTo[orders.StatusPaymentReview])

	start := make(chan struct{})
	confirmErr := make(chan error, 1)
	cancelErr := make(chan error, 1)
	go func() {
		<-start
		confirmErr <- applyTrigger(s, orderID, orders.TriggerConfirmPayment)
	}()
	go func() {
		<-start
		cancelErr <- applyTrigger(s, orderID, orders.TriggerOperatorCancel)
	}()
	close(start)
	confirm, cancel := <-confirmErr, <-cancelErr

	switch {
	case confirm == nil && cancel == nil:
		t.Fatal("both the confirmation and the cancellation claim to have won")
	case confirm != nil && cancel != nil:
		t.Fatalf("nobody won: confirm = %v, cancel = %v", confirm, cancel)
	case confirm == nil:
		if !errors.Is(cancel, orders.ErrConflict) {
			t.Errorf("losing cancellation: err = %v, want ErrConflict", cancel)
		}
		if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusPaid) {
			t.Errorf("order status = %q, want paid", got)
		}
		assertBillingState(t, s, orderID, "paid", "paid")
	default:
		if !errors.Is(confirm, orders.ErrConflict) {
			t.Errorf("losing confirmation: err = %v, want ErrConflict", confirm)
		}
		if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusCancelledByOperator) {
			t.Errorf("order status = %q, want cancelled_by_operator", got)
		}
		assertBillingState(t, s, orderID, "failed", "voided")
	}
}

func assertBillingState(t *testing.T, s *stack, orderID, wantPayment, wantInvoice string) {
	t.Helper()
	ctx := context.Background()
	var payment, invoice string
	if err := s.pool.QueryRow(ctx,
		`SELECT status FROM billing.payments WHERE order_id = $1
		 ORDER BY created_at DESC LIMIT 1`, orderID).Scan(&payment); err != nil {
		t.Fatalf("read payment status: %v", err)
	}
	if err := s.pool.QueryRow(ctx,
		`SELECT status FROM billing.invoices WHERE order_id = $1
		 ORDER BY version DESC LIMIT 1`, orderID).Scan(&invoice); err != nil {
		t.Fatalf("read invoice status: %v", err)
	}
	if payment != wantPayment {
		t.Errorf("payment status = %q, want %q", payment, wantPayment)
	}
	if invoice != wantInvoice {
		t.Errorf("invoice status = %q, want %q", invoice, wantInvoice)
	}
}
