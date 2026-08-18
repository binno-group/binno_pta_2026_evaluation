-- name: GetCurrentPaymentInvoice :one
-- 'paid' stays retrievable: the buyer's payment document does not vanish the
-- moment the seller confirms the money.
SELECT *
FROM billing.invoices
WHERE order_id = $1
  AND status IN ('issued', 'paid')
ORDER BY version DESC
LIMIT 1;

-- name: MarkInvoicePaid :execrows
-- The seller confirmed the money; the document stops being payable and starts
-- being a receipt. Zero rows is a valid replay.
UPDATE billing.invoices
SET status = 'paid'
WHERE order_id = sqlc.arg(order_id)
  AND status = 'issued';

-- name: MarkInvoiceRefunded :execrows
-- A completed refund settles the document by return.
UPDATE billing.invoices
SET status = 'refunded'
WHERE order_id = sqlc.arg(order_id)
  AND status = 'paid';

-- name: GetPaymentByProviderTransaction :one
SELECT *
FROM billing.payments
WHERE provider = sqlc.arg(provider)
  AND provider_txn_id = sqlc.arg(provider_txn_id);

-- name: CreateRefund :one
INSERT INTO billing.refunds (
    id, order_id, amount, reason, status, due_at, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(order_id),
    sqlc.arg(amount),
    sqlc.narg(reason),
    'requested',
    sqlc.arg(due_at),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: SubmitRefundEvidence :one
UPDATE billing.refunds
SET
    evidence_url = sqlc.arg(evidence_url),
    status = 'evidence_uploaded'
WHERE id = sqlc.arg(id)
  AND status = 'requested'
RETURNING *;

-- name: GetRefundForUpdate :one
SELECT * FROM billing.refunds
WHERE order_id = $1
ORDER BY created_at DESC
LIMIT 1
FOR UPDATE;

-- name: ListCommissionInvoicesByOwner :many
SELECT *
FROM billing.commission_invoices
WHERE owner_id = sqlc.arg(owner_id)
  AND (
    sqlc.narg(before_period_start)::date IS NULL
    OR period_start < sqlc.narg(before_period_start)::date
  )
ORDER BY period_start DESC
LIMIT sqlc.arg(page_size);

-- name: CreateCommissionLedgerEntry :one
INSERT INTO billing.commission_ledger (
    id, order_id, owner_id, base_amount, rate_bps, accrued, discount,
    payable, invoice_id, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(order_id),
    sqlc.arg(owner_id),
    sqlc.arg(base_amount),
    sqlc.arg(rate_bps),
    sqlc.arg(accrued),
    sqlc.arg(discount),
    sqlc.arg(payable),
    sqlc.narg(invoice_id),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: IssueInvoice :one
-- The payment document the buyer pays against.
INSERT INTO billing.invoices (
    id, order_id, number, version, owner_snapshot, buyer_snapshot,
    total_amount, status, expires_at, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(order_id),
    'BINNO-'
      || to_char(sqlc.arg(created_at)::timestamptz AT TIME ZONE 'UTC', 'YYYYMMDD')
      || '-'
      || lpad(nextval('billing.invoice_number_seq')::text, 6, '0'),
    (SELECT coalesce(max(i.version), 0) + 1
       FROM billing.invoices i
      WHERE i.order_id = sqlc.arg(order_id)),
    sqlc.arg(owner_snapshot),
    sqlc.arg(buyer_snapshot),
    sqlc.arg(total_amount),
    'issued',
    sqlc.arg(expires_at),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: CreateManualPayment :one
-- A bank-transfer settlement: the buyer paid off-platform and uploaded the
-- bank's receipt for the seller to check.
INSERT INTO billing.payments (
    id, order_id, provider, provider_txn_id, mode, goods_amount, delivery_fee,
    commission_amount, seller_amount, status, receipt_url, raw, created_at
) VALUES (
    sqlc.arg(id),
    sqlc.arg(order_id),
    'manual',
    sqlc.arg(id)::uuid::text,
    'direct',
    sqlc.arg(goods_amount),
    sqlc.arg(delivery_fee),
    0,
    sqlc.arg(seller_amount),
    'created',
    sqlc.arg(receipt_url),
    sqlc.arg(raw),
    sqlc.arg(created_at)
)
RETURNING *;

-- name: SettleManualPayment :one
-- Compare-and-set on 'created' so a decision can be applied exactly once.
UPDATE billing.payments
SET
    status  = sqlc.arg(status),
    paid_at = CASE WHEN sqlc.arg(status)::text = 'paid' THEN sqlc.arg(decided_at) ELSE paid_at END
WHERE order_id = sqlc.arg(order_id)
  AND status = 'created'
RETURNING *;

-- name: VoidCurrentInvoice :execrows
-- Cancellation compensation: the payment document stops being payable.
UPDATE billing.invoices
SET status = 'voided'
WHERE order_id = sqlc.arg(order_id)
  AND status = 'issued';

-- name: FailLivePayment :execrows
-- Cancellation compensation: an undecided manual payment stops blocking the
-- one-live-payment slot.
UPDATE billing.payments
SET status = 'failed'
WHERE order_id = sqlc.arg(order_id)
  AND status = 'created';

-- name: CompleteRefund :one
-- The buyer confirmed the money came back.
UPDATE billing.refunds
SET status = 'refunded',
    buyer_confirmed_at = sqlc.arg(confirmed_at)
WHERE order_id = sqlc.arg(order_id)
  AND status IN ('requested', 'evidence_uploaded', 'overdue')
RETURNING *;

-- name: ReversePaidPayment :execrows
-- A completed refund reverses the settled payment on the books.
UPDATE billing.payments
SET status = 'reversed'
WHERE order_id = sqlc.arg(order_id)
  AND status = 'paid';

-- name: ListRefundsDue :many
-- Drives the refund SLA sweep; served by idx_refunds_due.
SELECT *
FROM billing.refunds
WHERE status IN ('requested', 'evidence_uploaded')
  AND due_at <= sqlc.arg(deadline)
ORDER BY due_at
LIMIT sqlc.arg(page_size);

-- name: MarkRefundOverdue :execrows
UPDATE billing.refunds
SET status = 'overdue'
WHERE id = sqlc.arg(id)
  AND status IN ('requested', 'evidence_uploaded');

-- name: ListUnbilledCommissionPeriods :many
-- One row per (owner, calendar month) still waiting for its statement. Ledger
-- rows are stamped with the close-time clock, so a completed month's unbilled
-- set can only shrink, never grow.
SELECT
    owner_id,
    date_trunc('month', created_at)::date AS period_start,
    sum(accrued)::bigint  AS accrued_amount,
    sum(discount)::bigint AS discount_amount,
    sum(payable)::bigint  AS amount
FROM billing.commission_ledger
WHERE invoice_id IS NULL
  AND created_at < sqlc.arg(before)
GROUP BY owner_id, date_trunc('month', created_at)
ORDER BY period_start, owner_id
LIMIT sqlc.arg(page_size);

-- name: CreateCommissionInvoice :one
-- The no-op DO UPDATE turns a replayed rollup into a read of the existing row.
INSERT INTO billing.commission_invoices (
    id, owner_id, period_start, period_end, accrued_amount, discount_amount,
    amount, due_at, status
) VALUES (
    sqlc.arg(id),
    sqlc.arg(owner_id),
    sqlc.arg(period_start),
    sqlc.arg(period_end),
    sqlc.arg(accrued_amount),
    sqlc.arg(discount_amount),
    sqlc.arg(amount),
    sqlc.arg(due_at),
    'issued'
)
ON CONFLICT (owner_id, period_start) DO UPDATE
    SET status = billing.commission_invoices.status
RETURNING id;

-- name: AttachLedgerToInvoice :execrows
UPDATE billing.commission_ledger
SET invoice_id = sqlc.arg(invoice_id)
WHERE owner_id = sqlc.arg(owner_id)
  AND invoice_id IS NULL
  AND created_at >= sqlc.arg(period_start)::date
  AND created_at < (sqlc.arg(period_start)::date + interval '1 month');

-- name: LockOwnerCommissionLedger :exec
-- Serialise commission accrual per owner for the duration of the transaction.
SELECT pg_advisory_xact_lock(hashtextextended(sqlc.arg(owner_id)::text, 0));

-- name: CountOwnerCommissionEntries :one
-- One ledger row exists per closed order, so this count IS the owner's
-- completed order count.
SELECT count(*) FROM billing.commission_ledger WHERE owner_id = sqlc.arg(owner_id);
