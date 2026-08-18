//go:build integration

package catalog_test

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// The reservation is one guarded UPDATE — `SET reserved_qty = reserved_qty + q
// WHERE declared_qty - reserved_qty >= q` — so overselling is impossible no
// matter how many writers race. These tests put real concurrency behind that
// claim; run them under -race like the rest of the suite.

func newLinePort(t *testing.T, pool *postgres.Pool) catalog.OrderLinePort {
	t.Helper()
	return catalog.New(pool, location.New(pool).Guard(), clock.New()).OrderLines()
}

func reserveOne(pool *postgres.Pool, port catalog.OrderLinePort, storeID, productID string) error {
	ctx := context.Background()
	tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback(ctx) }()
	if _, err := port.ReserveOrderLines(ctx, tx, catalog.ReserveRequest{
		StoreID: storeID,
		Lines:   []catalog.RequestedLine{{ProductID: productID, Qty: "1"}},
		At:      time.Now().UTC(),
	}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func TestConcurrentReservationsNeverOversell(t *testing.T) {
	pool := pgtest.Pool(t)
	port := newLinePort(t, pool)
	w := seed.Marketplace(t, pool, seed.Config{DeclaredQty: "5"})

	const buyers = 20
	start := make(chan struct{})
	results := make(chan error, buyers)
	for range buyers {
		go func() {
			<-start
			results <- reserveOne(pool, port, w.StoreID, w.ProductID)
		}()
	}
	close(start)

	var won, lost int
	for range buyers {
		switch err := <-results; {
		case err == nil:
			won++
		case errors.Is(err, catalog.ErrOfferUnavailable):
			lost++
		default:
			t.Fatalf("reservation failed with a non-domain error: %v", err)
		}
	}
	if won != 5 || lost != 15 {
		t.Errorf("won/lost = %d/%d, want 5/15: every declared unit sold once, no more", won, lost)
	}

	declared, reserved := seed.Offer(t, pool, w.OfferID)
	if declared != "5" || reserved != "5" {
		t.Errorf("declared/reserved = %s/%s, want 5/5 after the race", declared, reserved)
	}
}

func TestConcurrentReleasesNeverGoNegative(t *testing.T) {
	pool := pgtest.Pool(t)
	port := newLinePort(t, pool)
	w := seed.Marketplace(t, pool, seed.Config{DeclaredQty: "5"})
	ctx := context.Background()

	// Hold all five units, then race more releases than there are holds: the
	// extras must be absorbed, not push reserved_qty below zero.
	for range 5 {
		if err := reserveOne(pool, port, w.StoreID, w.ProductID); err != nil {
			t.Fatalf("seed reservation: %v", err)
		}
	}

	const releases = 8
	start := make(chan struct{})
	results := make(chan error, releases)
	for range releases {
		go func() {
			<-start
			tx, err := pool.BeginTx(ctx, pgx.TxOptions{})
			if err != nil {
				results <- err
				return
			}
			defer func() { _ = tx.Rollback(ctx) }()
			if err := port.ReleaseOrderLines(ctx, tx, catalog.ReleaseRequest{
				StoreID: w.StoreID,
				Lines:   []catalog.RequestedLine{{ProductID: w.ProductID, Qty: "1"}},
			}); err != nil {
				results <- err
				return
			}
			results <- tx.Commit(ctx)
		}()
	}
	close(start)
	for range releases {
		if err := <-results; err != nil {
			t.Fatalf("release failed: %v", err)
		}
	}

	declared, reserved := seed.Offer(t, pool, w.OfferID)
	if declared != "5" || reserved != "0" {
		t.Errorf("declared/reserved = %s/%s, want 5/0: extra releases absorbed", declared, reserved)
	}
}
