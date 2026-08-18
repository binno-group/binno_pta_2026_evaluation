package operator

import (
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const (
	defaultPageSize = int32(50)
	maxPageSize     = int32(100)
)

// ErrInvalidQueueType reports an unsupported queue type.
var (
	ErrInvalidQueueType  = errors.New("invalid operator queue type")
	ErrInvalidResolution = errors.New("invalid operator queue resolution")
)

// QueueItem is one analytics-backed operator work item.
type QueueItem struct {
	ID       string
	RefID    string
	OpenedAt time.Time
	DueAt    time.Time
}

// QueuePage is one keyset-paginated operator queue response.
type QueuePage struct {
	Type       string
	Items      []QueueItem
	NextCursor *string
}

// Service reads operator queues only from the analytics database.
type Service struct {
	repository queueRepository
	clock      clock.Clock
}

// NewService creates an operator read service.
func NewService(repository queueRepository, clocks ...clock.Clock) *Service {
	clk := clock.New()
	if len(clocks) > 0 {
		clk = clocks[0]
	}
	return &Service{repository: repository, clock: clk}
}

// ListQueue returns a deterministic keyset page for queueType.
func (s *Service) ListQueue(ctx context.Context, queueType, cursor string, pageSize int32) (QueuePage, error) {
	if !validQueueType(queueType) {
		return QueuePage{}, ErrInvalidQueueType
	}
	if pageSize <= 0 {
		pageSize = defaultPageSize
	}
	if pageSize > maxPageSize {
		pageSize = maxPageSize
	}

	before, beforeID, err := decodeCursor(cursor)
	if err != nil {
		return QueuePage{}, err
	}
	rows, err := s.repository.ListQueue(ctx, QueueQuery{
		Type:         queueType,
		BeforeOpened: before,
		BeforeID:     beforeID,
		PageSize:     pageSize + 1,
	})
	if err != nil {
		return QueuePage{}, fmt.Errorf("operator: list %s queue: %w", queueType, err)
	}

	hasMore := len(rows) > int(pageSize)
	if hasMore {
		rows = rows[:pageSize]
	}
	items := make([]QueueItem, 0, len(rows))
	for _, row := range rows {
		items = append(items, QueueItem{
			ID:       row.ID,
			RefID:    row.RefID,
			OpenedAt: row.OpenedAt.UTC(),
			DueAt:    row.DueAt.UTC(),
		})
	}

	var next *string
	if hasMore && len(rows) > 0 {
		value := encodeCursor(rows[len(rows)-1].OpenedAt, rows[len(rows)-1].ID)
		next = &value
	}
	return QueuePage{Type: queueType, Items: items, NextCursor: next}, nil
}

func (s *Service) Resolve(ctx context.Context, resolution Resolution) error {
	if !validQueueType(resolution.QueueType) || resolution.QueueEventID == "" ||
		strings.TrimSpace(resolution.Action) == "" || len(resolution.Action) > 100 ||
		len(resolution.Note) > 1000 || resolution.ActorID == "" || resolution.OperationKey == "" {
		return ErrInvalidResolution
	}
	resolution.OccurredAt = s.clock.Now()
	resolver, ok := s.repository.(queueResolver)
	if !ok {
		return fmt.Errorf("operator: repository does not support queue resolution")
	}
	return resolver.Resolve(ctx, resolution)
}

func validQueueType(queueType string) bool {
	switch queueType {
	case "payment_review", "refund_overdue", "sla_escalation",
		"catalog_request", "confirmation_chase":
		return true
	default:
		return false
	}
}

func decodeCursor(cursor string) (*time.Time, string, error) {
	if cursor == "" {
		return nil, "", nil
	}
	raw, err := base64.RawURLEncoding.DecodeString(cursor)
	if err != nil {
		return nil, "", fmt.Errorf("operator: decode cursor: %w", err)
	}
	parts := strings.SplitN(string(raw), "|", 2)
	if len(parts) != 2 || parts[1] == "" {
		return nil, "", fmt.Errorf("operator: invalid cursor shape")
	}
	if _, err := uuid.Parse(parts[1]); err != nil {
		return nil, "", fmt.Errorf("operator: parse cursor id: %w", err)
	}
	at, err := time.Parse(time.RFC3339Nano, parts[0])
	if err != nil {
		return nil, "", fmt.Errorf("operator: parse cursor: %w", err)
	}
	utc := at.UTC()
	return &utc, parts[1], nil
}

func encodeCursor(at time.Time, id string) string {
	value := at.UTC().Format(time.RFC3339Nano) + "|" + id
	return base64.RawURLEncoding.EncodeToString([]byte(value))
}
