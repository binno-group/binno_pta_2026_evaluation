//go:build integration

package clickhouse_test

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"testing"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics/clickhouse"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox/outboxtest"
)

func TestClickHouseSink_ConsumerContract(t *testing.T) {
	if os.Getenv("TEST_CLICKHOUSE_URL") == "" {
		t.Skip("TEST_CLICKHOUSE_URL not set")
	}
	const endpoint = "http://127.0.0.1:8123"
	writer, err := clickhouse.NewHTTPWriter(endpoint, "analytics", http.DefaultClient)
	if err != nil {
		t.Fatalf("create ClickHouse writer: %v", err)
	}
	sink := clickhouse.NewSink(writer)

	occurrences := func(ctx context.Context, eventID uuid.UUID) (int, error) {
		parsed, err := url.Parse(endpoint)
		if err != nil {
			return 0, err
		}
		query := parsed.Query()
		query.Set("database", "analytics")
		query.Set("query", fmt.Sprintf(
			"SELECT count() FROM analytics_events FINAL WHERE event_id = toUUID('%s')",
			eventID,
		))
		parsed.RawQuery = query.Encode()
		request, err := http.NewRequestWithContext(ctx, http.MethodGet, parsed.String(), nil)
		if err != nil {
			return 0, err
		}
		response, err := http.DefaultClient.Do(request)
		if err != nil {
			return 0, err
		}
		defer func() { _ = response.Body.Close() }()
		if response.StatusCode != http.StatusOK {
			body, _ := io.ReadAll(io.LimitReader(response.Body, 4096))
			return 0, fmt.Errorf("clickhouse status %d: %s",
				response.StatusCode, strings.TrimSpace(string(body)))
		}
		body, err := io.ReadAll(response.Body)
		if err != nil {
			return 0, err
		}
		return strconv.Atoi(strings.TrimSpace(string(body)))
	}

	outboxtest.ConsumerContract(t, sink, occurrences)
}
