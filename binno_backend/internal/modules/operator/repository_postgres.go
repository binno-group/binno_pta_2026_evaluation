package operator

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator/store"
)

// Postgres reads analytics data through sqlc.
type Postgres struct {
	queries *store.Queries
}

func (r *Postgres) Resolve(ctx context.Context, resolution Resolution) error {
	queueID, err := uuid.Parse(resolution.QueueEventID)
	if err != nil {
		return ErrInvalidResolution
	}
	payload, err := json.Marshal(map[string]string{
		"queue_event_id": resolution.QueueEventID, "queue_type": resolution.QueueType,
		"action": resolution.Action, "note": resolution.Note, "actor_id": resolution.ActorID,
	})
	if err != nil {
		return fmt.Errorf("operator repo: encode resolution: %w", err)
	}
	// Deterministic like the ClickHouse repository: a retried resolution maps
	// to the same event_id on either backend.
	eventID := operationUUID(resolution.OperationKey)
	return r.queries.ResolveOperatorQueueItem(ctx, &store.ResolveOperatorQueueItemParams{
		EventID:      pgtype.UUID{Bytes: eventID, Valid: true},
		EventType:    string(eventcatalog.OperatorQueueItemResolved),
		OperationKey: &resolution.OperationKey,
		AggregateID:  pgtype.UUID{Bytes: queueID, Valid: true},
		OccurredAt:   pgtype.Timestamptz{Time: resolution.OccurredAt, Valid: true},
		Payload:      payload,
	})
}

// NewPostgresRepository creates a PostgreSQL operator repository.
func NewPostgresRepository(queries *store.Queries) *Postgres {
	return &Postgres{queries: queries}
}

// ListQueue returns an ordered keyset page from the computed analytics view.
func (r *Postgres) ListQueue(ctx context.Context, query QueueQuery) ([]QueueRecord, error) {
	var before pgtype.Timestamptz
	var beforeID pgtype.UUID
	if query.BeforeOpened != nil {
		before = pgtype.Timestamptz{Time: *query.BeforeOpened, Valid: true}
		parsedID, err := uuid.Parse(query.BeforeID)
		if err != nil {
			return nil, fmt.Errorf("operator repo: parse cursor id: %w", err)
		}
		beforeID = pgtype.UUID{Bytes: parsedID, Valid: true}
	}
	rows, err := r.queries.ListOperatorQueue(ctx, &store.ListOperatorQueueParams{
		QueueType: query.Type, BeforeOpenedAt: before, BeforeID: beforeID,
		PageSize: query.PageSize,
	})
	if err != nil {
		return nil, fmt.Errorf("operator repo: list postgres queue: %w", err)
	}
	result := make([]QueueRecord, 0, len(rows))
	for _, row := range rows {
		result = append(result, QueueRecord{
			ID: uuid.UUID(row.ID.Bytes).String(), RefID: uuid.UUID(row.RefID.Bytes).String(),
			OpenedAt: row.OpenedAt.Time.UTC(), DueAt: row.DueAt.Time.UTC(),
		})
	}
	return result, nil
}

var _ queueRepository = (*Postgres)(nil)
