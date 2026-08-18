//go:build integration

package operator_test

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator/operatortest"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// The PostgreSQL backend runs the same queue contract as the ClickHouse one, so
// a deployment cannot see a different operator queue depending on which target
// it was configured with.
func TestPostgresOperatorRepository_QueueContract(t *testing.T) {
	url := os.Getenv("TEST_ANALYTICS_DB_URL")
	if url == "" {
		t.Skip("TEST_ANALYTICS_DB_URL not set")
	}

	pool, err := postgres.NewPool(context.Background(), postgres.Config{
		URL: url, MaxConns: 5, StatementTimeout: 5 * time.Second,
	})
	if err != nil {
		t.Fatalf("connect analytics db: %v", err)
	}
	t.Cleanup(pool.Close)

	repository := operator.NewPostgresRepository(store.New(pool))

	seed := func(ctx context.Context, t *testing.T, event operatortest.Event) {
		t.Helper()
		payload, err := json.Marshal(map[string]string{
			"due_at": event.DueAt.UTC().Format(time.RFC3339),
		})
		if err != nil {
			t.Fatalf("encode payload: %v", err)
		}
		if _, err := pool.Exec(ctx, `
			INSERT INTO analytics.analytics_events
				(event_id, operation_key, event_type, aggregate_id, occurred_at, payload)
			VALUES ($1, $2, $3, $4, $5, $6)`,
			event.EventID, fmt.Sprintf("seed-%s", event.EventID),
			event.EventType, event.AggregateID, event.OccurredAt, payload,
		); err != nil {
			t.Fatalf("seed event: %v", err)
		}
	}

	reset := func(ctx context.Context, t *testing.T) {
		t.Helper()
		if _, err := pool.Exec(ctx, `TRUNCATE analytics.analytics_events`); err != nil {
			t.Fatalf("reset analytics events: %v", err)
		}
	}

	operatortest.QueueContract(t, repository, seed, reset)
}
