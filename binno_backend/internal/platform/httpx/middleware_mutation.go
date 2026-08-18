package httpx

import (
	"bytes"
	"context"
	"errors"
	"io"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/idempotency"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

// Mutating is the required registration path for state-changing routes.

const (
	idempotencyKeyHeader    = "Idempotency-Key"
	idempotencyReplayHeader = "Idempotency-Replayed"

	// bookkeepingTimeout bounds the post-handler idempotency writes.
	bookkeepingTimeout = time.Second
)

// AuditEntry is one access record for a mutating request.
type AuditEntry struct {
	Module    string
	Action    string
	Method    string
	Route     string
	Status    int
	RequestID string
	At        time.Time
}

// AuditRecorder persists audit entries.
type AuditRecorder interface {
	Record(ctx context.Context, entry AuditEntry) error
}

// LogAuditRecorder writes mutation access records to structured logs.
type LogAuditRecorder struct{}

// NewLogAuditRecorder returns the log-backed AuditRecorder.
func NewLogAuditRecorder() LogAuditRecorder { return LogAuditRecorder{} }

// Record emits one structured "audit" line for entry.
func (LogAuditRecorder) Record(ctx context.Context, entry AuditEntry) error {
	logging.FromContext(ctx).InfoContext(ctx, "audit",
		"module", entry.Module,
		"action", entry.Action,
		"method", entry.Method,
		"route", entry.Route,
		"status", entry.Status,
		"request_id", entry.RequestID,
		"at", entry.At.Format(time.RFC3339Nano),
	)
	return nil
}

// IdempotencyStore defines the storage operations required by Mutating.
type IdempotencyStore interface {
	Reserve(ctx context.Context, key, fingerprint string) (idempotency.Outcome, idempotency.StoredResponse, error)
	SaveResponse(ctx context.Context, key string, response idempotency.StoredResponse) error
	Release(ctx context.Context, key string) error
}

// maxFingerprintBody bounds how much of a request body is buffered to compute
// its idempotency fingerprint.
const maxFingerprintBody = 1 << 20

// MutationSupport contains shared mutation middleware dependencies.
type MutationSupport struct {
	Audit       AuditRecorder
	Idempotency IdempotencyStore
	Clock       clock.Clock
	// Subject returns the caller ID used to namespace idempotency keys.
	Subject func(ctx context.Context) string
}

type (
	mutationSupportKey     struct{}
	operationKeyContextKey struct{}
)

// OperationKey returns the stable, caller-scoped key of the current mutation.
func OperationKey(ctx context.Context) string {
	key, _ := ctx.Value(operationKeyContextKey{}).(string)
	return key
}

// WithMutationSupport puts s in the request context for Mutating to find.
func WithMutationSupport(s MutationSupport) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), mutationSupportKey{}, s)))
		})
	}
}

func mutationSupportFrom(ctx context.Context) (MutationSupport, bool) {
	s, ok := ctx.Value(mutationSupportKey{}).(MutationSupport)
	return s, ok
}

// Mutating wraps h with audit logging and Idempotency-Key support for the
// mutating endpoint identified by module and action (e.g.
func Mutating(module, action string, h http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		support, ok := mutationSupportFrom(r.Context())
		if !ok {
			logging.FromContext(r.Context()).ErrorContext(r.Context(),
				"mutating route without mutation support", "module", module, "action", action)
			WriteProblem(w, r, NewAppError(ProblemTypeInternal, "Internal Server Error",
				http.StatusInternalServerError, "", nil))
			return
		}

		key := r.Header.Get(idempotencyKeyHeader)
		if key == "" {
			WriteProblem(w, r, NewAppError(
				ProblemTypeIdempotencyKeyRequired,
				"Bad Request",
				http.StatusBadRequest,
				"Idempotency-Key header is required",
				nil,
			))
			audit(w, r, support, module, action, http.StatusBadRequest)
			return
		}
		fingerprint, err := fingerprintBody(r)
		if errors.Is(err, errBodyTooLarge) {
			WriteProblem(w, r, NewAppError("https://binno.uz/problems/validation", "Payload Too Large",
				http.StatusRequestEntityTooLarge,
				"request body exceeds the mutation size limit", err))
			audit(w, r, support, module, action, http.StatusRequestEntityTooLarge)
			return
		}
		if err != nil {
			WriteProblem(w, r, NewAppError("https://binno.uz/problems/validation", "Bad Request",
				http.StatusBadRequest, "request body could not be read", err))
			audit(w, r, support, module, action, http.StatusBadRequest)
			return
		}

		scopedKey := support.scopedKey(r.Context(), module, action, key)
		status := serveIdempotent(w, r, h, support, scopedKey, fingerprint)
		audit(w, r, support, module, action, status)
	}
}

// errBodyTooLarge reports a mutation body past maxFingerprintBody: an
// unfingerprintable body would defeat key-reuse detection, so it is refused
// rather than waved through.
var errBodyTooLarge = errors.New("httpx: mutation body exceeds fingerprint limit")

// fingerprintBody reads the request body, fingerprints it, and puts it back so
// the handler still sees a complete stream.
func fingerprintBody(r *http.Request) (string, error) {
	if r.Body == nil {
		return idempotency.Fingerprint(nil), nil
	}
	buffered, err := io.ReadAll(io.LimitReader(r.Body, maxFingerprintBody+1))
	if err != nil {
		return "", err
	}
	r.Body = &restoredBody{
		Reader: io.MultiReader(bytes.NewReader(buffered), r.Body),
		Closer: r.Body,
	}
	if len(buffered) > maxFingerprintBody {
		return "", errBodyTooLarge
	}
	return idempotency.Fingerprint(buffered), nil
}

// restoredBody re-attaches the original Closer to a rebuilt read stream, so
// buffering the body for a fingerprint does not leak the connection's reader.
type restoredBody struct {
	io.Reader
	io.Closer
}

// scopedKey namespaces the client's key by caller and endpoint.
func (s MutationSupport) scopedKey(ctx context.Context, module, action, key string) string {
	subject := "anonymous"
	if s.Subject != nil {
		if id := s.Subject(ctx); id != "" {
			subject = id
		}
	}
	return subject + ":" + module + ":" + action + ":" + key
}

func serveIdempotent(w http.ResponseWriter, r *http.Request, h http.HandlerFunc,
	support MutationSupport, key, fingerprint string,
) int {
	outcome, stored, err := support.Idempotency.Reserve(r.Context(), key, fingerprint)
	if err != nil {
		return writeUnavailable(w, r, err, "reserve idempotency key")
	}

	switch outcome {
	case idempotency.Replay:
		return replay(w, stored)
	case idempotency.InFlight:
		WriteProblem(w, r, NewAppError(ProblemTypeIdempotencyConflict, "Conflict",
			http.StatusConflict, "a request with this Idempotency-Key is still in flight", nil))
		return http.StatusConflict
	case idempotency.Mismatch:
		WriteProblem(w, r, NewAppError(ProblemTypeIdempotencyKeyReuse, "Unprocessable Entity",
			http.StatusUnprocessableEntity,
			"this Idempotency-Key was already used with a different request body", nil))
		return http.StatusUnprocessableEntity
	case idempotency.Acquired:
	}

	captured := &capturingWriter{ResponseWriter: w, status: http.StatusOK, body: &bytes.Buffer{}}
	ctx := context.WithValue(r.Context(), operationKeyContextKey{}, key)
	h(captured, r.WithContext(ctx))

	ctx, cancel := context.WithTimeout(context.WithoutCancel(r.Context()), bookkeepingTimeout)
	defer cancel()

	if captured.status >= 200 && captured.status < 300 {
		response := idempotency.StoredResponse{Status: captured.status, Body: captured.body.Bytes()}
		if err := support.Idempotency.SaveResponse(ctx, key, response); err != nil {
			logging.FromContext(r.Context()).ErrorContext(r.Context(),
				"idempotency response not cached", "err", err)
		}
		return captured.status
	}

	if err := support.Idempotency.Release(ctx, key); err != nil {
		logging.FromContext(r.Context()).ErrorContext(r.Context(),
			"idempotency key not released", "err", err)
	}
	return captured.status
}

// replay returns the first response for this key verbatim.
func replay(w http.ResponseWriter, stored idempotency.StoredResponse) int {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set(idempotencyReplayHeader, "true")
	w.WriteHeader(stored.Status)
	_, _ = w.Write(stored.Body)
	return stored.Status
}

func writeUnavailable(w http.ResponseWriter, r *http.Request, err error, what string) int {
	logging.FromContext(r.Context()).ErrorContext(r.Context(), what+" failed", "err", err)
	if errors.Is(err, idempotency.ErrUnavailable) {
		WriteProblem(w, r, NewAppError(ProblemTypeDependencyUnavailable, "Service Unavailable",
			http.StatusServiceUnavailable, "idempotency store unavailable, retry later", nil))
		return http.StatusServiceUnavailable
	}
	WriteProblem(w, r, NewAppError(ProblemTypeInternal, "Internal Server Error",
		http.StatusInternalServerError, "", nil))
	return http.StatusInternalServerError
}

func audit(w http.ResponseWriter, r *http.Request, support MutationSupport, module, action string, status int) {
	entry := AuditEntry{
		Module:    module,
		Action:    action,
		Method:    r.Method,
		Route:     routePattern(r),
		Status:    status,
		RequestID: w.Header().Get(requestIDHeader),
		At:        support.Clock.Now(),
	}
	if err := support.Audit.Record(r.Context(), entry); err != nil {
		logging.FromContext(r.Context()).ErrorContext(r.Context(),
			"audit entry not recorded", "module", module, "action", action, "err", err)
	}
}

func routePattern(r *http.Request) string {
	if rc := chi.RouteContext(r.Context()); rc != nil && rc.RoutePattern() != "" {
		return rc.RoutePattern()
	}
	return r.URL.Path
}

// capturingWriter records the status a handler produced, and optionally its
// body, so the wrapper can audit and cache the response without the handler
// knowing it is being observed.
type capturingWriter struct {
	http.ResponseWriter
	status int
	body   *bytes.Buffer
}

func (c *capturingWriter) WriteHeader(status int) {
	c.status = status
	c.ResponseWriter.WriteHeader(status)
}

func (c *capturingWriter) Write(p []byte) (int, error) {
	if c.body != nil {
		c.body.Write(p)
	}
	return c.ResponseWriter.Write(p)
}

// WithOperationKey binds a stable operation key to ctx for a mutation that does
// not arrive over HTTP.
func WithOperationKey(ctx context.Context, key string) context.Context {
	return context.WithValue(ctx, operationKeyContextKey{}, key)
}
