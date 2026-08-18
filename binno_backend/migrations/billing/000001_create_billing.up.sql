-- PSP payment rail, refunds and owner commission ledger.
CREATE SCHEMA IF NOT EXISTS billing;

CREATE TABLE billing.invoices (
    id             UUID PRIMARY KEY,
    order_id       UUID NOT NULL REFERENCES orders.orders(id),
    number         TEXT NOT NULL UNIQUE,
    version        INT NOT NULL DEFAULT 1 CHECK (version > 0),
    owner_snapshot JSONB NOT NULL,
    buyer_snapshot JSONB NOT NULL,
    total_amount   BIGINT NOT NULL CHECK (total_amount >= 0),
    pdf_url        TEXT,
    -- issued -> paid -> refunded is the settled path; issued -> voided is the
    -- cancellation path. A paid invoice is never voided.
    status         TEXT NOT NULL CHECK (status IN ('issued', 'paid', 'refunded', 'voided')),
    expires_at     TIMESTAMPTZ NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL,
    UNIQUE (order_id, version)
);

-- The invoice lookup is (order_id, status still current) ordered by version
-- DESC; the UNIQUE(order_id, version) index cannot skip voided versions on its
-- own. 'paid' stays visible: the buyer's document does not vanish on payment.
CREATE INDEX idx_invoices_issued
    ON billing.invoices (order_id, version DESC)
    WHERE status IN ('issued', 'paid');

-- 'manual' is a provider alongside the three gateways.
CREATE TABLE billing.payments (
    id                UUID PRIMARY KEY,
    order_id          UUID NOT NULL REFERENCES orders.orders(id),
    provider          TEXT NOT NULL CHECK (provider IN ('payme', 'click', 'paynet', 'manual')),
    provider_txn_id   TEXT NOT NULL,
    mode              TEXT NOT NULL CHECK (mode IN ('split', 'direct')),
    goods_amount      BIGINT NOT NULL CHECK (goods_amount >= 0),
    delivery_fee      BIGINT NOT NULL CHECK (delivery_fee >= 0),
    commission_amount BIGINT NOT NULL DEFAULT 0 CHECK (commission_amount >= 0),
    seller_amount     BIGINT NOT NULL CHECK (seller_amount >= 0),
    status            TEXT NOT NULL CHECK (status IN ('created', 'paid', 'failed', 'reversed')),
    paid_at           TIMESTAMPTZ,
    receipt_url       TEXT,
    raw               JSONB NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL,
    UNIQUE (provider, provider_txn_id),
    CONSTRAINT chk_payments_manual_receipt
        CHECK (provider <> 'manual' OR receipt_url IS NOT NULL)
);

CREATE INDEX idx_payments_order ON billing.payments (order_id, created_at DESC);

-- At most one live payment per order.
CREATE UNIQUE INDEX ux_payments_order_live
    ON billing.payments (order_id)
    WHERE status IN ('created', 'paid');

-- Invoice numbers are BINNO-<yyyymmdd>-<sequence>.
CREATE SEQUENCE billing.invoice_number_seq;

CREATE TABLE billing.refunds (
    id                 UUID PRIMARY KEY,
    order_id           UUID NOT NULL REFERENCES orders.orders(id),
    amount             BIGINT NOT NULL CHECK (amount > 0),
    reason             TEXT,
    status             TEXT NOT NULL CHECK (status IN (
        'requested', 'evidence_uploaded', 'refunded', 'overdue'
    )),
    due_at             TIMESTAMPTZ NOT NULL,
    evidence_url       TEXT,
    buyer_confirmed_at TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_refunds_order ON billing.refunds (order_id, created_at DESC);

-- Refund SLA sweeps read only refunds that can still become overdue.
CREATE INDEX idx_refunds_due
    ON billing.refunds (due_at)
    WHERE status IN ('requested', 'evidence_uploaded');

CREATE TABLE billing.commission_invoices (
    id              UUID PRIMARY KEY,
    owner_id        UUID NOT NULL REFERENCES location.owners(id),
    period_start    DATE NOT NULL,
    period_end      DATE NOT NULL,
    accrued_amount  BIGINT NOT NULL DEFAULT 0 CHECK (accrued_amount >= 0),
    discount_amount BIGINT NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    amount          BIGINT NOT NULL CHECK (amount >= 0),
    due_at          TIMESTAMPTZ NOT NULL,
    status          TEXT NOT NULL CHECK (status IN ('issued', 'paid', 'overdue')),
    paid_at         TIMESTAMPTZ,
    UNIQUE (owner_id, period_start),
    CHECK (period_end >= period_start),
    CHECK (amount = accrued_amount - discount_amount)
);

CREATE INDEX idx_commission_invoices_unpaid
    ON billing.commission_invoices (due_at)
    WHERE status <> 'paid';

CREATE TABLE billing.commission_ledger (
    id          UUID PRIMARY KEY,
    order_id    UUID NOT NULL UNIQUE REFERENCES orders.orders(id),
    owner_id    UUID NOT NULL REFERENCES location.owners(id),
    base_amount BIGINT NOT NULL CHECK (base_amount >= 0),
    rate_bps    INT NOT NULL CHECK (rate_bps >= 0),
    accrued     BIGINT NOT NULL CHECK (accrued >= 0),
    discount    BIGINT NOT NULL DEFAULT 0 CHECK (discount >= 0),
    payable     BIGINT NOT NULL CHECK (payable >= 0),
    invoice_id  UUID REFERENCES billing.commission_invoices(id),
    created_at  TIMESTAMPTZ NOT NULL,
    CHECK (payable = accrued - discount)
);

-- Period rollup groups unbilled ledger rows by owner.
CREATE INDEX idx_commission_ledger_unbilled
    ON billing.commission_ledger (owner_id, created_at)
    WHERE invoice_id IS NULL;

CREATE INDEX idx_commission_ledger_invoice
    ON billing.commission_ledger (invoice_id)
    WHERE invoice_id IS NOT NULL;

-- The founding allowance counts an owner's ledger rows on every close.
CREATE INDEX idx_commission_ledger_owner
    ON billing.commission_ledger (owner_id);
