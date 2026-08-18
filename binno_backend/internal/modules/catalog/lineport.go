package catalog

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"slices"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/money"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/otelx"
)

// linePort implements OrderLinePort.
type linePort struct {
	pool *postgres.Pool
}

func newLinePort(pool *postgres.Pool) *linePort { return &linePort{pool: pool} }

var _ OrderLinePort = (*linePort)(nil)

// ReserveOrderLines prices and holds stock for one order inside the caller's
// transaction.
func (p *linePort) ReserveOrderLines(ctx context.Context, tx pgx.Tx, request ReserveRequest) (Quote, error) {
	if len(request.Lines) == 0 {
		return Quote{}, ErrOfferUnavailable
	}
	queries := store.New(tx)
	storeID, ok := parseUUID(request.StoreID)
	if !ok {
		return Quote{}, ErrOfferUnavailable
	}

	// Reserve in a deterministic order so two orders over the same products
	// never take their row locks in opposite directions and deadlock.
	lines := make([]RequestedLine, len(request.Lines))
	copy(lines, request.Lines)
	slices.SortFunc(lines, func(a, b RequestedLine) int {
		return strings.Compare(a.ProductID, b.ProductID)
	})

	quote := Quote{
		Lines:                make([]QuotedLine, 0, len(lines)),
		ConfirmationDeadline: request.At,
	}
	for _, line := range lines {
		productID, ok := parseUUID(line.ProductID)
		if !ok {
			return Quote{}, ErrOfferUnavailable
		}
		quantity, err := numeric(line.Qty)
		if err != nil {
			return Quote{}, ErrOfferUnavailable
		}

		offer, err := queries.GetOfferForOrder(ctx, &store.GetOfferForOrderParams{
			StoreID: storeID, ProductID: productID,
		})
		if errors.Is(err, pgx.ErrNoRows) {
			return Quote{}, ErrOfferUnavailable
		}
		if err != nil {
			return Quote{}, fmt.Errorf("catalog: load offer: %w", err)
		}

		if _, err := queries.ReserveOfferQuantity(ctx, &store.ReserveOfferQuantityParams{
			Qty: quantity, ID: offer.ID,
		}); errors.Is(err, pgx.ErrNoRows) {
			return Quote{}, ErrOfferUnavailable
		} else if err != nil {
			return Quote{}, fmt.Errorf("catalog: reserve offer: %w", err)
		}

		lineAmount, err := money.Multiply(line.Qty, offer.Price)
		if err != nil {
			return Quote{}, fmt.Errorf("%w: %s", ErrOfferUnavailable, err)
		}
		quote.GoodsAmount += lineAmount
		quote.Lines = append(quote.Lines, QuotedLine{
			ProductID:     line.ProductID,
			Qty:           line.Qty,
			UnitPrice:     offer.Price,
			LineAmount:    lineAmount,
			CommissionBps: offer.CommissionBps,
		})

		deadline := request.At.Add(time.Duration(offer.ConfirmWindowMinutes) * time.Minute)
		if deadline.After(quote.ConfirmationDeadline) {
			quote.ConfirmationDeadline = deadline
		}
	}

	if request.Delivery {
		tariff, err := queries.GetDeliveryTariff(ctx, &store.GetDeliveryTariffParams{
			StoreID: storeID, DistrictID: request.DistrictID,
		})
		if errors.Is(err, pgx.ErrNoRows) {
			return Quote{}, ErrTariffUnavailable
		}
		if err != nil {
			return Quote{}, fmt.Errorf("catalog: delivery tariff: %w", err)
		}
		quote.DeliveryFee = tariff.Price
	}

	quote.TotalAmount = quote.GoodsAmount + quote.DeliveryFee
	return quote, nil
}

// ReleaseOrderLines returns reserved stock when an order will not proceed.
func (p *linePort) ReleaseOrderLines(ctx context.Context, tx pgx.Tx, request ReleaseRequest) error {
	queries := store.New(tx)
	return adjustOrderLines(ctx, "release", request,
		func(ctx context.Context, storeID, productID pgtype.UUID, qty pgtype.Numeric) (int64, error) {
			return queries.ReleaseOfferQuantity(ctx, &store.ReleaseOfferQuantityParams{
				Qty: qty, StoreID: storeID, ProductID: productID,
			})
		})
}

// ConsumeOrderLines deducts a closed order's quantities from declared and
// reserved stock: the reservation ends because the sale completed.
func (p *linePort) ConsumeOrderLines(ctx context.Context, tx pgx.Tx, request ReleaseRequest) error {
	queries := store.New(tx)
	return adjustOrderLines(ctx, "consume", request,
		func(ctx context.Context, storeID, productID pgtype.UUID, qty pgtype.Numeric) (int64, error) {
			return queries.ConsumeOfferQuantity(ctx, &store.ConsumeOfferQuantityParams{
				Qty: qty, StoreID: storeID, ProductID: productID,
			})
		})
}

// adjustOrderLines runs one stock adjustment per line. A malformed line is an
// error: every value comes from our own order snapshot, so it cannot be wrong
// without corruption, and corruption must surface, not skip. A zero-row
// adjustment does not fail the transition — a cancellation must never be
// blocked by drift — but it is loud: the offer's reservation did not hold what
// the order thought it held.
func adjustOrderLines(
	ctx context.Context,
	op string,
	request ReleaseRequest,
	adjust func(ctx context.Context, storeID, productID pgtype.UUID, qty pgtype.Numeric) (int64, error),
) error {
	storeID, ok := parseUUID(request.StoreID)
	if !ok {
		return fmt.Errorf("catalog: %s stock: malformed store id %q", op, request.StoreID)
	}
	for _, line := range request.Lines {
		productID, ok := parseUUID(line.ProductID)
		if !ok {
			return fmt.Errorf("catalog: %s stock: malformed product id %q", op, line.ProductID)
		}
		quantity, err := numeric(line.Qty)
		if err != nil {
			return fmt.Errorf("catalog: %s stock: malformed quantity %q: %w", op, line.Qty, err)
		}
		rows, err := adjust(ctx, storeID, productID, quantity)
		if err != nil {
			return fmt.Errorf("catalog: %s offer quantity: %w", op, err)
		}
		if rows == 0 {
			otelx.ObserveStockNoop(op)
			slog.ErrorContext(ctx, "stock adjustment matched no offer row",
				"op", op, "store_id", request.StoreID,
				"product_id", line.ProductID, "qty", line.Qty)
		}
	}
	return nil
}

// alternativesPageSize is the client-visible page size; the query asks for one
// more row to decide whether a next cursor exists.
const alternativesPageSize = 50

// ListAlternatives returns substitute offers for a declined order's products.
func (p *linePort) ListAlternatives(ctx context.Context, request AlternativesRequest) (AlternativePage, error) {
	excludeStore, ok := parseUUID(request.ExcludeStoreID)
	if !ok || len(request.ProductIDs) == 0 {
		return AlternativePage{Items: []Alternative{}}, nil
	}
	products := make([]pgtype.UUID, 0, len(request.ProductIDs))
	for _, id := range request.ProductIDs {
		parsed, ok := parseUUID(id)
		if !ok {
			continue
		}
		products = append(products, parsed)
	}
	if len(products) == 0 {
		return AlternativePage{Items: []Alternative{}}, nil
	}

	beforePrice, beforeID, err := decodeAlternativeCursor(request.Cursor)
	if err != nil {
		return AlternativePage{}, err
	}
	pageSize := request.PageSize
	if pageSize <= 0 || pageSize > alternativesPageSize {
		pageSize = alternativesPageSize
	}

	rows, err := store.New(p.pool).ListOfferAlternatives(ctx, &store.ListOfferAlternativesParams{
		ProductIds:     products,
		ExcludeStoreID: excludeStore,
		BeforePrice:    beforePrice,
		BeforeID:       beforeID,
		PageSize:       pageSize + 1,
	})
	if err != nil {
		return AlternativePage{}, fmt.Errorf("catalog: list alternatives: %w", err)
	}

	limit := min(int(pageSize), len(rows))
	page := AlternativePage{Items: make([]Alternative, 0, limit)}
	for _, row := range rows[:limit] {
		page.Items = append(page.Items, Alternative{
			OfferID:     uuidString(row.ID),
			StoreID:     uuidString(row.StoreID),
			ProductID:   uuidString(row.ProductID),
			Price:       row.Price,
			DeclaredQty: numericText(row.DeclaredQty),
			FreshnessAt: row.FreshnessAt.Time.UTC().Format(time.RFC3339),
		})
	}
	if len(rows) > limit && limit > 0 {
		last := page.Items[limit-1]
		page.NextCursor = encodeAlternativeCursor(last.Price, last.OfferID)
	}
	return page, nil
}

type alternativeCursor struct {
	Price *int64 `json:"price"`
	ID    string `json:"id"`
}

func decodeAlternativeCursor(value string) (*int64, pgtype.UUID, error) {
	if value == "" {
		return nil, pgtype.UUID{}, nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(value)
	if err != nil {
		return nil, pgtype.UUID{}, ErrInvalid
	}
	var cursor alternativeCursor
	if err := json.Unmarshal(raw, &cursor); err != nil {
		return nil, pgtype.UUID{}, ErrInvalid
	}
	id, ok := parseUUID(cursor.ID)
	if cursor.Price == nil || !ok {
		return nil, pgtype.UUID{}, ErrInvalid
	}
	return cursor.Price, id, nil
}

func encodeAlternativeCursor(price int64, id string) *string {
	raw, err := json.Marshal(alternativeCursor{Price: &price, ID: id})
	if err != nil {
		return nil
	}
	encoded := base64.RawURLEncoding.EncodeToString(raw)
	return &encoded
}

func parseUUID(value string) (pgtype.UUID, bool) {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}, false
	}
	return pgtype.UUID{Bytes: id, Valid: true}, true
}

func uuidString(value pgtype.UUID) string {
	if !value.Valid {
		return ""
	}
	return uuid.UUID(value.Bytes).String()
}
