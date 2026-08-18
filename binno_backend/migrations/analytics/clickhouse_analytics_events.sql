-- dormant target.
--
-- Objects are qualified with the analytics database so this file lands the
-- table in the right place whether it is applied by hand (clickhouse-client) or
-- auto-run from /docker-entrypoint-initdb.d, where the entrypoint connects to
-- the default database and ignores CLICKHOUSE_DB. The app and its tests reach
-- the table with an unqualified name over a connection whose database=analytics,
-- which resolves to exactly this object.
CREATE DATABASE IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS analytics.analytics_events
(
    event_id      UUID,
    operation_key String DEFAULT '',
    event_type    LowCardinality(String),
    aggregate_id  UUID,
    owner_id      Nullable(UUID),
    store_id      Nullable(UUID),
    district_id   Nullable(Int32),
    occurred_at   DateTime64(3, 'UTC'),
    payload       String
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(occurred_at)
ORDER BY (event_type, aggregate_id, operation_key, event_id)
SETTINGS non_replicated_deduplication_window = 1000;

-- The operator queue excludes items that have already been resolved, by
-- matching a resolution event's payload against the open item's event_id:  AND
-- event_id NOT IN ( SELECT toUUIDOrNull(JSONExtractString(payload,
-- 'queue_event_id')) FROM analytics_events FINAL WHERE event_type =
-- 'operator.queue_item_resolved')  The ORDER BY key above cannot serve that:
-- the value being matched lives inside a JSON string, so the subquery reads
-- and parses the payload of every resolution event ever written on each
-- dashboard load.
ALTER TABLE analytics.analytics_events
    ADD INDEX IF NOT EXISTS idx_queue_resolution
    (toUUIDOrNull(JSONExtractString(payload, 'queue_event_id')))
    TYPE minmax GRANULARITY 4;
