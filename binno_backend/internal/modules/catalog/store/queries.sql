-- name: CreateCatalogRequest :one
INSERT INTO catalog.catalog_requests (
    id, store_id, name, unit, description, image_url, status, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(store_id),
    sqlc.arg(name),
    sqlc.arg(unit),
    sqlc.narg(description),
    sqlc.narg(image_url),
    'pending',
    sqlc.arg(created_at)
)
RETURNING *;

-- name: GetCategory :one
SELECT *
FROM catalog.categories
WHERE id = $1;

-- name: GetProduct :one
SELECT *
FROM catalog.products
WHERE id = $1;

-- name: GetCatalogRequestForUpdate :one
SELECT *
FROM catalog.catalog_requests
WHERE id = $1
FOR UPDATE;

-- name: ResolveCatalogRequest :one
UPDATE catalog.catalog_requests
SET
    status = sqlc.arg(status),
    product_id = sqlc.narg(product_id),
    reject_reason = sqlc.narg(reject_reason),
    resolved_at = sqlc.arg(resolved_at)
WHERE id = sqlc.arg(id)
  AND status = 'pending'
RETURNING *;

-- name: CreateOffer :one
INSERT INTO catalog.offers (
    id, store_id, product_id, price, declared_qty, reserved_qty,
    freshness_at, status
) VALUES (
    sqlc.arg(id),
    sqlc.arg(store_id),
    sqlc.arg(product_id),
    sqlc.arg(price),
    sqlc.arg(declared_qty),
    0,
    sqlc.arg(freshness_at),
    'published'
)
RETURNING *;

-- name: GetOfferForUpdate :one
SELECT *
FROM catalog.offers
WHERE id = $1
FOR UPDATE;

-- name: UpdateOfferValues :one
UPDATE catalog.offers
SET
    price = sqlc.arg(price),
    declared_qty = sqlc.arg(declared_qty),
    freshness_at = CASE
        WHEN price IS DISTINCT FROM sqlc.arg(price)
          OR declared_qty IS DISTINCT FROM sqlc.arg(declared_qty)
        THEN sqlc.arg(changed_at)
        ELSE freshness_at
    END
WHERE id = sqlc.arg(id)
RETURNING *;

-- name: UpdateOfferStatus :one
-- Seller-facing pause and republish. Only published <-> hidden moves through
-- the API; 'archived' is an ops decision and cannot be reversed here.
UPDATE catalog.offers
SET status = sqlc.arg(status)
WHERE id = sqlc.arg(id)
  AND status IN ('published', 'hidden')
RETURNING *;

-- name: ReserveOfferQuantity :one
UPDATE catalog.offers
SET reserved_qty = reserved_qty + sqlc.arg(qty)
WHERE id = sqlc.arg(id)
  AND status = 'published'
  AND declared_qty - reserved_qty >= sqlc.arg(qty)
RETURNING *;

-- name: ConsumeOfferQuantity :execrows
-- A closed sale leaves the shelf for good: both the declared stock and the
-- reservation that was holding it shrink together, so a later declared-stock
-- update by the seller is not blocked by phantom holds.
UPDATE catalog.offers
SET declared_qty = declared_qty - sqlc.arg(qty),
    reserved_qty = reserved_qty - sqlc.arg(qty)
WHERE store_id = sqlc.arg(store_id)
  AND product_id = sqlc.arg(product_id)
  AND reserved_qty >= sqlc.arg(qty);

-- name: ReleaseOfferQuantity :execrows
UPDATE catalog.offers
SET reserved_qty = reserved_qty - sqlc.arg(qty)
WHERE store_id = sqlc.arg(store_id)
  AND product_id = sqlc.arg(product_id)
  AND reserved_qty >= sqlc.arg(qty);

-- name: GetDeliveryTariff :one
SELECT store_id, district_id, price, updated_at
FROM catalog.delivery_tariffs
WHERE store_id = sqlc.arg(store_id)
  AND district_id = sqlc.arg(district_id);

-- name: GetOfferForOrder :one
SELECT o.*, c.confirm_window_minutes, c.commission_bps
FROM catalog.offers o
JOIN catalog.products p ON p.id = o.product_id
JOIN catalog.categories c ON c.id = p.category_id
WHERE o.store_id = sqlc.arg(store_id)
  AND o.product_id = sqlc.arg(product_id)
  AND o.status = 'published'
  AND p.is_active
  AND c.is_active
FOR UPDATE OF o;

-- name: ListOfferAlternatives :many
-- Substitute offers for the same products from a different store, cheapest
-- first. No price cap: a pricier substitute is still a substitute.
SELECT o.id, o.store_id, o.product_id, o.price, o.declared_qty, o.freshness_at
FROM catalog.offers o
WHERE o.product_id = ANY(sqlc.arg(product_ids)::uuid[])
  AND o.store_id <> sqlc.arg(exclude_store_id)
  AND o.status = 'published'
  AND o.declared_qty > o.reserved_qty
  AND (
    sqlc.narg(before_price)::bigint IS NULL
    OR (o.price, o.id) > (sqlc.narg(before_price)::bigint, sqlc.narg(before_id)::uuid)
  )
ORDER BY o.price, o.id
LIMIT sqlc.arg(page_size);

-- name: GetOfferStore :one
-- Ownership probe for seller mutations on an existing offer.
SELECT store_id
FROM catalog.offers
WHERE id = $1;

-- name: GetCatalogRequestStore :one
SELECT store_id
FROM catalog.catalog_requests
WHERE id = $1;
