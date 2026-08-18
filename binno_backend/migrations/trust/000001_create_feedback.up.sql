-- Binary, transaction-bound store feedback.
CREATE SCHEMA IF NOT EXISTS trust;

CREATE TABLE trust.order_feedback (
    order_id    UUID PRIMARY KEY REFERENCES orders.orders(id),
    store_id    UUID NOT NULL REFERENCES location.stores(id),
    had_problem BOOLEAN NOT NULL,
    tags        TEXT[] NOT NULL DEFAULT '{}',
    comment     TEXT,
    channel     TEXT NOT NULL CHECK (channel IN ('push', 'sms', 'app')),
    created_at  TIMESTAMPTZ NOT NULL,
    CHECK (
        tags <@ ARRAY['late', 'qty_short', 'quality', 'price_mismatch', 'no_response']::TEXT[]
    )
);

CREATE INDEX idx_feedback_store ON trust.order_feedback (store_id, created_at);
