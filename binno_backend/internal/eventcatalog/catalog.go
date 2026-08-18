// Package eventcatalog is the closed, versioned taxonomy shared by domain
// publishers, the dispatcher and analytics read models.
package eventcatalog

import "fmt"

// Name is a stable domain.fact event identifier.
type Name string

// Reviewed event taxonomy.
const (
	OrderCreated                    Name = "order.created"
	OrderAccepted                   Name = "order.accepted"
	OrderDeclined                   Name = "order.declined"
	OrderExpired                    Name = "order.expired"
	OrderAwaitingPayment            Name = "order.awaiting_payment"
	OrderPaid                       Name = "order.paid"
	OrderPreparing                  Name = "order.preparing"
	OrderReady                      Name = "order.ready"
	OrderDelivered                  Name = "order.delivered"
	OrderClosed                     Name = "order.closed"
	OrderCancelled                  Name = "order.cancelled"
	OrderPickupConfirmed            Name = "order.pickup_confirmed"
	OrderSLAEscalated               Name = "order.sla_escalated"
	OrderConfirmationChaseRequested Name = "order.confirmation_chase_requested"
	PaymentReviewStarted            Name = "payment.review_started"
	OrderRefunded                   Name = "order.refunded"
	RefundRequested                 Name = "refund.requested"
	RefundBecameOverdue             Name = "refund.became_overdue"
	CatalogRequested                Name = "catalog.requested"
	CatalogRequestResolved          Name = "catalog.request_resolved"
	OfferCreated                    Name = "offer.created"
	OfferUpdated                    Name = "offer.updated"
	FeedbackCreated                 Name = "feedback.created"
	OperatorQueueItemResolved       Name = "operator.queue_item_resolved"
)

// Definition is the registry entry for one event.
type Definition struct {
	// Versions lists every wire version a consumer still understands, oldest first.
	Versions []int
	// Producer names the module that emits the event, or "" when the taxonomy entry
	// is reserved and no code publishes it yet.
	Producer string
	// Description is what a consumer author reads before subscribing.
	Description string
}

// Current returns the version producers emit today.
func (d Definition) Current() int {
	if len(d.Versions) == 0 {
		return 0
	}
	return d.Versions[len(d.Versions)-1]
}

// Supports reports whether version is still understood by consumers.
func (d Definition) Supports(version int) bool {
	for _, v := range d.Versions {
		if v == version {
			return true
		}
	}
	return false
}

// definitions is the registry.
func definitions() map[Name]Definition {
	return map[Name]Definition{
		OrderCreated:                    {Versions: []int{1}, Producer: "orders", Description: "A buyer placed an order; inventory is reserved and the supplier clock started."},
		OrderAccepted:                   {Versions: []int{1}, Producer: "orders", Description: "The supplier confirmed the order, in-app or by SMS token."},
		OrderDeclined:                   {Versions: []int{1}, Producer: "orders", Description: "The supplier declined; the buyer is offered alternatives."},
		OrderExpired:                    {Versions: []int{1}, Producer: "orders", Description: "The supplier confirmation window elapsed with no decision."},
		OrderCancelled:                  {Versions: []int{1}, Producer: "orders", Description: "The order was cancelled by the buyer or an operator; reservations are released."},
		OrderPickupConfirmed:            {Versions: []int{1}, Producer: "orders", Description: "The buyer confirmed collection with a code or signature."},
		OrderSLAEscalated:               {Versions: []int{1}, Producer: "orders", Description: "An order breached its confirmation SLA and needs operator attention."},
		OrderConfirmationChaseRequested: {Versions: []int{1}, Description: "Reserved: chase the supplier before the window closes. No producer; the pre-deadline chase is a product decision the SLA sweeper does not make."},
		CatalogRequested:                {Versions: []int{1}, Producer: "catalog", Description: "A seller asked for a product that is not in the platform catalogue."},
		CatalogRequestResolved:          {Versions: []int{1}, Producer: "catalog", Description: "An operator added or rejected a catalogue request."},
		OfferCreated:                    {Versions: []int{1}, Producer: "catalog", Description: "A seller published a new offer."},
		OfferUpdated:                    {Versions: []int{1}, Producer: "catalog", Description: "A seller changed an offer's price or declared quantity."},
		FeedbackCreated:                 {Versions: []int{1}, Producer: "trust", Description: "A buyer left binary feedback on a closed order."},
		OperatorQueueItemResolved:       {Versions: []int{1}, Producer: "operator", Description: "An operator resolved a queue item."},

		OrderAwaitingPayment: {Versions: []int{1}, Producer: "orders", Description: "An invoice was issued and the buyer owes payment."},
		PaymentReviewStarted: {Versions: []int{1}, Producer: "orders", Description: "The buyer submitted a payment receipt; the seller must verify it."},
		OrderPaid:            {Versions: []int{1}, Producer: "orders", Description: "Payment was confirmed against the seller's account, or settled by a PSP."},
		OrderPreparing:       {Versions: []int{1}, Producer: "orders", Description: "The supplier started preparing the goods."},
		OrderReady:           {Versions: []int{1}, Producer: "orders", Description: "The goods are ready for handover."},
		OrderDelivered:       {Versions: []int{1}, Producer: "orders", Description: "The goods were delivered to the buyer's drop-off address."},
		OrderClosed:          {Versions: []int{1}, Producer: "orders", Description: "The order settled and closed; commission accrued to the owner's ledger."},

		RefundRequested:     {Versions: []int{1}, Producer: "orders", Description: "An operator opened a refund on a paid order; the seller owes the money back."},
		RefundBecameOverdue: {Versions: []int{1}, Producer: "billing", Description: "A refund passed its due date without settlement evidence; operators chase it."},
		OrderRefunded:       {Versions: []int{1}, Producer: "orders", Description: "The buyer confirmed the refund arrived; the order is settled by return."},
	}
}

// Lookup returns the registry entry for name.
func Lookup(name Name) (Definition, bool) {
	definition, ok := definitions()[name]
	return definition, ok
}

// All returns every registered event name with its definition.
func All() map[Name]Definition {
	registry := definitions()
	out := make(map[Name]Definition, len(registry))
	for name, definition := range registry {
		out[name] = definition
	}
	return out
}

// Valid reports whether name belongs to the reviewed event taxonomy.
func Valid(name string) bool {
	_, ok := definitions()[Name(name)]
	return ok
}

// ValidVersion reports whether a consumer contract exists for eventName at
// version.
func ValidVersion(eventName string, version int) bool {
	definition, ok := definitions()[Name(eventName)]
	return ok && definition.Supports(version)
}

// CurrentVersion returns the version producers should emit for name.
func CurrentVersion(name Name) int {
	definition, ok := definitions()[name]
	if !ok {
		panic(fmt.Sprintf("eventcatalog: %q is not registered", name))
	}
	return definition.Current()
}
