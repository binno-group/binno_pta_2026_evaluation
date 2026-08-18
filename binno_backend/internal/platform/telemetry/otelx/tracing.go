package otelx

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
	"go.opentelemetry.io/otel/trace"
)

// TracingMiddleware starts a server span for every request and extracts any
// inbound W3C traceparent, so trace_id/span_id exist before logging, metrics and
// handlers run .
func TracingMiddleware(service string) func(http.Handler) http.Handler {
	instrument := otelhttp.NewMiddleware(service)
	return func(next http.Handler) http.Handler {
		return instrument(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			next.ServeHTTP(w, r)
			nameSpanAfterRouting(r)
		}))
	}
}

// nameSpanAfterRouting replaces the pre-routing span name with the chi route
// pattern.
func nameSpanAfterRouting(r *http.Request) {
	rctx := chi.RouteContext(r.Context())
	if rctx == nil || rctx.RoutePattern() == "" {
		return
	}
	span := trace.SpanFromContext(r.Context())
	if !span.IsRecording() {
		return
	}
	span.SetName(r.Method + " " + rctx.RoutePattern())
	span.SetAttributes(semconv.HTTPRoute(rctx.RoutePattern()))
}
