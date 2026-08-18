package httpx_test

import (
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

// A request beyond the limit is refused immediately rather than queued.
func TestLimitInFlightShedsBeyondTheLimit(t *testing.T) {
	release := make(chan struct{})
	entered := make(chan struct{}, 1)
	handler := httpx.LimitInFlight(1)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		entered <- struct{}{}
		<-release
		w.WriteHeader(http.StatusOK)
	}))

	var wg sync.WaitGroup
	wg.Add(1)
	first := httptest.NewRecorder()
	go func() {
		defer wg.Done()
		handler.ServeHTTP(first, httptest.NewRequest(http.MethodGet, "/api/v1/search", nil))
	}()
	<-entered // the only slot is now occupied

	second := httptest.NewRecorder()
	handler.ServeHTTP(second, httptest.NewRequest(http.MethodGet, "/api/v1/search", nil))
	if second.Code != http.StatusServiceUnavailable {
		t.Fatalf("shed request status = %d, want %d", second.Code, http.StatusServiceUnavailable)
	}
	if got := second.Header().Get("Retry-After"); got == "" {
		t.Error("shed request carries no Retry-After header")
	}
	if got := second.Header().Get("Content-Type"); got != "application/problem+json" {
		t.Errorf("shed request content type = %q, want application/problem+json", got)
	}

	close(release)
	wg.Wait()
	if first.Code != http.StatusOK {
		t.Errorf("admitted request status = %d, want %d", first.Code, http.StatusOK)
	}
}

// A released slot is reusable: the limiter bounds concurrency, not lifetime
// throughput.
func TestLimitInFlightReleasesSlots(t *testing.T) {
	handler := httpx.LimitInFlight(1)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	for i := range 5 {
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/search", nil))
		if rec.Code != http.StatusOK {
			t.Fatalf("sequential request %d status = %d, want 200", i, rec.Code)
		}
	}
}

// A non-positive limit disables admission control instead of refusing
// everything, so a missing setting degrades to the previous behaviour rather
// than to a total outage.
func TestLimitInFlightZeroIsPassThrough(t *testing.T) {
	handler := httpx.LimitInFlight(0)(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/api/v1/search", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", rec.Code)
	}
}
