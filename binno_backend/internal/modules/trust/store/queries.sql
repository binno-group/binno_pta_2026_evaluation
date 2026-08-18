-- name: CreateOrderFeedback :one
INSERT INTO trust.order_feedback (
    order_id, store_id, had_problem, tags, comment, channel, created_at
) VALUES (
    sqlc.arg(order_id),
    sqlc.arg(store_id),
    sqlc.arg(had_problem),
    sqlc.arg(tags),
    sqlc.narg(comment),
    sqlc.arg(channel),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: GetOrderFeedback :one
SELECT *
FROM trust.order_feedback
WHERE order_id = $1;

-- name: GetStoreFeedbackCounts :one
SELECT
    count(*)::bigint AS response_count,
    count(*) FILTER (WHERE NOT had_problem)::bigint AS problem_free_count
FROM trust.order_feedback
WHERE store_id = $1;
