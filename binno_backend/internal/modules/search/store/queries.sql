-- Search is a read-only projection over catalog.offers and location.stores.

-- name: SearchOffers :many
-- Shape matters here, not just correctness.
WITH nearby_stores AS (
    SELECT
        s.id,
        s.owner_id,
        round(ST_Distance(
            s.location,
            ST_SetSRID(ST_MakePoint(sqlc.arg(lng)::float8, sqlc.arg(lat)::float8), 4326)::geography
        ))::bigint AS distance_meters
    FROM location.stores s
    WHERE s.status = 'active'
      AND ST_DWithin(
            s.location,
            ST_SetSRID(ST_MakePoint(sqlc.arg(lng)::float8, sqlc.arg(lat)::float8), 4326)::geography,
            sqlc.arg(radius_meters)::integer
          )
      AND (
        s.complex_id IS NULL
        OR EXISTS (
            SELECT 1
            FROM location.trade_complexes tc
            WHERE tc.id = s.complex_id
              AND tc.is_active
              AND tc.district_id = sqlc.arg(district_id)
        )
      )
),
owner_totals AS (
    SELECT ns.owner_id, count(*)::bigint AS owner_offer_count
    FROM nearby_stores ns
    JOIN catalog.offers o ON o.store_id = ns.id
    WHERE o.status = 'published'
      AND o.declared_qty > o.reserved_qty
      AND (sqlc.narg(product_id)::uuid IS NULL OR o.product_id = sqlc.narg(product_id))
    GROUP BY ns.owner_id
),
best AS (
    SELECT t.owner_id, t.owner_offer_count, b.*
    FROM owner_totals t
    CROSS JOIN LATERAL (
        SELECT o.id, o.store_id, o.product_id, o.price, o.declared_qty,
               o.freshness_at, ns.distance_meters
        FROM nearby_stores ns
        JOIN catalog.offers o ON o.store_id = ns.id
        WHERE ns.owner_id = t.owner_id
          AND o.status = 'published'
          AND o.declared_qty > o.reserved_qty
          AND (sqlc.narg(product_id)::uuid IS NULL OR o.product_id = sqlc.narg(product_id))
        ORDER BY o.price, ns.distance_meters, o.id
        LIMIT 1
    ) b
)
SELECT
    id, store_id, product_id, price, declared_qty, freshness_at, distance_meters,
    greatest(owner_offer_count - 1, 0)::bigint AS other_owner_store_count
FROM best
WHERE (
    sqlc.narg(before_price)::bigint IS NULL
    OR (price, distance_meters, id) > (
      sqlc.narg(before_price)::bigint,
      sqlc.narg(before_distance)::bigint,
      sqlc.narg(before_id)::uuid
    )
  )
ORDER BY price, distance_meters, id
LIMIT sqlc.arg(page_size);

-- name: GetComplexAggregate :one
SELECT id, name,
       (pickup_point IS NOT NULL)::boolean AS has_pickup,
       coalesce(ST_Y(pickup_point::geometry), 0)::float8 AS pickup_lat,
       coalesce(ST_X(pickup_point::geometry), 0)::float8 AS pickup_lng
FROM location.trade_complexes
WHERE id = sqlc.arg(id) AND is_active;

-- name: ListComplexOffers :many
SELECT o.id, o.store_id, o.product_id, o.price, o.declared_qty, o.freshness_at,
       0::bigint AS distance_meters,
       greatest(count(*) OVER (PARTITION BY s.owner_id) - 1, 0)::bigint AS other_owner_store_count
FROM catalog.offers o
JOIN location.stores s ON s.id = o.store_id
WHERE s.complex_id = sqlc.arg(complex_id)
  AND s.status = 'active'
  AND o.status = 'published'
  AND o.declared_qty > o.reserved_qty
  AND (sqlc.narg(product_id)::uuid IS NULL OR o.product_id = sqlc.narg(product_id))
  AND (
    sqlc.narg(before_price)::bigint IS NULL
    OR (o.price, o.id) > (sqlc.narg(before_price)::bigint, sqlc.narg(before_id)::uuid)
  )
ORDER BY o.price, o.id
LIMIT sqlc.arg(page_size);

-- name: RefreshOffers :many
-- Re-reads the volatile fields of an already-ranked page and re-applies the
-- sale gate, so the cache-hit path returns exactly what a fresh SearchOffers
-- would for these ids. Price is volatile; so is eligibility: an offer that was
-- paused, sold out, or whose store was suspended since the page was cached must
-- drop out on the very next read, not linger for the cache TTL. The store join
-- mirrors the `s.status = 'active'` gate in SearchOffers so a suspended seller
-- disappears from cached results immediately.
SELECT o.id, o.price, o.declared_qty, o.freshness_at
FROM catalog.offers o
JOIN location.stores s ON s.id = o.store_id
WHERE o.id = ANY(sqlc.arg(ids)::uuid[])
  AND o.status = 'published'
  AND o.declared_qty > o.reserved_qty
  AND s.status = 'active';
