package httpx_test

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/idempotency"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// every mutating route carries an audit entry and honours Idempotency-Key.

type recordedAudit struct {
	entries []httpx.AuditEntry
	err     error
}

func (r *recordedAudit) Record(_ context.Context, entry httpx.AuditEntry) error {
	r.entries = append(r.entries, entry)
	return r.err
}

type fakeIdempotency struct {
	outcome     idempotency.Outcome
	stored      idempotency.StoredResponse
	reserve     error
	saved       *idempotency.StoredResponse
	released    bool
	reservedAs  string
	fingerprint string
}

func (f *fakeIdempotency) Reserve(_ context.Context, key, fingerprint string) (idempotency.Outcome, idempotency.StoredResponse, error) {
	f.reservedAs = key
	f.fingerprint = fingerprint
	return f.outcome, f.stored, f.reserve
}

func (f *fakeIdempotency) SaveResponse(_ context.Context, _ string, response idempotency.StoredResponse) error {
	f.saved = &response
	return nil
}

func (f *fakeIdempotency) Release(context.Context, string) error {
	f.released = true
	return nil
}

func handlerWriting(status int, body string, calls *int) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		*calls++
		w.WriteHeader(status)
		_, _ = fmt.Fprint(w, body)
	}
}

func serveMutating(t *testing.T, support httpx.MutationSupport, key string, h http.HandlerFunc) *httptest.ResponseRecorder {
	t.Helper()
	return serveMutatingBody(t, support, key, "", h)
}

func serveMutatingBody(t *testing.T, support httpx.MutationSupport, key, body string, h http.HandlerFunc) *httptest.ResponseRecorder {
	t.Helper()
	var req *http.Request
	if body == "" {
		req = httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil)
	} else {
		req = httptest.NewRequest(http.MethodPost, "/api/v1/orders", strings.NewReader(body))
	}
	if key != "" {
		req.Header.Set("Idempotency-Key", key)
	}
	rec := httptest.NewRecorder()
	handler := httpx.WithMutationSupport(support)(httpx.Mutating("orders", "create_order", h))
	handler.ServeHTTP(rec, req)
	return rec
}

func fixedSupport(audit *recordedAudit, store *fakeIdempotency) httpx.MutationSupport {
	return httpx.MutationSupport{
		Audit:       audit,
		Idempotency: store,
		Clock:       clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)),
	}
}

func TestMutating_AuditsEveryRequest(t *testing.T) {
	tests := []struct {
		name       string
		key        string
		outcome    idempotency.Outcome
		handler    int
		wantStatus int
		wantCalls  int
	}{
		{name: "no key is rejected", key: "", outcome: idempotency.Acquired, handler: http.StatusCreated, wantStatus: http.StatusBadRequest, wantCalls: 0},
		{name: "acquired runs handler", key: "k1", outcome: idempotency.Acquired, handler: http.StatusCreated, wantStatus: http.StatusCreated, wantCalls: 1},
		{name: "in flight is a conflict", key: "k1", outcome: idempotency.InFlight, handler: http.StatusCreated, wantStatus: http.StatusConflict, wantCalls: 0},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			calls := 0
			audit := &recordedAudit{}
			store := &fakeIdempotency{outcome: tc.outcome}

			rec := serveMutating(t, fixedSupport(audit, store), tc.key, handlerWriting(tc.handler, `{"id":"1"}`, &calls))

			if rec.Code != tc.wantStatus {
				t.Errorf("status = %d, want %d", rec.Code, tc.wantStatus)
			}
			if calls != tc.wantCalls {
				t.Errorf("handler calls = %d, want %d", calls, tc.wantCalls)
			}
			if len(audit.entries) != 1 {
				t.Fatalf("audit entries = %d, want exactly 1", len(audit.entries))
			}
			entry := audit.entries[0]
			if entry.Module != "orders" || entry.Action != "create_order" || entry.Method != http.MethodPost {
				t.Errorf("audit entry = %+v, want module/action/method of the route", entry)
			}
			if entry.Status != tc.wantStatus {
				t.Errorf("audit status = %d, want %d; the audit records what the client was told", entry.Status, tc.wantStatus)
			}
		})
	}
}

func TestMutating_ScopesTheKeyToTheCaller(t *testing.T) {
	reservedFor := func(t *testing.T, subject string) string {
		t.Helper()
		calls := 0
		store := &fakeIdempotency{outcome: idempotency.Acquired}
		support := fixedSupport(&recordedAudit{}, store)
		support.Subject = func(context.Context) string { return subject }

		req := httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil)
		req.Header.Set("Idempotency-Key", "shared-key")
		handler := httpx.WithMutationSupport(support)(
			httpx.Mutating("orders", "create_order", handlerWriting(http.StatusCreated, "{}", &calls)))
		handler.ServeHTTP(httptest.NewRecorder(), req)

		return store.reservedAs
	}

	buyer, supplier := reservedFor(t, "buyer-1"), reservedFor(t, "supplier-2")

	if buyer == supplier {
		t.Fatalf("both callers reserved %q; one caller could replay the other's response", buyer)
	}
	if !strings.Contains(buyer, "buyer-1") || !strings.Contains(buyer, "create_order") {
		t.Errorf("reserved key %q does not name the caller and the endpoint", buyer)
	}
}

func TestMutating_ReplayReturnsFirstResponseWithoutRunningHandler(t *testing.T) {
	calls := 0
	store := &fakeIdempotency{
		outcome: idempotency.Replay,
		stored:  idempotency.StoredResponse{Status: http.StatusCreated, Body: []byte(`{"id":"first"}`)},
	}

	rec := serveMutating(t, fixedSupport(&recordedAudit{}, store), "k1", handlerWriting(http.StatusCreated, `{"id":"second"}`, &calls))

	if calls != 0 {
		t.Errorf("handler ran %d times on replay; the mutation must execute at most once", calls)
	}
	if rec.Code != http.StatusCreated || rec.Body.String() != `{"id":"first"}` {
		t.Errorf("replay = %d %q, want the stored response verbatim", rec.Code, rec.Body.String())
	}
	if rec.Header().Get("Idempotency-Replayed") != "true" {
		t.Error("replayed response is not marked with Idempotency-Replayed")
	}
}

func TestMutating_CachesSuccessButKeepsFailuresRetryable(t *testing.T) {
	tests := []struct {
		name      string
		status    int
		wantSaved bool
	}{
		{name: "2xx is cached", status: http.StatusCreated, wantSaved: true},
		{name: "4xx stays retryable", status: http.StatusUnprocessableEntity, wantSaved: false},
		{name: "5xx stays retryable", status: http.StatusInternalServerError, wantSaved: false},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			calls := 0
			store := &fakeIdempotency{outcome: idempotency.Acquired}

			serveMutating(t, fixedSupport(&recordedAudit{}, store), "k1", handlerWriting(tc.status, `{"id":"1"}`, &calls))

			if tc.wantSaved {
				if store.saved == nil {
					t.Fatal("successful mutation was not cached for replay")
				}
				if store.saved.Status != tc.status || string(store.saved.Body) != `{"id":"1"}` {
					t.Errorf("cached %d %q, want the handler's own response", store.saved.Status, store.saved.Body)
				}
				if store.released {
					t.Error("successful mutation released its key; a retry would re-execute it")
				}
				return
			}
			if store.saved != nil {
				t.Error("failed mutation was cached; the client could never retry within 24h")
			}
			if !store.released {
				t.Error("failed mutation did not release its key; retries would be rejected until the reservation expires")
			}
		})
	}
}

func TestMutating_FailsClosedWhenIdempotencyStoreIsDown(t *testing.T) {
	calls := 0
	store := &fakeIdempotency{reserve: fmt.Errorf("%w: dial tcp: connection refused", idempotency.ErrUnavailable)}

	rec := serveMutating(t, fixedSupport(&recordedAudit{}, store), "k1", handlerWriting(http.StatusCreated, "{}", &calls))

	if calls != 0 {
		t.Errorf("handler ran %d times with an unreachable store; must fail closed", calls)
	}
	if rec.Code != http.StatusServiceUnavailable {
		t.Errorf("status = %d, want 503", rec.Code)
	}
	if got := rec.Header().Get("Content-Type"); got != "application/problem+json" {
		t.Errorf("content type = %q, want application/problem+json", got)
	}
}

func TestMutating_RefusesToRunWithoutMutationSupport(t *testing.T) {
	calls := 0
	req := httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil)
	rec := httptest.NewRecorder()

	httpx.Mutating("orders", "create_order", handlerWriting(http.StatusCreated, "{}", &calls))(rec, req)

	if calls != 0 {
		t.Errorf("handler ran %d times without audit support; an unaudited mutation must never execute", calls)
	}
	if rec.Code != http.StatusInternalServerError {
		t.Errorf("status = %d, want 500", rec.Code)
	}
}

func TestMutating_AuditFailureDoesNotRewriteTheClientsAnswer(t *testing.T) {
	calls := 0
	audit := &recordedAudit{err: errors.New("audit store down")}

	rec := serveMutating(t, fixedSupport(audit, &fakeIdempotency{outcome: idempotency.Acquired}), "key-1",
		handlerWriting(http.StatusCreated, `{"id":"1"}`, &calls))

	if rec.Code != http.StatusCreated {
		t.Errorf("status = %d, want 201; the mutation happened, so the response must say so", rec.Code)
	}
}

func TestMutating_RequiresIdempotencyKey(t *testing.T) {
	calls := 0
	audit := &recordedAudit{}

	rec := serveMutating(t, fixedSupport(audit, &fakeIdempotency{outcome: idempotency.Acquired}), "",
		handlerWriting(http.StatusCreated, `{"id":"1"}`, &calls))

	if rec.Code != http.StatusBadRequest {
		t.Errorf("status = %d, want 400", rec.Code)
	}
	if calls != 0 {
		t.Errorf("handler ran %d times without Idempotency-Key, want 0", calls)
	}
}

// The fingerprint is what makes key reuse detectable, so the middleware must
// compute it from the body the caller actually sent, and must hand that body on
// to the handler intact, since buffering it is the whole mechanism.
func TestMutating_FingerprintsTheBodyAndStillDeliversIt(t *testing.T) {
	audit := &recordedAudit{}
	store := &fakeIdempotency{outcome: idempotency.Acquired}

	var seen string
	rec := serveMutatingBody(t, fixedSupport(audit, store), "k1", `{"qty":"1"}`,
		func(w http.ResponseWriter, r *http.Request) {
			body, err := io.ReadAll(r.Body)
			if err != nil {
				t.Errorf("handler could not read the body: %v", err)
			}
			seen = string(body)
			w.WriteHeader(http.StatusCreated)
		})

	if rec.Code != http.StatusCreated {
		t.Fatalf("status = %d, want 201", rec.Code)
	}
	if seen != `{"qty":"1"}` {
		t.Errorf("handler saw body %q, want the original; buffering for the fingerprint must not consume it", seen)
	}
	if want := idempotency.Fingerprint([]byte(`{"qty":"1"}`)); store.fingerprint != want {
		t.Errorf("fingerprint = %q, want %q", store.fingerprint, want)
	}
}

// Measured before this existed: one key, bodies qty=1 then qty=7, answered
// 201/201 with BOTH returning the qty=1 order.
func TestMutating_KeyReuseWithADifferentBodyIsRefused(t *testing.T) {
	calls := 0
	audit := &recordedAudit{}
	store := &fakeIdempotency{outcome: idempotency.Mismatch}

	rec := serveMutatingBody(t, fixedSupport(audit, store), "k1", `{"qty":"7"}`,
		handlerWriting(http.StatusCreated, `{"id":"1"}`, &calls))

	if rec.Code != http.StatusUnprocessableEntity {
		t.Errorf("status = %d, want 422", rec.Code)
	}
	if calls != 0 {
		t.Errorf("handler ran %d times, want 0; a refused mutation must not execute", calls)
	}
	if !strings.Contains(rec.Body.String(), "idempotency-key-reuse") {
		t.Errorf("body = %s, want the idempotency-key-reuse problem type so a client can branch on it", rec.Body.String())
	}
	if len(audit.entries) != 1 || audit.entries[0].Status != http.StatusUnprocessableEntity {
		t.Errorf("audit = %+v, want one entry recording the 422 the client was told", audit.entries)
	}
}

// A body above the 1 MiB fingerprint limit is refused outright: an
// unfingerprintable body would defeat key-reuse detection, and no mutating
// endpoint accepts payloads that large anyway. Only the first 1 MiB is ever
// buffered, so an oversized request cannot be used as a memory amplifier.
func TestMutating_OversizedBodyIsRejected(t *testing.T) {
	audit := &recordedAudit{}
	store := &fakeIdempotency{outcome: idempotency.Acquired}
	big := strings.Repeat("x", (1<<20)+512)

	handlerRan := false
	rec := serveMutatingBody(t, fixedSupport(audit, store), "k1", big,
		func(w http.ResponseWriter, r *http.Request) {
			handlerRan = true
			w.WriteHeader(http.StatusCreated)
		})

	if rec.Code != http.StatusRequestEntityTooLarge {
		t.Fatalf("status = %d, want 413", rec.Code)
	}
	if handlerRan {
		t.Error("handler ran for a body the middleware should have refused")
	}
	if len(audit.entries) != 1 || audit.entries[0].Status != http.StatusRequestEntityTooLarge {
		t.Errorf("audit = %+v, want one entry recording the 413", audit.entries)
	}
}
