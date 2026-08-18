package httpx_test

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

func TestWriteProblem_AppError(t *testing.T) {
	appErr := httpx.NewAppError("https://binno.dev/problems/otp-expired", "OTP Expired", http.StatusUnprocessableEntity, "the code has expired", errors.New("otp: ttl exceeded"))

	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/otp/verify", nil)

	httpx.WriteProblem(rec, req, appErr)

	if rec.Code != http.StatusUnprocessableEntity {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusUnprocessableEntity)
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q, want application/problem+json", ct)
	}

	var body httpx.Problem
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if body.Type != appErr.ProblemType || body.Title != appErr.Title || body.Detail != appErr.Detail {
		t.Fatalf("body = %+v, want fields from %+v", body, appErr)
	}
	if body.Instance != req.URL.Path {
		t.Fatalf("Instance = %q, want %q", body.Instance, req.URL.Path)
	}
}

func TestWriteProblem_UnrecognizedErrorBecomesGeneric500(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/whatever", nil)

	httpx.WriteProblem(rec, req, errors.New("boom: leaked internal detail"))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusInternalServerError)
	}

	var body httpx.Problem
	if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
		t.Fatalf("decode body: %v", err)
	}
	if body.Title != "Internal Server Error" {
		t.Fatalf("Title = %q, want generic title", body.Title)
	}
	if want := "boom: leaked internal detail"; body.Detail == want || rec.Body.String() == want {
		t.Fatalf("raw error text %q leaked into the client-facing response", want)
	}
}

func TestWriteProblem_BudgetExhaustionIsShedNotFault(t *testing.T) {
	cases := map[string]error{
		"pool acquire":     fmt.Errorf("orders: begin create: %w", context.DeadlineExceeded),
		"query wait":       fmt.Errorf("catalog: load offer: timeout: %w", context.DeadlineExceeded),
		"caller went away": fmt.Errorf("dedup: reserve mutation: %w", context.Canceled),
		"bare deadline":    context.DeadlineExceeded,
		// PostgreSQL trips its own statement_timeout / lock_timeout before the Go
		// context deadline does; those come back as pgconn SQLSTATEs that never
		// match the context sentinels, and must still shed as 503 not fault as 500.
		"statement timeout": fmt.Errorf("orders: reserve stock: %w",
			&pgconn.PgError{Code: "57014", Message: "canceling statement due to statement timeout"}),
		"lock not available": fmt.Errorf("orders: lock offer: %w",
			&pgconn.PgError{Code: "55P03", Message: "canceling statement due to lock timeout"}),
	}
	for name, err := range cases {
		t.Run(name, func(t *testing.T) {
			rec := httptest.NewRecorder()
			req := httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil)

			httpx.WriteProblem(rec, req, err)

			if rec.Code != http.StatusServiceUnavailable {
				t.Fatalf("status = %d, want %d", rec.Code, http.StatusServiceUnavailable)
			}
			if got := rec.Header().Get("Retry-After"); got == "" {
				t.Error("no Retry-After: the client cannot tell this is worth retrying")
			}
			var body httpx.Problem
			if err := json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
				t.Fatalf("decode body: %v", err)
			}
			if body.Type != httpx.ProblemTypeTimeout {
				t.Errorf("Type = %q, want %q", body.Type, httpx.ProblemTypeTimeout)
			}
		})
	}
}

func TestWriteProblem_DeliberateStatusSurvivesADeadline(t *testing.T) {
	for _, status := range []int{
		http.StatusConflict,
		http.StatusUnprocessableEntity,
		http.StatusNotFound,
	} {
		appErr := httpx.NewAppError("https://binno.uz/problems/orders", "Conflict", status,
			"", fmt.Errorf("wrapped: %w", context.DeadlineExceeded))

		rec := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil)
		httpx.WriteProblem(rec, req, appErr)

		if rec.Code != status {
			t.Errorf("status = %d, want %d (the module's own classification)", rec.Code, status)
		}
	}
}

func TestWriteProblem_GenuineFaultStaysA500(t *testing.T) {
	rec := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/api/v1/orders", nil)

	httpx.WriteProblem(rec, req, errors.New("nil map write"))

	if rec.Code != http.StatusInternalServerError {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusInternalServerError)
	}
	if rec.Header().Get("Retry-After") != "" {
		t.Error("Retry-After on a fault invites a retry that cannot help")
	}
}
