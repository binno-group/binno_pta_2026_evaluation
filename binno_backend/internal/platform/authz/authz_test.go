package authz_test

import (
	"context"
	"errors"
	"net/http"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

const (
	alice = "018f0f50-0000-7000-8000-00000000a11c"
	bob   = "018f0f50-0000-7000-8000-00000000b0b0"
)

func buyerContext(userID string) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{
		UserID: userID, Roles: []authz.Role{authz.RoleBuyer},
	})
}

func TestAnonymousContextIsUnauthenticated(t *testing.T) {
	t.Parallel()
	if _, err := authz.Require(context.Background()); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("Require(background) error = %v, want ErrUnauthenticated", err)
	}
	if got := authz.Subject(context.Background()); got != "" {
		t.Fatalf("Subject(background) = %q, want empty", got)
	}
}

// A principal with an empty user id is not authenticated, so a zero-value
// Principal placed in the context by mistake cannot pass a guard.
func TestZeroPrincipalDoesNotAuthenticate(t *testing.T) {
	t.Parallel()
	ctx := authz.WithPrincipal(context.Background(), authz.Principal{})
	if _, ok := authz.FromContext(ctx); ok {
		t.Fatal("FromContext accepted a zero principal")
	}
	if _, err := authz.Require(ctx); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("Require error = %v, want ErrUnauthenticated", err)
	}
}

func TestRequireRole(t *testing.T) {
	t.Parallel()
	ctx := buyerContext(alice)

	if _, err := authz.RequireRole(ctx, authz.RoleBuyer); err != nil {
		t.Fatalf("RequireRole(buyer) error = %v", err)
	}
	if _, err := authz.RequireRole(ctx, authz.RoleOperator); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("RequireRole(operator) error = %v, want ErrForbidden", err)
	}
	if _, err := authz.RequireRole(context.Background(), authz.RoleBuyer); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("RequireRole on anonymous error = %v, want ErrUnauthenticated", err)
	}
}

// EnsureSelf is the check that stops one authenticated user acting on another's
// resource, the defect that let any token holder cancel any order.
func TestEnsureSelfSeparatesPrincipals(t *testing.T) {
	t.Parallel()
	ctx := buyerContext(alice)

	if err := authz.EnsureSelf(ctx, alice); err != nil {
		t.Fatalf("EnsureSelf(own id) error = %v", err)
	}
	if err := authz.EnsureSelf(ctx, bob); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("EnsureSelf(other id) error = %v, want ErrForbidden", err)
	}
	if err := authz.EnsureSelf(ctx, ""); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("EnsureSelf(empty id) error = %v, want ErrForbidden", err)
	}
}

// Unknown role strings must not survive into the principal, so a token naming a
// capability this build does not implement cannot widen access after a deploy
// that adds it.
func TestValidRoleIsAClosedSet(t *testing.T) {
	t.Parallel()
	for _, role := range []string{"buyer", "seller", "operator"} {
		if !authz.ValidRole(role) {
			t.Errorf("ValidRole(%q) = false, want true", role)
		}
	}
	for _, role := range []string{"", "admin", "root", "Buyer", "superuser"} {
		if authz.ValidRole(role) {
			t.Errorf("ValidRole(%q) = true, want false", role)
		}
	}
}

func TestHTTPStatusMapping(t *testing.T) {
	t.Parallel()
	tests := []struct {
		err        error
		wantStatus int
		wantOK     bool
	}{
		{authz.ErrUnauthenticated, http.StatusUnauthorized, true},
		{authz.ErrForbidden, http.StatusForbidden, true},
		{errors.New("something else"), 0, false},
	}
	for _, test := range tests {
		status, ok := authz.HTTPStatus(test.err)
		if status != test.wantStatus || ok != test.wantOK {
			t.Errorf("HTTPStatus(%v) = (%d, %v), want (%d, %v)",
				test.err, status, ok, test.wantStatus, test.wantOK)
		}
	}
}
