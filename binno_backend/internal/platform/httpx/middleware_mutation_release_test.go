package httpx_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/idempotency"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// contextObservingStore records whether the context handed to the post-handler
// bookkeeping was already cancelled.
type contextObservingStore struct {
	releaseErr    error
	releaseCalled bool
	releaseCtxErr error
	saveCalled    bool
	saveCtxErr    error
}

func (s *contextObservingStore) Reserve(context.Context, string, string) (idempotency.Outcome, idempotency.StoredResponse, error) {
	return idempotency.Acquired, idempotency.StoredResponse{}, nil
}

func (s *contextObservingStore) SaveResponse(ctx context.Context, _ string, _ idempotency.StoredResponse) error {
	s.saveCalled = true
	s.saveCtxErr = ctx.Err()
	return nil
}

func (s *contextObservingStore) Release(ctx context.Context, _ string) error {
	s.releaseCalled = true
	s.releaseCtxErr = ctx.Err()
	return s.releaseErr
}

// serveWithCancelledRequest runs a mutation whose request context is already
// cancelled by the time the handler returns, the state every request is in after
// Timeout fires.
func serveWithCancelledRequest(t *testing.T, store *contextObservingStore, status int) {
	t.Helper()
	support := httpx.MutationSupport{
		Audit:       &recordedAudit{},
		Idempotency: store,
		Clock:       clock.NewFixed(time.Date(2026, 7, 30, 10, 0, 0, 0, time.UTC)),
	}

	ctx, cancel := context.WithCancel(context.Background())
	req := httptest.NewRequest(http.MethodPost, "/api/v1/orders", nil).WithContext(ctx)
	req.Header.Set("Idempotency-Key", "key-under-test")

	handler := httpx.WithMutationSupport(support)(
		httpx.Mutating("orders", "create_order", func(w http.ResponseWriter, _ *http.Request) {
			cancel()
			w.WriteHeader(status)
		}))
	handler.ServeHTTP(httptest.NewRecorder(), req)
}

// A mutation that times out must still free its Idempotency-Key.
func TestMutating_ReleasesKeyAfterRequestContextIsCancelled(t *testing.T) {
	store := &contextObservingStore{}
	serveWithCancelledRequest(t, store, http.StatusServiceUnavailable)

	if !store.releaseCalled {
		t.Fatal("Release was never called for a failed mutation")
	}
	if store.releaseCtxErr != nil {
		t.Errorf("Release ran on a cancelled context (%v): the key stays reserved "+
			"for reservationTTL and the client's retry gets 409", store.releaseCtxErr)
	}
}

// The same applies to caching a successful response: a 2xx that raced the
// timeout must still be replayable, or the retry re-executes the mutation.
func TestMutating_CachesResponseAfterRequestContextIsCancelled(t *testing.T) {
	store := &contextObservingStore{}
	serveWithCancelledRequest(t, store, http.StatusCreated)

	if !store.saveCalled {
		t.Fatal("SaveResponse was never called for a successful mutation")
	}
	if store.saveCtxErr != nil {
		t.Errorf("SaveResponse ran on a cancelled context (%v): the response is not "+
			"cached and a retry re-executes the mutation", store.saveCtxErr)
	}
}
