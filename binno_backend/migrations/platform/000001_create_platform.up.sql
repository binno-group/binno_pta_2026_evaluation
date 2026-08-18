-- Shared infrastructure: the transactional outbox and mutation receipts.
CREATE SCHEMA IF NOT EXISTS platform;

CREATE TABLE platform.outbox (
    id               BIGSERIAL PRIMARY KEY,
    event_id         UUID NOT NULL UNIQUE,
    module           TEXT NOT NULL,
    event_name       TEXT NOT NULL,
    event_version    INT NOT NULL,
    aggregate_id     TEXT NOT NULL,
    payload          JSONB NOT NULL,
    occurred_at      TIMESTAMPTZ NOT NULL,
    claimed_at       TIMESTAMPTZ,
    dispatched_at    TIMESTAMPTZ,
    attempt_count    INT NOT NULL DEFAULT 0,
    last_error       TEXT,
    next_attempt_at  TIMESTAMPTZ,
    dead_lettered_at TIMESTAMPTZ,
    CONSTRAINT chk_outbox_attempt_count CHECK (attempt_count >= 0)
);

CREATE INDEX idx_outbox_pending
    ON platform.outbox (id)
    WHERE dispatched_at IS NULL AND dead_lettered_at IS NULL;

CREATE INDEX idx_outbox_dispatched_retention
    ON platform.outbox (dispatched_at)
    WHERE dispatched_at IS NOT NULL;

-- The claim query enforces per-aggregate ordering with a correlated NOT EXISTS
-- over earlier undispatched rows.
CREATE INDEX idx_outbox_aggregate_pending
    ON platform.outbox (aggregate_id, id)
    WHERE dispatched_at IS NULL AND dead_lettered_at IS NULL;

-- The dead-letter gauge is a FILTER'd count; its own small index keeps the
-- metric off the delivered history.
CREATE INDEX idx_outbox_dead_lettered
    ON platform.outbox (dead_lettered_at)
    WHERE dead_lettered_at IS NOT NULL;

CREATE TABLE platform.mutation_receipts (
    operation_key TEXT PRIMARY KEY,
    resource_id   UUID,
    created_at    TIMESTAMPTZ NOT NULL,
    CHECK (length(operation_key) BETWEEN 1 AND 512)
);

CREATE INDEX idx_mutation_receipts_created_at
    ON platform.mutation_receipts (created_at);
