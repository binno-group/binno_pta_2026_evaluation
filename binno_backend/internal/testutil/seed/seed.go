//go:build integration

// Package seed inserts the cross-module rows an order needs to exist: a buyer,
// an owner with a store, and a published offer. Every identifier is fresh, so
// worlds from parallel tests and repeated runs never collide on a shared
// database.
package seed

import (
	"context"
	"math/rand/v2"
	"testing"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// Config tunes the world; zero values mean an active owner with an active
// store selling one product at 10 000 tiyin, 100 units declared, at the
// platform-default 250 bps (2.5%) commission.
type Config struct {
	OwnerStatus          string
	StoreStatus          string
	Founding             bool
	Price                int64
	DeclaredQty          string
	CommissionBps        int32
	ConfirmWindowMinutes int32
}

// World is one self-contained marketplace tenant.
type World struct {
	BuyerUserID  string
	BuyerPhone   string
	SellerUserID string
	OwnerID      string
	TIN          string
	StoreID      string
	CategoryID   string
	ProductID    string
	OfferID      string
	Price        int64
}

// Marketplace creates a world and returns its identifiers.
func Marketplace(t *testing.T, pool *postgres.Pool, cfg Config) World {
	t.Helper()
	if cfg.OwnerStatus == "" {
		cfg.OwnerStatus = "active"
	}
	if cfg.StoreStatus == "" {
		cfg.StoreStatus = "active"
	}
	if cfg.Price == 0 {
		cfg.Price = 10_000
	}
	if cfg.DeclaredQty == "" {
		cfg.DeclaredQty = "100"
	}
	if cfg.CommissionBps == 0 {
		cfg.CommissionBps = 250
	}
	if cfg.ConfirmWindowMinutes == 0 {
		cfg.ConfirmWindowMinutes = 240
	}

	w := World{
		BuyerUserID:  uuid.NewString(),
		BuyerPhone:   Phone(),
		SellerUserID: uuid.NewString(),
		OwnerID:      uuid.NewString(),
		TIN:          digits(9),
		StoreID:      uuid.NewString(),
		CategoryID:   uuid.NewString(),
		Price:        cfg.Price,
	}

	exec := execFn(t, pool)
	exec(`INSERT INTO identity.users (id, phone, status, created_at)
	      VALUES ($1, $2, 'active', now())`, w.BuyerUserID, w.BuyerPhone)
	exec(`INSERT INTO identity.users (id, phone, status, created_at)
	      VALUES ($1, $2, 'active', now())`, w.SellerUserID, Phone())
	exec(`INSERT INTO location.owners
	        (id, user_id, tin, legal_name, status, is_founding, credit_limit, created_at)
	      VALUES ($1, $2, $3, 'Suite Test LLC', $4, $5, 0, now())`,
		w.OwnerID, w.SellerUserID, w.TIN, cfg.OwnerStatus, cfg.Founding)
	exec(`INSERT INTO location.stores (id, owner_id, name, status, location, created_at)
	      VALUES ($1, $2, 'Suite Test Store', $3,
	              ST_SetSRID(ST_MakePoint(69.24, 41.31), 4326)::geography, now())`,
		w.StoreID, w.OwnerID, cfg.StoreStatus)
	exec(`INSERT INTO catalog.categories (id, name, confirm_window_minutes, commission_bps)
	      VALUES ($1, 'Suite Test Category', $2, $3)`,
		w.CategoryID, cfg.ConfirmWindowMinutes, cfg.CommissionBps)

	w.ProductID, w.OfferID = NewOffer(t, pool, w, cfg.Price, cfg.DeclaredQty)
	return w
}

// NewOffer adds a fresh product with one published offer to the world's store,
// so each case can assert stock movements on an offer nobody else touches.
func NewOffer(t *testing.T, pool *postgres.Pool, w World, price int64, declaredQty string) (productID, offerID string) {
	t.Helper()
	productID = uuid.NewString()
	offerID = uuid.NewString()
	exec := execFn(t, pool)
	exec(`INSERT INTO catalog.products (id, category_id, name, unit, created_at)
	      VALUES ($1, $2, 'Suite Test Product', 'bag', now())`, productID, w.CategoryID)
	exec(`INSERT INTO catalog.offers
	        (id, store_id, product_id, price, declared_qty, reserved_qty, freshness_at, status)
	      VALUES ($1, $2, $3, $4, $5, 0, now(), 'published')`,
		offerID, w.StoreID, productID, price, declaredQty)
	return productID, offerID
}

// OrderRow inserts an order directly in the given status, bypassing the state
// machine. For seeding rejection-matrix cases and states the machine only
// passes through; lifecycle tests must walk real transitions instead.
func OrderRow(t *testing.T, pool *postgres.Pool, w World, status string, goods, delivery int64) string {
	t.Helper()
	orderID := uuid.NewString()
	execFn(t, pool)(`INSERT INTO orders.orders
	        (id, buyer_id, store_id, status, buyer_type, fulfillment, is_urgent,
	         goods_amount, delivery_fee, total_amount, supplier_confirmation_deadline, created_at)
	      VALUES ($1, $2, $3, $4, 'individual', 'pickup', false,
	              $5, $6, $5 + $6, now() + interval '4 hours', now())`,
		orderID, w.BuyerUserID, w.StoreID, status, goods, delivery)
	return orderID
}

// Offer reads the offer's current stock counters.
func Offer(t *testing.T, pool *postgres.Pool, offerID string) (declared, reserved string) {
	t.Helper()
	err := pool.QueryRow(context.Background(),
		`SELECT declared_qty::text, reserved_qty::text FROM catalog.offers WHERE id = $1`,
		offerID).Scan(&declared, &reserved)
	if err != nil {
		t.Fatalf("read offer %s: %v", offerID, err)
	}
	return declared, reserved
}

// Phone returns a fresh, valid-looking Uzbek mobile number.
func Phone() string {
	return "998" + digits(9)
}

func digits(n int) string {
	out := make([]byte, n)
	for i := range out {
		out[i] = byte('0' + rand.IntN(10))
	}
	return string(out)
}

func execFn(t *testing.T, pool *postgres.Pool) func(sql string, args ...any) {
	return func(sql string, args ...any) {
		t.Helper()
		if _, err := pool.Exec(context.Background(), sql, args...); err != nil {
			head := sql
			if len(head) > 60 {
				head = head[:60]
			}
			t.Fatalf("seed %q: %v", head, err)
		}
	}
}
