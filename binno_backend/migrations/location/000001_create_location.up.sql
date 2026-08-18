-- Reference, responsibility and location axes.
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE SCHEMA IF NOT EXISTS location;

CREATE TABLE location.districts (
    id        INT PRIMARY KEY,
    name      TEXT NOT NULL,
    region_id INT NOT NULL
);

CREATE INDEX idx_districts_region ON location.districts (region_id);

-- owners.user_id references identity.users, so migrations/identity must run
-- before this directory. The Makefile's OLTP_MIGRATION_DIRS fixes that order.
CREATE TABLE location.owners (
    id                UUID PRIMARY KEY,
    user_id           UUID UNIQUE NOT NULL REFERENCES identity.users(id),
    tin               CHAR(9) UNIQUE NOT NULL,
    legal_name        TEXT NOT NULL,
    legal_form        TEXT,
    bank_account      CHAR(20),
    mfo               CHAR(5),
    psp_provider      TEXT CHECK (psp_provider IS NULL OR psp_provider IN ('payme', 'click', 'paynet')),
    psp_merchant_id   TEXT,
    psp_verified_at   TIMESTAMPTZ,
    status            TEXT NOT NULL
        CONSTRAINT chk_owners_status CHECK (status IN ('pending', 'active', 'blocked')),
    is_founding       BOOLEAN NOT NULL DEFAULT FALSE,
    credit_limit      BIGINT NOT NULL,
    verified_at       TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL,
    CONSTRAINT chk_owners_tin CHECK (tin ~ '^[0-9]{9}$')
);

CREATE TABLE location.trade_complexes (
    id           UUID PRIMARY KEY,
    name         TEXT NOT NULL,
    district_id  INT NOT NULL REFERENCES location.districts(id),
    location     GEOGRAPHY(Point, 4326) NOT NULL,
    pickup_point GEOGRAPHY(Point, 4326),
    is_active    BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_complexes_location ON location.trade_complexes USING GIST (location);

-- Search filters complexes by district before ranking; without this the
-- district predicate degrades into a scan of every complex.
CREATE INDEX idx_complexes_district ON location.trade_complexes (district_id) WHERE is_active;

CREATE TABLE location.complex_blocks (
    id         UUID PRIMARY KEY,
    complex_id UUID NOT NULL REFERENCES location.trade_complexes(id),
    label      TEXT NOT NULL,
    UNIQUE (complex_id, label),
    UNIQUE (id, complex_id)
);

CREATE TABLE location.stores (
    id          UUID PRIMARY KEY,
    owner_id    UUID NOT NULL REFERENCES location.owners(id),
    name        TEXT NOT NULL,
    complex_id  UUID REFERENCES location.trade_complexes(id),
    block_id    UUID,
    unit_number TEXT,
    address     TEXT,
    location    GEOGRAPHY(Point, 4326) NOT NULL,
    phone       TEXT,
    status      TEXT NOT NULL DEFAULT 'active'
        CONSTRAINT chk_stores_status CHECK (status IN ('active', 'suspended')),
    created_at  TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (block_id, complex_id) REFERENCES location.complex_blocks(id, complex_id),
    CHECK (block_id IS NULL OR complex_id IS NOT NULL)
);

-- Partial: search only ever ranks active stores, so the inactive tail is kept
-- out of the index that the ST_DWithin radius probe walks.
CREATE INDEX idx_stores_location ON location.stores USING GIST (location) WHERE status = 'active';

-- The order path resolves store -> owner on every reservation and refuses the
-- sale when the owner is not active.
CREATE INDEX idx_owners_status ON location.owners (status) WHERE status <> 'active';

-- Authorization resolves owner -> store on every seller mutation, and
-- PostgreSQL does not index foreign keys automatically.
CREATE INDEX idx_stores_owner ON location.stores (owner_id);

CREATE INDEX idx_stores_complex ON location.stores (complex_id) WHERE complex_id IS NOT NULL;
