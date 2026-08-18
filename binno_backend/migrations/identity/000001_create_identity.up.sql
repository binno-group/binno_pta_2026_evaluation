-- Identity: who a caller is, and how they proved it.
CREATE SCHEMA IF NOT EXISTS identity;

-- A person.
CREATE TABLE identity.users (
    id            UUID PRIMARY KEY,
    phone         TEXT NOT NULL UNIQUE,
    status        TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'blocked')),
    -- Granted out-of-band by the platform team (make grant-operator); there is
    -- deliberately no API that sets it.
    is_operator   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL,
    last_login_at TIMESTAMPTZ,
    CONSTRAINT chk_users_phone CHECK (phone ~ '^998[0-9]{9}$')
);

-- Refresh tokens.
CREATE TABLE identity.refresh_tokens (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES identity.users(id) ON DELETE CASCADE,
    token_hash  BYTEA NOT NULL UNIQUE,
    issued_at   TIMESTAMPTZ NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked_at  TIMESTAMPTZ,
    rotated_from UUID REFERENCES identity.refresh_tokens(id) ON DELETE SET NULL,
    CONSTRAINT chk_refresh_expiry CHECK (expires_at > issued_at)
);

-- Lookup is always "find the live sessions for this user", for revocation and
-- for bounding how many sessions one account may hold.
CREATE INDEX idx_refresh_tokens_user ON identity.refresh_tokens (user_id)
    WHERE revoked_at IS NULL;

-- Retention scans expired rows so a cleanup can bound the table; without this
-- it grows with every login for the lifetime of the product.
CREATE INDEX idx_refresh_tokens_expiry ON identity.refresh_tokens (expires_at);
