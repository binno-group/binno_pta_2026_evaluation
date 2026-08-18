//go:build integration

package outbox_test

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

func testPool(t *testing.T) *postgres.Pool {
	t.Helper()
	url := os.Getenv("TEST_DB_URL")
	if url == "" {
		t.Skip("TEST_DB_URL not set")
	}
	pool, err := postgres.NewPool(context.Background(), postgres.Config{URL: url, MaxConns: 5, StatementTimeout: 5 * time.Second})
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	if _, err := pool.Exec(context.Background(),
		`TRUNCATE platform.outbox, platform.mutation_receipts`); err != nil {
		t.Fatalf("reset outbox: %v", err)
	}
	t.Cleanup(pool.Close)
	return pool
}

func seedEvent(t *testing.T, pool *postgres.Pool, aggregateID string) uuid.UUID {
	t.Helper()
	eventID := uuid.Must(uuid.NewV7())
	_, err := pool.Exec(context.Background(), `
		INSERT INTO platform.outbox (event_id, module, event_name, event_version, aggregate_id, payload, occurred_at)
		VALUES ($1, 'test', 'test.happened', 1, $2, '{}'::jsonb, now())`, eventID, aggregateID)
	if err != nil {
		t.Fatalf("seed event: %v", err)
	}
	return eventID
}

type recordingSink struct {
	batches [][]outbox.Record
	err     error
}

type selectiveSink struct {
	failEvent uuid.UUID
	relayed   []uuid.UUID
}

func (s *selectiveSink) Send(_ context.Context, batch []outbox.Record) error {
	for _, record := range batch {
		if record.EventID == s.failEvent {
			return &outbox.PermanentSinkError{
				EventID: record.EventID,
				Err:     errors.New("poison event"),
			}
		}
	}
	for _, record := range batch {
		s.relayed = append(s.relayed, record.EventID)
	}
	return nil
}

func (s *recordingSink) Send(_ context.Context, batch []outbox.Record) error {
	if s.err != nil {
		return s.err
	}
	s.batches = append(s.batches, batch)
	return nil
}

func newDispatcher(pool *postgres.Pool, sink outbox.Sink, c clock.Clock, claimTTL time.Duration) *outbox.Dispatcher {
	return outbox.NewDispatcher(pool, sink, c, slog.New(slog.NewJSONHandler(io.Discard, nil)),
		outbox.DispatcherConfig{
			Interval:    time.Second,
			BatchSize:   10,
			ClaimTTL:    claimTTL,
			MaxAttempts: 8,
			RetryBase:   time.Second,
		})
}

func TestRunOnce_RelaysAndMarksDispatched(t *testing.T) {
	pool := testPool(t)
	aggregate := uuid.NewString()
	eventID := seedEvent(t, pool, aggregate)

	sink := &recordingSink{}
	relayed, err := newDispatcher(pool, sink, clock.New(), time.Minute).RunOnce(context.Background())
	if err != nil {
		t.Fatalf("RunOnce: %v", err)
	}
	if relayed == 0 {
		t.Fatal("relayed 0 events, want at least the seeded one")
	}

	var dispatchedAt *time.Time
	if err := pool.QueryRow(context.Background(),
		`SELECT dispatched_at FROM platform.outbox WHERE event_id = $1`, eventID).Scan(&dispatchedAt); err != nil {
		t.Fatalf("read back: %v", err)
	}
	if dispatchedAt == nil {
		t.Fatal("event was relayed but dispatched_at is still NULL; it would be re-sent forever")
	}
}

func TestRunOnce_ClaimedRowsAreNotReRelayedWhileLeaseHolds(t *testing.T) {
	pool := testPool(t)
	seedEvent(t, pool, uuid.NewString())

	failing := &recordingSink{err: errors.New("sink down")}
	if _, err := newDispatcher(pool, failing, clock.New(), time.Minute).RunOnce(context.Background()); err == nil {
		t.Fatal("RunOnce with a failing sink returned nil error")
	}

	concurrent := &recordingSink{}
	relayed, err := newDispatcher(pool, concurrent, clock.New(), time.Minute).RunOnce(context.Background())
	if err != nil {
		t.Fatalf("concurrent RunOnce: %v", err)
	}
	if relayed != 0 {
		t.Fatalf("concurrent dispatcher relayed %d rows still under lease, want 0", relayed)
	}
}

func TestRunOnce_ExpiredClaimIsReclaimed(t *testing.T) {
	pool := testPool(t)
	eventID := seedEvent(t, pool, uuid.NewString())

	failing := &recordingSink{err: errors.New("sink down")}
	if _, err := newDispatcher(pool, failing, clock.New(), time.Minute).RunOnce(context.Background()); err == nil {
		t.Fatal("RunOnce with a failing sink returned nil error")
	}

	future := clock.NewFixed(time.Now().UTC().Add(2 * time.Minute))
	sink := &recordingSink{}
	relayed, err := newDispatcher(pool, sink, future, time.Minute).RunOnce(context.Background())
	if err != nil {
		t.Fatalf("reclaim RunOnce: %v", err)
	}
	if relayed == 0 {
		t.Fatal("expired claim was never reclaimed; the event would be lost")
	}

	var found bool
	for _, batch := range sink.batches {
		for _, rec := range batch {
			if rec.EventID == eventID {
				found = true
			}
		}
	}
	if !found {
		t.Fatalf("reclaimed batch does not contain event %s", eventID)
	}
}

func TestRunOnce_IsolatesPoisonEventAndDispatchesHealthySibling(t *testing.T) {
	pool := testPool(t)
	poisonID := seedEvent(t, pool, uuid.NewString())
	healthyID := seedEvent(t, pool, uuid.NewString())

	sink := &selectiveSink{failEvent: poisonID}
	relayed, err := newDispatcher(pool, sink, clock.New(), time.Minute).RunOnce(context.Background())
	if err == nil {
		t.Fatal("RunOnce error = nil, want poison event error")
	}
	if relayed != 1 {
		t.Fatalf("relayed = %d, want healthy sibling count 1", relayed)
	}
	if len(sink.relayed) != 1 || sink.relayed[0] != healthyID {
		t.Fatalf("relayed events = %v, want only %s", sink.relayed, healthyID)
	}

	var attempts int
	var dispatchedAt *time.Time
	if err := pool.QueryRow(context.Background(), `
		SELECT attempt_count, dispatched_at
		FROM platform.outbox
		WHERE event_id = $1`, poisonID).Scan(&attempts, &dispatchedAt); err != nil {
		t.Fatalf("read poison state: %v", err)
	}
	if attempts != 1 || dispatchedAt != nil {
		t.Fatalf("poison attempts/dispatched_at = %d/%v, want 1/nil", attempts, dispatchedAt)
	}
}

func TestRunOnce_PoisonEventBacksOffThenDeadLetters(t *testing.T) {
	pool := testPool(t)
	poisonID := seedEvent(t, pool, uuid.NewString())
	sink := &selectiveSink{failEvent: poisonID}

	dispatcher := outbox.NewDispatcher(pool, sink, clock.New(),
		slog.New(slog.NewJSONHandler(io.Discard, nil)),
		outbox.DispatcherConfig{
			Interval: time.Second, BatchSize: 10, ClaimTTL: time.Minute,
			MaxAttempts: 2, RetryBase: time.Second,
			Registerer: prometheus.NewRegistry(),
		})

	if _, err := dispatcher.RunOnce(context.Background()); err == nil {
		t.Fatal("first RunOnce error = nil, want poison failure")
	}
	attempts, nextAttempt, deadLettered := poisonState(t, pool, poisonID)
	if attempts != 1 {
		t.Fatalf("attempt_count = %d after one failure, want 1", attempts)
	}
	if nextAttempt == nil {
		t.Fatal("next_attempt_at not set: the event would be retried immediately, with no backoff")
	}
	if deadLettered != nil {
		t.Fatal("event dead-lettered before MaxAttempts was reached")
	}

	future := clock.NewFixed(time.Now().UTC().Add(time.Hour))
	second := outbox.NewDispatcher(pool, sink, future,
		slog.New(slog.NewJSONHandler(io.Discard, nil)),
		outbox.DispatcherConfig{
			Interval: time.Second, BatchSize: 10, ClaimTTL: time.Minute,
			MaxAttempts: 2, RetryBase: time.Second,
			Registerer: prometheus.NewRegistry(),
		})
	if _, err := second.RunOnce(context.Background()); err == nil {
		t.Fatal("second RunOnce error = nil, want poison failure")
	}
	attempts, _, deadLettered = poisonState(t, pool, poisonID)
	if attempts != 2 {
		t.Fatalf("attempt_count = %d after two failures, want 2", attempts)
	}
	if deadLettered == nil {
		t.Fatal("event not dead-lettered at MaxAttempts: it would be retried forever")
	}

	third := outbox.NewDispatcher(pool, sink, future,
		slog.New(slog.NewJSONHandler(io.Discard, nil)),
		outbox.DispatcherConfig{
			Interval: time.Second, BatchSize: 10, ClaimTTL: time.Minute,
			MaxAttempts: 2, RetryBase: time.Second,
			Registerer: prometheus.NewRegistry(),
		})
	if _, err := third.RunOnce(context.Background()); err != nil {
		t.Fatalf("dead-lettered event was claimed again: %v", err)
	}
}

func poisonState(t *testing.T, pool *postgres.Pool, eventID uuid.UUID) (int, *time.Time, *time.Time) {
	t.Helper()
	var attempts int
	var nextAttempt, deadLettered *time.Time
	if err := pool.QueryRow(context.Background(), `
		SELECT attempt_count, next_attempt_at, dead_lettered_at
		FROM platform.outbox WHERE event_id = $1`, eventID,
	).Scan(&attempts, &nextAttempt, &deadLettered); err != nil {
		t.Fatalf("read poison state: %v", err)
	}
	return attempts, nextAttempt, deadLettered
}
