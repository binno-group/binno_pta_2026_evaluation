// Package httpx holds the shared HTTP surface: the RFC 7807 problem mapper,
// cross-cutting middleware, and router assembly.
package httpx

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

// Problem type identifiers.
const (
	// ProblemTypeInternal is the catch-all for failures the client cannot act on.
	ProblemTypeInternal = "about:blank"
	// ProblemTypeTimeout marks a request that exceeded the server timeout budget .
	ProblemTypeTimeout = "https://binno.uz/problems/request-timeout"
	// ProblemTypeNotReady marks a readiness failure on /readyz.
	ProblemTypeNotReady = "https://binno.uz/problems/not-ready"
	// ProblemTypeIdempotencyConflict marks a retry that arrived while the first
	// request for the same Idempotency-Key is still running.
	ProblemTypeIdempotencyConflict = "https://binno.uz/problems/idempotency-conflict"
	// ProblemTypeDependencyUnavailable marks a request refused because a fail-
	// closed dependency (Redis, an internal call) was unreachable.
	ProblemTypeDependencyUnavailable = "https://binno.uz/problems/dependency-unavailable"
	// ProblemTypeIdempotencyKeyRequired marks a mutating request that omitted the
	// mandatory  header.
	ProblemTypeIdempotencyKeyRequired = "https://binno.uz/problems/idempotency-key-required"
	// ProblemTypeIdempotencyKeyReuse marks an Idempotency-Key presented with a
	// request body different from the one it was first used with.
	ProblemTypeIdempotencyKeyReuse = "https://binno.uz/problems/idempotency-key-reuse"
	// ProblemTypeUnauthorized marks a request with no valid credentials.
	ProblemTypeUnauthorized = "https://binno.uz/problems/unauthorized"
	// ProblemTypeForbidden marks an authenticated caller acting on a resource that
	// is not theirs.
	ProblemTypeForbidden = "https://binno.uz/problems/forbidden"
	// ProblemTypeRateLimited marks a caller that exceeded its request budget.
	ProblemTypeRateLimited = "https://binno.uz/problems/rate-limited"
	// ProblemTypeOverloaded marks a request shed because the server is at its
	// concurrency limit.
	ProblemTypeOverloaded = "https://binno.uz/problems/overloaded"
)

// Problem is an RFC 7807 application/problem+json body.
type Problem struct {
	Type     string `json:"type"`
	Title    string `json:"title"`
	Status   int    `json:"status"`
	Detail   string `json:"detail,omitempty"`
	Instance string `json:"instance,omitempty"`
}

// AppError is the one error type handlers/services return to signal an HTTP
// outcome.
type AppError struct {
	ProblemType string
	Title       string
	Status      int
	Detail      string
	Err         error
}

func (e *AppError) Error() string {
	if e.Err != nil {
		return e.Title + ": " + e.Err.Error()
	}
	return e.Title
}

func (e *AppError) Unwrap() error { return e.Err }

// NewAppError builds an AppError for the given problem type/title/status.
func NewAppError(problemType, title string, status int, detail string, err error) *AppError {
	return &AppError{ProblemType: problemType, Title: title, Status: status, Detail: detail, Err: err}
}

// WriteProblem maps err to an RFC 7807 response.
func WriteProblem(w http.ResponseWriter, r *http.Request, err error) {
	problem := Problem{
		Type:     ProblemTypeInternal,
		Title:    "Internal Server Error",
		Status:   http.StatusInternalServerError,
		Instance: r.URL.Path,
	}

	unmapped := false

	var appErr *AppError
	switch {
	case errors.As(err, &appErr):
		problem.Type = appErr.ProblemType
		problem.Title = appErr.Title
		problem.Status = appErr.Status
		problem.Detail = appErr.Detail
	case errors.Is(err, authz.ErrUnauthenticated):
		problem.Type = ProblemTypeUnauthorized
		problem.Title = "Unauthorized"
		problem.Status = http.StatusUnauthorized
		problem.Detail = "valid bearer token is required"
	case errors.Is(err, authz.ErrForbidden):
		problem.Type = ProblemTypeForbidden
		problem.Title = "Forbidden"
		problem.Status = http.StatusForbidden
		problem.Detail = "this resource belongs to another account"
	default:
		unmapped = true
	}

	if problem.Status >= http.StatusInternalServerError && isBudgetExhausted(err) {
		problem = Problem{
			Type:     ProblemTypeTimeout,
			Title:    "Service Unavailable",
			Status:   http.StatusServiceUnavailable,
			Detail:   "the server ran out of time for this request, retry shortly",
			Instance: r.URL.Path,
		}
		unmapped = false
	}

	// Every 503 this service emits means "come back shortly", so the hint is set
	// once here rather than remembered at each of the handlers that can produce
	// one. An earlier, more specific value wins.
	if problem.Status == http.StatusServiceUnavailable && w.Header().Get("Retry-After") == "" {
		w.Header().Set("Retry-After", "1")
	}

	logProblem(r, problem, err, unmapped)
	writeProblemBody(w, problem)
}

// isBudgetExhausted reports a failure that means "the server ran out of time,
// retry shortly" rather than "this request was wrong". It covers two distinct
// signals that both surface when a request starves under load: the Go request
// context deadline firing (pool acquire or query cancelled client-side), and
// PostgreSQL's own statement_timeout / lock_timeout tripping first, which comes
// back as a pgconn error with SQLSTATE 57014 or 55P03 that errors.Is against the
// context sentinels never matches. Both must map to 503, not 500.
func isBudgetExhausted(err error) bool {
	return errors.Is(err, context.DeadlineExceeded) ||
		errors.Is(err, context.Canceled) ||
		postgres.IsContentionTimeout(err)
}

func logProblem(r *http.Request, problem Problem, err error, unmapped bool) {
	if problem.Status < http.StatusInternalServerError {
		return
	}
	logger := logging.FromContext(r.Context())
	attrs := []any{
		"err", err,
		"status", problem.Status,
		"problem_type", problem.Type,
		"method", r.Method,
		"route", routePattern(r),
	}
	if problem.Status == http.StatusServiceUnavailable {
		logger.WarnContext(r.Context(), "request shed", attrs...)
		return
	}
	msg := "request failed"
	if unmapped {
		msg = "unhandled error"
	}
	logger.ErrorContext(r.Context(), msg, attrs...)
}

func writeProblemBody(w http.ResponseWriter, problem Problem) {
	w.Header().Set("Content-Type", "application/problem+json")
	w.WriteHeader(problem.Status)
	_ = json.NewEncoder(w).Encode(problem)
}
