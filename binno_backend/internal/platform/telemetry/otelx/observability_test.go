package otelx_test

import (
	"bytes"
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/otelx"
)

// TestObservabilityWired: OTel is live from the first endpoint.
func TestObservabilityWired(t *testing.T) {
	provider, err := otelx.NewProvider(context.Background(), "binno-test", "")
	if err != nil {
		t.Fatalf("NewProvider: %v", err)
	}
	t.Cleanup(func() { _ = provider.Shutdown(context.Background()) })

	var logs bytes.Buffer
	logger := logging.New(&logs, slog.LevelInfo)

	metrics := otelx.NewREDMetrics(clock.New())
	router := httpx.NewRouter(httpx.RouterConfig{
		Logger:            logger,
		RequestTimeout:    time.Second,
		TracingMiddleware: otelx.TracingMiddleware("binno-test"),
		MetricsMiddleware: metrics.Middleware,
		MetricsHandler:    otelx.MetricsHandler(),
		Mount: func(api chi.Router) {
			api.Get("/probe/{id}", func(w http.ResponseWriter, r *http.Request) {
				logging.FromContext(r.Context()).InfoContext(r.Context(), "probe handled")
				w.WriteHeader(http.StatusOK)
			})
		},
	})

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/probe/42", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("probe status = %d, want 200", rec.Code)
	}

	traceID := traceIDFromLogs(t, logs.Bytes())
	if traceID == "" || traceID == "00000000000000000000000000000000" {
		t.Fatalf("log line carries no usable trace_id (got %q); tracing middleware is not wired", traceID)
	}

	metricsRec := httptest.NewRecorder()
	router.ServeHTTP(metricsRec, httptest.NewRequest(http.MethodGet, "/metrics", nil))
	body := metricsRec.Body.String()
	for _, series := range []string{"binno_http_requests_total", "binno_http_request_duration_seconds"} {
		if !strings.Contains(body, series) {
			t.Errorf("/metrics missing RED series %q", series)
		}
	}
	if !strings.Contains(body, `route="/api/v1/probe/{id}"`) {
		t.Errorf("/metrics does not label by chi route pattern:\n%s", body)
	}
}

func traceIDFromLogs(t *testing.T, raw []byte) string {
	t.Helper()
	for _, line := range bytes.Split(bytes.TrimSpace(raw), []byte("\n")) {
		if len(line) == 0 {
			continue
		}
		var entry struct {
			Msg     string `json:"msg"`
			TraceID string `json:"trace_id"`
		}
		if err := json.Unmarshal(line, &entry); err != nil {
			t.Fatalf("log line is not JSON: %s", line)
		}
		if entry.Msg == "probe handled" {
			return entry.TraceID
		}
	}
	t.Fatal("handler log line not found")
	return ""
}
