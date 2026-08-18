package location

import (
	"context"
	"errors"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

const (
	alice      = "018f0f50-0000-7000-8000-00000000a11c"
	ownedStore = "018f0f50-0000-7000-8000-0000000057a1"
	otherStore = "018f0f50-0000-7000-8000-0000000057a2"
	ownerOne   = "018f0f50-0000-7000-8000-00000000e001"
)

type stubOwnership struct {
	stores  map[string]string // storeID -> userID that may act for it
	owners  map[string]string // ownerID -> userID
	ownerOf map[string]string // userID -> ownerID
	err     error
}

func (s stubOwnership) StoreBelongsToUser(_ context.Context, userID, storeID string) (bool, error) {
	if s.err != nil {
		return false, s.err
	}
	return s.stores[storeID] == userID, nil
}

func (s stubOwnership) OwnerBelongsToUser(_ context.Context, userID, ownerID string) (bool, error) {
	if s.err != nil {
		return false, s.err
	}
	return s.owners[ownerID] == userID, nil
}

func (s stubOwnership) OwnerIDForUser(_ context.Context, userID string) (string, error) {
	if s.err != nil {
		return "", s.err
	}
	ownerID, ok := s.ownerOf[userID]
	if !ok {
		return "", ErrNotFound
	}
	return ownerID, nil
}

func sellerContext(userID string) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{
		UserID: userID, Roles: []authz.Role{authz.RoleSeller},
	})
}

func TestEnsureOwnsStore(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{stores: map[string]string{ownedStore: alice}})

	if err := guard.EnsureOwnsStore(sellerContext(alice), ownedStore); err != nil {
		t.Fatalf("own store error = %v", err)
	}
	if err := guard.EnsureOwnsStore(sellerContext(alice), otherStore); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("other store error = %v, want ErrForbidden", err)
	}
	if err := guard.EnsureOwnsStore(context.Background(), ownedStore); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("anonymous error = %v, want ErrUnauthenticated", err)
	}
}

// The seller role is necessary but not sufficient, and its absence is refused
// before the ownership lookup runs.
func TestEnsureOwnsStoreRequiresTheSellerRole(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{stores: map[string]string{ownedStore: alice}})
	buyerOnly := authz.WithPrincipal(context.Background(), authz.Principal{
		UserID: alice, Roles: []authz.Role{authz.RoleBuyer},
	})

	if err := guard.EnsureOwnsStore(buyerOnly, ownedStore); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("buyer-only principal error = %v, want ErrForbidden", err)
	}
}

// A malformed or unknown store id must not be treated as "unknown, therefore
// allow". The guard authorises positively or not at all.
func TestUnknownStoreIsForbiddenNotAllowed(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{stores: map[string]string{}})

	for _, storeID := range []string{"", "not-a-uuid", otherStore} {
		if err := guard.EnsureOwnsStore(sellerContext(alice), storeID); !errors.Is(err, authz.ErrForbidden) {
			t.Errorf("store %q: error = %v, want ErrForbidden", storeID, err)
		}
	}
}

func TestEnsureOwner(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{owners: map[string]string{ownerOne: alice}})

	if err := guard.EnsureOwner(sellerContext(alice), ownerOne); err != nil {
		t.Fatalf("own owner account error = %v", err)
	}
	if err := guard.EnsureOwner(sellerContext(alice), "018f0f50-0000-7000-8000-00000000e999"); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("other owner error = %v, want ErrForbidden", err)
	}
}

// A caller with no owner account is forbidden, not an internal error: it is an
// ordinary "you are not a seller" outcome.
func TestOwnerIDForNonOwnerIsForbidden(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{ownerOf: map[string]string{}})

	if _, err := guard.OwnerID(sellerContext(alice)); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("error = %v, want ErrForbidden", err)
	}
}

// A database failure must surface as an error, never as a silent allow.
func TestLookupFailureDoesNotAuthorize(t *testing.T) {
	t.Parallel()
	guard := NewGuard(stubOwnership{err: errors.New("database down")})
	ctx := sellerContext(alice)

	if err := guard.EnsureOwnsStore(ctx, ownedStore); err == nil {
		t.Fatal("EnsureOwnsStore allowed the request while the lookup was failing")
	}
	if err := guard.EnsureOwner(ctx, ownerOne); err == nil {
		t.Fatal("EnsureOwner allowed the request while the lookup was failing")
	}
	if _, err := guard.OwnerID(ctx); err == nil {
		t.Fatal("OwnerID returned an owner while the lookup was failing")
	}
}
