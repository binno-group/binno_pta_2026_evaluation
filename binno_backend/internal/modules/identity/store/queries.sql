-- Identity owns the identity schema and reads location.owners to decide
-- whether a user carries the seller role.

-- name: UpsertUserByPhone :one
-- Login and registration are the same operation.
INSERT INTO identity.users (id, phone, status, created_at, last_login_at)
VALUES (sqlc.arg(id), sqlc.arg(phone), 'active', sqlc.arg(now), sqlc.arg(now))
ON CONFLICT (phone) DO UPDATE
    SET last_login_at = sqlc.arg(now)
RETURNING *, (identity.users.created_at = sqlc.arg(now)) AS registered;

-- name: GetUserByID :one
SELECT * FROM identity.users WHERE id = sqlc.arg(id);

-- name: GetUserRoles :one
-- The seller role is derived from location.owners, never stored on the user;
-- the operator role is a stored flag granted out-of-band.
SELECT
    u.is_operator,
    EXISTS (
        SELECT 1 FROM location.owners o
        WHERE o.user_id = u.id AND o.status = 'active'
    ) AS is_seller
FROM identity.users u
WHERE u.id = sqlc.arg(user_id);

-- name: InsertRefreshToken :one
INSERT INTO identity.refresh_tokens
    (id, user_id, token_hash, issued_at, expires_at, rotated_from)
VALUES (sqlc.arg(id), sqlc.arg(user_id), sqlc.arg(token_hash),
        sqlc.arg(issued_at), sqlc.arg(expires_at), sqlc.narg(rotated_from))
RETURNING *;

-- name: GetRefreshToken :one
-- Joins the account so the refresh path can refuse a blocked user without a
-- second round trip.
SELECT t.*, u.status AS user_status
FROM identity.refresh_tokens t
JOIN identity.users u ON u.id = t.user_id
WHERE t.token_hash = sqlc.arg(token_hash);

-- name: RevokeRefreshToken :execrows
-- Conditional on not already being revoked, so the caller can tell a first
-- revocation from a replay of an already-revoked token.
UPDATE identity.refresh_tokens
SET revoked_at = sqlc.arg(now)
WHERE id = sqlc.arg(id) AND revoked_at IS NULL;

-- name: RevokeAllUserTokens :execrows
-- Used on logout-everywhere and on detected theft.
UPDATE identity.refresh_tokens
SET revoked_at = sqlc.arg(now)
WHERE user_id = sqlc.arg(user_id) AND revoked_at IS NULL;

-- name: DeleteExpiredRefreshTokens :execrows
-- Bounded like the outbox retention: an unbounded delete on a table that grows
-- with every login is one long transaction holding one long snapshot.
DELETE FROM identity.refresh_tokens
WHERE id IN (
    SELECT expired.id FROM identity.refresh_tokens AS expired
    WHERE expired.expires_at < sqlc.arg(cutoff)
    ORDER BY expired.expires_at
    LIMIT sqlc.arg(batch_size)
);
