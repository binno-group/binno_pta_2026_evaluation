// Package postgres implements the PostgreSQL analytics sink.
package postgres

import (
	"context"
	"fmt"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
)

// Sink writes analytics events to PostgreSQL.
type Sink struct {
	pool *postgres.Pool
}

// NewSink creates a PostgreSQL analytics sink.
func NewSink(pool *postgres.Pool) *Sink {
	return &Sink{pool: pool}
}

// Send appends a batch idempotently by event_id.
func (s *Sink) Send(ctx context.Context, batch []outbox.Record) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("analytics: begin postgres tx: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	const stmt = `
        INSERT INTO analytics.analytics_events (
            event_id, event_type, aggregate_id, owner_id, store_id,
            district_id, occurred_at, payload
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        ON CONFLICT (event_id) DO NOTHING`

	for _, record := range batch {
		evt, err := analytics.EventFromRecord(record)
		if err != nil {
			return &outbox.PermanentSinkError{EventID: record.EventID, Err: err}
		}
		if _, err := tx.Exec(ctx, stmt,
			evt.EventID, evt.EventType, evt.AggregateID, evt.OwnerID,
			evt.StoreID, evt.DistrictID, evt.OccurredAt, evt.Payload,
		); err != nil {
			return fmt.Errorf("analytics: insert postgres event %s: %w", evt.EventType, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("analytics: commit postgres tx: %w", err)
	}
	return nil
}

// Prune deletes analytics events older than cutoff, up to batch rows per call.
func (s *Sink) Prune(ctx context.Context, cutoff time.Time, batch int) (int64, error) {
	tag, err := s.pool.Exec(ctx, `
		DELETE FROM analytics.analytics_events
		WHERE event_id IN (
			SELECT event_id FROM analytics.analytics_events
			WHERE occurred_at < $1
			ORDER BY occurred_at
			LIMIT $2
		)`, cutoff, batch)
	if err != nil {
		return 0, fmt.Errorf("analytics: prune postgres events: %w", err)
	}
	return tag.RowsAffected(), nil
}

var (
	_ analytics.EventSink = (*Sink)(nil)
	_ outbox.Pruner       = (*Sink)(nil)
)
