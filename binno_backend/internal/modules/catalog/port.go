package catalog

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
)

// OrderLinePort is the pricing and stock-reservation surface catalog publishes
// to the order module.
type OrderLinePort interface {
	// ReserveOrderLines prices the requested lines and reserves their stock inside
	// tx.
	ReserveOrderLines(ctx context.Context, tx pgx.Tx, request ReserveRequest) (Quote, error)
	// ReleaseOrderLines returns previously reserved stock inside tx.
	ReleaseOrderLines(ctx context.Context, tx pgx.Tx, request ReleaseRequest) error
	// ConsumeOrderLines deducts a closed order's quantities from both declared
	// and reserved stock inside tx: the goods left the shelf for good.
	ConsumeOrderLines(ctx context.Context, tx pgx.Tx, request ReleaseRequest) error
	// ListAlternatives returns cheaper published offers for the given products from
	// a different store, newest keyset page first.
	ListAlternatives(ctx context.Context, request AlternativesRequest) (AlternativePage, error)
}

// Port errors.
var (
	// ErrOfferUnavailable reports a line whose offer is missing, unpublished or
	// short of free stock.
	ErrOfferUnavailable = errors.New("catalog: offer unavailable at requested quantity")
	// ErrTariffUnavailable reports a delivery request to a district the store does
	// not serve.
	ErrTariffUnavailable = errors.New("catalog: store has no tariff for district")
)

// RequestedLine is one product/quantity pair on an incoming order.
type RequestedLine struct {
	ProductID string
	// Qty is a decimal string; catalog converts it to an exact amount.
	Qty string
}

// ReserveRequest asks catalog to price and hold stock for one order.
type ReserveRequest struct {
	StoreID    string
	DistrictID int32
	// Delivery selects whether a delivery tariff is added to the quote.
	Delivery bool
	Lines    []RequestedLine
	// At anchors the supplier confirmation deadline.
	At time.Time
}

// QuotedLine is a priced order line.
type QuotedLine struct {
	ProductID     string
	Qty           string
	UnitPrice     int64
	LineAmount    int64
	CommissionBps int32
}

// Quote is the priced result of a reservation.
type Quote struct {
	Lines       []QuotedLine
	GoodsAmount int64
	DeliveryFee int64
	TotalAmount int64
	// ConfirmationDeadline is the latest confirmation window across the quoted
	// categories, anchored at ReserveRequest.At.
	ConfirmationDeadline time.Time
}

// ReleaseRequest returns stock held for an order that will not proceed.
type ReleaseRequest struct {
	StoreID string
	Lines   []RequestedLine
}

// AlternativesRequest asks for substitutes for a declined order's products.
type AlternativesRequest struct {
	ProductIDs     []string
	ExcludeStoreID string
	Cursor         string
	PageSize       int32
}

// Alternative is one substitute offer.
type Alternative struct {
	OfferID     string `json:"id"`
	StoreID     string `json:"store_id"`
	ProductID   string `json:"product_id"`
	Price       int64  `json:"price"`
	DeclaredQty string `json:"declared_qty"`
	FreshnessAt string `json:"freshness_at"`
}

// AlternativePage is a keyset page of substitutes.
type AlternativePage struct {
	Items      []Alternative `json:"items"`
	NextCursor *string       `json:"next_cursor"`
}
