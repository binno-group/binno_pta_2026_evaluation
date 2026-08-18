// Package authz carries the authenticated principal and the resource-ownership
// checks that every protected handler runs before it acts.
package authz

import (
	"context"
	"errors"
	"net/http"
	"slices"
)

// Role is a coarse capability carried in the JWT "roles" claim.
type Role string

const (
	// RoleBuyer may create orders and act on its own orders.
	RoleBuyer Role = "buyer"
	// RoleSeller may manage catalogue offers and confirm orders for its stores.
	RoleSeller Role = "seller"
	// RoleOperator may read and resolve operator queues across all tenants.
	RoleOperator Role = "operator"
)

// ValidRole reports whether value is a role this system issues.
func ValidRole(value string) bool {
	switch Role(value) {
	case RoleBuyer, RoleSeller, RoleOperator:
		return true
	default:
		return false
	}
}

// Principal is the authenticated caller.
type Principal struct {
	// UserID is the JWT subject: a UUID identifying the human account.
	UserID string
	// Roles are the capabilities asserted by the token, already filtered to known
	// roles.
	Roles []Role
}

// Authenticated reports whether a verified token produced this principal.
func (p Principal) Authenticated() bool { return p.UserID != "" }

// Has reports whether the principal carries role.
func (p Principal) Has(role Role) bool { return slices.Contains(p.Roles, role) }

// Errors returned by the guards.
var (
	// ErrUnauthenticated means no valid token was presented.
	ErrUnauthenticated = errors.New("authz: authentication required")
	// ErrForbidden means a valid principal may not touch this resource.
	ErrForbidden = errors.New("authz: principal may not access this resource")
)

type principalKey struct{}

// WithPrincipal returns ctx carrying p.
func WithPrincipal(ctx context.Context, p Principal) context.Context {
	return context.WithValue(ctx, principalKey{}, p)
}

// FromContext returns the principal carried by ctx, if any.
func FromContext(ctx context.Context) (Principal, bool) {
	p, ok := ctx.Value(principalKey{}).(Principal)
	return p, ok && p.Authenticated()
}

// Subject returns the authenticated user ID, or "" when the request is
// anonymous.
func Subject(ctx context.Context) string {
	p, ok := FromContext(ctx)
	if !ok {
		return ""
	}
	return p.UserID
}

// Require returns the authenticated principal or ErrUnauthenticated.
func Require(ctx context.Context) (Principal, error) {
	p, ok := FromContext(ctx)
	if !ok {
		return Principal{}, ErrUnauthenticated
	}
	return p, nil
}

// RequireRole returns the authenticated principal if it carries role.
func RequireRole(ctx context.Context, role Role) (Principal, error) {
	p, err := Require(ctx)
	if err != nil {
		return Principal{}, err
	}
	if !p.Has(role) {
		return Principal{}, ErrForbidden
	}
	return p, nil
}

// Guard answers ownership questions about the calling principal.
type Guard interface {
	// OwnerID returns the owner account the principal administers.
	OwnerID(ctx context.Context) (string, error)
	// EnsureOwnsStore returns nil when the principal's owner account owns storeID,
	// ErrForbidden otherwise.
	EnsureOwnsStore(ctx context.Context, storeID string) error
	// EnsureOwner returns nil when ownerID is the principal's own owner account.
	EnsureOwner(ctx context.Context, ownerID string) error
}

// EnsureSelf returns nil when userID is the calling principal, so a handler can
// guard "your own resource" without reaching for a Guard round trip.
func EnsureSelf(ctx context.Context, userID string) error {
	p, err := Require(ctx)
	if err != nil {
		return err
	}
	if p.UserID != userID {
		return ErrForbidden
	}
	return nil
}

// HTTPStatus maps an authorization error to its response status.
func HTTPStatus(err error) (int, bool) {
	switch {
	case errors.Is(err, ErrUnauthenticated):
		return http.StatusUnauthorized, true
	case errors.Is(err, ErrForbidden):
		return http.StatusForbidden, true
	default:
		return 0, false
	}
}
