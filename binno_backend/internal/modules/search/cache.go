package search

import (
	"context"
	"strings"
)

// offerCache is the seam a read-through cache plugs into.
type offerCache interface {
	// Get returns a cached page.
	Get(ctx context.Context, key string) (page OfferPage, found bool)
	// Put stores a page.
	Put(ctx context.Context, key string, page OfferPage)
}

// NoopCache satisfies the cache seam and caches nothing.
type NoopCache struct{}

// Get always misses.
func (NoopCache) Get(context.Context, string) (OfferPage, bool) { return OfferPage{}, false }

// Put discards.
func (NoopCache) Put(context.Context, string, OfferPage) {}

// CacheKey renders a query as a stable cache key.
func CacheKey(q Query) string {
	var b strings.Builder
	b.WriteString("search:v1:")
	b.WriteString(q.Location.GridKey())
	b.WriteString(":")
	b.WriteString(itoa(int64(q.DistrictID)))
	b.WriteString(":")
	b.WriteString(itoa(int64(q.RadiusMeters)))
	if q.ProductID != "" {
		b.WriteString(":p=" + q.ProductID)
	}
	if q.Cursor != "" {
		b.WriteString(":c=" + q.Cursor)
	}
	return b.String()
}

// itoa avoids pulling strconv in for two call sites and keeps the key builder
// allocation-free for the common case.
func itoa(v int64) string {
	if v == 0 {
		return "0"
	}
	var buf [20]byte
	i := len(buf)
	neg := v < 0
	if neg {
		v = -v
	}
	for v > 0 {
		i--
		buf[i] = byte('0' + v%10)
		v /= 10
	}
	if neg {
		i--
		buf[i] = '-'
	}
	return string(buf[i:])
}
