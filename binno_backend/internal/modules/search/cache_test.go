package search

import (
	"context"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
)

func query(lat, lng float64) Query {
	return Query{Location: geo.Point{Lat: lat, Lng: lng}, DistrictID: 3, RadiusMeters: 5000}
}

// The whole value of the cache depends on nearby callers sharing a key.
func TestCacheKeyQuantisesNearbyLocationsTogether(t *testing.T) {
	base := query(41.311081, 69.240562)
	nudged := query(41.311400, 69.240900)

	if CacheKey(base) != CacheKey(nudged) {
		t.Errorf("callers 40m apart got different keys:\n  %s\n  %s",
			CacheKey(base), CacheKey(nudged))
	}
}

func TestCacheKeySeparatesDistantLocations(t *testing.T) {
	near := query(41.311081, 69.240562)
	far := query(41.331081, 69.260562)

	if CacheKey(near) == CacheKey(far) {
		t.Errorf("callers 2km apart collapsed onto one key: %s", CacheKey(near))
	}
}

// Every field that changes the result set must change the key.
func TestCacheKeySeparatesEveryResultAffectingField(t *testing.T) {
	base := query(41.311081, 69.240562)
	for name, mutate := range map[string]func(Query) Query{
		"district": func(q Query) Query { q.DistrictID = 4; return q },
		"radius":   func(q Query) Query { q.RadiusMeters = 10000; return q },
		"product":  func(q Query) Query { q.ProductID = "b5b1a1a0-0000-4000-8000-000000000001"; return q },
		"cursor":   func(q Query) Query { q.Cursor = "eyJwcmljZSI6MX0"; return q },
	} {
		t.Run(name, func(t *testing.T) {
			if CacheKey(base) == CacheKey(mutate(base)) {
				t.Errorf("%s does not affect the cache key: %s", name, CacheKey(base))
			}
		})
	}
}

func TestCacheKeyIsStable(t *testing.T) {
	q := query(41.311081, 69.240562)
	first, second := CacheKey(q), CacheKey(q)
	if first != second {
		t.Errorf("cache key is not deterministic: %q then %q", first, second)
	}
}

// The default must behave exactly as no cache at all, so wiring the seam in
// cannot change behaviour until an implementation is chosen.
func TestNoopCacheAlwaysMisses(t *testing.T) {
	var c offerCache = NoopCache{}
	c.Put(context.Background(), "k", OfferPage{Items: []Offer{{ID: "x"}}})
	if _, found := c.Get(context.Background(), "k"); found {
		t.Error("NoopCache returned a hit")
	}
}

// A cache that answered a query the validator would have rejected, or that
// stored an error, would turn a transient fault into a sticky one.
func TestServiceDoesNotCacheFailures(t *testing.T) {
	repo := &countingRepo{err: ErrInvalid}
	cache := &mapCache{data: map[string]OfferPage{}}
	svc := NewService(repo, cache)

	for i := 0; i < 2; i++ {
		if _, err := svc.SearchOffers(context.Background(), query(41.311081, 69.240562)); err == nil {
			t.Fatal("expected the repository error to surface")
		}
	}
	if len(cache.data) != 0 {
		t.Errorf("a failed search was cached: %v", cache.data)
	}
	if repo.calls != 2 {
		t.Errorf("repository called %d times, want 2: a cached failure would have skipped the retry", repo.calls)
	}
}

func TestServiceServesSecondCallFromCache(t *testing.T) {
	repo := &countingRepo{page: OfferPage{Items: []Offer{{ID: "offer-1"}}}}
	cache := &mapCache{data: map[string]OfferPage{}}
	svc := NewService(repo, cache)

	q := query(41.311081, 69.240562)
	first, err := svc.SearchOffers(context.Background(), q)
	if err != nil {
		t.Fatalf("first search: %v", err)
	}
	second, err := svc.SearchOffers(context.Background(), q)
	if err != nil {
		t.Fatalf("second search: %v", err)
	}
	if repo.calls != 1 {
		t.Errorf("repository called %d times, want 1", repo.calls)
	}
	if len(second.Items) != len(first.Items) || second.Items[0].ID != first.Items[0].ID {
		t.Errorf("cached page differs from the original: %+v vs %+v", second, first)
	}
}

type countingRepo struct {
	page       OfferPage
	err        error
	calls      int
	refreshes  int
	refreshErr error
	sold       map[string]bool
	liveQty    string
}

func (r *countingRepo) SearchOffers(context.Context, Query) (OfferPage, error) {
	r.calls++
	return r.page, r.err
}

func (r *countingRepo) GetComplexAggregate(context.Context, ComplexQuery) (ComplexAggregate, error) {
	return ComplexAggregate{}, nil
}

// refreshed records how the service asked for a cached page to be revalidated,
// and drops whatever `sold` names, the fake equivalent of an offer selling out
// between the cache write and the read.
func (r *countingRepo) RefreshOffers(_ context.Context, in OfferPage) (OfferPage, error) {
	r.refreshes++
	if r.refreshErr != nil {
		return OfferPage{}, r.refreshErr
	}
	items := make([]Offer, 0, len(in.Items))
	for _, item := range in.Items {
		if r.sold[item.ID] {
			continue
		}
		if r.liveQty != "" {
			item.DeclaredQty = r.liveQty
		}
		items = append(items, item)
	}
	in.Items = items
	return in, nil
}

type mapCache struct{ data map[string]OfferPage }

func (c *mapCache) Get(_ context.Context, key string) (OfferPage, bool) {
	page, ok := c.data[key]
	return page, ok
}

func (c *mapCache) Put(_ context.Context, key string, page OfferPage) { c.data[key] = page }

// --- automatic radius expansion -------------------------------------------

// radiusRepo answers with offers only once the radius reaches foundAt, and
// records every radius it was asked about.
type radiusRepo struct {
	foundAt int32
	seen    []int32
}

func (r *radiusRepo) SearchOffers(_ context.Context, q Query) (OfferPage, error) {
	r.seen = append(r.seen, q.RadiusMeters)
	if r.foundAt > 0 && q.RadiusMeters >= r.foundAt {
		return OfferPage{Items: []Offer{{ID: "offer-1"}}}, nil
	}
	return OfferPage{Items: []Offer{}}, nil
}

func (r *radiusRepo) GetComplexAggregate(context.Context, ComplexQuery) (ComplexAggregate, error) {
	return ComplexAggregate{}, nil
}

func (r *radiusRepo) RefreshOffers(_ context.Context, in OfferPage) (OfferPage, error) {
	return in, nil
}

func TestSearchStartsAtFiveKilometres(t *testing.T) {
	repo := &radiusRepo{foundAt: DefaultRadiusMeters}
	page, err := NewService(repo).SearchOffers(context.Background(), Query{
		Location: geoPoint(), DistrictID: 3,
	})
	if err != nil {
		t.Fatalf("search: %v", err)
	}
	if len(repo.seen) != 1 || repo.seen[0] != 5_000 {
		t.Errorf("radii tried = %v, want exactly [5000]", repo.seen)
	}
	if page.RadiusMeters != 5_000 {
		t.Errorf("radius_meters = %d, want 5000", page.RadiusMeters)
	}
	if page.SearchExhausted {
		t.Error("search_exhausted set on a page that found offers")
	}
}

func TestSearchExpandsInFiveKilometreStepsUntilItFinds(t *testing.T) {
	repo := &radiusRepo{foundAt: 15_000}
	page, err := NewService(repo).SearchOffers(context.Background(), Query{
		Location: geoPoint(), DistrictID: 3,
	})
	if err != nil {
		t.Fatalf("search: %v", err)
	}
	want := []int32{5_000, 10_000, 15_000}
	if len(repo.seen) != len(want) {
		t.Fatalf("radii tried = %v, want %v", repo.seen, want)
	}
	for i := range want {
		if repo.seen[i] != want[i] {
			t.Fatalf("radii tried = %v, want %v", repo.seen, want)
		}
	}
	if page.RadiusMeters != 15_000 {
		t.Errorf("radius_meters = %d, want 15000", page.RadiusMeters)
	}
	if page.SearchExhausted {
		t.Error("search_exhausted set on a page that found offers")
	}
}

func TestSearchStopsAtTwentyKilometresAndReportsExhausted(t *testing.T) {
	repo := &radiusRepo{foundAt: 0} // never finds anything
	page, err := NewService(repo).SearchOffers(context.Background(), Query{
		Location: geoPoint(), DistrictID: 3,
	})
	if err != nil {
		t.Fatalf("search: %v", err)
	}
	want := []int32{5_000, 10_000, 15_000, 20_000}
	if len(repo.seen) != len(want) {
		t.Fatalf("radii tried = %v, want %v (default + %d expansions)",
			repo.seen, want, MaxRadiusExpansions)
	}
	for i := range want {
		if repo.seen[i] != want[i] {
			t.Fatalf("radii tried = %v, want %v", repo.seen, want)
		}
	}
	if !page.SearchExhausted {
		t.Error("search_exhausted not set after expansion found nothing: " +
			"the UI cannot tell this from an empty product filter")
	}
	if page.RadiusMeters != AutoExpandCeilingMeters {
		t.Errorf("radius_meters = %d, want %d", page.RadiusMeters, AutoExpandCeilingMeters)
	}
}

// An explicit radius is a deliberate bound.
func TestExplicitRadiusIsNeverExpanded(t *testing.T) {
	repo := &radiusRepo{foundAt: 0}
	page, err := NewService(repo).SearchOffers(context.Background(), Query{
		Location: geoPoint(), DistrictID: 3, RadiusMeters: 5_000,
	})
	if err != nil {
		t.Fatalf("search: %v", err)
	}
	if len(repo.seen) != 1 || repo.seen[0] != 5_000 {
		t.Errorf("radii tried = %v, want exactly [5000]", repo.seen)
	}
	if page.SearchExhausted {
		t.Error("search_exhausted set for an explicit radius: an empty result " +
			"there means 'nothing in the area you asked about', not 'nothing exists'")
	}
}

// A cursor encodes a position inside one result set.
func TestPagingDoesNotExpand(t *testing.T) {
	repo := &radiusRepo{foundAt: 0}
	if _, err := NewService(repo).SearchOffers(context.Background(), Query{
		Location: geoPoint(), DistrictID: 3, Cursor: "eyJwcmljZSI6MX0",
	}); err != nil {
		t.Fatalf("search: %v", err)
	}
	if len(repo.seen) != 1 {
		t.Errorf("radii tried = %v, want exactly one: paging must not widen", repo.seen)
	}
}

func geoPoint() geo.Point { return geo.Point{Lat: 41.311081, Lng: 69.240562} }

// --- cache correctness: a hit must never advertise stock that is gone --------

// This is the property the whole cache design hangs on.
func TestCacheHitDropsOffersThatSoldOut(t *testing.T) {
	repo := &countingRepo{
		page: OfferPage{Items: []Offer{
			{ID: "a", DeclaredQty: "10"}, {ID: "b", DeclaredQty: "5"}, {ID: "c", DeclaredQty: "1"},
		}},
		sold: map[string]bool{"b": true},
	}
	cache := &mapCache{data: map[string]OfferPage{}}
	svc := NewService(repo, cache)
	q := query(41.311081, 69.240562)

	if _, err := svc.SearchOffers(context.Background(), q); err != nil {
		t.Fatalf("priming search: %v", err)
	}
	page, err := svc.SearchOffers(context.Background(), q)
	if err != nil {
		t.Fatalf("cached search: %v", err)
	}
	if repo.calls != 1 {
		t.Errorf("repository queried %d times, want 1; the second call should hit the cache", repo.calls)
	}
	if repo.refreshes != 1 {
		t.Fatalf("cached page was refreshed %d times, want 1; a hit MUST revalidate stock", repo.refreshes)
	}
	for _, item := range page.Items {
		if item.ID == "b" {
			t.Fatal("a sold-out offer survived a cache hit; the buyer would get a 409 at order creation")
		}
	}
	if len(page.Items) != 2 {
		t.Errorf("page has %d items, want 2", len(page.Items))
	}
}

// Ranking is cached; quantity is not.
func TestCacheHitCarriesLiveQuantity(t *testing.T) {
	repo := &countingRepo{
		page:    OfferPage{Items: []Offer{{ID: "a", DeclaredQty: "10"}}},
		liveQty: "3",
	}
	cache := &mapCache{data: map[string]OfferPage{}}
	svc := NewService(repo, cache)
	q := query(41.311081, 69.240562)

	if _, err := svc.SearchOffers(context.Background(), q); err != nil {
		t.Fatalf("priming search: %v", err)
	}
	page, err := svc.SearchOffers(context.Background(), q)
	if err != nil {
		t.Fatalf("cached search: %v", err)
	}
	if got := page.Items[0].DeclaredQty; got != "3" {
		t.Errorf("declared_qty = %q, want the live %q; the cached value was served", got, "3")
	}
}

// The refresh is a cheap primary-key lookup.
func TestCacheHitSurfacesRefreshFailure(t *testing.T) {
	repo := &countingRepo{
		page:       OfferPage{Items: []Offer{{ID: "a"}}},
		refreshErr: ErrInvalid,
	}
	cache := &mapCache{data: map[string]OfferPage{}}
	svc := NewService(repo, cache)
	q := query(41.311081, 69.240562)

	if _, err := svc.SearchOffers(context.Background(), q); err != nil {
		t.Fatalf("priming search: %v", err)
	}
	if _, err := svc.SearchOffers(context.Background(), q); err == nil {
		t.Fatal("a failed stock refresh was swallowed; stale stock would be served as if fresh")
	}
}

// Without a cache the refresh path must never run: a miss already read live
// data, and revalidating it would be a second query for nothing.
func TestNoCacheMeansNoRefresh(t *testing.T) {
	repo := &countingRepo{page: OfferPage{Items: []Offer{{ID: "a"}}}}
	svc := NewService(repo)
	for i := 0; i < 3; i++ {
		if _, err := svc.SearchOffers(context.Background(), query(41.311081, 69.240562)); err != nil {
			t.Fatalf("search: %v", err)
		}
	}
	if repo.refreshes != 0 {
		t.Errorf("RefreshOffers called %d times without a cache, want 0", repo.refreshes)
	}
	if repo.calls != 3 {
		t.Errorf("repository queried %d times, want 3", repo.calls)
	}
}
