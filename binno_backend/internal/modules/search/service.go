package search

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
)

// Service errors.
var (
	ErrInvalid     = errors.New("invalid search input")
	ErrNotFound    = errors.New("complex not found")
	ErrUnavailable = errors.New("search temporarily unavailable")
)

// Search radius bounds, in metres.
const (
	DefaultRadiusMeters int32 = 5_000
	MaxRadiusMeters     int32 = 100_000
	MinRadiusMeters     int32 = 100
)

// Automatic radius expansion.
const (
	RadiusExpansionStep int32 = 5_000
	MaxRadiusExpansions int32 = 3
)

// AutoExpandCeilingMeters is the widest radius automatic expansion will reach.
const AutoExpandCeilingMeters = DefaultRadiusMeters + RadiusExpansionStep*MaxRadiusExpansions

// Query is an offer search around a point.
type Query struct {
	Location   geo.Point
	DistrictID int32
	// RadiusMeters bounds the search.
	RadiusMeters int32
	ProductID    string
	Cursor       string
}

// ComplexQuery selects one trade complex and a page of its offers.
type ComplexQuery struct{ ID, ProductID, Cursor string }

// Offer is one published offer in a search result.
type Offer struct {
	ID                   string `json:"id"`
	StoreID              string `json:"store_id"`
	ProductID            string `json:"product_id"`
	Price                int64  `json:"price"`
	DeclaredQty          string `json:"declared_qty"`
	FreshnessAt          string `json:"freshness_at"`
	FreshnessLabel       string `json:"freshness_label"`
	DistanceMeters       int64  `json:"distance_meters"`
	OtherOwnerStoreCount int64  `json:"other_owner_store_count"`
}

// OfferPage is a keyset page of offers.
type OfferPage struct {
	Items      []Offer `json:"items"`
	NextCursor *string `json:"next_cursor"`
	// RadiusMeters is the radius that actually produced these results, which is not
	// always the one requested: an unspecified radius expands when it finds
	// nothing.
	RadiusMeters int32 `json:"radius_meters"`
	// SearchExhausted reports that automatic expansion reached
	// AutoExpandCeilingMeters and still found nothing.
	SearchExhausted bool `json:"search_exhausted"`
}

// ComplexAggregate is a trade complex with its offers.
type ComplexAggregate struct {
	ComplexID   string     `json:"complex_id"`
	ComplexName string     `json:"complex_name"`
	PickupPoint *geo.Point `json:"pickup_point"`
	Offers      OfferPage  `json:"offers"`
}

type repository interface {
	SearchOffers(context.Context, Query) (OfferPage, error)
	GetComplexAggregate(context.Context, ComplexQuery) (ComplexAggregate, error)
	// RefreshOffers rebuilds a cached page against current stock.
	RefreshOffers(context.Context, OfferPage) (OfferPage, error)
}

// Service validates search input.
type Service struct {
	repository repository
	cache      offerCache
}

// NewService creates a search service.
func NewService(repository repository, cache ...offerCache) *Service {
	s := &Service{repository: repository, cache: NoopCache{}}
	if len(cache) > 0 && cache[0] != nil {
		s.cache = cache[0]
	}
	return s
}

// SearchOffers returns the cheapest offer per owner around a point.
func (s *Service) SearchOffers(ctx context.Context, q Query) (OfferPage, error) {
	if !q.Location.Valid() || q.DistrictID <= 0 {
		return OfferPage{}, ErrInvalid
	}
	if q.ProductID != "" && uuid.Validate(q.ProductID) != nil {
		return OfferPage{}, ErrInvalid
	}
	radius, explicit, err := normalizeRadius(q.RadiusMeters)
	if err != nil {
		return OfferPage{}, err
	}
	q.RadiusMeters = radius

	key := CacheKey(q)
	if page, found := s.cache.Get(ctx, key); found {
		fresh, err := s.repository.RefreshOffers(ctx, page)
		if err != nil {
			return OfferPage{}, err
		}
		return fresh, nil
	}

	attempts := 1
	if !explicit && q.Cursor == "" {
		attempts = int(MaxRadiusExpansions) + 1
	}

	var page OfferPage
	for attempt := 0; attempt < attempts; attempt++ {
		page, err = s.repository.SearchOffers(ctx, q)
		if err != nil {
			return OfferPage{}, err
		}
		page.RadiusMeters = q.RadiusMeters
		if len(page.Items) > 0 {
			s.cache.Put(ctx, key, page)
			return page, nil
		}
		if attempt < attempts-1 {
			q.RadiusMeters += RadiusExpansionStep
		}
	}

	page.SearchExhausted = attempts > 1
	s.cache.Put(ctx, key, page)
	return page, nil
}

// normalizeRadius applies the default and rejects out-of-range values.
func normalizeRadius(requested int32) (radius int32, explicit bool, err error) {
	if requested == 0 {
		return DefaultRadiusMeters, false, nil
	}
	if requested < MinRadiusMeters || requested > MaxRadiusMeters {
		return 0, false, ErrInvalid
	}
	return requested, true, nil
}

// GetComplexAggregate returns one trade complex and a page of its offers.
func (s *Service) GetComplexAggregate(ctx context.Context, q ComplexQuery) (ComplexAggregate, error) {
	if uuid.Validate(q.ID) != nil || (q.ProductID != "" && uuid.Validate(q.ProductID) != nil) {
		return ComplexAggregate{}, ErrInvalid
	}
	return s.repository.GetComplexAggregate(ctx, q)
}
