package catalog

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const (
	sellerAlice = "018f0f50-0000-7000-8000-00000000a11c"
	ownedStore  = "018f0f50-0000-7000-8000-0000000057a1"
	otherStore  = "018f0f50-0000-7000-8000-0000000057a2"
	productOne  = "018f0f50-0000-7000-8000-000000000401"
	offerOne    = "018f0f50-0000-7000-8000-000000000f01"
	requestOne  = "018f0f50-0000-7000-8000-000000000c01"
)

type fakeRepository struct {
	offerStore string
	requests   int
	resolves   int
	creates    int
	updates    int
}

func (f *fakeRepository) CreateCatalogRequest(context.Context, CatalogRequestInput, time.Time) (string, error) {
	f.requests++
	return requestOne, nil
}

func (f *fakeRepository) ResolveCatalogRequest(context.Context, CatalogResolution, time.Time) error {
	f.resolves++
	return nil
}

func (f *fakeRepository) CreateOffer(context.Context, OfferInput, time.Time) (string, error) {
	f.creates++
	return offerOne, nil
}

func (f *fakeRepository) UpdateOffer(context.Context, OfferUpdate, time.Time) error {
	f.updates++
	return nil
}

func (f *fakeRepository) OfferStore(context.Context, string) (string, error) {
	return f.offerStore, nil
}

type stubGuard struct{ stores map[string]bool }

func (g stubGuard) OwnerID(context.Context) (string, error) { return "", authz.ErrForbidden }

func (g stubGuard) EnsureOwnsStore(_ context.Context, storeID string) error {
	if g.stores[storeID] {
		return nil
	}
	return authz.ErrForbidden
}

func (g stubGuard) EnsureOwner(context.Context, string) error { return authz.ErrForbidden }

func newService(repository repository, owned ...string) *Service {
	stores := make(map[string]bool, len(owned))
	for _, id := range owned {
		stores[id] = true
	}
	return NewService(repository, stubGuard{stores: stores},
		clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)))
}

func principal(userID string, roles ...authz.Role) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{UserID: userID, Roles: roles})
}

// A seller may publish only into stores it owns; without this check any
// authenticated caller could add offers to a competitor's storefront.
func TestCreateOfferRequiresStoreOwnership(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(repository, ownedStore)
	ctx := principal(sellerAlice, authz.RoleSeller)

	_, err := service.CreateOffer(ctx, OfferInput{
		StoreID: otherStore, ProductID: productOne, DeclaredQty: "10", Price: 5000,
	})
	if !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("error = %v, want ErrForbidden", err)
	}
	if repository.creates != 0 {
		t.Fatal("an unauthorised offer reached the repository")
	}

	if _, err := service.CreateOffer(ctx, OfferInput{
		StoreID: ownedStore, ProductID: productOne, DeclaredQty: "10", Price: 5000,
	}); err != nil {
		t.Fatalf("own store error = %v", err)
	}
}

// The client supplies only the offer id, so ownership is resolved from the
// stored offer rather than from anything in the request.
func TestUpdateOfferResolvesOwnershipFromTheStoredOffer(t *testing.T) {
	t.Parallel()
	price := int64(6000)

	foreign := &fakeRepository{offerStore: otherStore}
	service := newService(foreign, ownedStore)
	err := service.UpdateOffer(principal(sellerAlice, authz.RoleSeller), OfferUpdate{ID: offerOne, Price: &price})
	if !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("error = %v, want ErrForbidden", err)
	}
	if foreign.updates != 0 {
		t.Fatal("an unauthorised update reached the repository")
	}

	own := &fakeRepository{offerStore: ownedStore}
	ownService := newService(own, ownedStore)
	if err := ownService.UpdateOffer(principal(sellerAlice, authz.RoleSeller), OfferUpdate{ID: offerOne, Price: &price}); err != nil {
		t.Fatalf("own offer error = %v", err)
	}
}

// Catalogue curation is a platform responsibility, not a seller one.
func TestResolveCatalogRequestRequiresOperatorRole(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(repository, ownedStore)
	resolution := CatalogResolution{ID: requestOne, Status: "added", ProductID: productOne}

	if err := service.ResolveCatalogRequest(principal(sellerAlice, authz.RoleSeller), resolution); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("seller error = %v, want ErrForbidden", err)
	}
	if err := service.ResolveCatalogRequest(context.Background(), resolution); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("anonymous error = %v, want ErrUnauthenticated", err)
	}
	if repository.resolves != 0 {
		t.Fatal("an unauthorised resolution reached the repository")
	}

	if err := service.ResolveCatalogRequest(principal(sellerAlice, authz.RoleOperator), resolution); err != nil {
		t.Fatalf("operator error = %v", err)
	}
}

func TestOfferValidation(t *testing.T) {
	t.Parallel()
	service := newService(&fakeRepository{offerStore: ownedStore}, ownedStore)
	ctx := principal(sellerAlice, authz.RoleSeller)

	invalid := map[string]OfferInput{
		"zero price":        {StoreID: ownedStore, ProductID: productOne, DeclaredQty: "1", Price: 0},
		"negative price":    {StoreID: ownedStore, ProductID: productOne, DeclaredQty: "1", Price: -5},
		"bad quantity":      {StoreID: ownedStore, ProductID: productOne, DeclaredQty: "1.2.3", Price: 10},
		"empty quantity":    {StoreID: ownedStore, ProductID: productOne, DeclaredQty: "", Price: 10},
		"malformed product": {StoreID: ownedStore, ProductID: "nope", DeclaredQty: "1", Price: 10},
	}
	for name, input := range invalid {
		t.Run(name, func(t *testing.T) {
			if _, err := service.CreateOffer(ctx, input); !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
		})
	}

	if _, err := service.CreateOffer(ctx, OfferInput{
		StoreID: ownedStore, ProductID: productOne, DeclaredQty: "0", Price: 10,
	}); err != nil {
		t.Fatalf("zero declared quantity rejected: %v", err)
	}

	if err := service.UpdateOffer(ctx, OfferUpdate{ID: offerOne}); !errors.Is(err, ErrInvalid) {
		t.Fatalf("empty update error = %v, want ErrInvalid", err)
	}

	// Visibility: only the seller-facing pair is accepted, and a status-only
	// update is a complete request.
	for _, status := range []string{"published", "hidden"} {
		if err := service.UpdateOffer(ctx, OfferUpdate{ID: offerOne, Status: &status}); err != nil {
			t.Fatalf("status-only update to %q rejected: %v", status, err)
		}
	}
	for _, status := range []string{"archived", "deleted", ""} {
		if err := service.UpdateOffer(ctx, OfferUpdate{ID: offerOne, Status: &status}); !errors.Is(err, ErrInvalid) {
			t.Fatalf("status %q error = %v, want ErrInvalid", status, err)
		}
	}
}
