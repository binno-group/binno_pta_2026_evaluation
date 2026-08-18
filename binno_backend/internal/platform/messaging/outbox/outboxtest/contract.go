// Package outboxtest holds the contract every outbox.Sink implementation must
// satisfy.
package outboxtest

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
)

// Occurrences reports how many times the event landed in the sink's destination.
type Occurrences func(ctx context.Context, eventID uuid.UUID) (int, error)

// ConsumerContract asserts the contract every Sink must honour.
func ConsumerContract(t *testing.T, sink outbox.Sink, occurrences Occurrences) {
	t.Helper()

	t.Run("redelivery applies the event once", func(t *testing.T) {
		ctx := context.Background()
		record := newRecord(t)

		for attempt := 1; attempt <= 2; attempt++ {
			if err := sink.Send(ctx, []outbox.Record{record}); err != nil {
				t.Fatalf("send attempt %d: %v", attempt, err)
			}
		}

		got, err := occurrences(ctx, record.EventID)
		if err != nil {
			t.Fatalf("count occurrences: %v", err)
		}
		if got != 1 {
			t.Errorf("event applied %d times after redelivery, want 1 ", got)
		}
	})

	t.Run("a redelivered event does not block new ones", func(t *testing.T) {
		ctx := context.Background()
		seen, fresh := newRecord(t), newRecord(t)

		if err := sink.Send(ctx, []outbox.Record{seen}); err != nil {
			t.Fatalf("send first batch: %v", err)
		}
		if err := sink.Send(ctx, []outbox.Record{seen, fresh}); err != nil {
			t.Fatalf("send overlapping batch: %v", err)
		}

		for name, id := range map[string]uuid.UUID{"redelivered": seen.EventID, "new": fresh.EventID} {
			got, err := occurrences(ctx, id)
			if err != nil {
				t.Fatalf("count %s occurrences: %v", name, err)
			}
			if got != 1 {
				t.Errorf("%s event applied %d times, want 1", name, got)
			}
		}
	})
}

func newRecord(t *testing.T) outbox.Record {
	t.Helper()
	eventID, err := uuid.NewV7()
	if err != nil {
		t.Fatalf("new event id: %v", err)
	}
	return outbox.Record{
		EventID:      eventID,
		Module:       "orders",
		EventName:    string(eventcatalog.OrderCreated),
		EventVersion: 1,
		AggregateID:  uuid.NewString(),
		Payload:      []byte(`{}`),
		OccurredAt:   time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC),
	}
}
