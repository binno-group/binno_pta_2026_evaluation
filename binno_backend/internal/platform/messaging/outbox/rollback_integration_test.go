//go:build integration

package outbox_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
)

// The outbox pattern's whole promise is that the event and the state change
// share one transaction. A rollback must erase the event as completely as it
// erases the state: no row means nothing for the dispatcher to ever claim.
func TestEventInRolledBackTransactionIsNeverDispatched(t *testing.T) {
	pool := pgtest.Pool(t)
	writer := outbox.NewWriter(clock.New())
	ctx := context.Background()

	payload := func() eventcatalog.Payload {
		return eventcatalog.OrderSLAEscalatedPayload{
			StoreID: uuid.NewString(), BuyerID: uuid.NewString(),
			Reason: "suite", DueAt: time.Now().UTC(),
		}
	}
	countFor := func(aggregateID string) int {
		var n int
		if err := pool.QueryRow(ctx,
			`SELECT count(*) FROM platform.outbox WHERE aggregate_id = $1`,
			aggregateID).Scan(&n); err != nil {
			t.Fatalf("count outbox rows: %v", err)
		}
		return n
	}

	rolledBack := uuid.NewString()
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	if err := writer.Write(ctx, tx, "orders", rolledBack, payload()); err != nil {
		t.Fatalf("write event: %v", err)
	}
	if err := tx.Rollback(ctx); err != nil {
		t.Fatalf("rollback: %v", err)
	}
	if n := countFor(rolledBack); n != 0 {
		t.Errorf("rolled-back event left %d outbox rows; the dispatcher would deliver a change that never happened", n)
	}

	// The committed twin proves the write path itself works, so the zero above
	// means "erased", not "never written".
	committed := uuid.NewString()
	tx, err = pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	if err := writer.Write(ctx, tx, "orders", committed, payload()); err != nil {
		t.Fatalf("write event: %v", err)
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatalf("commit: %v", err)
	}
	if n := countFor(committed); n != 1 {
		t.Errorf("committed event rows = %d, want 1", n)
	}
}
