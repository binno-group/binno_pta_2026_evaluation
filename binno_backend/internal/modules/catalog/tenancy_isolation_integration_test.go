//go:build integration

package catalog_test

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

func sellerCtx(userID string) context.Context {
	ctx := httpx.WithOperationKey(context.Background(), uuid.NewString())
	return authz.WithPrincipal(ctx, authz.Principal{
		UserID: userID, Roles: []authz.Role{authz.RoleSeller},
	})
}

// Offer management goes through the ownership guard backed by the real
// location schema: a seller can only touch stock in stores their owner
// account holds.
func TestSellerCannotEditOffersOfAForeignStore(t *testing.T) {
	pool := pgtest.Pool(t)
	clk := clock.New()
	svc := catalog.NewService(catalog.NewRepository(pool, clk), location.New(pool).Guard(), clk)

	mine := seed.Marketplace(t, pool, seed.Config{})
	foreign := seed.Marketplace(t, pool, seed.Config{})

	price := int64(1)
	err := svc.UpdateOffer(sellerCtx(foreign.SellerUserID), catalog.OfferUpdate{
		ID: mine.OfferID, Price: &price,
	})
	if !errors.Is(err, authz.ErrForbidden) {
		t.Errorf("foreign seller UpdateOffer: err = %v, want ErrForbidden", err)
	}

	_, err = svc.CreateOffer(sellerCtx(foreign.SellerUserID), catalog.OfferInput{
		StoreID: mine.StoreID, ProductID: foreign.ProductID, DeclaredQty: "5", Price: 1_000,
	})
	if !errors.Is(err, authz.ErrForbidden) {
		t.Errorf("foreign seller CreateOffer into my store: err = %v, want ErrForbidden", err)
	}

	var storedPrice int64
	if err := pool.QueryRow(context.Background(),
		`SELECT price FROM catalog.offers WHERE id = $1`, mine.OfferID).Scan(&storedPrice); err != nil {
		t.Fatalf("read offer price: %v", err)
	}
	if storedPrice != mine.Price {
		t.Errorf("offer price = %d, want %d untouched", storedPrice, mine.Price)
	}

	// The owning seller edits the same offer without friction.
	ownPrice := int64(12_345)
	if err := svc.UpdateOffer(sellerCtx(mine.SellerUserID), catalog.OfferUpdate{
		ID: mine.OfferID, Price: &ownPrice,
	}); err != nil {
		t.Fatalf("own seller UpdateOffer: %v, want success", err)
	}
	if err := pool.QueryRow(context.Background(),
		`SELECT price FROM catalog.offers WHERE id = $1`, mine.OfferID).Scan(&storedPrice); err != nil {
		t.Fatalf("re-read offer price: %v", err)
	}
	if storedPrice != ownPrice {
		t.Errorf("offer price = %d, want %d after the owner's update", storedPrice, ownPrice)
	}
}
