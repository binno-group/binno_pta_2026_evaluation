-- Post-run invariants. Every capacity run ends here; any violated invariant
-- raises and fails the run (run with psql -v ON_ERROR_STOP=1).
--
-- These are cross-aggregate truths no amount of load may bend: money and
-- stock must balance exactly, whatever the latency percentiles said.

DO $$
DECLARE
    bad bigint;
BEGIN
    -- 1. No orphan order items. The FK makes this structurally impossible;
    -- keeping the check means a future FK relaxation fails loudly here.
    SELECT count(*) INTO bad
      FROM orders.order_items oi
      LEFT JOIN orders.orders o ON o.id = oi.order_id
     WHERE o.id IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 1 violated: % orphan order_items rows', bad;
    END IF;

    -- 2a. Every closed order has exactly one commission ledger row.
    SELECT count(*) INTO bad
      FROM orders.orders o
      LEFT JOIN billing.commission_ledger l ON l.order_id = o.id
     WHERE o.status = 'closed' AND l.id IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 2a violated: % closed orders without a ledger row', bad;
    END IF;

    -- 2b. Ledger rows only exist for closed orders.
    SELECT count(*) INTO bad
      FROM billing.commission_ledger l
      JOIN orders.orders o ON o.id = l.order_id
     WHERE o.status <> 'closed';
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 2b violated: % ledger rows on orders that are not closed', bad;
    END IF;

    -- 2c. The accrual equals the order lines' amounts at their snapshotted
    -- rates, rounded half-up — the same arithmetic as money.ApplyBasisPoints.
    SELECT count(*) INTO bad
      FROM billing.commission_ledger l
     WHERE l.accrued <> (
        SELECT COALESCE(sum((oi.line_amount * oi.commission_bps + 5000) / 10000), 0)
          FROM orders.order_items oi
         WHERE oi.order_id = l.order_id
     );
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 2c violated: % ledger rows disagree with closed orders x rate', bad;
    END IF;

    -- 2d. Payable is accrual minus discounts (also a CHECK; belt and braces).
    SELECT count(*) INTO bad
      FROM billing.commission_ledger
     WHERE payable <> accrued - discount;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 2d violated: % ledger rows where payable <> accrued - discount', bad;
    END IF;

    -- 3. Stock bounds on every offer.
    SELECT count(*) INTO bad
      FROM catalog.offers
     WHERE reserved_qty < 0 OR reserved_qty > declared_qty;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 3 violated: % offers with reserved_qty out of [0, declared_qty]', bad;
    END IF;

    -- 4a. Every closed order has exactly one applied (paid) payment row.
    SELECT count(*) INTO bad
      FROM orders.orders o
     WHERE o.status = 'closed'
       AND (SELECT count(*) FROM billing.payments p
             WHERE p.order_id = o.id AND p.status = 'paid') <> 1;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 4a violated: % closed orders without exactly one paid payment', bad;
    END IF;

    -- 4b. No order carries more than one live (created or paid) payment.
    SELECT count(*) INTO bad
      FROM (
        SELECT order_id
          FROM billing.payments
         WHERE status IN ('created', 'paid')
         GROUP BY order_id
        HAVING count(*) > 1
      ) doubles;
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 4b violated: % orders with more than one live payment', bad;
    END IF;

    -- 5. Pass-through states never rest: the machine closes them in the same
    -- transaction that produces them.
    SELECT count(*) INTO bad
      FROM orders.orders
     WHERE status IN ('accepted', 'delivered', 'picked_up_by_buyer');
    IF bad > 0 THEN
        RAISE EXCEPTION 'invariant 5 violated: % orders resting in pass-through states', bad;
    END IF;

    RAISE NOTICE 'all capacity invariants hold';
END
$$;
