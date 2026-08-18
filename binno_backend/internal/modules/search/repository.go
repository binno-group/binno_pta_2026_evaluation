package search

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/search/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// pageSize is the client-visible page size.
const pageSize = 50

// Repository reads the offer projection.
type Repository struct {
	queries *store.Queries
	clock   clock.Clock
}

// NewRepository returns a search repository over pool.
func NewRepository(pool *postgres.Pool, clk clock.Clock) *Repository {
	return &Repository{queries: store.New(pool), clock: clk}
}

// SearchOffers returns one keyset page of the cheapest offer per owner within
// the requested radius.
func (r *Repository) SearchOffers(ctx context.Context, in Query) (OfferPage, error) {
	cursor, err := decodeCursor(in.Cursor)
	if err != nil {
		return OfferPage{}, ErrInvalid
	}
	rows, err := r.queries.SearchOffers(ctx, &store.SearchOffersParams{
		Lat:            in.Location.Lat,
		Lng:            in.Location.Lng,
		RadiusMeters:   in.RadiusMeters,
		DistrictID:     in.DistrictID,
		ProductID:      nullableUUID(in.ProductID),
		BeforePrice:    cursor.Price,
		BeforeDistance: cursor.Distance,
		BeforeID:       nullableUUID(cursor.ID),
		PageSize:       pageSize + 1,
	})
	if err != nil {
		return OfferPage{}, wrapQueryError("offers", err)
	}
	limit := min(len(rows), pageSize)
	items := make([]Offer, 0, limit)
	for _, row := range rows[:limit] {
		items = append(items, r.offer(row.ID, row.StoreID, row.ProductID, row.Price,
			row.DeclaredQty, row.FreshnessAt.Time, row.DistanceMeters, row.OtherOwnerStoreCount))
	}
	return page(items, len(rows) > limit, true), nil
}

// GetComplexAggregate returns a trade complex with a page of its offers.
func (r *Repository) GetComplexAggregate(ctx context.Context, in ComplexQuery) (ComplexAggregate, error) {
	complex, err := r.queries.GetComplexAggregate(ctx, nullableUUID(in.ID))
	if errors.Is(err, pgx.ErrNoRows) {
		return ComplexAggregate{}, ErrNotFound
	}
	if err != nil {
		return ComplexAggregate{}, wrapQueryError("get complex", err)
	}
	cursor, err := decodeCursor(in.Cursor)
	if err != nil {
		return ComplexAggregate{}, ErrInvalid
	}
	rows, err := r.queries.ListComplexOffers(ctx, &store.ListComplexOffersParams{
		ComplexID: nullableUUID(in.ID), ProductID: nullableUUID(in.ProductID),
		BeforePrice: cursor.Price, BeforeID: nullableUUID(cursor.ID), PageSize: pageSize + 1,
	})
	if err != nil {
		return ComplexAggregate{}, wrapQueryError("list complex offers", err)
	}
	limit := min(len(rows), pageSize)
	items := make([]Offer, 0, limit)
	for _, row := range rows[:limit] {
		items = append(items, r.offer(row.ID, row.StoreID, row.ProductID, row.Price,
			row.DeclaredQty, row.FreshnessAt.Time, row.DistanceMeters, row.OtherOwnerStoreCount))
	}
	var pickup *geo.Point
	if complex.HasPickup {
		pickup = &geo.Point{Lat: complex.PickupLat, Lng: complex.PickupLng}
	}
	return ComplexAggregate{
		ComplexID: uuidString(complex.ID), ComplexName: complex.Name, PickupPoint: pickup,
		Offers: page(items, len(rows) > limit, false),
	}, nil
}

// Freshness thresholds for the label shown next to an offer.
const (
	freshWindow = 24 * time.Hour
	staleWindow = 72 * time.Hour
)

// offer maps a row to the API shape.
func (r *Repository) offer(
	id, storeID, productID pgtype.UUID,
	price int64, qty pgtype.Numeric, fresh time.Time, distance, ownerStores int64,
) Offer {
	return Offer{
		ID: uuidString(id), StoreID: uuidString(storeID), ProductID: uuidString(productID),
		Price: price, DeclaredQty: numericString(qty),
		FreshnessAt: fresh.UTC().Format(time.RFC3339), FreshnessLabel: r.freshnessLabel(fresh),
		DistanceMeters: distance, OtherOwnerStoreCount: ownerStores,
	}
}

// freshnessLabel derives the label from how old the data is.
func (r *Repository) freshnessLabel(fresh time.Time) string {
	switch age := r.clock.Now().Sub(fresh); {
	case age <= freshWindow:
		return "today"
	case age <= staleWindow:
		return "stale_warning"
	}
	return "none"
}

func page(items []Offer, hasMore, withDistance bool) OfferPage {
	result := OfferPage{Items: items}
	if !hasMore || len(items) == 0 {
		return result
	}
	last := items[len(items)-1]
	distance := last.DistanceMeters
	if !withDistance {
		distance = 0
	}
	value := encodeCursor(last.Price, distance, last.ID)
	result.NextCursor = &value
	return result
}

type cursor struct {
	Price    *int64 `json:"price,omitempty"`
	Distance *int64 `json:"distance,omitempty"`
	ID       string `json:"id,omitempty"`
}

func encodeCursor(price, distance int64, id string) string {
	raw, _ := json.Marshal(cursor{Price: &price, Distance: &distance, ID: id})
	return base64.RawURLEncoding.EncodeToString(raw)
}

func decodeCursor(value string) (cursor, error) {
	if value == "" {
		return cursor{}, nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(value)
	if err != nil {
		return cursor{}, ErrInvalid
	}
	var decoded cursor
	if err := json.Unmarshal(raw, &decoded); err != nil {
		return cursor{}, ErrInvalid
	}
	if decoded.Price == nil || decoded.Distance == nil || uuid.Validate(decoded.ID) != nil {
		return cursor{}, ErrInvalid
	}
	return decoded, nil
}

func nullableUUID(value string) pgtype.UUID {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}
	}
	return pgtype.UUID{Bytes: id, Valid: true}
}

func uuidString(value pgtype.UUID) string {
	if !value.Valid {
		return ""
	}
	return uuid.UUID(value.Bytes).String()
}

func numericString(value pgtype.Numeric) string {
	raw, err := value.Value()
	if err != nil || raw == nil {
		return "0"
	}
	return fmt.Sprint(raw)
}

// RefreshOffers rebuilds a cached page against current stock.
func (r *Repository) RefreshOffers(ctx context.Context, in OfferPage) (OfferPage, error) {
	if len(in.Items) == 0 {
		return in, nil
	}
	ids := make([]pgtype.UUID, 0, len(in.Items))
	for _, item := range in.Items {
		ids = append(ids, nullableUUID(item.ID))
	}
	rows, err := r.queries.RefreshOffers(ctx, ids)
	if err != nil {
		return OfferPage{}, wrapQueryError("refresh offers", err)
	}

	type live struct {
		price int64
		qty   string
		fresh time.Time
	}
	current := make(map[string]live, len(rows))
	for _, row := range rows {
		current[uuidString(row.ID)] = live{
			price: row.Price,
			qty:   numericString(row.DeclaredQty),
			fresh: row.FreshnessAt.Time,
		}
	}

	items := make([]Offer, 0, len(in.Items))
	for _, item := range in.Items {
		now, ok := current[item.ID]
		if !ok {
			continue // sold out or withdrawn since the page was cached
		}
		item.Price = now.price
		item.DeclaredQty = now.qty
		item.FreshnessAt = now.fresh.UTC().Format(time.RFC3339)
		item.FreshnessLabel = r.freshnessLabel(now.fresh)
		items = append(items, item)
	}

	out := in
	out.Items = items
	return out, nil
}

func wrapQueryError(what string, err error) error {
	if postgres.IsContentionTimeout(err) {
		return fmt.Errorf("search: %s: %w: %w", what, ErrUnavailable, err)
	}
	return fmt.Errorf("search: %s: %w", what, err)
}
