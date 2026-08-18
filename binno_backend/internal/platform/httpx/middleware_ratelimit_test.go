package httpx_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

type recordingLimiter struct {
	keys   []string
	limits []int64
	allow  bool
	err    error
}

func (l *recordingLimiter) Allow(_ context.Context, key string, limit int64, _ time.Duration) (bool, error) {
	l.keys = append(l.keys, key)
	l.limits = append(l.limits, limit)
	return l.allow, l.err
}

func rateLimitedRouter(t *testing.T, limiter httpx.Limiter, principal *authz.Principal) *chi.Mux {
	t.Helper()
	cfg := httpx.RouterConfig{
		RateLimitMiddleware: httpx.RateLimit(limiter, httpx.RateLimitConfig{
			Window: time.Minute, AuthenticatedBurst: 300, AnonymousBurst: 60,
		}),
		Mount: func(api chi.Router) {
			api.Get("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
			api.Post("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
		},
	}
	if principal != nil {
		p := *principal
		cfg.IdentityMiddleware = func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				next.ServeHTTP(w, r.WithContext(authz.WithPrincipal(r.Context(), p)))
			})
		}
	}
	router, _ := testRouter(t, cfg)
	return router
}

// An authenticated caller is metered by principal, not by IP. Keying on IP alone
// punishes everyone behind one NAT for a single abuser and lets an attacker with
// many addresses through.
func TestRateLimitKeysOnPrincipalWhenAuthenticated(t *testing.T) {
	limiter := &recordingLimiter{allow: true}
	principal := authz.Principal{UserID: "018f0f50-0000-7000-8000-00000000a11c"}
	router := rateLimitedRouter(t, limiter, &principal)

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil))

	if len(limiter.keys) != 1 {
		t.Fatalf("limiter called %d times, want 1", len(limiter.keys))
	}
	if want := "user:" + principal.UserID; limiter.keys[0] != want {
		t.Fatalf("key = %q, want %q", limiter.keys[0], want)
	}
	if limiter.limits[0] != 300 {
		t.Fatalf("limit = %d, want the authenticated burst", limiter.limits[0])
	}
}

// Anonymous callers fall back to the peer address and a smaller budget, because
// an IP is a far weaker identifier than a verified subject.
func TestRateLimitKeysOnIPWhenAnonymous(t *testing.T) {
	limiter := &recordingLimiter{allow: true}
	router := rateLimitedRouter(t, limiter, nil)

	request := httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil)
	request.RemoteAddr = "203.0.113.7:54321"
	router.ServeHTTP(httptest.NewRecorder(), request)

	if len(limiter.keys) != 1 || limiter.keys[0] != "ip:203.0.113.7" {
		t.Fatalf("keys = %v, want [ip:203.0.113.7]", limiter.keys)
	}
	if limiter.limits[0] != 60 {
		t.Fatalf("limit = %d, want the anonymous burst", limiter.limits[0])
	}
}

// X-Forwarded-For is client-supplied.
func TestRateLimitIgnoresClientSuppliedForwardedFor(t *testing.T) {
	limiter := &recordingLimiter{allow: true}
	router := rateLimitedRouter(t, limiter, nil)

	request := httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil)
	request.RemoteAddr = "203.0.113.7:54321"
	request.Header.Set("X-Forwarded-For", "198.51.100.99")
	router.ServeHTTP(httptest.NewRecorder(), request)

	if limiter.keys[0] != "ip:203.0.113.7" {
		t.Fatalf("key = %q, want the transport peer address", limiter.keys[0])
	}
}

// Behind a configured proxy the peer is the load balancer, so metering it would
// put every anonymous caller in one bucket and let the first busy client rate-
// limit everyone.
func TestRateLimitKeysOnForwardedIPBehindATrustedProxy(t *testing.T) {
	limiter := &recordingLimiter{allow: true}
	proxies, err := httpx.NewTrustedProxies([]string{"10.0.0.0/8"})
	if err != nil {
		t.Fatalf("NewTrustedProxies: %v", err)
	}
	router, _ := testRouter(t, httpx.RouterConfig{
		RateLimitMiddleware: httpx.RateLimit(limiter, httpx.RateLimitConfig{
			Window: time.Minute, AuthenticatedBurst: 300, AnonymousBurst: 60,
			TrustedProxies: proxies,
		}),
		Mount: func(api chi.Router) {
			api.Get("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
		},
	})

	request := httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil)
	request.RemoteAddr = "10.1.0.4:41000"
	request.Header.Set("X-Forwarded-For", "203.0.113.7")
	router.ServeHTTP(httptest.NewRecorder(), request)

	if len(limiter.keys) != 1 || limiter.keys[0] != "ip:203.0.113.7" {
		t.Fatalf("keys = %v, want [ip:203.0.113.7], not the balancer address", limiter.keys)
	}
}

func TestRateLimitRefusesOverBudget(t *testing.T) {
	limiter := &recordingLimiter{allow: false}
	router := rateLimitedRouter(t, limiter, nil)

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil))

	if rec.Code != http.StatusTooManyRequests {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusTooManyRequests)
	}
	if rec.Header().Get("Retry-After") == "" {
		t.Error("Retry-After header is missing")
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q, want application/problem+json", ct)
	}
}

// A limiter outage must not take down public reads.
func TestRateLimitFailsOpenForReadsAndClosedForWrites(t *testing.T) {
	t.Run("safe method proceeds", func(t *testing.T) {
		limiter := &recordingLimiter{err: errors.New("redis down")}
		router := rateLimitedRouter(t, limiter, nil)

		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil))

		if rec.Code != http.StatusOK {
			t.Fatalf("status = %d, want %d: a limiter outage must not break reads", rec.Code, http.StatusOK)
		}
	})

	t.Run("unsafe method is refused", func(t *testing.T) {
		limiter := &recordingLimiter{err: errors.New("redis down")}
		router := rateLimitedRouter(t, limiter, nil)

		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/api/v1/thing", nil))

		if rec.Code != http.StatusServiceUnavailable {
			t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
		}
	})
}

// Health and metrics endpoints decide whether this instance stays in rotation.
func TestRateLimitDoesNotApplyToProbes(t *testing.T) {
	limiter := &recordingLimiter{allow: false}
	router := rateLimitedRouter(t, limiter, nil)

	for _, path := range []string{"/healthz", "/readyz"} {
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
		if rec.Code == http.StatusTooManyRequests {
			t.Errorf("%s was rate limited", path)
		}
	}
	if len(limiter.keys) != 0 {
		t.Fatalf("limiter consulted for probe paths: %v", limiter.keys)
	}
}
