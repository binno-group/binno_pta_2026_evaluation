-- name: GetStore :one
SELECT *
FROM location.stores
WHERE id = $1;

-- name: GetStoreOwner :one
SELECT owner_id, status
FROM location.stores
WHERE id = $1;

-- name: GetOwnerByUser :one
SELECT id, status, credit_limit, psp_verified_at, verified_at, is_founding
FROM location.owners
WHERE user_id = $1;

-- name: StoreBelongsToUser :one
-- The seller authorization probe. Ownership only, deliberately status-blind:
-- a suspended store must still finish its open orders (confirm payment,
-- prepare, hand over). Availability is a different question — new sales are
-- refused by GetStoreSaleState and search hides non-active stores.
SELECT EXISTS (
    SELECT 1
    FROM location.stores s
    JOIN location.owners o ON o.id = s.owner_id
    WHERE s.id = sqlc.arg(store_id)
      AND o.user_id = sqlc.arg(user_id)
)::boolean AS allowed;

-- name: OwnerBelongsToUser :one
SELECT EXISTS (
    SELECT 1
    FROM location.owners
    WHERE id = sqlc.arg(owner_id)
      AND user_id = sqlc.arg(user_id)
)::boolean AS allowed;

-- name: GetOwnerCreditStateForStore :one
SELECT
    o.id AS owner_id,
    o.status,
    o.credit_limit,
    o.psp_verified_at
FROM location.owners AS o
JOIN location.stores AS s ON s.owner_id = o.id
WHERE s.id = $1;

-- name: GetTradeComplex :one
SELECT *
FROM location.trade_complexes
WHERE id = $1;

-- name: GetDistrict :one
SELECT *
FROM location.districts
WHERE id = $1;

-- name: GetOwner :one
SELECT *
FROM location.owners
WHERE id = $1;

-- name: GetComplexBlock :one
SELECT *
FROM location.complex_blocks
WHERE id = $1;

-- name: RegisterOwner :one
-- Seller registration.
INSERT INTO location.owners (
    id, user_id, tin, legal_name, legal_form, bank_account, mfo,
    status, is_founding, credit_limit, created_at
) VALUES (
    sqlc.arg(id), sqlc.arg(user_id), sqlc.arg(tin), sqlc.arg(legal_name),
    sqlc.arg(legal_form), sqlc.arg(bank_account), sqlc.arg(mfo),
    'pending', false, 0, sqlc.arg(now)
)
RETURNING *;

-- name: GetOwnerForUser :one
SELECT * FROM location.owners WHERE user_id = sqlc.arg(user_id);

-- name: GetStoreSaleState :one
-- The one question the order path asks of location: may this store sell right
-- now, and to whose account does the commission go?  FOR SHARE OF o is
-- deliberate and is the whole reason this is a query rather than two lookups.
SELECT
    s.id            AS store_id,
    s.name          AS store_name,
    s.status        AS store_status,
    s.phone         AS store_phone,
    o.id            AS owner_id,
    o.status        AS owner_status,
    o.tin           AS owner_tin,
    o.legal_name    AS owner_legal_name,
    o.bank_account  AS owner_bank_account,
    o.mfo           AS owner_mfo
FROM location.stores s
JOIN location.owners o ON o.id = s.owner_id
WHERE s.id = sqlc.arg(store_id)
FOR SHARE OF o;
