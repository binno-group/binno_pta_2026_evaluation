package clickhouse

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"sync"
)

// HTTPWriter writes JSONEachRow batches through ClickHouse's native HTTP
// endpoint without pulling a database driver into the API binary.
type HTTPWriter struct {
	endpoint       string
	healthEndpoint string
	client         *http.Client
	mu             sync.Mutex
	rows           []clickHouseRow
}

type clickHouseRow struct {
	EventID     string  `json:"event_id"`
	EventType   string  `json:"event_type"`
	AggregateID string  `json:"aggregate_id"`
	OwnerID     *string `json:"owner_id"`
	StoreID     *string `json:"store_id"`
	DistrictID  *int32  `json:"district_id"`
	OccurredAt  string  `json:"occurred_at"`
	Payload     string  `json:"payload"`
}

// NewHTTPWriter creates a writer for database.analytics_events.
func NewHTTPWriter(endpoint, database string, client *http.Client) (*HTTPWriter, error) {
	parsed, err := url.Parse(endpoint)
	if err != nil {
		return nil, fmt.Errorf("analytics: parse clickhouse URL: %w", err)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return nil, fmt.Errorf("analytics: clickhouse URL scheme must be http or https")
	}
	if parsed.Host == "" {
		return nil, fmt.Errorf("analytics: clickhouse URL host is required")
	}
	if client == nil {
		client = &http.Client{}
	}
	query := parsed.Query()
	query.Set("database", database)
	query.Set("query", "SELECT 1")
	parsed.RawQuery = query.Encode()
	healthEndpoint := parsed.String()
	query.Set("query", "INSERT INTO analytics_events FORMAT JSONEachRow")
	parsed.RawQuery = query.Encode()
	return &HTTPWriter{
		endpoint: parsed.String(), healthEndpoint: healthEndpoint, client: client,
	}, nil
}

// Ping verifies that ClickHouse accepts a bounded query.
func (w *HTTPWriter) Ping(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, w.healthEndpoint, nil)
	if err != nil {
		return fmt.Errorf("analytics: create clickhouse health request: %w", err)
	}
	response, err := w.client.Do(req)
	if err != nil {
		return fmt.Errorf("analytics: clickhouse health request: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("analytics: clickhouse health status %d", response.StatusCode)
	}
	return nil
}

// Append buffers one event for the current dispatcher batch.
func (w *HTTPWriter) Append(_ context.Context, eventID, eventType, aggregateID string,
	ownerID, storeID *string, districtID *int32, occurredAt, payload string,
) error {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.rows = append(w.rows, clickHouseRow{
		EventID: eventID, EventType: eventType, AggregateID: aggregateID,
		OwnerID: ownerID, StoreID: storeID, DistrictID: districtID,
		OccurredAt: occurredAt, Payload: payload,
	})
	return nil
}

// Flush sends the buffered batch atomically from the writer's perspective.
func (w *HTTPWriter) Flush(ctx context.Context) error {
	w.mu.Lock()
	rows := append([]clickHouseRow(nil), w.rows...)
	w.rows = w.rows[:0]
	w.mu.Unlock()

	var body bytes.Buffer
	encoder := json.NewEncoder(&body)
	for _, row := range rows {
		if err := encoder.Encode(row); err != nil {
			return fmt.Errorf("analytics: encode clickhouse row: %w", err)
		}
	}
	endpoint, err := url.Parse(w.endpoint)
	if err != nil {
		return fmt.Errorf("analytics: parse configured clickhouse endpoint: %w", err)
	}
	query := endpoint.Query()
	query.Set("insert_deduplication_token", deduplicationToken(rows))
	endpoint.RawQuery = query.Encode()
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint.String(), &body)
	if err != nil {
		return fmt.Errorf("analytics: create clickhouse request: %w", err)
	}
	req.Header.Set("Content-Type", "application/x-ndjson")
	response, err := w.client.Do(req)
	if err != nil {
		return fmt.Errorf("analytics: send clickhouse batch: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode < http.StatusOK || response.StatusCode >= http.StatusMultipleChoices {
		detail, _ := io.ReadAll(io.LimitReader(response.Body, 4096))
		return fmt.Errorf("analytics: clickhouse status %d: %s",
			response.StatusCode, strings.TrimSpace(string(detail)))
	}
	return nil
}

// deduplicationToken identifies this exact block of rows.
func deduplicationToken(rows []clickHouseRow) string {
	hash := sha256.New()
	for _, row := range rows {
		_, _ = hash.Write([]byte(row.EventID))
	}
	return fmt.Sprintf("%x", hash.Sum(nil))
}
