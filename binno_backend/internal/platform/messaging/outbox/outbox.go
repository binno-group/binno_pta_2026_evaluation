// Package outbox implements the transactional outbox: every domain event is
// written in the same DB transaction as the state change that caused it, then
// relayed to analytics by a separate dispatcher.
package outbox

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Envelope is the wire shape of a domain event.
type Envelope struct {
	EventID      uuid.UUID       `json:"event_id"`
	EventName    string          `json:"event_name"`
	EventVersion int             `json:"event_version"`
	AggregateID  string          `json:"aggregate_id"`
	OccurredAt   string          `json:"occurred_at"`
	Payload      json.RawMessage `json:"payload"`
}

// Writer inserts outbox rows.
type Writer struct {
	clock clock.Clock
}

// NewWriter returns a Writer that stamps occurred_at using c.
func NewWriter(c clock.Clock) *Writer {
	return &Writer{clock: c}
}

// Write inserts one outbox row for module, to be relayed later by
// cmd/dispatcher.
func (w *Writer) Write(ctx context.Context, tx pgx.Tx, module, aggregateID string, payload eventcatalog.Payload) error {
	if module == "" {
		return fmt.Errorf("outbox: module is required")
	}
	if payload == nil {
		return fmt.Errorf("outbox: payload is required")
	}
	eventName := payload.EventName()
	definition, ok := eventcatalog.Lookup(eventName)
	if !ok {
		return fmt.Errorf("outbox: event name %q is not registered", eventName)
	}
	eventVersion := definition.Current()
	if _, err := uuid.Parse(aggregateID); err != nil {
		return fmt.Errorf("outbox: aggregate id %q: %w", aggregateID, err)
	}
	eventID, err := uuid.NewV7()
	if err != nil {
		return fmt.Errorf("outbox: generate event id: %w", err)
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("outbox: marshal payload: %w", err)
	}
	if !json.Valid(body) || len(body) == 0 || body[0] != '{' {
		return fmt.Errorf("outbox: payload must be a JSON object")
	}

	const stmt = `
		INSERT INTO platform.outbox (event_id, module, event_name, event_version, aggregate_id, payload, occurred_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)`
	if _, err := tx.Exec(ctx, stmt, eventID, module, string(eventName), eventVersion, aggregateID, body, w.clock.Now()); err != nil {
		return fmt.Errorf("outbox: insert event %s: %w", eventName, err)
	}
	return nil
}
