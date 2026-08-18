//go:build integration

package orders_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// The sale gate is the credit/standing check on order intake: a blocked owner
// account or a suspended store takes no new orders, and when the gate cannot
// answer at all the answer is deny — nothing half-created, nothing reserved.

func tryPlace(s *stack, w seed.World) error {
	_, err := s.repo.Create(opCtx(), orders.CreateCommand{
		CreateInput: orders.CreateInput{
			StoreID: w.StoreID, BuyerType: "individual", Fulfillment: "pickup",
			Items: []orders.ItemInput{{ProductID: w.ProductID, Qty: "1"}},
		},
		BuyerID: w.BuyerUserID,
		At:      time.Now().UTC(),
	})
	return err
}

func assertNothingPersisted(t *testing.T, s *stack, w seed.World) {
	t.Helper()
	var count int
	if err := s.pool.QueryRow(context.Background(),
		`SELECT count(*) FROM orders.orders WHERE buyer_id = $1`, w.BuyerUserID).Scan(&count); err != nil {
		t.Fatalf("count orders: %v", err)
	}
	if count != 0 {
		t.Errorf("refused order still persisted %d rows", count)
	}
	_, reserved := seed.Offer(t, s.pool, w.OfferID)
	if reserved != "0" {
		t.Errorf("refused order still holds stock: reserved = %s, want 0", reserved)
	}
}

func TestBlockedOwnerReceivesNoNewOrders(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{OwnerStatus: "blocked"})

	if err := tryPlace(s, w); !errors.Is(err, orders.ErrConflict) {
		t.Fatalf("order for a blocked owner: err = %v, want ErrConflict", err)
	}
	assertNothingPersisted(t, s, w)
}

func TestSuspendedStoreReceivesNoNewOrders(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{StoreStatus: "suspended"})

	if err := tryPlace(s, w); !errors.Is(err, orders.ErrConflict) {
		t.Fatalf("order for a suspended store: err = %v, want ErrConflict", err)
	}
	assertNothingPersisted(t, s, w)
}

// When the gate's data source is unreachable the check must fail closed: the
// order is refused, not waved through on stale hope. An exclusive lock on the
// owners table stands in for the outage; the placing stack runs with a short
// statement timeout so the test answers quickly.
func TestSaleGateFailsClosedWhenOwnersUnreachable(t *testing.T) {
	shortPool, err := postgres.NewPool(context.Background(), postgres.Config{
		URL: pgtest.URL(t), MaxConns: 4, StatementTimeout: time.Second,
	})
	if err != nil {
		t.Fatalf("connect short-timeout pool: %v", err)
	}
	t.Cleanup(shortPool.Close)
	s := newStackOn(t, shortPool)
	w := seed.Marketplace(t, s.pool, seed.Config{})
	ctx := context.Background()

	blocker := pgtest.Pool(t)
	lockTx, err := blocker.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		t.Fatalf("begin lock tx: %v", err)
	}
	if _, err := lockTx.Exec(ctx, `LOCK TABLE location.owners IN ACCESS EXCLUSIVE MODE`); err != nil {
		t.Fatalf("take owners lock: %v", err)
	}

	placeErr := tryPlace(s, w)
	if err := lockTx.Rollback(ctx); err != nil {
		t.Fatalf("release owners lock: %v", err)
	}
	if placeErr == nil {
		t.Fatal("order accepted while the sale gate could not read owner standing")
	}
	assertNothingPersisted(t, s, w)

	// Once the source is reachable again the same order goes through.
	if err := tryPlace(s, w); err != nil {
		t.Errorf("order after the outage cleared: %v, want success", err)
	}
}
