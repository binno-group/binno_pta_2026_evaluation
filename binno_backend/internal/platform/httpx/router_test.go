package httpx_test

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/contracts"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

func testRouter(t *testing.T, cfg httpx.RouterConfig) (*chi.Mux, *bytes.Buffer) {
	t.Helper()
	var logs bytes.Buffer
	cfg.Logger = slog.New(slog.NewJSONHandler(&logs, nil))
	if cfg.RequestTimeout == 0 {
		cfg.RequestTimeout = 2 * time.Second
	}
	return httpx.NewRouter(cfg), &logs
}

func TestReadyz_DoesNotLeakDependencyDetail(t *testing.T) {
	secret := "failed to connect to `user=binno database=binno` 10.0.0.7:5432"
	router, logs := testRouter(t, httpx.RouterConfig{
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return errors.New(secret) }, Critical: true},
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
	for _, leak := range []string{"user=binno", "database=binno", "10.0.0.7", "5432"} {
		if strings.Contains(rec.Body.String(), leak) {
			t.Fatalf("dependency detail %q leaked to client: %s", leak, rec.Body.String())
		}
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q, want application/problem+json", ct)
	}
	if !strings.Contains(logs.String(), secret) {
		t.Fatalf("probe error must still reach the server log, got: %s", logs.String())
	}
}

func TestReadyz_OKWhenAllProbesPass(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return nil }},
			{Name: "redis", Probe: func(context.Context) error { return nil }},
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
}

// Metrics must observe the status the client actually received, so the RED
// series reflects timeouts instead of the abandoned handler's eventual result.
func TestRouter_MetricsSeeTimeoutStatus(t *testing.T) {
	observed := make(chan int, 1)
	router, _ := testRouter(t, httpx.RouterConfig{
		RequestTimeout: 20 * time.Millisecond,
		MetricsMiddleware: func(next http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				rec := &statusSpy{ResponseWriter: w, status: http.StatusOK}
				next.ServeHTTP(rec, r)
				observed <- rec.status
			})
		},
		Mount: func(api chi.Router) {
			api.Get("/slow", func(w http.ResponseWriter, r *http.Request) {
				<-r.Context().Done()
				w.WriteHeader(http.StatusOK)
			})
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/slow", nil))

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("client status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
	select {
	case got := <-observed:
		if got != http.StatusServiceUnavailable {
			t.Fatalf("metrics observed status %d, want %d (timeout must not be recorded as success)",
				got, http.StatusServiceUnavailable)
		}
	case <-time.After(time.Second):
		t.Fatal("metrics middleware never completed")
	}
}

func TestRouter_TimeoutRendersProblemJSON(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		RequestTimeout: 20 * time.Millisecond,
		Mount: func(api chi.Router) {
			api.Get("/slow", func(w http.ResponseWriter, r *http.Request) {
				<-r.Context().Done()
			})
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/slow", nil))

	if ct := rec.Header().Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q, want application/problem+json ", ct)
	}
	var problem httpx.Problem
	if err := json.Unmarshal(rec.Body.Bytes(), &problem); err != nil {
		t.Fatalf("timeout body is not valid problem+json: %v (%s)", err, rec.Body.String())
	}
	if problem.Status != http.StatusServiceUnavailable || problem.Type != httpx.ProblemTypeTimeout {
		t.Fatalf("problem = %+v, want status 503 and type %q", problem, httpx.ProblemTypeTimeout)
	}
}

// A handler that ignores context cancellation must not corrupt the response
// already sent to the client.
func TestRouter_LateHandlerWriteAfterTimeoutIsDiscarded(t *testing.T) {
	released := make(chan struct{})
	router, _ := testRouter(t, httpx.RouterConfig{
		RequestTimeout: 20 * time.Millisecond,
		Mount: func(api chi.Router) {
			api.Get("/slow", func(w http.ResponseWriter, r *http.Request) {
				<-r.Context().Done()
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusOK)
				_, _ = w.Write([]byte(`{"leaked":true}`))
				close(released)
			})
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/slow", nil))

	select {
	case <-released:
	case <-time.After(time.Second):
		t.Fatal("handler never finished")
	}

	if strings.Contains(rec.Body.String(), "leaked") {
		t.Fatalf("late handler write reached the client: %s", rec.Body.String())
	}
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
}

func TestRouter_PanicBecomesProblemJSON(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		Mount: func(api chi.Router) {
			api.Get("/boom", func(http.ResponseWriter, *http.Request) {
				panic("handler exploded")
			})
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/boom", nil))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusInternalServerError)
	}
	if strings.Contains(rec.Body.String(), "handler exploded") {
		t.Fatalf("panic value leaked to client: %s", rec.Body.String())
	}
}

type statusSpy struct {
	http.ResponseWriter
	status int
}

func (s *statusSpy) WriteHeader(status int) {
	s.status = status
	s.ResponseWriter.WriteHeader(status)
}

// A non-critical dependency must not take the instance out of rotation.
func TestReadyz_NonCriticalFailureStaysInRotation(t *testing.T) {
	router, logs := testRouter(t, httpx.RouterConfig{
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return nil }, Critical: true},
			{Name: "analytics", Probe: func(context.Context) error { return errors.New("analytics down") }},
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d for a non-critical failure", rec.Code, http.StatusOK)
	}
	if got := rec.Header().Get("X-Readiness"); got != "degraded" {
		t.Fatalf("X-Readiness = %q, want \"degraded\"", got)
	}
	if !strings.Contains(logs.String(), "analytics down") {
		t.Fatalf("degraded probe error must still be logged, got: %s", logs.String())
	}
}

// A critical dependency still fails readiness.
func TestReadyz_CriticalFailureLeavesRotation(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: func(context.Context) error { return errors.New("down") }, Critical: true},
			{Name: "analytics", Probe: func(context.Context) error { return nil }},
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/readyz", nil))

	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
	}
}

// The docs mount must serve the spec, not the page that asks for it.
func TestDocsMount_ServesSpecNotShell(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{DocsHandler: contracts.Handler()})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/docs/openapi.yaml", nil))

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/yaml" {
		t.Fatalf("Content-Type = %q, want application/yaml", ct)
	}
	if !strings.Contains(rec.Body.String(), "openapi: 3.1.0") {
		t.Fatal("spec route served something other than the OpenAPI document")
	}
	if strings.Contains(rec.Body.String(), "SwaggerUIBundle") {
		t.Fatal("spec route fell through to the Swagger UI shell")
	}
}

// Both spellings of the mount point reach the page.
func TestDocsMount_IndexOnBothSpellings(t *testing.T) {
	router, _ := testRouter(t, httpx.RouterConfig{DocsHandler: contracts.Handler()})

	for _, path := range []string{"/docs", "/docs/"} {
		rec := httptest.NewRecorder()
		router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))

		if rec.Code != http.StatusOK {
			t.Fatalf("GET %s: status = %d, want %d", path, rec.Code, http.StatusOK)
		}
		if !strings.Contains(rec.Body.String(), "SwaggerUIBundle") {
			t.Fatalf("GET %s: did not serve the Swagger UI shell", path)
		}
	}
}
