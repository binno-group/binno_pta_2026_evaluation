package outbox_test

import (
	"context"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const validAggregate = "018f0f50-0000-7000-8000-000000000001"

// unregisteredPayload names an event that is not in the catalog registry.
type unregisteredPayload struct{}

func (unregisteredPayload) EventName() eventcatalog.Name { return eventcatalog.Name("order.maybe") }

// Every rejection below happens before any database I/O: tx is nil, so a test
// that reaches the INSERT panics instead of passing.
func TestWriterRejectsInvalidEnvelopeBeforeDatabaseIO(t *testing.T) {
	writer := outbox.NewWriter(clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)))
	var tx pgx.Tx

	tests := []struct {
		name        string
		module      string
		aggregateID string
		payload     eventcatalog.Payload
	}{
		{
			name:        "missing module",
			aggregateID: validAggregate,
			payload:     eventcatalog.OrderCreatedPayload{},
		},
		{
			name:        "unregistered event name",
			module:      "orders",
			aggregateID: validAggregate,
			payload:     unregisteredPayload{},
		},
		{
			name:        "malformed aggregate id",
			module:      "orders",
			aggregateID: "bad",
			payload:     eventcatalog.OrderCreatedPayload{},
		},
		{
			name:        "nil payload",
			module:      "orders",
			aggregateID: validAggregate,
			payload:     nil,
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if err := writer.Write(context.Background(), tx, test.module, test.aggregateID, test.payload); err == nil {
				t.Fatal("Write error = nil, want envelope validation error")
			}
		})
	}
}

// The payload type is what selects the event name, so a caller cannot pair an
// order.accepted name with an order.created body.
func TestPayloadNamesItsOwnEvent(t *testing.T) {
	tests := []struct {
		payload eventcatalog.Payload
		want    eventcatalog.Name
	}{
		{eventcatalog.OrderCreatedPayload{}, eventcatalog.OrderCreated},
		{eventcatalog.OfferCreatedPayload{}, eventcatalog.OfferCreated},
		{eventcatalog.FeedbackCreatedPayload{}, eventcatalog.FeedbackCreated},
		{eventcatalog.OrderSLAEscalatedPayload{}, eventcatalog.OrderSLAEscalated},
		{
			eventcatalog.NewOrderStatusChanged(eventcatalog.OrderCancelled,
				eventcatalog.OrderStatusChangedPayload{}),
			eventcatalog.OrderCancelled,
		},
	}
	for _, test := range tests {
		if got := test.payload.EventName(); got != test.want {
			t.Errorf("EventName() = %q, want %q", got, test.want)
		}
		if !eventcatalog.Valid(string(test.want)) {
			t.Errorf("%q is not registered in the event catalog", test.want)
		}
	}
}
