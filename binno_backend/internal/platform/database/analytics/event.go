package analytics

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
)

// Event is the validated analytics representation of an outbox record.
type Event struct {
	EventID     uuid.UUID
	EventType   string
	AggregateID uuid.UUID
	OwnerID     *uuid.UUID
	StoreID     *uuid.UUID
	DistrictID  *int32
	OccurredAt  time.Time
	Payload     json.RawMessage
}

type dimensions struct {
	OwnerID    *uuid.UUID `json:"owner_id"`
	StoreID    *uuid.UUID `json:"store_id"`
	DistrictID *int32     `json:"district_id"`
}

// EventFromRecord validates and converts an outbox record.
func EventFromRecord(record outbox.Record) (Event, error) {
	if !eventcatalog.Valid(record.EventName) {
		return Event{}, fmt.Errorf("analytics: unregistered event type %q", record.EventName)
	}
	if !eventcatalog.ValidVersion(record.EventName, record.EventVersion) {
		return Event{}, fmt.Errorf("analytics: unsupported event version %s@v%d",
			record.EventName, record.EventVersion)
	}
	if len(record.Payload) == 0 || record.Payload[0] != '{' {
		return Event{}, fmt.Errorf("analytics: payload for %s is not an object", record.EventID)
	}
	aggregateID, err := uuid.Parse(record.AggregateID)
	if err != nil {
		return Event{}, fmt.Errorf("analytics: parse aggregate id %q: %w", record.AggregateID, err)
	}

	var dims dimensions
	if err := json.Unmarshal(record.Payload, &dims); err != nil {
		return Event{}, fmt.Errorf("analytics: decode dimensions for %s: %w", record.EventID, err)
	}

	return Event{
		EventID:     record.EventID,
		EventType:   record.EventName,
		AggregateID: aggregateID,
		OwnerID:     dims.OwnerID,
		StoreID:     dims.StoreID,
		DistrictID:  dims.DistrictID,
		OccurredAt:  record.OccurredAt,
		Payload:     record.Payload,
	}, nil
}
