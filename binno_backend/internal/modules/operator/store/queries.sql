-- name: ListOperatorQueue :many
SELECT
    id,
    queue_type,
    ref_id,
    opened_at,
    due_at,
    payload
FROM analytics.operator_queue
WHERE queue_type = sqlc.arg(queue_type)
  AND (
    sqlc.narg(before_opened_at)::timestamptz IS NULL
    OR (opened_at, id) < (
        sqlc.narg(before_opened_at)::timestamptz,
        sqlc.narg(before_id)::uuid
    )
  )
ORDER BY opened_at DESC, id DESC
LIMIT sqlc.arg(page_size);

-- name: CountOperatorQueue :one
SELECT count(*)::bigint
FROM analytics.operator_queue
WHERE queue_type = $1;

-- name: ListAnalyticsEventsByAggregate :many
SELECT *
FROM analytics.analytics_events
WHERE aggregate_id = sqlc.arg(aggregate_id)
  AND (
    sqlc.narg(before_occurred_at)::timestamptz IS NULL
    OR occurred_at < sqlc.narg(before_occurred_at)::timestamptz
  )
ORDER BY occurred_at DESC, event_id DESC
LIMIT sqlc.arg(page_size);

-- name: ResolveOperatorQueueItem :exec
INSERT INTO analytics.analytics_events (
  event_id, operation_key, event_type, aggregate_id, occurred_at, payload
) VALUES (
  sqlc.arg(event_id), sqlc.arg(operation_key), sqlc.arg(event_type), sqlc.arg(aggregate_id),
  sqlc.arg(occurred_at), sqlc.arg(payload)
)
ON CONFLICT (operation_key) DO NOTHING;
