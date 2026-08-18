//go:build integration

package httpx_test

import (
	"context"
	"fmt"
	"math/rand/v2"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/ratelimit"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// The limiter behind the middleware, against real Redis: it must engage at the
// burst limit inside one window and admit the same caller again in the next.
func TestRateLimiterEngagesAndRecovers(t *testing.T) {
	addr := os.Getenv("TEST_REDIS_ADDR")
	if addr == "" {
		t.Skip("TEST_REDIS_ADDR not set")
	}
	client := redisx.New(redisx.Config{Addr: addr})
	if err := client.Ping(context.Background()); err != nil {
		t.Skipf("redis unreachable at %s: %v", addr, err)
	}
	t.Cleanup(func() { _ = client.Close() })

	const window = time.Second
	limiter := ratelimit.New(client, clock.New())
	handler := httpx.RateLimit(limiter, httpx.RateLimitConfig{
		Window: window, AnonymousBurst: 3,
	})(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))

	// A fresh anonymous caller each run, so leftover counters from earlier
	// suites never leak in.
	callerIP := fmt.Sprintf("203.0.113.%d:9999", rand.IntN(250)+1)
	get := func() *httptest.ResponseRecorder {
		req := httptest.NewRequest(http.MethodGet, "/search", nil)
		req.RemoteAddr = callerIP
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, req)
		return rec
	}
	// Align to the start of a counting window so the burst below cannot
	// straddle two of them.
	waitForFreshWindow := func() {
		now := time.Now()
		time.Sleep(time.Until(now.Truncate(window).Add(window)) + 50*time.Millisecond)
	}

	waitForFreshWindow()
	for i := 1; i <= 3; i++ {
		if code := get().Code; code != http.StatusOK {
			t.Fatalf("request %d inside the burst: status %d, want 200", i, code)
		}
	}
	throttled := get()
	if throttled.Code != http.StatusTooManyRequests {
		t.Fatalf("request beyond the burst: status %d, want 429", throttled.Code)
	}
	if throttled.Header().Get("Retry-After") == "" {
		t.Error("429 without a Retry-After header leaves clients guessing")
	}

	// The next window admits the caller again — the limiter recovered.
	waitForFreshWindow()
	if code := get().Code; code != http.StatusOK {
		t.Errorf("request in the next window: status %d, want 200 (limiter must recover)", code)
	}
}
