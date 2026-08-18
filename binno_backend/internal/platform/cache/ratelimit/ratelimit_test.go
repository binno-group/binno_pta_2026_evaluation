package ratelimit_test

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/ratelimit"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const window = time.Minute

func newClient(t *testing.T) *redisx.Client {
	t.Helper()
	addr := os.Getenv("TEST_REDIS_ADDR")
	if addr == "" {
		t.Skip("TEST_REDIS_ADDR not set")
	}
	client := redisx.New(redisx.Config{Addr: addr})
	if err := client.Ping(context.Background()); err != nil {
		t.Skipf("redis unreachable at %s: %v", addr, err)
	}
	t.Cleanup(func() { _ = client.Close() })
	return client
}

func newLimiter(t *testing.T, c clock.Clock) *ratelimit.Limiter {
	t.Helper()
	return ratelimit.New(newClient(t), c)
}

// The fixed window admits exactly limit requests and denies the rest.
func TestAllow_DeniesBeyondLimitWithinWindow(t *testing.T) {
	fixed := clock.NewFixed(time.Date(2026, 7, 27, 10, 0, 0, 0, time.UTC))
	limiter := newLimiter(t, fixed)
	ctx := context.Background()
	key := "test:" + uuid.NewString()

	const limit = 3
	for i := 1; i <= limit; i++ {
		allowed, err := limiter.Allow(ctx, key, limit, window)
		if err != nil {
			t.Fatalf("Allow #%d: %v", i, err)
		}
		if !allowed {
			t.Fatalf("request #%d denied, want allowed (limit %d)", i, limit)
		}
	}

	allowed, err := limiter.Allow(ctx, key, limit, window)
	if err != nil {
		t.Fatalf("Allow beyond limit: %v", err)
	}
	if allowed {
		t.Fatal("request beyond the limit was allowed")
	}
}

// The window is derived from the injected clock, so advancing it resets the
// budget without sleeping.
func TestAllow_ResetsInNextWindow(t *testing.T) {
	start := time.Date(2026, 7, 27, 10, 0, 0, 0, time.UTC)
	limiter := newLimiter(t, clock.NewFixed(start))
	ctx := context.Background()
	key := "test:" + uuid.NewString()

	if _, err := limiter.Allow(ctx, key, 1, window); err != nil {
		t.Fatalf("first Allow: %v", err)
	}
	denied, err := limiter.Allow(ctx, key, 1, window)
	if err != nil {
		t.Fatalf("second Allow: %v", err)
	}
	if denied {
		t.Fatal("second request in the same window was allowed")
	}

	next := newLimiter(t, clock.NewFixed(start.Add(window)))
	allowed, err := next.Allow(ctx, key, 1, window)
	if err != nil {
		t.Fatalf("Allow in next window: %v", err)
	}
	if !allowed {
		t.Fatal("request in a fresh window was denied")
	}
}

// Every bucket must carry an expiry, on the first call and on every call after
// it.
func TestAllow_AlwaysGivesTheBucketATTL(t *testing.T) {
	client := newClient(t)
	fixed := clock.NewFixed(time.Date(2026, 7, 27, 10, 0, 0, 0, time.UTC))
	limiter := ratelimit.New(client, fixed)
	ctx := context.Background()

	key := "test:" + uuid.NewString()
	bucket := fixed.Now().UnixNano() / window.Nanoseconds()
	redisKey := fmt.Sprintf("ratelimit:%s:%d", key, bucket)
	t.Cleanup(func() { _ = client.Del(context.Background(), redisKey).Err() })

	for i := 1; i <= 3; i++ {
		if _, err := limiter.Allow(ctx, key, 10, window); err != nil {
			t.Fatalf("Allow #%d: %v", i, err)
		}
		ttl, err := client.TTL(ctx, redisKey).Result()
		if err != nil {
			t.Fatalf("TTL after Allow #%d: %v", i, err)
		}
		if ttl <= 0 {
			t.Fatalf("after Allow #%d the bucket TTL is %v, want a positive expiry", i, ttl)
		}
		if ttl > window {
			t.Fatalf("after Allow #%d the bucket TTL is %v, longer than the %v window", i, ttl, window)
		}
	}
}

// a Redis outage must not be read as "no requests counted yet"; the limiter
// denies rather than silently removing the limit.
func TestAllow_FailsClosedOnRedisOutage(t *testing.T) {
	client := redisx.New(redisx.Config{Addr: "127.0.0.1:1"}) // nothing listens here
	t.Cleanup(func() { _ = client.Close() })
	limiter := ratelimit.New(client, clock.New())

	allowed, err := limiter.Allow(context.Background(), "any-key", 100, window)
	if err == nil {
		t.Fatal("Allow with unreachable Redis returned nil error; must fail closed")
	}
	if allowed {
		t.Fatal("Allow returned true on Redis outage; rate limiting silently disabled")
	}
}
