//go:build integration

package postgres_test

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/google/uuid"

	analyticspostgres "github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox/outboxtest"
)

func TestPostgresSink_ConsumerContract(t *testing.T) {
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

	occurrences := func(ctx context.Context, eventID uuid.UUID) (int, error) {
		var count int
		err := pool.QueryRow(ctx,
			`SELECT count(*) FROM analytics.analytics_events WHERE event_id = $1`,
			eventID,
		).Scan(&count)
		return count, err
	}

	outboxtest.ConsumerContract(t, analyticspostgres.NewSink(pool), occurrences)
}
