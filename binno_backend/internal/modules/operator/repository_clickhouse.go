package operator

import (
	"bufio"
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
)

// ClickHouse reads analytics data through the ClickHouse HTTP API.
type ClickHouse struct {
	endpoint string
	client   *http.Client
}

// NewClickHouseRepository validates and creates a ClickHouse operator
// repository.
func NewClickHouseRepository(endpoint, database string, client *http.Client) (*ClickHouse, error) {
	parsed, err := url.Parse(endpoint)
	if err != nil {
		return nil, fmt.Errorf("operator repo: parse clickhouse URL: %w", err)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" || parsed.Host == "" {
		return nil, fmt.Errorf("operator repo: invalid clickhouse URL")
	}
	query := parsed.Query()
	query.Set("database", database)
	parsed.RawQuery = query.Encode()
	if client == nil {
		client = &http.Client{}
	}
	return &ClickHouse{endpoint: parsed.String(), client: client}, nil
}

// Ping verifies the ClickHouse read endpoint.
func (r *ClickHouse) Ping(ctx context.Context) error {
	endpoint, err := url.Parse(r.endpoint)
	if err != nil {
		return fmt.Errorf("operator repo: parse configured clickhouse URL: %w", err)
	}
	values := endpoint.Query()
	values.Set("query", "SELECT 1")
	endpoint.RawQuery = values.Encode()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint.String(), nil)
	if err != nil {
		return fmt.Errorf("operator repo: create clickhouse health request: %w", err)
	}
	response, err := r.client.Do(request)
	if err != nil {
		return fmt.Errorf("operator repo: clickhouse health request: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("operator repo: clickhouse health status %d", response.StatusCode)
	}
	return nil
}

// ListQueue computes the same queue projection as the PostgreSQL view.
func (r *ClickHouse) ListQueue(ctx context.Context, query QueueQuery) ([]QueueRecord, error) {
	statement := clickHouseQueueSQL(query)
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, r.endpoint, strings.NewReader(statement))
	if err != nil {
		return nil, fmt.Errorf("operator repo: create clickhouse request: %w", err)
	}
	request.Header.Set("Content-Type", "text/plain; charset=utf-8")
	response, err := r.client.Do(request)
	if err != nil {
		return nil, fmt.Errorf("operator repo: query clickhouse: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("operator repo: clickhouse status %d", response.StatusCode)
	}

	rows := make([]QueueRecord, 0, query.PageSize)
	scanner := bufio.NewScanner(response.Body)
	for scanner.Scan() {
		var row clickHouseQueueRow
		if err := json.Unmarshal(scanner.Bytes(), &row); err != nil {
			return nil, fmt.Errorf("operator repo: decode clickhouse row: %w", err)
		}
		openedAt, err := time.Parse("2006-01-02 15:04:05.000", row.OpenedAt)
		if err != nil {
			return nil, fmt.Errorf("operator repo: parse clickhouse opened_at: %w", err)
		}
		dueAt, err := time.Parse(time.RFC3339Nano, row.DueAt)
		if err != nil {
			return nil, fmt.Errorf("operator repo: parse clickhouse due_at: %w", err)
		}
		rows = append(rows, QueueRecord{
			ID: row.ID, RefID: row.RefID, OpenedAt: openedAt.UTC(), DueAt: dueAt.UTC(),
		})
	}
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("operator repo: scan clickhouse rows: %w", err)
	}
	return rows, nil
}

func (r *ClickHouse) Resolve(ctx context.Context, resolution Resolution) error {
	queueID, err := uuid.Parse(resolution.QueueEventID)
	if err != nil {
		return ErrInvalidResolution
	}
	eventID := operationUUID(resolution.OperationKey)
	row := map[string]any{
		"event_id": eventID.String(), "event_type": string(eventcatalog.OperatorQueueItemResolved),
		"operation_key": resolution.OperationKey,
		"aggregate_id":  queueID.String(), "occurred_at": resolution.OccurredAt.UTC().Format("2006-01-02 15:04:05.000"),
		"payload": map[string]string{
			"queue_event_id": resolution.QueueEventID, "queue_type": resolution.QueueType,
			"action": resolution.Action, "note": resolution.Note, "actor_id": resolution.ActorID,
		},
	}
	body, err := json.Marshal(row)
	if err != nil {
		return fmt.Errorf("operator repo: encode clickhouse resolution: %w", err)
	}
	statement := "INSERT INTO analytics_events FORMAT JSONEachRow\n" + string(body) + "\n"
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, r.endpoint, strings.NewReader(statement))
	if err != nil {
		return fmt.Errorf("operator repo: create clickhouse resolution request: %w", err)
	}
	request.Header.Set("Content-Type", "text/plain; charset=utf-8")
	response, err := r.client.Do(request)
	if err != nil {
		return fmt.Errorf("operator repo: write clickhouse resolution: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("operator repo: clickhouse resolution status %d", response.StatusCode)
	}
	return nil
}

func operationUUID(operationKey string) uuid.UUID {
	sum := sha256.Sum256([]byte(operationKey))
	var id uuid.UUID
	copy(id[:], sum[:16])
	id[6] = (id[6] & 0x0f) | 0x50
	id[8] = (id[8] & 0x3f) | 0x80
	return id
}

type clickHouseQueueRow struct {
	ID       string `json:"id"`
	RefID    string `json:"ref_id"`
	OpenedAt string `json:"opened_at"`
	DueAt    string `json:"due_at"`
}

// queueClosure names the events that make an open queue item moot: the
// underlying work resolved itself, so the item leaves the queue without an
// operator touching it. Strict marks a strict (>) time comparison —
// payment_review needs it because order.awaiting_payment is also emitted at
// invoice issue, before the review opens. This table must stay in lockstep
// with the analytics.operator_queue view on the PostgreSQL side; the shared
// operatortest contract holds the two together.
type queueClosure struct {
	Types  []string
	Strict bool
}

func queueClosureFor(queueType string) (queueClosure, bool) {
	closure, ok := map[string]queueClosure{
		"sla_escalation": {Types: []string{
			"order.accepted", "order.declined", "order.expired", "order.cancelled",
		}},
		"payment_review": {Types: []string{
			"order.paid", "order.awaiting_payment", "order.cancelled", "order.expired",
		}, Strict: true},
		"catalog_request": {Types: []string{"catalog.request_resolved"}},
		"refund_overdue":  {Types: []string{"order.refunded"}},
	}[queueType]
	return closure, ok
}

func clickHouseQueueSQL(query QueueQuery) string {
	eventType := map[string]string{
		"payment_review": "payment.review_started", "refund_overdue": "refund.became_overdue",
		"sla_escalation": "order.sla_escalated", "catalog_request": "catalog.requested",
		"confirmation_chase": "order.confirmation_chase_requested",
	}[query.Type]
	var before string
	if query.BeforeOpened != nil {
		at := query.BeforeOpened.UTC().Format(time.RFC3339Nano)
		before = " AND (source.occurred_at < parseDateTime64BestEffort('" + at + "')" +
			" OR (source.occurred_at = parseDateTime64BestEffort('" + at + "')" +
			" AND source.event_id < toUUID('" + query.BeforeID + "')))"
	}

	// Auto-closure: the newest closing event per aggregate decides. max() is
	// enough — any closing event at or after the opening closes the item, and
	// an unmatched LEFT JOIN row compares as the epoch, which never closes.
	var closureJoin, closureFilter string
	if closure, ok := queueClosureFor(query.Type); ok {
		quoted := make([]string, len(closure.Types))
		for i, name := range closure.Types {
			quoted[i] = "'" + name + "'"
		}
		closureJoin = " LEFT JOIN (SELECT aggregate_id, max(occurred_at) AS closed_at" +
			" FROM analytics_events FINAL" +
			" WHERE event_type IN (" + strings.Join(quoted, ", ") + ")" +
			" GROUP BY aggregate_id) AS closure" +
			" ON closure.aggregate_id = source.aggregate_id"
		operator := "<"
		if closure.Strict {
			operator = "<="
		}
		closureFilter = " AND closure.closed_at " + operator + " source.occurred_at"
	}

	return strings.Join([]string{
		"SELECT toString(source.event_id) AS id, toString(source.aggregate_id) AS ref_id,",
		"formatDateTime(source.occurred_at, '%Y-%m-%d %H:%i:%s.%f') AS opened_at,",
		"if(JSONExtractString(source.payload, 'due_at') = '',",
		"formatDateTime(source.occurred_at, '%Y-%m-%dT%H:%i:%s.%fZ'),",
		"JSONExtractString(source.payload, 'due_at')) AS due_at",
		"FROM analytics_events AS source FINAL" + closureJoin,
		"WHERE source.event_type = '" + eventType + "'" + before,
		"AND source.event_id NOT IN (",
		"SELECT toUUIDOrNull(JSONExtractString(payload, 'queue_event_id'))",
		"FROM analytics_events FINAL WHERE event_type = '" + string(eventcatalog.OperatorQueueItemResolved) + "')" +
			closureFilter,
		"ORDER BY source.occurred_at DESC, source.event_id DESC",
		"LIMIT " + strconv.FormatInt(int64(query.PageSize), 10),
		"FORMAT JSONEachRow",
	}, " ")
}

var _ queueRepository = (*ClickHouse)(nil)
