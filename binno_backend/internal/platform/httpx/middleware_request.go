package httpx

import (
	"log/slog"
	"net/http"

	"github.com/google/uuid"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

const requestIDHeader = "X-Request-Id"

// RequestID assigns a UUID v7 request ID, sets it on the response, and attaches
// a request-scoped logger to the context.
func RequestID(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			id := inboundRequestID(r)
			w.Header().Set(requestIDHeader, id)

			scoped := logger.With("request_id", id)
			if span := trace.SpanFromContext(r.Context()); span.IsRecording() {
				span.SetAttributes(attribute.String("request_id", id))
			}

			ctx := logging.IntoContext(r.Context(), scoped)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func inboundRequestID(r *http.Request) string {
	if inbound := r.Header.Get(requestIDHeader); inbound != "" {
		if parsed, err := uuid.Parse(inbound); err == nil {
			return parsed.String()
		}
	}
	generated, err := uuid.NewV7()
	if err != nil {
		generated = uuid.New()
	}
	return generated.String()
}
