-- The sole write path for orders.status.

-- name: TransitionOrder :one
UPDATE orders.orders
SET
    status = sqlc.arg(to_status),
    closed_at = CASE
        WHEN sqlc.arg(to_status)::text = 'closed' THEN sqlc.arg(occurred_at)
        ELSE closed_at
    END
WHERE id = sqlc.arg(id)
  AND status = sqlc.arg(from_status)
RETURNING *;

-- name: AppendOrderEvent :exec
INSERT INTO orders.order_events (
    order_id, from_status, to_status, actor, source, payload, created_at
) VALUES (
    sqlc.arg(order_id),
    sqlc.narg(from_status),
    sqlc.arg(to_status),
    sqlc.arg(actor),
    sqlc.arg(source),
    sqlc.narg(payload),
    sqlc.arg(created_at)
);
