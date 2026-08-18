//go:build integration

package orders_test

import (
	"context"
	"errors"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// Tenancy through the real guard and the real database: another tenant's order
// is not "forbidden", it does not exist. These complement the unit tests in
// service_test.go, which prove the same policy against fakes.

func principalCtx(userID string, roles ...authz.Role) context.Context {
	return authz.WithPrincipal(opCtx(), authz.Principal{UserID: userID, Roles: roles})
}

func TestBuyerCannotReadOrCancelAnotherBuyersOrder(t *testing.T) {
	s := newStack(t)
	guard := location.New(s.pool).Guard()
	svc := orders.NewService(s.repo, guard, clock.New())

	mine := seed.Marketplace(t, s.pool, seed.Config{})
	theirs := seed.Marketplace(t, s.pool, seed.Config{})
	orderID := placeOrder(t, s, mine, mine.ProductID, "1")

	stranger := principalCtx(theirs.BuyerUserID, authz.RoleBuyer)
	if _, err := svc.GetOrder(stranger, orderID); !errors.Is(err, orders.ErrNotFound) {
		t.Errorf("stranger GetOrder: err = %v, want ErrNotFound (existence hidden)", err)
	}
	if err := svc.Cancel(stranger, orderID, "not mine"); !errors.Is(err, orders.ErrNotFound) {
		t.Errorf("stranger Cancel: err = %v, want ErrNotFound", err)
	}
	if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusCreated) {
		t.Errorf("order status = %q, want created untouched", got)
	}

	// The owner still sees and controls their own order.
	owner := principalCtx(mine.BuyerUserID, authz.RoleBuyer)
	if _, err := svc.GetOrder(owner, orderID); err != nil {
		t.Errorf("owner GetOrder: %v, want the order served", err)
	}
	if err := svc.Cancel(owner, orderID, "changed my mind"); err != nil {
		t.Errorf("owner Cancel: %v, want success", err)
	}
}

func TestSellerCannotActOnAnotherStoresOrder(t *testing.T) {
	s := newStack(t)
	guard := location.New(s.pool).Guard()
	svc := orders.NewService(s.repo, guard, clock.New())

	selling := seed.Marketplace(t, s.pool, seed.Config{})
	rivalWorld := seed.Marketplace(t, s.pool, seed.Config{})
	orderID := placeOrder(t, s, selling, selling.ProductID, "1")

	rival := principalCtx(rivalWorld.SellerUserID, authz.RoleSeller)
	err := svc.SupplierConfirm(rival, orderID)
	if !errors.Is(err, orders.ErrNotFound) && !errors.Is(err, authz.ErrForbidden) {
		t.Errorf("rival SupplierConfirm: err = %v, want not-found or forbidden", err)
	}
	if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusCreated) {
		t.Errorf("order status = %q, want created untouched", got)
	}

	// The selling store's own seller confirms fine.
	own := principalCtx(selling.SellerUserID, authz.RoleSeller)
	if err := svc.SupplierConfirm(own, orderID); err != nil {
		t.Errorf("own SupplierConfirm: %v, want success", err)
	}
}
