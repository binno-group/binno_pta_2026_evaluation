package operator

import (
	"context"
	"errors"
	"testing"
	"time"
)

type fakeQueueRepository struct {
	rows  []QueueRecord
	query QueueQuery
}

func (r *fakeQueueRepository) ListQueue(_ context.Context, query QueueQuery) ([]QueueRecord, error) {
	r.query = query
	return r.rows, nil
}

func TestListQueueRejectsUnknownTypeBeforeRepositoryIO(t *testing.T) {
	repository := &fakeQueueRepository{}
	_, err := NewService(repository).ListQueue(context.Background(), "unknown", "", 50)
	if !errors.Is(err, ErrInvalidQueueType) {
		t.Fatalf("ListQueue error = %v, want ErrInvalidQueueType", err)
	}
	if repository.query.Type != "" {
		t.Fatal("repository called for invalid queue type")
	}
}

func TestListQueueUsesLookaheadForNextCursor(t *testing.T) {
	first := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
	repository := &fakeQueueRepository{rows: []QueueRecord{
		{ID: "018f0f50-0000-7000-8000-000000000001", RefID: "a", OpenedAt: first, DueAt: first},
		{ID: "018f0f50-0000-7000-8000-000000000002", RefID: "b", OpenedAt: first.Add(-time.Minute), DueAt: first},
		{ID: "018f0f50-0000-7000-8000-000000000003", RefID: "c", OpenedAt: first.Add(-2 * time.Minute), DueAt: first},
	}}

	page, err := NewService(repository).ListQueue(
		context.Background(), "payment_review", "", 2,
	)
	if err != nil {
		t.Fatalf("ListQueue error = %v", err)
	}
	if len(page.Items) != 2 {
		t.Fatalf("items = %d, want 2", len(page.Items))
	}
	if page.NextCursor == nil {
		t.Fatal("next_cursor = nil, want keyset cursor")
	}
	if repository.query.PageSize != 3 {
		t.Fatalf("repository page size = %d, want lookahead 3", repository.query.PageSize)
	}
}
