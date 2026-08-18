// Package clickhouse implements the ClickHouse analytics sink.
package clickhouse

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
)

// Writer writes one dispatcher batch.
type Writer interface {
	Append(ctx context.Context, eventID, eventType, aggregateID string,
		ownerID, storeID *string, districtID *int32, occurredAt, payload string) error
	Flush(ctx context.Context) error
}

// Sink writes analytics events to ClickHouse.
type Sink struct {
	writer Writer
}

// NewSink creates a ClickHouse analytics sink.
func NewSink(writer Writer) *Sink {
	return &Sink{writer: writer}
}

// Send appends and flushes one dispatcher batch through the driver seam.
func (s *Sink) Send(ctx context.Context, batch []outbox.Record) error {
	for _, record := range batch {
		evt, err := analytics.EventFromRecord(record)
		if err != nil {
			return &outbox.PermanentSinkError{EventID: record.EventID, Err: err}
		}
		if err := s.writer.Append(
			ctx,
			evt.EventID.String(),
			evt.EventType,
			evt.AggregateID.String(),
			uuidString(evt.OwnerID),
			uuidString(evt.StoreID),
			evt.DistrictID,
			evt.OccurredAt.UTC().Format("2006-01-02 15:04:05.000"),
			string(evt.Payload),
		); err != nil {
			return fmt.Errorf("analytics: append clickhouse event %s: %w", evt.EventType, err)
		}
	}
	if err := s.writer.Flush(ctx); err != nil {
		return fmt.Errorf("analytics: flush clickhouse batch: %w", err)
	}
	return nil
}

func uuidString(id *uuid.UUID) *string {
	if id == nil {
		return nil
	}
	value := id.String()
	return &value
}

var _ analytics.EventSink = (*Sink)(nil)
