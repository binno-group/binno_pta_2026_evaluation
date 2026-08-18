-- name: CreateOrder :one
INSERT INTO orders.orders (
    id, buyer_id, store_id, status, buyer_type, buyer_tin, fulfillment,
    is_urgent, goods_amount, delivery_fee, total_amount, dropoff, dropoff_address,
    district_id, supplier_confirmation_deadline, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(buyer_id),
    sqlc.arg(store_id),
    'created',
    sqlc.arg(buyer_type),
    sqlc.narg(buyer_tin),
    sqlc.arg(fulfillment),
    sqlc.arg(is_urgent),
    sqlc.arg(goods_amount),
    sqlc.arg(delivery_fee),
    sqlc.arg(total_amount),
    CASE WHEN sqlc.narg(dropoff_lat)::float8 IS NULL OR sqlc.narg(dropoff_lng)::float8 IS NULL
      THEN NULL
      ELSE ST_SetSRID(ST_MakePoint(sqlc.narg(dropoff_lng)::float8, sqlc.narg(dropoff_lat)::float8), 4326)::geography
    END,
    sqlc.narg(dropoff_address),
    sqlc.narg(district_id),
    sqlc.arg(supplier_confirmation_deadline),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: CreateOrderItem :one
INSERT INTO orders.order_items (
    id, order_id, product_id, qty, unit_price, line_amount, commission_bps
) VALUES (
    sqlc.arg(id),
    sqlc.arg(order_id),
    sqlc.arg(product_id),
    sqlc.arg(qty),
    sqlc.arg(unit_price),
    sqlc.arg(line_amount),
    sqlc.arg(commission_bps)
)
RETURNING *;

-- name: GetOrderForUpdate :one
SELECT *
FROM orders.orders
WHERE id = $1
FOR UPDATE;

-- name: GetOrder :one
SELECT *
FROM orders.orders
WHERE id = $1;

-- name: GetOrderSummary :one
-- The published cross-module read of an order.
SELECT id, buyer_id, store_id, status, total_amount, created_at, closed_at
FROM orders.orders
WHERE id = $1;

-- name: ListOrderEvents :many
SELECT *
FROM orders.order_events
WHERE order_id = $1
ORDER BY id;

-- name: ListOrderItems :many
SELECT *
FROM orders.order_items
WHERE order_id = $1
ORDER BY id;

-- name: ListOrdersAwaitingConfirmation :many
-- Drives the supplier-confirmation SLA sweeper.
SELECT id, store_id, buyer_id, supplier_confirmation_deadline
FROM orders.orders
WHERE status = 'created'
  AND supplier_confirmation_deadline <= sqlc.arg(deadline)
ORDER BY supplier_confirmation_deadline
LIMIT sqlc.arg(page_size);

-- name: ListOrdersPaymentOverdue :many
-- Drives the payment SLA sweeper.
SELECT id, store_id, buyer_id, payment_due_at
FROM orders.orders
WHERE status = 'awaiting_payment'
  AND payment_due_at <= sqlc.arg(deadline)
ORDER BY payment_due_at
LIMIT sqlc.arg(page_size);

-- name: SetOrderPaymentDue :exec
-- Recorded when the invoice is issued, so the sweeper never has to read the
-- billing schema.
UPDATE orders.orders
SET payment_due_at = sqlc.arg(payment_due_at)
WHERE id = sqlc.arg(id);

-- name: ListOrdersByBuyer :many
-- Buyer order history, newest first, keyset-paginated.
SELECT *
FROM orders.orders
WHERE buyer_id = sqlc.arg(buyer_id)
  AND (
    sqlc.narg(before_created_at)::timestamptz IS NULL
    OR (created_at, id) < (sqlc.narg(before_created_at)::timestamptz, sqlc.narg(before_id)::uuid)
  )
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg(page_size);

-- name: ListStoreOpenOrders :many
-- The seller fulfilment queue: open orders for one store, newest first.
SELECT *
FROM orders.orders
WHERE store_id = sqlc.arg(store_id)
  AND status IN ('accepted', 'awaiting_payment', 'payment_review',
                 'paid', 'preparing', 'ready')
  AND (
    sqlc.narg(before_created_at)::timestamptz IS NULL
    OR (created_at, id) < (sqlc.narg(before_created_at)::timestamptz, sqlc.narg(before_id)::uuid)
  )
ORDER BY created_at DESC, id DESC
LIMIT sqlc.arg(page_size);

-- name: CreateConfirmToken :exec
INSERT INTO orders.confirm_tokens (
    token_hash, order_id, store_id, expires_at
) VALUES (
    sqlc.arg(token_hash),
    sqlc.arg(order_id),
    sqlc.arg(store_id),
    sqlc.arg(expires_at)
);

-- name: ConsumeConfirmToken :one
UPDATE orders.confirm_tokens
SET used_at = sqlc.arg(used_at)
WHERE token_hash = sqlc.arg(token_hash)
  AND used_at IS NULL
  AND expires_at > sqlc.arg(used_at)
RETURNING *;
