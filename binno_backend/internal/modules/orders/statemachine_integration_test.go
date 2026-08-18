//go:build integration

package orders_test

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// The lifecycle's unit tests prove the transition table is self-consistent;
// these prove the table is what actually happens in the database: the status
// row moves, the audit event lands, the domain event is queued, and stock
// follows the edge's declaration — all in one transaction.

// permittedCase is one legal (trigger, from) edge and the resting state the
// order must land in, including any follow-on the edge declares.
type permittedCase struct {
	trigger orders.Trigger
	from    orders.Status
	want    orders.Status
	// teleport marks from-states the machine passes through without resting;
	// the order is moved there directly, reservation intact.
	teleport bool
}

func permittedCases() []permittedCase {
	return []permittedCase{
		{trigger: orders.TriggerSupplierConfirm, from: orders.StatusCreated, want: orders.StatusAwaitingPayment},
		{trigger: orders.TriggerTokenConfirm, from: orders.StatusCreated, want: orders.StatusAwaitingPayment},
		{trigger: orders.TriggerSupplierDecline, from: orders.StatusCreated, want: orders.StatusBuyerDecisionPending},

		{trigger: orders.TriggerBuyerCancel, from: orders.StatusCreated, want: orders.StatusCancelledByBuyerSLA},
		{trigger: orders.TriggerBuyerCancel, from: orders.StatusBuyerDecisionPending, want: orders.StatusCancelledByBuyerSLA},
		{trigger: orders.TriggerBuyerCancel, from: orders.StatusAwaitingPayment, want: orders.StatusCancelledByBuyerSLA},

		{trigger: orders.TriggerOperatorCancel, from: orders.StatusCreated, want: orders.StatusCancelledByOperator},
		{trigger: orders.TriggerOperatorCancel, from: orders.StatusBuyerDecisionPending, want: orders.StatusCancelledByOperator},
		{trigger: orders.TriggerOperatorCancel, from: orders.StatusAwaitingPayment, want: orders.StatusCancelledByOperator},
		{trigger: orders.TriggerOperatorCancel, from: orders.StatusPaymentReview, want: orders.StatusCancelledByOperator},

		{trigger: orders.TriggerIssueInvoice, from: orders.StatusAccepted, want: orders.StatusAwaitingPayment, teleport: true},
		{trigger: orders.TriggerSubmitReceipt, from: orders.StatusAwaitingPayment, want: orders.StatusPaymentReview},
		{trigger: orders.TriggerConfirmPayment, from: orders.StatusPaymentReview, want: orders.StatusPaid},
		{trigger: orders.TriggerRejectPayment, from: orders.StatusPaymentReview, want: orders.StatusAwaitingPayment},

		{trigger: orders.TriggerStartPreparing, from: orders.StatusPaid, want: orders.StatusPreparing},
		{trigger: orders.TriggerMarkReady, from: orders.StatusPreparing, want: orders.StatusReady},

		{trigger: orders.TriggerConfirmPickup, from: orders.StatusReady, want: orders.StatusClosed},
		{trigger: orders.TriggerConfirmPickup, from: orders.StatusPaid, want: orders.StatusClosed},
		{trigger: orders.TriggerConfirmDelivery, from: orders.StatusReady, want: orders.StatusClosed},
		{trigger: orders.TriggerConfirmDelivery, from: orders.StatusPaid, want: orders.StatusClosed},
		{trigger: orders.TriggerCloseOrder, from: orders.StatusPickedUpByBuyer, want: orders.StatusClosed, teleport: true},
		{trigger: orders.TriggerCloseOrder, from: orders.StatusDelivered, want: orders.StatusClosed, teleport: true},

		{trigger: orders.TriggerExpire, from: orders.StatusCreated, want: orders.StatusExpired},
		{trigger: orders.TriggerPaymentExpire, from: orders.StatusAwaitingPayment, want: orders.StatusExpired},

		{trigger: orders.TriggerRefundRequest, from: orders.StatusPaid, want: orders.StatusRefundRequested},
		{trigger: orders.TriggerRefundRequest, from: orders.StatusPreparing, want: orders.StatusRefundRequested},
		{trigger: orders.TriggerRefundRequest, from: orders.StatusReady, want: orders.StatusRefundRequested},
		{trigger: orders.TriggerRefundOverdue, from: orders.StatusRefundRequested, want: orders.StatusRefundOverdue},
		{trigger: orders.TriggerConfirmRefund, from: orders.StatusRefundRequested, want: orders.StatusRefunded},
		{trigger: orders.TriggerConfirmRefund, from: orders.StatusRefundOverdue, want: orders.StatusRefunded},
	}
}

func TestEveryPermittedTransitionLands(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{})
	ctx := context.Background()

	// The declared transition table drives the assertions, so a new edge fails
	// this test until it gets a case above.
	covered := map[string]bool{}
	for _, tc := range permittedCases() {
		covered[string(tc.trigger)+"|"+string(tc.from)] = true
	}
	for _, trigger := range orders.Triggers() {
		transition, _ := orders.TransitionFor(trigger)
		for _, from := range transition.From {
			if !covered[string(trigger)+"|"+string(from)] {
				t.Fatalf("edge %s from %s is permitted by the table but has no case", trigger, from)
			}
		}
	}

	for _, tc := range permittedCases() {
		t.Run(fmt.Sprintf("%s_from_%s", tc.trigger, tc.from), func(t *testing.T) {
			productID, offerID := seed.NewOffer(t, s.pool, w, 10_000, "100")
			orderID := placeOrder(t, s, w, productID, "2")

			if tc.teleport {
				teleport(t, s, orderID, string(tc.from))
			} else {
				mustWalk(t, s, orderID, walkTo[tc.from])
			}

			if err := applyTrigger(s, orderID, tc.trigger); err != nil {
				t.Fatalf("apply %s from %s: %v", tc.trigger, tc.from, err)
			}

			if got := orderStatus(t, s.pool, orderID); got != string(tc.want) {
				t.Errorf("status = %q, want %q", got, tc.want)
			}

			transition, _ := orders.TransitionFor(tc.trigger)
			var audited bool
			if err := s.pool.QueryRow(ctx,
				`SELECT EXISTS (SELECT 1 FROM orders.order_events
				  WHERE order_id = $1 AND from_status = $2 AND to_status = $3
				    AND actor = $4 AND source = $5)`,
				orderID, string(tc.from), string(transition.To),
				string(transition.Actor), string(transition.Source)).Scan(&audited); err != nil {
				t.Fatalf("read order_events: %v", err)
			}
			if !audited {
				t.Errorf("no order_events row for %s -> %s by %s/%s",
					tc.from, transition.To, transition.Actor, transition.Source)
			}

			if transition.Event != "" {
				var queued bool
				if err := s.pool.QueryRow(ctx,
					`SELECT EXISTS (SELECT 1 FROM platform.outbox
					  WHERE aggregate_id = $1 AND event_name = $2)`,
					orderID, string(transition.Event)).Scan(&queued); err != nil {
					t.Fatalf("read outbox: %v", err)
				}
				if !queued {
					t.Errorf("domain event %s not queued in the outbox", transition.Event)
				}
			}

			declared, reserved := seed.Offer(t, s.pool, offerID)
			switch {
			case transition.ConsumesStock:
				if declared != "98" || reserved != "0" {
					t.Errorf("consumed sale: declared/reserved = %s/%s, want 98/0", declared, reserved)
				}
			case transition.ReleasesStock:
				if reserved != "0" {
					t.Errorf("released order still holds stock: reserved = %s, want 0", reserved)
				}
				if declared != "100" {
					t.Errorf("release changed declared stock: %s, want 100", declared)
				}
			}
		})
	}
}

func TestEveryForbiddenTransitionIsRejected(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{})
	ctx := context.Background()

	for _, trigger := range orders.Triggers() {
		transition, _ := orders.TransitionFor(trigger)
		for _, from := range orders.AllStatuses() {
			if transition.Permits(from) {
				continue
			}
			t.Run(fmt.Sprintf("%s_from_%s", trigger, from), func(t *testing.T) {
				orderID := seed.OrderRow(t, s.pool, w, string(from), 10_000, 0)

				err := applyTrigger(s, orderID, trigger)
				if !errors.Is(err, orders.ErrConflict) {
					t.Fatalf("apply %s from %s: err = %v, want ErrConflict", trigger, from, err)
				}

				if got := orderStatus(t, s.pool, orderID); got != string(from) {
					t.Errorf("rejected transition moved the order: %q -> %q", from, got)
				}
				var events int
				if err := s.pool.QueryRow(ctx,
					`SELECT count(*) FROM orders.order_events WHERE order_id = $1`,
					orderID).Scan(&events); err != nil {
					t.Fatalf("count order_events: %v", err)
				}
				if events != 0 {
					t.Errorf("rejected transition wrote %d audit events, want 0", events)
				}
			})
		}
	}
}

// Closing a sale bills the owner at the category rate snapshotted on the order
// lines: 250 bps is exactly 2.5% of the goods amount, and the allowance zeroes
// what a young account owes.
func TestCloseAccruesDefaultCategoryRate(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{})

	orderID := placeOrder(t, s, w, w.ProductID, "2") // 2 x 10 000 = 20 000 goods
	mustWalk(t, s, orderID, walkTo[orders.StatusReady])
	if err := applyTrigger(s, orderID, orders.TriggerConfirmDelivery); err != nil {
		t.Fatalf("close via delivery: %v", err)
	}

	var base, accrued, discount, payable int64
	var rate int32
	if err := s.pool.QueryRow(context.Background(),
		`SELECT base_amount, rate_bps, accrued, discount, payable
		   FROM billing.commission_ledger WHERE order_id = $1`,
		orderID).Scan(&base, &rate, &accrued, &discount, &payable); err != nil {
		t.Fatalf("read ledger: %v", err)
	}
	if base != 20_000 || rate != 250 || accrued != 500 {
		t.Errorf("ledger base/rate/accrued = %d/%d/%d, want 20000/250/500 (2.5%% of goods)",
			base, rate, accrued)
	}
	// This is the owner's first completed order, so the allowance covers it in
	// full — see docs/test-plan.md D4: the allowance applies to every owner's
	// first ten orders, not only the founding cohort.
	if discount != 500 || payable != 0 {
		t.Errorf("ledger discount/payable = %d/%d, want 500/0 under the allowance", discount, payable)
	}
}
