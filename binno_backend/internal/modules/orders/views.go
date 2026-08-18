package orders

import (
	"encoding/base64"
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// OrderView is one order as the owning parties see it in lists and detail.
type OrderView struct {
	OrderID                      string     `json:"order_id"`
	StoreID                      string     `json:"store_id"`
	Status                       string     `json:"status"`
	BuyerType                    string     `json:"buyer_type"`
	Fulfillment                  string     `json:"fulfillment"`
	Urgent                       bool       `json:"urgent"`
	GoodsAmount                  int64      `json:"goods_amount"`
	DeliveryFee                  int64      `json:"delivery_fee"`
	TotalAmount                  int64      `json:"total_amount"`
	SupplierConfirmationDeadline time.Time  `json:"supplier_confirmation_deadline"`
	PaymentDueAt                 *time.Time `json:"payment_due_at,omitempty"`
	CreatedAt                    time.Time  `json:"created_at"`
	ClosedAt                     *time.Time `json:"closed_at,omitempty"`
}

// OrderLineView is one item on an order detail.
type OrderLineView struct {
	ProductID  string `json:"product_id"`
	Qty        string `json:"qty"`
	UnitPrice  int64  `json:"unit_price"`
	LineAmount int64  `json:"line_amount"`
}

// OrderDetail is one order with its item snapshot.
type OrderDetail struct {
	OrderView
	Items []OrderLineView `json:"items"`
}

// OrderPage is a keyset page of orders, newest first.
type OrderPage struct {
	Items      []OrderView `json:"items"`
	NextCursor *string     `json:"next_cursor"`
}

// listCursor is the keyset position of an order list page.
type listCursor struct {
	CreatedAt time.Time `json:"created_at"`
	ID        string    `json:"id"`
}

func encodeListCursor(createdAt time.Time, id string) *string {
	raw, err := json.Marshal(listCursor{CreatedAt: createdAt, ID: id})
	if err != nil {
		return nil
	}
	encoded := base64.RawURLEncoding.EncodeToString(raw)
	return &encoded
}

func decodeListCursor(value string) (listCursor, bool, error) {
	if value == "" {
		return listCursor{}, false, nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(value)
	if err != nil {
		return listCursor{}, false, ErrInvalid
	}
	var cursor listCursor
	if err := json.Unmarshal(raw, &cursor); err != nil {
		return listCursor{}, false, ErrInvalid
	}
	if cursor.CreatedAt.IsZero() || uuid.Validate(cursor.ID) != nil {
		return listCursor{}, false, ErrInvalid
	}
	return cursor, true, nil
}
