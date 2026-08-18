package search

import (
	"context"
	"encoding/json"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/otelx"
)

// DefaultCacheTTL bounds how stale a cached RANKING may be.
const DefaultCacheTTL = 60 * time.Second

// RedisCache stores ranked pages in Redis.
type RedisCache struct {
	client *redisx.Client
	ttl    time.Duration
}

// NewRedisCache creates a cache backed by client.
func NewRedisCache(client *redisx.Client, ttl time.Duration) *RedisCache {
	if ttl <= 0 {
		ttl = DefaultCacheTTL
	}
	return &RedisCache{client: client, ttl: ttl}
}

// Get returns a cached page.
func (c *RedisCache) Get(ctx context.Context, key string) (OfferPage, bool) {
	raw, err := c.client.Get(ctx, key).Bytes()
	if err != nil {
		otelx.ObserveCache("search", false)
		return OfferPage{}, false
	}
	var page OfferPage
	if err := json.Unmarshal(raw, &page); err != nil {
		otelx.ObserveCache("search", false)
		return OfferPage{}, false
	}
	otelx.ObserveCache("search", true)
	return page, true
}

// emptyPageTTL bounds how long a "nothing found" answer is served: a seller
// publishing their first offer in an area should not wait a full ranking TTL
// to become visible.
const emptyPageTTL = 10 * time.Second

// Put stores a page, ignoring failures for the same reason Get does.
func (c *RedisCache) Put(ctx context.Context, key string, page OfferPage) {
	raw, err := json.Marshal(page)
	if err != nil {
		return
	}
	ttl := c.ttl
	if len(page.Items) == 0 && ttl > emptyPageTTL {
		ttl = emptyPageTTL
	}
	c.client.Set(ctx, key, raw, ttl)
}
