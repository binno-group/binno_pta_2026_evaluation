//go:build integration

package operator_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator/operatortest"
)

// The ClickHouse backend runs the same queue contract as the PostgreSQL one.
func TestClickHouseOperatorRepository_QueueContract(t *testing.T) {
	endpoint := os.Getenv("TEST_CLICKHOUSE_URL")
	if endpoint == "" {
		t.Skip("TEST_CLICKHOUSE_URL not set")
	}
	const database = "analytics"

	client := &http.Client{Timeout: 10 * time.Second}
	repository, err := operator.NewClickHouseRepository(endpoint, database, client)
	if err != nil {
		t.Fatalf("create clickhouse repository: %v", err)
	}

	exec := func(ctx context.Context, t *testing.T, statement string) {
		t.Helper()
		target := fmt.Sprintf("%s/?database=%s", strings.TrimRight(endpoint, "/"), url.QueryEscape(database))
		request, err := http.NewRequestWithContext(ctx, http.MethodPost, target, strings.NewReader(statement))
		if err != nil {
			t.Fatalf("build request: %v", err)
		}
		response, err := client.Do(request)
		if err != nil {
			t.Fatalf("clickhouse request: %v", err)
		}
		defer func() { _ = response.Body.Close() }()
		if response.StatusCode != http.StatusOK {
			t.Fatalf("clickhouse status %d for %q", response.StatusCode, statement)
		}
	}

	seed := func(ctx context.Context, t *testing.T, event operatortest.Event) {
		t.Helper()
		payload, err := json.Marshal(map[string]string{
			"due_at": event.DueAt.UTC().Format(time.RFC3339),
		})
		if err != nil {
			t.Fatalf("encode payload: %v", err)
		}
		row, err := json.Marshal(map[string]any{
			"event_id":      event.EventID,
			"operation_key": "seed-" + event.EventID,
			"event_type":    event.EventType,
			"aggregate_id":  event.AggregateID,
			"occurred_at":   event.OccurredAt.UTC().Format("2006-01-02 15:04:05.000"),
			"payload":       string(payload),
		})
		if err != nil {
			t.Fatalf("encode row: %v", err)
		}
		exec(ctx, t, "INSERT INTO analytics_events FORMAT JSONEachRow "+string(row))
	}

	reset := func(ctx context.Context, t *testing.T) {
		t.Helper()
		exec(ctx, t, "TRUNCATE TABLE analytics_events")
	}

	operatortest.QueueContract(t, repository, seed, reset)
}
