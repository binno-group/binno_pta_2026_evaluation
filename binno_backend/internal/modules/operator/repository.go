package operator

import (
	"context"
	"time"
)

// QueueQuery is the storage-neutral keyset request.
type QueueQuery struct {
	Type         string
	BeforeOpened *time.Time
	BeforeID     string
	PageSize     int32
}

// QueueRecord is the storage-neutral operator queue projection.
type QueueRecord struct {
	ID       string
	RefID    string
	OpenedAt time.Time
	DueAt    time.Time
}

// queueRepository is implemented by PostgreSQL and ClickHouse adapters.
type queueRepository interface {
	ListQueue(ctx context.Context, query QueueQuery) ([]QueueRecord, error)
}

type queueResolver interface {
	Resolve(ctx context.Context, resolution Resolution) error
}

type Resolution struct {
	QueueType, QueueEventID, Action, Note, ActorID, OperationKey string
	OccurredAt                                                   time.Time
}
