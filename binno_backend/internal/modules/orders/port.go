package orders

import (
	"context"
	"time"
)

// SummaryPort is the published cross-module read of an order.
type SummaryPort interface {
	GetOrderSummary(ctx context.Context, orderID string) (Summary, error)
}

// Summary is the cross-module projection of an order.
type Summary struct {
	OrderID     string
	BuyerID     string
	StoreID     string
	Status      Status
	TotalAmount int64
	CreatedAt   time.Time
	ClosedAt    *time.Time
}

// IsClosed reports whether the order reached its terminal settled state.
func (s Summary) IsClosed() bool { return s.Status == StatusClosed }
