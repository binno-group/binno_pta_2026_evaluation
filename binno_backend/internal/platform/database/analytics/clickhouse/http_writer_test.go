package clickhouse_test

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics/clickhouse"
)

func TestHTTPClickHouseWriterFlushesJSONEachRowWithStableDeduplication(t *testing.T) {
	var bodies []string
	var tokens []string
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		body, _ := io.ReadAll(r.Body)
		bodies = append(bodies, string(body))
		tokens = append(tokens, r.URL.Query().Get("insert_deduplication_token"))
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       io.NopCloser(strings.NewReader("")),
			Header:     make(http.Header),
		}, nil
	})}

	writer, err := clickhouse.NewHTTPWriter("http://clickhouse:8123", "analytics", client)
	if err != nil {
		t.Fatalf("NewHTTPWriter error = %v", err)
	}
	appendBatch := func() {
		t.Helper()
		if err := writer.Append(context.Background(), "event-1", "order.created", "order-1",
			nil, nil, nil, "2026-07-29 10:00:00.000", `{"owner_id":null}`); err != nil {
			t.Fatalf("Append error = %v", err)
		}
		if err := writer.Flush(context.Background()); err != nil {
			t.Fatalf("Flush error = %v", err)
		}
	}

	appendBatch()
	appendBatch()

	if len(tokens) != 2 || tokens[0] == "" || tokens[0] != tokens[1] {
		t.Fatalf("deduplication tokens = %v, want two equal non-empty values", tokens)
	}
	if len(bodies) != 2 || strings.Count(bodies[0], "\n") != 1 {
		t.Fatalf("request bodies = %q, want one JSONEachRow row per flush", bodies)
	}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(request *http.Request) (*http.Response, error) {
	return f(request)
}
