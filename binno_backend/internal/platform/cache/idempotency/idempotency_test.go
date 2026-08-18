package idempotency_test

import (
	"context"
	"errors"
	"net/http"
	"os"
	"testing"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/idempotency"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
)

func newStore(t *testing.T) *idempotency.Store {
	t.Helper()
	addr := os.Getenv("TEST_REDIS_ADDR")
	if addr == "" {
		t.Skip("TEST_REDIS_ADDR not set")
	}
	client := redisx.New(redisx.Config{Addr: addr})
	if err := client.Ping(context.Background()); err != nil {
		t.Skipf("redis unreachable at %s: %v", addr, err)
	}
	t.Cleanup(func() { _ = client.Close() })
	return idempotency.New(client)
}

func freshKey(t *testing.T) string {
	t.Helper()
	return "test:" + t.Name() + ":" + uuid.NewString()
}

func fp(body string) string { return idempotency.Fingerprint([]byte(body)) }

func TestReserve_FirstCallAcquires(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()

	outcome, _, err := store.Reserve(ctx, freshKey(t), fp("body"))
	if err != nil {
		t.Fatalf("Reserve: %v", err)
	}
	if outcome != idempotency.Acquired {
		t.Fatalf("outcome = %v, want Acquired", outcome)
	}
}

// A retry arriving while the first request is still mid-mutation must be told
// InFlight, never allowed to re-execute the mutation.
func TestReserve_ConcurrentRetryIsInFlight(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	key := freshKey(t)

	if _, _, err := store.Reserve(ctx, key, fp("body")); err != nil {
		t.Fatalf("first Reserve: %v", err)
	}

	outcome, _, err := store.Reserve(ctx, key, fp("body"))
	if err != nil {
		t.Fatalf("second Reserve: %v", err)
	}
	if outcome != idempotency.InFlight {
		t.Fatalf("outcome = %v, want InFlight", outcome)
	}
}

func TestReserve_ReplaysStoredResponse(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	key := freshKey(t)
	original := idempotency.StoredResponse{Status: http.StatusCreated, Body: []byte(`{"order_id":"abc"}`)}

	if _, _, err := store.Reserve(ctx, key, fp("body")); err != nil {
		t.Fatalf("Reserve: %v", err)
	}
	if err := store.SaveResponse(ctx, key, original); err != nil {
		t.Fatalf("SaveResponse: %v", err)
	}

	outcome, replayed, err := store.Reserve(ctx, key, fp("body"))
	if err != nil {
		t.Fatalf("replay Reserve: %v", err)
	}
	if outcome != idempotency.Replay {
		t.Fatalf("outcome = %v, want Replay", outcome)
	}
	if replayed.Status != original.Status || string(replayed.Body) != string(original.Body) {
		t.Fatalf("replayed = %+v, want %+v", replayed, original)
	}
}

// A mutation that fails before SaveResponse must not poison the key: without
// Release the client would be rejected for the whole reservation TTL while no
// response ever becomes available.
func TestRelease_AllowsImmediateRetryAfterFailure(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	key := freshKey(t)

	if _, _, err := store.Reserve(ctx, key, fp("body")); err != nil {
		t.Fatalf("Reserve: %v", err)
	}
	if err := store.Release(ctx, key); err != nil {
		t.Fatalf("Release: %v", err)
	}

	outcome, _, err := store.Reserve(ctx, key, fp("body"))
	if err != nil {
		t.Fatalf("retry Reserve: %v", err)
	}
	if outcome != idempotency.Acquired {
		t.Fatalf("outcome after Release = %v, want Acquired", outcome)
	}
}

// TestRedisFailClosed: Redis is never a source of truth, and an unreachable
// Redis must deny the mutation rather than silently behave as if no key was ever
// reserved (which would let a duplicate payment through).
func TestRedisFailClosed(t *testing.T) {
	client := redisx.New(redisx.Config{Addr: "127.0.0.1:1"}) // nothing listens here
	t.Cleanup(func() { _ = client.Close() })
	store := idempotency.New(client)
	ctx := context.Background()

	outcome, _, err := store.Reserve(ctx, "any-key", fp("body"))
	if err == nil {
		t.Fatal("Reserve with unreachable Redis returned nil error; must fail closed")
	}
	if !errors.Is(err, idempotency.ErrUnavailable) {
		t.Fatalf("error = %v, want ErrUnavailable so callers can map it to 503", err)
	}
	if outcome == idempotency.Acquired {
		t.Fatal("outcome = Acquired on Redis outage; the mutation would run unguarded")
	}
}

// A key reused with a DIFFERENT body must be reported as a mismatch, never
// replayed.
func TestReserve_DifferentBodyIsMismatch(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	key := freshKey(t)

	if _, _, err := store.Reserve(ctx, key, fp(`{"qty":"1"}`)); err != nil {
		t.Fatalf("first Reserve: %v", err)
	}
	if err := store.SaveResponse(ctx, key, idempotency.StoredResponse{
		Status: http.StatusCreated, Body: []byte(`{"order_id":"a"}`),
	}); err != nil {
		t.Fatalf("SaveResponse: %v", err)
	}

	outcome, _, err := store.Reserve(ctx, key, fp(`{"qty":"7"}`))
	if err != nil {
		t.Fatalf("Reserve with a different body: %v", err)
	}
	if outcome != idempotency.Mismatch {
		t.Fatalf("outcome = %v, want Mismatch", outcome)
	}

	outcome, replayed, err := store.Reserve(ctx, key, fp(`{"qty":"1"}`))
	if err != nil {
		t.Fatalf("Reserve with the original body: %v", err)
	}
	if outcome != idempotency.Replay || string(replayed.Body) != `{"order_id":"a"}` {
		t.Fatalf("outcome = %v body = %q, want Replay of the stored response", outcome, replayed.Body)
	}
}

// Reservations written before fingerprinting existed hold "1".
func TestReserve_LegacyReservationStillReplays(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	key := freshKey(t)

	if _, _, err := store.Reserve(ctx, key, idempotency.LegacyFingerprint); err != nil {
		t.Fatalf("seed legacy reservation: %v", err)
	}
	if err := store.SaveResponse(ctx, key, idempotency.StoredResponse{
		Status: http.StatusCreated, Body: []byte(`{"order_id":"legacy"}`),
	}); err != nil {
		t.Fatalf("SaveResponse: %v", err)
	}

	outcome, replayed, err := store.Reserve(ctx, key, fp(`{"qty":"1"}`))
	if err != nil {
		t.Fatalf("Reserve: %v", err)
	}
	if outcome != idempotency.Replay || string(replayed.Body) != `{"order_id":"legacy"}` {
		t.Fatalf("outcome = %v body = %q, want Replay; a legacy key must not be refused", outcome, replayed.Body)
	}
}

func TestFingerprint_DistinguishesBodies(t *testing.T) {
	if fp(`{"qty":"1"}`) == fp(`{"qty":"7"}`) {
		t.Fatal("different bodies produced the same fingerprint")
	}
	first, again := fp(`{"qty":"1"}`), fp(`{"qty":"1"}`)
	if first != again {
		t.Fatalf("the same body produced different fingerprints: %q vs %q", first, again)
	}
	if fp(`{"a":1,"b":2}`) == fp(`{"b":2,"a":1}`) {
		t.Fatal("reordered JSON hashed identically; the fingerprint is not over raw bytes")
	}
}
