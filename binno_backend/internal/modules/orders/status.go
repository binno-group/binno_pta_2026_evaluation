package orders

import (
	"slices"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
)

// Status is an order lifecycle state.
type Status string

// Order lifecycle states, in the canonical order used by chk_orders_status.
const (
	StatusCreated              Status = "created"
	StatusDeclined             Status = "declined"
	StatusExpired              Status = "expired"
	StatusBuyerDecisionPending Status = "buyer_decision_pending"
	StatusAccepted             Status = "accepted"
	StatusAwaitingPayment      Status = "awaiting_payment"
	StatusPaid                 Status = "paid"
	StatusPaymentReview        Status = "payment_review"
	StatusPreparing            Status = "preparing"
	StatusReady                Status = "ready"
	StatusDelivered            Status = "delivered"
	StatusPickedUpByBuyer      Status = "picked_up_by_buyer"
	StatusClosed               Status = "closed"
	StatusCancelledByBuyerSLA  Status = "cancelled_by_buyer_sla"
	StatusCancelledByOperator  Status = "cancelled_by_operator"
	StatusRefundRequested      Status = "refund_requested"
	StatusRefunded             Status = "refunded"
	StatusRefundOverdue        Status = "refund_overdue"
)

// AllStatuses returns every declared status in the order the SQL CHECK lists
// them.
func AllStatuses() []Status {
	return []Status{
		StatusCreated, StatusDeclined, StatusExpired,
		StatusBuyerDecisionPending, StatusAccepted, StatusAwaitingPayment, StatusPaid,
		StatusPaymentReview, StatusPreparing, StatusReady, StatusDelivered,
		StatusPickedUpByBuyer, StatusClosed,
		StatusCancelledByBuyerSLA, StatusCancelledByOperator,
		StatusRefundRequested, StatusRefunded, StatusRefundOverdue,
	}
}

// Actor is who caused a transition.
type Actor string

// Transition actors.
const (
	ActorBuyer    Actor = "buyer"
	ActorSeller   Actor = "seller"
	ActorOperator Actor = "operator"
	ActorSystem   Actor = "system"
)

// Source is the channel a transition arrived through.
type Source string

// Transition sources.
const (
	SourceApp       Source = "app"
	SourceSMSToken  Source = "sms_token"
	SourcePhoneCall Source = "phone_call"
	SourceWebhook   Source = "webhook"
	SourceCron      Source = "cron"
)

// Trigger names one legal way to move an order.
type Trigger string

// Triggers currently implemented.
const (
	TriggerSupplierConfirm Trigger = "supplier_confirm"
	TriggerTokenConfirm    Trigger = "token_confirm"
	TriggerSupplierDecline Trigger = "supplier_decline"
	TriggerBuyerCancel     Trigger = "buyer_cancel"
	TriggerOperatorCancel  Trigger = "operator_cancel"
	TriggerExpire          Trigger = "expire"

	// Settlement.
	TriggerIssueInvoice   Trigger = "issue_invoice"
	TriggerSubmitReceipt  Trigger = "submit_receipt"
	TriggerConfirmPayment Trigger = "confirm_payment"
	TriggerRejectPayment  Trigger = "reject_payment"

	// Fulfilment.
	TriggerStartPreparing  Trigger = "start_preparing"
	TriggerMarkReady       Trigger = "mark_ready"
	TriggerConfirmPickup   Trigger = "confirm_pickup"
	TriggerConfirmDelivery Trigger = "confirm_delivery"
	TriggerCloseOrder      Trigger = "close_order"

	// Payment SLA.
	TriggerPaymentExpire Trigger = "payment_expire"

	// Refunds.
	TriggerRefundRequest Trigger = "refund_request"
	TriggerRefundOverdue Trigger = "refund_overdue"
	TriggerConfirmRefund Trigger = "confirm_refund"
)

// Transition is one edge of the state machine.
type Transition struct {
	// From is the set of states the trigger may be applied to.
	From []Status
	// To is the resulting state.
	To Status
	// Actor and Source are recorded on the order_events row.
	Actor  Actor
	Source Source
	// Event is the domain event published on success.
	Event eventcatalog.Name
	// Then is a transition the machine applies immediately after this one, in the
	// same transaction, with no actor between them.
	Then Trigger
	// ReleasesStock reports whether reaching To must return the order's reserved
	// quantities to the catalogue.
	ReleasesStock bool
	// ConsumesStock reports whether reaching To must deduct the order's
	// quantities from the catalogue for good: the sale happened, the goods left
	// the shelf.
	ConsumesStock bool
}

// TransitionFor returns the edge for trigger.
func TransitionFor(trigger Trigger) (Transition, bool) {
	transition, ok := transitionTable()[trigger]
	return transition, ok
}

// transitionTable is the state machine.
func transitionTable() map[Trigger]Transition {
	return map[Trigger]Transition{
		TriggerSupplierConfirm: {
			From:   []Status{StatusCreated},
			To:     StatusAccepted,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderAccepted,
			Then:   TriggerIssueInvoice,
		},
		TriggerTokenConfirm: {
			From:   []Status{StatusCreated},
			To:     StatusAccepted,
			Actor:  ActorSeller,
			Source: SourceSMSToken,
			Event:  eventcatalog.OrderAccepted,
			Then:   TriggerIssueInvoice,
		},
		TriggerSupplierDecline: {
			From:          []Status{StatusCreated},
			To:            StatusBuyerDecisionPending,
			Actor:         ActorSeller,
			Source:        SourceApp,
			Event:         eventcatalog.OrderDeclined,
			ReleasesStock: true,
		},
		// accepted is a pass-through state (confirmation issues the invoice in
		// the same transaction), so no committed order rests in it: cancels
		// depart from awaiting_payment, the state acceptance actually lands in.
		TriggerBuyerCancel: {
			From: []Status{
				StatusCreated,
				StatusBuyerDecisionPending, StatusAwaitingPayment,
			},
			To:            StatusCancelledByBuyerSLA,
			Actor:         ActorBuyer,
			Source:        SourceApp,
			Event:         eventcatalog.OrderCancelled,
			ReleasesStock: true,
		},
		TriggerOperatorCancel: {
			From: []Status{
				StatusCreated, StatusBuyerDecisionPending,
				StatusAwaitingPayment, StatusPaymentReview,
			},
			To:            StatusCancelledByOperator,
			Actor:         ActorOperator,
			Source:        SourceApp,
			Event:         eventcatalog.OrderCancelled,
			ReleasesStock: true,
		},
		TriggerIssueInvoice: {
			From:   []Status{StatusAccepted},
			To:     StatusAwaitingPayment,
			Actor:  ActorSystem,
			Source: SourceApp,
			Event:  eventcatalog.OrderAwaitingPayment,
		},
		TriggerSubmitReceipt: {
			From:   []Status{StatusAwaitingPayment},
			To:     StatusPaymentReview,
			Actor:  ActorBuyer,
			Source: SourceApp,
			Event:  eventcatalog.PaymentReviewStarted,
		},
		TriggerConfirmPayment: {
			From:   []Status{StatusPaymentReview},
			To:     StatusPaid,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderPaid,
		},
		TriggerRejectPayment: {
			From:   []Status{StatusPaymentReview},
			To:     StatusAwaitingPayment,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderAwaitingPayment,
		},

		TriggerStartPreparing: {
			From:   []Status{StatusPaid},
			To:     StatusPreparing,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderPreparing,
		},
		TriggerMarkReady: {
			From:   []Status{StatusPreparing},
			To:     StatusReady,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderReady,
		},
		TriggerConfirmPickup: {
			From:   []Status{StatusReady, StatusPaid},
			To:     StatusPickedUpByBuyer,
			Actor:  ActorBuyer,
			Source: SourceApp,
			Event:  eventcatalog.OrderPickupConfirmed,
			Then:   TriggerCloseOrder,
		},
		TriggerConfirmDelivery: {
			From:   []Status{StatusReady, StatusPaid},
			To:     StatusDelivered,
			Actor:  ActorSeller,
			Source: SourceApp,
			Event:  eventcatalog.OrderDelivered,
			Then:   TriggerCloseOrder,
		},
		TriggerCloseOrder: {
			From:          []Status{StatusPickedUpByBuyer, StatusDelivered},
			To:            StatusClosed,
			Actor:         ActorSystem,
			Source:        SourceApp,
			Event:         eventcatalog.OrderClosed,
			ConsumesStock: true,
		},
		TriggerExpire: {
			From:          []Status{StatusCreated},
			To:            StatusExpired,
			Actor:         ActorSystem,
			Source:        SourceCron,
			Event:         eventcatalog.OrderExpired,
			ReleasesStock: true,
		},
		TriggerPaymentExpire: {
			From:          []Status{StatusAwaitingPayment},
			To:            StatusExpired,
			Actor:         ActorSystem,
			Source:        SourceCron,
			Event:         eventcatalog.OrderExpired,
			ReleasesStock: true,
		},

		TriggerRefundRequest: {
			// delivered and picked_up_by_buyer are pass-through states (their
			// producers close the order in the same transaction), so a refund
			// can only be opened before the handover is confirmed. Post-close
			// disputes are an operator process outside the state machine; a
			// closed -> refund edge would also need a commission reversal.
			From:          []Status{StatusPaid, StatusPreparing, StatusReady},
			To:            StatusRefundRequested,
			Actor:         ActorOperator,
			Source:        SourceApp,
			Event:         eventcatalog.RefundRequested,
			ReleasesStock: true,
		},
		TriggerRefundOverdue: {
			// billing publishes refund.became_overdue in the same sweep; the
			// order-side edge only moves the status, so Event stays empty.
			From:   []Status{StatusRefundRequested},
			To:     StatusRefundOverdue,
			Actor:  ActorSystem,
			Source: SourceCron,
		},
		TriggerConfirmRefund: {
			From:   []Status{StatusRefundRequested, StatusRefundOverdue},
			To:     StatusRefunded,
			Actor:  ActorBuyer,
			Source: SourceApp,
			Event:  eventcatalog.OrderRefunded,
		},
	}
}

// Triggers returns every implemented trigger.
func Triggers() []Trigger {
	table := transitionTable()
	out := make([]Trigger, 0, len(table))
	for trigger := range table {
		out = append(out, trigger)
	}
	slices.Sort(out)
	return out
}

// Permits reports whether the transition may be applied to from.
func (t Transition) Permits(from Status) bool {
	return slices.Contains(t.From, from)
}
