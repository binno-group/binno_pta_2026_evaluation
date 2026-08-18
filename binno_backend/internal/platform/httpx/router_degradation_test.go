package httpx_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

// routerWithProbes builds a router whose only dependency hangs, marked critical
// or not.
func routerWithProbes(critical bool) httpx.RouterConfig {
	return httpx.RouterConfig{
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return nil }, Critical: true},
			{Name: "analytics", Probe: hangingProbe, Critical: critical},
		},
	}
}

// hangingProbe blocks until its context is done: a dependency that has stopped
// answering rather than refusing, which is the failure mode the timeouts are
// there for.
func hangingProbe(ctx context.Context) error {
	<-ctx.Done()
	return ctx.Err()
}

// A hanging non-critical probe must not take the instance out of rotation.
func TestReadyz_HangingNonCriticalProbeStaysInRotation(t *testing.T) {
	router, _ := testRouter(t, routerWithProbes(false))

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d; body = %s", rec.Code, http.StatusOK,
			strings.TrimSpace(rec.Body.String()))
	}
	if got := rec.Header().Get("X-Readiness"); got != "degraded" {
		t.Errorf("X-Readiness = %q, want \"degraded\"", got)
	}
}

// A hanging critical probe still fails readiness.
func TestReadyz_HangingCriticalProbeLeavesRotation(t *testing.T) {
	router, _ := testRouter(t, routerWithProbes(true))

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
	if !strings.Contains(rec.Body.String(), "not-ready") {
		t.Errorf("body should be the not-ready problem, got %s", strings.TrimSpace(rec.Body.String()))
	}
}

// The verdict arrives inside the request budget rather than at the end of it.
func TestReadyz_ProbeDeadlineIsShorterThanTheRequestBudget(t *testing.T) {
	cfg := routerWithProbes(false)
	cfg.RequestTimeout = 2 * time.Second
	router, _ := testRouter(t, cfg)

	start := time.Now()
	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))
	elapsed := time.Since(start)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	if elapsed >= cfg.RequestTimeout {
		t.Errorf("readiness took %s, which reaches the %s request budget: the probe "+
			"deadline must be strictly shorter or Timeout wins the race", elapsed, cfg.RequestTimeout)
	}
}

// SecurityHeaders applies to every response, including the operational probes
// that no gateway may be sitting in front of.
func TestSecurityHeadersOnEveryResponse(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		Mount: func(r chi.Router) {
			r.Get("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
		},
	})

	for _, path := range []string{"/healthz", "/api/v1/thing"} {
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
		for header, want := range map[string]string{
			"X-Content-Type-Options": "nosniff",
			"X-Frame-Options":        "DENY",
			"Referrer-Policy":        "no-referrer",
		} {
			if got := rec.Header().Get(header); got != want {
				t.Errorf("%s: %s = %q, want %q", path, header, got, want)
			}
		}
	}
}

// Business responses are principal-scoped or price-sensitive, so a shared cache
// holding one is a correctness bug, not just a staleness annoyance.
func TestNoStoreOnBusinessResponsesOnly(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		Mount: func(r chi.Router) {
			r.Get("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil))
	if got := rec.Header().Get("Cache-Control"); got != "no-store" {
		t.Errorf("business response Cache-Control = %q, want \"no-store\"", got)
	}

	rec = httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if got := rec.Header().Get("Cache-Control"); got != "" {
		t.Errorf("healthz Cache-Control = %q, want unset", got)
	}
}
