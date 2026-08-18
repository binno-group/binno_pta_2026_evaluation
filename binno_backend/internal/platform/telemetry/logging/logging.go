// Package logging provides structured slog JSON logging where every line carries
// trace_id/span_id from the active span, plus request_id/module/user_id attached
// per-request or per-module by callers.
package logging

import (
	"context"
	"io"
	"log/slog"

	"go.opentelemetry.io/otel/trace"
)

// New returns a JSON slog.Logger writing to w that enriches every record with
// the trace_id and span_id of the OTel span active in the record's context, if
// any.
func New(w io.Writer, level slog.Level) *slog.Logger {
	return slog.New(&traceHandler{Handler: slog.NewJSONHandler(w, &slog.HandlerOptions{Level: level})})
}

type traceHandler struct {
	slog.Handler
}

func (h *traceHandler) Handle(ctx context.Context, r slog.Record) error {
	if sc := trace.SpanContextFromContext(ctx); sc.IsValid() {
		r.AddAttrs(
			slog.String("trace_id", sc.TraceID().String()),
			slog.String("span_id", sc.SpanID().String()),
		)
	}
	return h.Handler.Handle(ctx, r)
}

func (h *traceHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return &traceHandler{Handler: h.Handler.WithAttrs(attrs)}
}

func (h *traceHandler) WithGroup(name string) slog.Handler {
	return &traceHandler{Handler: h.Handler.WithGroup(name)}
}

type ctxKey struct{}

// IntoContext stores logger in ctx so downstream code can retrieve the request-
// scoped logger (carrying request_id, etc.) via FromContext.
func IntoContext(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, ctxKey{}, logger)
}

// FromContext returns the logger stored by IntoContext, or a package default if
// none was attached, so callers always get a usable logger and never nil.
func FromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(ctxKey{}).(*slog.Logger); ok {
		return logger
	}
	return slog.Default()
}
