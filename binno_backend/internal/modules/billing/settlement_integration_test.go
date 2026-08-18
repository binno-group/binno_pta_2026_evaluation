//go:build integration

package billing_test

import (
	"context"
	"errors"
	"fmt"
	"os"
	"sync"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// The founding allowance and the ledger invariants are asserted against a real
// PostgreSQL because every guarantee they rest on is a database guarantee: the
// UNIQUE on commission_ledger.order_id, the CHECK that payable = accrued -
// discount, and an advisory lock whose whole purpose is to behave correctly when
// two transactions run at once.

func testPool(t *testing.T) *postgres.Pool {
	t.Helper()
	url := os.Getenv("TEST_DB_URL")
	if url == "" {
		t.Skip("TEST_DB_URL not set")
	}
	pool, err := postgres.NewPool(context.Background(), postgres.Config{
		URL: url, MaxConns: 12, StatementTimeout: 10 * time.Second,
	})
	if err != nil {
		t.Fatalf("connect: %v", err)
	}
	t.Cleanup(pool.Close)
	return pool
}

// fixture creates one owner, one store and n orders belonging to it, and returns
// the owner id and the order ids.
type fixture struct {
	ownerID string
	orders  []string
}

func newFixture(t *testing.T, pool *postgres.Pool, orderCount int) fixture {
	t.Helper()
	ctx := context.Background()

	ownerID := uuid.NewString()
	userID := uuid.NewString()
	storeID := uuid.NewString()
	tin := fmt.Sprintf("%09d", time.Now().UnixNano()%1_000_000_000)

	exec := func(sql string, args ...any) {
		t.Helper()
		if _, err := pool.Exec(ctx, sql, args...); err != nil {
			t.Fatalf("fixture %s: %v", sql[:40], err)
		}
	}
	exec(`INSERT INTO identity.users (id, phone, status, created_at)
	      VALUES ($1, $2, 'active', now())`, userID, fmt.Sprintf("998%09d", time.Now().UnixNano()%1_000_000_000))
	exec(`INSERT INTO location.owners (id, user_id, tin, legal_name, status, is_founding, credit_limit, created_at)
	      VALUES ($1, $2, $3, 'Ledger Test LLC', 'active', false, 0, now())`, ownerID, userID, tin)
	exec(`INSERT INTO location.stores (id, owner_id, name, status, location, created_at)
	      VALUES ($1, $2, 'Ledger Test Store', 'active',
	              ST_SetSRID(ST_MakePoint(69.24, 41.31), 4326)::geography, now())`, storeID, ownerID)

	ids := make([]string, 0, orderCount)
	for i := range orderCount {
		orderID := uuid.NewString()
		exec(`INSERT INTO orders.orders
		        (id, buyer_id, store_id, status, buyer_type, fulfillment, is_urgent,
		         goods_amount, delivery_fee, total_amount, supplier_confirmation_deadline, created_at)
		      VALUES ($1, $2, $3, 'closed', 'individual', 'pickup', false,
		              100000, 0, 100000, now(), now())`, orderID, uuid.NewString(), storeID)
		ids = append(ids, orderID)
		_ = i
	}

	t.Cleanup(func() {
		_, _ = pool.Exec(ctx, `DELETE FROM billing.commission_ledger WHERE owner_id = $1`, ownerID)
		_, _ = pool.Exec(ctx, `DELETE FROM orders.orders WHERE store_id = $1`, storeID)
		_, _ = pool.Exec(ctx, `DELETE FROM location.stores WHERE id = $1`, storeID)
		_, _ = pool.Exec(ctx, `DELETE FROM location.owners WHERE id = $1`, ownerID)
		_, _ = pool.Exec(ctx, `DELETE FROM identity.users WHERE id = $1`, userID)
	})
	return fixture{ownerID: ownerID, orders: ids}
}

func accrue(t *testing.T, pool *postgres.Pool, port orders.SettlementPort, ownerID, orderID string) (orders.CommissionAccrued, error) {
	t.Helper()
	ctx := context.Background()
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	got, err := port.AccrueCommission(ctx, tx, orders.CommissionRequest{
		OrderID: orderID, OwnerID: ownerID,
		BaseAmount: 100_000, Accrued: 2_500, RateBps: 250, At: time.Now().UTC(),
	})
	if err != nil {
		return got, err
	}
	if err := tx.Commit(ctx); err != nil {
		t.Fatalf("commit: %v", err)
	}
	return got, nil
}

func TestFoundingAllowanceCoversExactlyTenOrders(t *testing.T) {
	pool := testPool(t)
	f := newFixture(t, pool, 11)
	port := billing.NewSettlementPort()

	for i, orderID := range f.orders {
		got, err := accrue(t, pool, port, f.ownerID, orderID)
		if err != nil {
			t.Fatalf("order %d: accrue: %v", i+1, err)
		}
		sequence := int64(i + 1)
		if got.Sequence != sequence {
			t.Errorf("order %d: Sequence = %d, want %d", i+1, got.Sequence, sequence)
		}
		if got.Accrued != 2_500 {
			t.Errorf("order %d: Accrued = %d, want 2500; the allowance waives the charge, it does not erase it",
				i+1, got.Accrued)
		}
		switch {
		case sequence <= 10:
			if got.Payable != 0 || got.Discount != 2_500 || !got.FreeOrder {
				t.Errorf("order %d: payable=%d discount=%d free=%v, want a full waiver",
					i+1, got.Payable, got.Discount, got.FreeOrder)
			}
		default:
			if got.Payable != 2_500 || got.Discount != 0 || got.FreeOrder {
				t.Errorf("order %d: payable=%d discount=%d free=%v, want the full charge",
					i+1, got.Payable, got.Discount, got.FreeOrder)
			}
		}
	}

	var free, charged int64
	if err := pool.QueryRow(context.Background(),
		`SELECT count(*) FILTER (WHERE payable = 0), count(*) FILTER (WHERE payable > 0)
		   FROM billing.commission_ledger WHERE owner_id = $1`, f.ownerID).
		Scan(&free, &charged); err != nil {
		t.Fatalf("count ledger: %v", err)
	}
	if free != 10 || charged != 1 {
		t.Errorf("ledger holds %d free and %d charged rows, want 10 and 1", free, charged)
	}
}

func TestCommissionIsAccruedOncePerOrder(t *testing.T) {
	pool := testPool(t)
	f := newFixture(t, pool, 1)
	port := billing.NewSettlementPort()

	if _, err := accrue(t, pool, port, f.ownerID, f.orders[0]); err != nil {
		t.Fatalf("first accrual: %v", err)
	}
	_, err := accrue(t, pool, port, f.ownerID, f.orders[0])
	if !errors.Is(err, orders.ErrSettlementConflict) {
		t.Fatalf("second accrual: err = %v, want ErrSettlementConflict", err)
	}

	var rows int64
	if err := pool.QueryRow(context.Background(),
		`SELECT count(*) FROM billing.commission_ledger WHERE order_id = $1`, f.orders[0]).
		Scan(&rows); err != nil {
		t.Fatalf("count: %v", err)
	}
	if rows != 1 {
		t.Errorf("ledger rows for one order = %d, want 1", rows)
	}
}

func TestConcurrentAccrualsDoNotOverspendTheAllowance(t *testing.T) {
	pool := testPool(t)
	const concurrent = 12
	f := newFixture(t, pool, concurrent)
	port := billing.NewSettlementPort()

	var wg sync.WaitGroup
	errs := make([]error, concurrent)
	start := make(chan struct{})
	for i, orderID := range f.orders {
		wg.Add(1)
		go func(i int, orderID string) {
			defer wg.Done()
			<-start
			_, errs[i] = accrue(t, pool, port, f.ownerID, orderID)
		}(i, orderID)
	}
	close(start)
	wg.Wait()

	for i, err := range errs {
		if err != nil {
			t.Errorf("concurrent accrual %d: %v", i, err)
		}
	}

	var free, charged int64
	if err := pool.QueryRow(context.Background(),
		`SELECT count(*) FILTER (WHERE payable = 0), count(*) FILTER (WHERE payable > 0)
		   FROM billing.commission_ledger WHERE owner_id = $1`, f.ownerID).
		Scan(&free, &charged); err != nil {
		t.Fatalf("count ledger: %v", err)
	}
	if free != 10 || charged != concurrent-10 {
		t.Errorf("after %d concurrent closes: %d free and %d charged, want 10 and %d",
			concurrent, free, charged, concurrent-10)
	}
}

func TestAccrualRefusesCommissionAboveTheBase(t *testing.T) {
	pool := testPool(t)
	f := newFixture(t, pool, 1)
	port := billing.NewSettlementPort()

	ctx := context.Background()
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin: %v", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	_, err = port.AccrueCommission(ctx, tx, orders.CommissionRequest{
		OrderID: f.orders[0], OwnerID: f.ownerID,
		BaseAmount: 1_000, Accrued: 1_001, RateBps: 250, At: time.Now().UTC(),
	})
	if !errors.Is(err, orders.ErrSettlementInvalid) {
		t.Fatalf("err = %v, want ErrSettlementInvalid", err)
	}
}
