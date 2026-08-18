-- Platform-owned catalog and store offers.
CREATE SCHEMA IF NOT EXISTS catalog;

CREATE TABLE catalog.categories (
    id                     UUID PRIMARY KEY,
    name                   TEXT NOT NULL,
    confirm_window_minutes INT NOT NULL DEFAULT 240,
    commission_bps         INT NOT NULL DEFAULT 250,
    is_active              BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (confirm_window_minutes > 0),
    CHECK (commission_bps >= 0)
);

CREATE TABLE catalog.products (
    id          UUID PRIMARY KEY,
    category_id UUID NOT NULL REFERENCES catalog.categories(id),
    name        TEXT NOT NULL,
    unit        TEXT NOT NULL,
    brand       TEXT,
    spec        JSONB,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_products_category ON catalog.products (category_id);

CREATE TABLE catalog.offers (
    id           UUID PRIMARY KEY,
    store_id     UUID NOT NULL REFERENCES location.stores(id),
    product_id   UUID NOT NULL REFERENCES catalog.products(id),
    price        BIGINT NOT NULL CHECK (price > 0),
    declared_qty NUMERIC NOT NULL CHECK (declared_qty >= 0),
    reserved_qty NUMERIC NOT NULL DEFAULT 0
        CHECK (reserved_qty >= 0 AND reserved_qty <= declared_qty),
    freshness_at TIMESTAMPTZ NOT NULL,
    status       TEXT NOT NULL DEFAULT 'published'
        CHECK (status IN ('published', 'hidden', 'archived')),
    UNIQUE (store_id, product_id)
);

-- Search is the hottest read path in the system.
CREATE INDEX idx_offers_sellable
    ON catalog.offers (product_id, price, id)
    WHERE status = 'published';

CREATE INDEX idx_offers_store_sellable
    ON catalog.offers (store_id)
    WHERE status = 'published';

CREATE TABLE catalog.catalog_requests (
    id            UUID PRIMARY KEY,
    store_id      UUID NOT NULL REFERENCES location.stores(id),
    name          TEXT NOT NULL,
    unit          TEXT NOT NULL,
    description   TEXT,
    image_url     TEXT,
    status        TEXT NOT NULL CHECK (status IN ('pending', 'added', 'rejected')),
    product_id    UUID REFERENCES catalog.products(id),
    reject_reason TEXT,
    resolved_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL,
    CHECK (status <> 'rejected' OR reject_reason IS NOT NULL),
    CHECK (status <> 'added' OR product_id IS NOT NULL)
);

CREATE INDEX idx_catalog_requests_store ON catalog.catalog_requests (store_id, created_at DESC);

-- The operator queue drains pending requests; the resolved tail is never
-- scanned.
CREATE INDEX idx_catalog_requests_pending
    ON catalog.catalog_requests (created_at)
    WHERE status = 'pending';

CREATE TABLE catalog.delivery_tariffs (
    store_id    UUID NOT NULL REFERENCES location.stores(id),
    district_id INT NOT NULL REFERENCES location.districts(id),
    price       BIGINT NOT NULL CHECK (price >= 0),
    updated_at  TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (store_id, district_id)
);

CREATE INDEX idx_delivery_tariffs_district ON catalog.delivery_tariffs (district_id);
