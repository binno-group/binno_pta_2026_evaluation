package search

import (
	"context"
	"errors"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
)

type fakeRepository struct {
	lastQuery Query
	// queries records every attempt, because a search with no explicit radius now
	// makes several: it starts at the default and widens until it finds offers.
	queries []Query
}

func (f *fakeRepository) SearchOffers(_ context.Context, q Query) (OfferPage, error) {
	f.lastQuery = q
	f.queries = append(f.queries, q)
	return OfferPage{Items: []Offer{}}, nil
}

func (f *fakeRepository) GetComplexAggregate(context.Context, ComplexQuery) (ComplexAggregate, error) {
	return ComplexAggregate{}, nil
}

func tashkent() geo.Point { return geo.Point{Lat: 41.311081, Lng: 69.240562} }

func validQuery() Query { return Query{Location: tashkent(), DistrictID: 1} }

// An absent radius must resolve to the default rather than to "unbounded".
func TestSearchAppliesDefaultRadius(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := NewService(repository)

	if _, err := service.SearchOffers(context.Background(), validQuery()); err != nil {
		t.Fatalf("SearchOffers error = %v", err)
	}
	if len(repository.queries) == 0 {
		t.Fatal("repository was never queried")
	}
	if got := repository.queries[0].RadiusMeters; got != DefaultRadiusMeters {
		t.Fatalf("first RadiusMeters = %d, want the default %d", got, DefaultRadiusMeters)
	}
}

// An out-of-range radius is refused, not clamped: silently searching a smaller
// area than requested makes an empty result ambiguous and the client cannot tell
// its parameter was ignored.
func TestSearchRejectsOutOfRangeRadiusInsteadOfClamping(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := NewService(repository)

	for _, radius := range []int32{MinRadiusMeters - 1, MaxRadiusMeters + 1, -1} {
		query := validQuery()
		query.RadiusMeters = radius
		if _, err := service.SearchOffers(context.Background(), query); !errors.Is(err, ErrInvalid) {
			t.Errorf("radius %d: error = %v, want ErrInvalid", radius, err)
		}
	}

	query := validQuery()
	query.RadiusMeters = MaxRadiusMeters
	if _, err := service.SearchOffers(context.Background(), query); err != nil {
		t.Fatalf("radius at the maximum rejected: %v", err)
	}
	if got := repository.lastQuery.RadiusMeters; got != MaxRadiusMeters {
		t.Fatalf("RadiusMeters = %d, want %d passed through unchanged", got, MaxRadiusMeters)
	}
}

func TestSearchInputValidation(t *testing.T) {
	t.Parallel()
	service := NewService(&fakeRepository{})

	tests := map[string]Query{
		"missing district":  {Location: tashkent()},
		"negative district": {Location: tashkent(), DistrictID: -1},
		"invalid latitude":  {Location: geo.Point{Lat: 100, Lng: 69}, DistrictID: 1},
		"invalid longitude": {Location: geo.Point{Lat: 41, Lng: 200}, DistrictID: 1},
		"malformed product": {Location: tashkent(), DistrictID: 1, ProductID: "nope"},
	}
	for name, query := range tests {
		t.Run(name, func(t *testing.T) {
			if _, err := service.SearchOffers(context.Background(), query); !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
		})
	}
}

func TestComplexAggregateValidation(t *testing.T) {
	t.Parallel()
	service := NewService(&fakeRepository{})

	if _, err := service.GetComplexAggregate(context.Background(), ComplexQuery{ID: "nope"}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("error = %v, want ErrInvalid", err)
	}
}

func (f *fakeRepository) RefreshOffers(_ context.Context, in OfferPage) (OfferPage, error) {
	return in, nil
}
