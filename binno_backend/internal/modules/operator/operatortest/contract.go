// Package operatortest holds the contract every operator queue repository must
// satisfy.
package operatortest

import (
	"context"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator"
)

// Seeder inserts one queue-opening analytics event into the backend under test.
type Seeder func(ctx context.Context, t *testing.T, event Event)

// Event is one queue-opening fact, in backend-neutral form.
type Event struct {
	EventID     string
	EventType   string
	AggregateID string
	OccurredAt  time.Time
	DueAt       time.Time
}

// Repository is the read surface both backends implement.
type Repository interface {
	ListQueue(ctx context.Context, query operator.QueueQuery) ([]operator.QueueRecord, error)
}

// QueueContract asserts the behaviour an operator queue backend must honour.
func QueueContract(t *testing.T, repository Repository, seed Seeder, reset func(context.Context, *testing.T)) {
	t.Helper()
	ctx := context.Background()

	t.Run("newest first", func(t *testing.T) {
		reset(ctx, t)
		base := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
		for index, offset := range []time.Duration{0, time.Hour, 2 * time.Hour} {
			seed(ctx, t, Event{
				EventID:     uuidFor(index + 1),
				EventType:   "order.sla_escalated",
				AggregateID: uuidFor(index + 100),
				OccurredAt:  base.Add(offset),
				DueAt:       base.Add(offset + 4*time.Hour),
			})
		}

		page, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue: %v", err)
		}
		if len(page) != 3 {
			t.Fatalf("got %d items, want 3", len(page))
		}
		for i := 1; i < len(page); i++ {
			if page[i-1].OpenedAt.Before(page[i].OpenedAt) {
				t.Fatalf("page is not newest-first: %v before %v",
					page[i-1].OpenedAt, page[i].OpenedAt)
			}
		}
	})

	t.Run("due_at comes from the payload", func(t *testing.T) {
		reset(ctx, t)
		opened := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
		due := opened.Add(6 * time.Hour)
		seed(ctx, t, Event{
			EventID:     uuidFor(1),
			EventType:   "order.sla_escalated",
			AggregateID: uuidFor(100),
			OccurredAt:  opened,
			DueAt:       due,
		})

		page, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue: %v", err)
		}
		if len(page) != 1 {
			t.Fatalf("got %d items, want 1", len(page))
		}
		if !page[0].DueAt.UTC().Equal(due) {
			t.Fatalf("DueAt = %v, want %v from the payload", page[0].DueAt.UTC(), due)
		}
	})

	t.Run("keyset page does not repeat an item", func(t *testing.T) {
		reset(ctx, t)
		base := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
		const total = 5
		for index := range total {
			seed(ctx, t, Event{
				EventID:     uuidFor(index + 1),
				EventType:   "order.sla_escalated",
				AggregateID: uuidFor(index + 100),
				OccurredAt:  base.Add(time.Duration(index) * time.Hour),
				DueAt:       base.Add(time.Duration(index)*time.Hour + 4*time.Hour),
			})
		}

		first, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 2})
		if err != nil {
			t.Fatalf("first page: %v", err)
		}
		if len(first) != 2 {
			t.Fatalf("first page has %d items, want 2", len(first))
		}
		last := first[len(first)-1]
		opened := last.OpenedAt
		second, err := repository.ListQueue(ctx, operator.QueueQuery{
			Type: "sla_escalation", PageSize: 2,
			BeforeOpened: &opened, BeforeID: last.ID,
		})
		if err != nil {
			t.Fatalf("second page: %v", err)
		}
		seen := map[string]bool{}
		for _, item := range first {
			seen[item.ID] = true
		}
		for _, item := range second {
			if seen[item.ID] {
				t.Fatalf("item %s appeared on both pages", item.ID)
			}
		}
	})

	t.Run("work that resolved itself leaves the queue", func(t *testing.T) {
		reset(ctx, t)
		opened := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)

		// Two escalations; only the first order's supplier answers.
		for index, aggregate := range []int{100, 101} {
			seed(ctx, t, Event{
				EventID:     uuidFor(index + 1),
				EventType:   "order.sla_escalated",
				AggregateID: uuidFor(aggregate),
				OccurredAt:  opened,
				DueAt:       opened.Add(4 * time.Hour),
			})
		}
		seed(ctx, t, Event{
			EventID:     uuidFor(3),
			EventType:   "order.accepted",
			AggregateID: uuidFor(100),
			OccurredAt:  opened.Add(time.Hour),
			DueAt:       opened.Add(time.Hour),
		})

		page, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue: %v", err)
		}
		if len(page) != 1 {
			t.Fatalf("got %d items, want 1: the accepted order closes its own item and no other", len(page))
		}
		if page[0].RefID != uuidFor(101) {
			t.Fatalf("remaining item refers to %s, want the unanswered order %s", page[0].RefID, uuidFor(101))
		}
	})

	t.Run("payment review closes only on a later verdict", func(t *testing.T) {
		reset(ctx, t)
		opened := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)

		// The invoice-issue awaiting_payment precedes the review and must not
		// close it.
		seed(ctx, t, Event{
			EventID:     uuidFor(1),
			EventType:   "order.awaiting_payment",
			AggregateID: uuidFor(100),
			OccurredAt:  opened.Add(-time.Hour),
			DueAt:       opened.Add(-time.Hour),
		})
		seed(ctx, t, Event{
			EventID:     uuidFor(2),
			EventType:   "payment.review_started",
			AggregateID: uuidFor(100),
			OccurredAt:  opened,
			DueAt:       opened,
		})

		page, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "payment_review", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue before verdict: %v", err)
		}
		if len(page) != 1 {
			t.Fatalf("got %d items before the verdict, want 1: the earlier awaiting_payment must not close the review", len(page))
		}

		seed(ctx, t, Event{
			EventID:     uuidFor(3),
			EventType:   "order.paid",
			AggregateID: uuidFor(100),
			OccurredAt:  opened.Add(time.Hour),
			DueAt:       opened.Add(time.Hour),
		})
		page, err = repository.ListQueue(ctx, operator.QueueQuery{Type: "payment_review", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue after verdict: %v", err)
		}
		if len(page) != 0 {
			t.Fatalf("got %d items after the seller's verdict, want 0", len(page))
		}
	})

	t.Run("catalog request closes on its resolution", func(t *testing.T) {
		reset(ctx, t)
		opened := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
		seed(ctx, t, Event{
			EventID:     uuidFor(1),
			EventType:   "catalog.requested",
			AggregateID: uuidFor(100),
			OccurredAt:  opened,
			DueAt:       opened.Add(24 * time.Hour),
		})
		seed(ctx, t, Event{
			EventID:     uuidFor(2),
			EventType:   "catalog.request_resolved",
			AggregateID: uuidFor(100),
			OccurredAt:  opened.Add(time.Hour),
			DueAt:       opened.Add(time.Hour),
		})

		page, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "catalog_request", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue: %v", err)
		}
		if len(page) != 0 {
			t.Fatalf("got %d items, want 0: the catalog decision closes its own queue item", len(page))
		}
	})

	t.Run("resolved items leave the queue", func(t *testing.T) {
		reset(ctx, t)
		opened := time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)
		seed(ctx, t, Event{
			EventID:     uuidFor(1),
			EventType:   "order.sla_escalated",
			AggregateID: uuidFor(100),
			OccurredAt:  opened,
			DueAt:       opened.Add(4 * time.Hour),
		})
		before, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue before resolve: %v", err)
		}
		if len(before) != 1 {
			t.Fatalf("got %d items before resolve, want 1", len(before))
		}

		resolver, ok := repository.(interface {
			Resolve(context.Context, operator.Resolution) error
		})
		if !ok {
			t.Skip("repository does not expose Resolve")
		}
		if err := resolver.Resolve(ctx, operator.Resolution{
			QueueType: "sla_escalation", QueueEventID: before[0].ID,
			Action: "resolved", ActorID: uuidFor(200),
			OperationKey: "contract-resolve-1", OccurredAt: opened.Add(time.Hour),
		}); err != nil {
			t.Fatalf("Resolve: %v", err)
		}

		after, err := repository.ListQueue(ctx, operator.QueueQuery{Type: "sla_escalation", PageSize: 10})
		if err != nil {
			t.Fatalf("ListQueue after resolve: %v", err)
		}
		if len(after) != 0 {
			t.Fatalf("resolved item still in the queue: %d items remain", len(after))
		}
	})
}

// uuidFor builds a stable UUID from a small integer so seeded rows are
// reproducible across backends.
func uuidFor(n int) string {
	const prefix = "018f0f50-0000-7000-8000-0000000000"
	digits := []byte{byte('0' + (n/16)%16), byte('0' + n%16)}
	for i, d := range digits {
		if d > '9' {
			digits[i] = 'a' + (d - '0' - 10)
		}
	}
	return prefix + string(digits)
}
