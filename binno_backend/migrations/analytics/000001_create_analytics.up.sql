-- Append-only analytics event store, written only by cmd/dispatcher and read
-- only by the operator module.
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE analytics.analytics_events (
    event_id      UUID PRIMARY KEY,
    operation_key TEXT UNIQUE,
    event_type    TEXT NOT NULL,
    aggregate_id  UUID NOT NULL,
    owner_id      UUID,
    store_id      UUID,
    district_id   INT,
    occurred_at   TIMESTAMPTZ NOT NULL,
    payload       JSONB NOT NULL
);

CREATE INDEX idx_analytics_events_type
    ON analytics.analytics_events (event_type, occurred_at);
CREATE INDEX idx_analytics_events_owner
    ON analytics.analytics_events (owner_id, occurred_at);
CREATE INDEX idx_analytics_events_store
    ON analytics.analytics_events (store_id, occurred_at);

-- The operator queue anti-joins open items against resolved events on a JSON
-- field, which no other index can serve.
CREATE INDEX idx_analytics_events_queue_resolution
    ON analytics.analytics_events ((payload ->> 'queue_event_id'))
    WHERE event_type = 'operator.queue_item_resolved';

-- Auto-closure walks the aggregate's later events; this index serves the
-- correlated NOT EXISTS per open item.
CREATE INDEX idx_analytics_events_aggregate
    ON analytics.analytics_events (aggregate_id, event_type, occurred_at);

-- Operator queues are computed from analytics events; the dashboard never
-- reads OLTP order tables. An item leaves the queue two ways: an operator
-- resolves it explicitly, or the underlying work resolves itself — the seller
-- settles the payment, the supplier answers a chased order, the catalogue
-- request gets its decision, the refund lands. payment_review compares
-- strictly (>) because order.awaiting_payment is also emitted at invoice
-- issue, before the review opens; every other pair compares >=.
CREATE VIEW analytics.operator_queue AS
SELECT
    source.event_id AS id,
    (CASE source.event_type
        WHEN 'payment.review_started' THEN 'payment_review'
        WHEN 'refund.became_overdue' THEN 'refund_overdue'
        WHEN 'order.sla_escalated' THEN 'sla_escalation'
        WHEN 'catalog.requested' THEN 'catalog_request'
        WHEN 'order.confirmation_chase_requested' THEN 'confirmation_chase'
    END)::text AS queue_type,
    source.aggregate_id AS ref_id,
    source.occurred_at AS opened_at,
    (CASE
        WHEN source.payload ? 'due_at'
        THEN (source.payload ->> 'due_at')::timestamptz
        ELSE source.occurred_at
    END)::timestamptz AS due_at,
    source.payload
FROM analytics.analytics_events AS source
WHERE source.event_type IN (
    'payment.review_started',
    'refund.became_overdue',
    'order.sla_escalated',
    'catalog.requested',
    'order.confirmation_chase_requested'
)
AND NOT EXISTS (
    SELECT 1
    FROM analytics.analytics_events AS resolved
    WHERE resolved.event_type = 'operator.queue_item_resolved'
      AND resolved.payload ->> 'queue_event_id' = source.event_id::text
)
AND NOT EXISTS (
    SELECT 1
    FROM analytics.analytics_events AS closing
    WHERE closing.aggregate_id = source.aggregate_id
      AND (
        (source.event_type = 'order.sla_escalated'
         AND closing.event_type IN
             ('order.accepted', 'order.declined', 'order.expired', 'order.cancelled')
         AND closing.occurred_at >= source.occurred_at)
        OR
        (source.event_type = 'payment.review_started'
         AND closing.event_type IN
             ('order.paid', 'order.awaiting_payment', 'order.cancelled', 'order.expired')
         AND closing.occurred_at > source.occurred_at)
        OR
        (source.event_type = 'catalog.requested'
         AND closing.event_type = 'catalog.request_resolved'
         AND closing.occurred_at >= source.occurred_at)
        OR
        (source.event_type = 'refund.became_overdue'
         AND closing.event_type = 'order.refunded'
         AND closing.occurred_at >= source.occurred_at)
      )
);
