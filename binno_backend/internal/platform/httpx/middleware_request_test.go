package httpx_test

import (
	"bytes"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

func TestRequestID_RejectsForgedInboundHeader(t *testing.T) {
	forged := `not-a-uuid" ,"level":"ERROR","msg":"injected`
	var logs bytes.Buffer

	var loggedID string
	handler := httpx.RequestID(slog.New(slog.NewJSONHandler(&logs, nil)))(
		http.HandlerFunc(func(_ http.ResponseWriter, r *http.Request) {
			logging.FromContext(r.Context()).InfoContext(r.Context(), "handled")
		}))

	req := httptest.NewRequest(http.MethodGet, "/api/v1/orders", nil)
	req.Header.Set("X-Request-Id", forged)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	loggedID = rec.Header().Get("X-Request-Id")
	if _, err := uuid.Parse(loggedID); err != nil {
		t.Fatalf("emitted request id %q is not a UUID: %v", loggedID, err)
	}
	if strings.Contains(logs.String(), "injected") {
		t.Fatalf("forged header reached the structured log: %s", logs.String())
	}
}

func TestRequestID_ReusesValidInboundHeader(t *testing.T) {
	inbound := uuid.Must(uuid.NewV7()).String()

	handler := httpx.RequestID(slog.New(slog.NewJSONHandler(&bytes.Buffer{}, nil)))(
		http.HandlerFunc(func(http.ResponseWriter, *http.Request) {}))

	req := httptest.NewRequest(http.MethodGet, "/api/v1/orders", nil)
	req.Header.Set("X-Request-Id", inbound)
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	if got := rec.Header().Get("X-Request-Id"); got != inbound {
		t.Fatalf("request id = %q, want the valid inbound id %q", got, inbound)
	}
}
