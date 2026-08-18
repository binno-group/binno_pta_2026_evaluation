package httpx_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

// Draining is what turns N instances into a deployment unit rather than a source
// of deploy-time 502s: the balancer learns the instance is leaving while the
// listener is still accepting, instead of discovering it by having connections
// refused.
func TestReadyz_ReportsUnavailableWhileDraining(t *testing.T) {
	readiness := &httpx.Readiness{}
	router, _ := testRouter(t, httpx.RouterConfig{
		Readiness: readiness,
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return nil }, Critical: true},
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("status before draining = %d, want %d", rec.Code, http.StatusOK)
	}

	readiness.Drain()

	rec = httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status while draining = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q, want application/problem+json", ct)
	}
}

// A draining instance is alive and still finishing work.
func TestHealthz_StaysOKWhileDraining(t *testing.T) {
	readiness := &httpx.Readiness{}
	router, _ := testRouter(t, httpx.RouterConfig{Readiness: readiness})
	readiness.Drain()

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/healthz", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d: liveness is not readiness", rec.Code, http.StatusOK)
	}
}

// The instance keeps serving business traffic for the whole drain window.
func TestDraining_KeepsServingAdmittedTraffic(t *testing.T) {
	readiness := &httpx.Readiness{}
	router, _ := testRouter(t, httpx.RouterConfig{
		Readiness: readiness,
		Mount: func(api chi.Router) {
			api.Get("/thing", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
		},
	})
	readiness.Drain()

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
}

// The verdict is about this instance leaving rotation, not about a dependency
// being broken, so the probes must not run.
func TestReadyz_SkipsProbesWhileDraining(t *testing.T) {
	probed := false
	readiness := &httpx.Readiness{}
	router, _ := testRouter(t, httpx.RouterConfig{
		Readiness: readiness,
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { probed = true; return nil }, Critical: true},
		},
	})
	readiness.Drain()

	router.ServeHTTP(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if probed {
		t.Fatal("readiness probes ran while draining")
	}
}

// A router built without a Readiness never drains, which keeps the field
// optional for the dispatcher and for tests.
func TestReadyz_WithoutReadinessNeverDrains(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
}
