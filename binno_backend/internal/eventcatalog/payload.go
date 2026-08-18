package eventcatalog

import "time"

// Payload is the typed body of a domain event.
type Payload interface {
	// EventName returns the registered name this payload is published under.
	EventName() Name
}

// OrderCreated ------------------------------------------------------------

// OrderCreatedPayload is published once inventory is reserved and the supplier
// confirmation clock has started.
type OrderCreatedPayload struct {
	StoreID     string    `json:"store_id"`
	BuyerID     string    `json:"buyer_id"`
	GoodsAmount int64     `json:"goods_amount"`
	DeliveryFee int64     `json:"delivery_fee"`
	TotalAmount int64     `json:"total_amount"`
	ItemCount   int       `json:"item_count"`
	Urgent      bool      `json:"urgent"`
	DueAt       time.Time `json:"due_at"`
}

// EventName implements Payload.
func (OrderCreatedPayload) EventName() Name { return OrderCreated }

// Order status changes ----------------------------------------------------

// OrderStatusChangedPayload carries a single state-machine transition.
type OrderStatusChangedPayload struct {
	StoreID    string `json:"store_id"`
	BuyerID    string `json:"buyer_id"`
	FromStatus string `json:"from_status"`
	ToStatus   string `json:"to_status"`
	Actor      string `json:"actor"`
	Source     string `json:"source"`
	// Reason is set for cancellations and declines, empty otherwise.
	Reason string `json:"reason,omitempty"`

	// name is the specific lifecycle event this transition publishes.
	name Name
}

// EventName implements Payload.
func (p OrderStatusChangedPayload) EventName() Name { return p.name }

// NewOrderStatusChanged binds a transition payload to the lifecycle event it is
// published under.
func NewOrderStatusChanged(name Name, payload OrderStatusChangedPayload) OrderStatusChangedPayload {
	payload.name = name
	return payload
}

// OrderSLAEscalatedPayload feeds the operator queue.
type OrderSLAEscalatedPayload struct {
	StoreID string    `json:"store_id"`
	BuyerID string    `json:"buyer_id"`
	Reason  string    `json:"reason"`
	DueAt   time.Time `json:"due_at"`
}

// EventName implements Payload.
func (OrderSLAEscalatedPayload) EventName() Name { return OrderSLAEscalated }

// OrderConfirmationChasePayload asks an operator to chase a supplier before the
// confirmation window closes.
type OrderConfirmationChasePayload struct {
	StoreID string    `json:"store_id"`
	BuyerID string    `json:"buyer_id"`
	DueAt   time.Time `json:"due_at"`
}

// EventName implements Payload.
func (OrderConfirmationChasePayload) EventName() Name {
	return OrderConfirmationChaseRequested
}

// Catalog -----------------------------------------------------------------

// CatalogRequestedPayload is published when a seller asks for a missing product.
type CatalogRequestedPayload struct {
	StoreID string    `json:"store_id"`
	Name    string    `json:"name"`
	Unit    string    `json:"unit"`
	DueAt   time.Time `json:"due_at"`
}

// EventName implements Payload.
func (CatalogRequestedPayload) EventName() Name { return CatalogRequested }

// CatalogRequestResolvedPayload records an operator's decision on a request.
type CatalogRequestResolvedPayload struct {
	StoreID      string `json:"store_id"`
	Status       string `json:"status"`
	ProductID    string `json:"product_id,omitempty"`
	RejectReason string `json:"reject_reason,omitempty"`
}

// EventName implements Payload.
func (CatalogRequestResolvedPayload) EventName() Name { return CatalogRequestResolved }

// OfferCreatedPayload announces a newly published offer.
type OfferCreatedPayload struct {
	StoreID     string `json:"store_id"`
	ProductID   string `json:"product_id"`
	Price       int64  `json:"price"`
	DeclaredQty string `json:"declared_qty"`
}

// EventName implements Payload.
func (OfferCreatedPayload) EventName() Name { return OfferCreated }

// OfferUpdatedPayload announces a price, stock or visibility change. Status
// was added additively within v1: consumers written before it treat the field
// as absent.
type OfferUpdatedPayload struct {
	StoreID     string `json:"store_id"`
	ProductID   string `json:"product_id"`
	Price       int64  `json:"price"`
	DeclaredQty string `json:"declared_qty"`
	Status      string `json:"status,omitempty"`
}

// EventName implements Payload.
func (OfferUpdatedPayload) EventName() Name { return OfferUpdated }

// Trust -------------------------------------------------------------------

// FeedbackCreatedPayload records binary feedback on a closed order.
type FeedbackCreatedPayload struct {
	StoreID    string   `json:"store_id"`
	BuyerID    string   `json:"buyer_id"`
	HadProblem bool     `json:"had_problem"`
	Tags       []string `json:"tags"`
	Channel    string   `json:"channel"`
}

// EventName implements Payload.
func (FeedbackCreatedPayload) EventName() Name { return FeedbackCreated }

// Billing -----------------------------------------------------------------

// RefundBecameOverduePayload opens a refund_overdue operator queue item.
type RefundBecameOverduePayload struct {
	OrderID string    `json:"order_id"`
	Amount  int64     `json:"amount"`
	DueAt   time.Time `json:"due_at"`
}

// EventName implements Payload.
func (RefundBecameOverduePayload) EventName() Name { return RefundBecameOverdue }
