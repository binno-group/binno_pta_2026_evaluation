-- Order state, accepted item snapshot and confirmation tokens.
CREATE SCHEMA IF NOT EXISTS orders;

CREATE TABLE orders.orders (
    id              UUID PRIMARY KEY,
    buyer_id        UUID NOT NULL,
    store_id        UUID NOT NULL REFERENCES location.stores(id),
    status          TEXT NOT NULL,
    buyer_type      TEXT NOT NULL DEFAULT 'individual'
        CHECK (buyer_type IN ('individual', 'legal_entity')),
    buyer_tin       TEXT,
    fulfillment     TEXT NOT NULL DEFAULT 'delivery'
        CHECK (fulfillment IN ('delivery', 'pickup')),
    is_urgent       BOOLEAN NOT NULL DEFAULT FALSE,
    goods_amount    BIGINT NOT NULL CHECK (goods_amount >= 0),
    delivery_fee    BIGINT NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    total_amount    BIGINT NOT NULL CHECK (total_amount >= 0),
    dropoff         GEOGRAPHY(Point, 4326),
    dropoff_address TEXT,
    district_id     INT REFERENCES location.districts(id),
    supplier_confirmation_deadline TIMESTAMPTZ NOT NULL,
    -- Set when the invoice is issued; the payment SLA sweeper expires the
    -- order once it passes unpaid.
    payment_due_at  TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL,
    closed_at       TIMESTAMPTZ,
    CONSTRAINT chk_orders_status CHECK (status IN (
        'created', 'declined', 'expired',
        'buyer_decision_pending', 'accepted', 'awaiting_payment', 'paid',
        'payment_review', 'preparing', 'ready', 'delivered',
        'picked_up_by_buyer', 'closed',
        'cancelled_by_buyer_sla', 'cancelled_by_operator',
        'refund_requested', 'refunded', 'refund_overdue'
    )),
    CONSTRAINT chk_orders_total CHECK (total_amount = goods_amount + delivery_fee),
    CONSTRAINT chk_orders_tin CHECK (
        buyer_type <> 'legal_entity'
        OR (buyer_tin IS NOT NULL AND buyer_tin ~ '^[0-9]{9}$')
    )
);

-- Buyer order history, newest first; id breaks created_at ties the same way
-- the keyset predicate does.
CREATE INDEX idx_orders_buyer ON orders.orders (buyer_id, created_at DESC, id DESC);

-- Seller dashboards filter by store and status.
CREATE INDEX idx_orders_store_status ON orders.orders (store_id, status, created_at DESC);

-- The SLA sweeper polls only orders still waiting on the supplier.
CREATE INDEX idx_orders_confirmation_due
    ON orders.orders (supplier_confirmation_deadline)
    WHERE status = 'created';

-- The payment SLA sweeper polls only unpaid invoiced orders.
CREATE INDEX idx_orders_payment_due
    ON orders.orders (payment_due_at)
    WHERE status = 'awaiting_payment';

CREATE INDEX idx_orders_district ON orders.orders (district_id) WHERE district_id IS NOT NULL;

-- The seller fulfilment queue reads open orders for one store, newest first;
-- id breaks created_at ties the same way the keyset predicate does.
CREATE INDEX idx_orders_store_open
    ON orders.orders (store_id, created_at DESC, id DESC)
    WHERE status IN ('accepted', 'awaiting_payment', 'payment_review',
                     'paid', 'preparing', 'ready');

CREATE TABLE orders.order_items (
    id          UUID PRIMARY KEY,
    order_id    UUID NOT NULL REFERENCES orders.orders(id),
    product_id  UUID NOT NULL REFERENCES catalog.products(id),
    qty         NUMERIC NOT NULL CHECK (qty > 0),
    unit_price  BIGINT NOT NULL CHECK (unit_price > 0),
    line_amount BIGINT NOT NULL CHECK (line_amount > 0),
    commission_bps INT NOT NULL
        CONSTRAINT chk_order_items_commission_bps CHECK (commission_bps BETWEEN 0 AND 10000),
    UNIQUE (order_id, product_id)
);

CREATE INDEX idx_order_items_product ON orders.order_items (product_id);

CREATE TABLE orders.order_events (
    id          BIGSERIAL PRIMARY KEY,
    order_id    UUID NOT NULL REFERENCES orders.orders(id),
    from_status TEXT,
    to_status   TEXT NOT NULL,
    actor       TEXT NOT NULL CHECK (actor IN ('buyer', 'seller', 'operator', 'system')),
    source      TEXT NOT NULL CHECK (source IN ('app', 'sms_token', 'phone_call', 'webhook', 'cron')),
    payload     JSONB,
    created_at  TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_order_events_order ON orders.order_events (order_id, id);

CREATE TABLE orders.confirm_tokens (
    token_hash TEXT PRIMARY KEY,
    order_id   UUID NOT NULL REFERENCES orders.orders(id),
    store_id   UUID NOT NULL REFERENCES location.stores(id),
    expires_at TIMESTAMPTZ NOT NULL,
    used_at    TIMESTAMPTZ
);

CREATE INDEX idx_confirm_tokens_order ON orders.confirm_tokens (order_id);

-- Expiry sweeps touch only live tokens.
CREATE INDEX idx_confirm_tokens_live
    ON orders.confirm_tokens (expires_at)
    WHERE used_at IS NULL;
