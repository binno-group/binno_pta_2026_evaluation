package location

import (
	"context"
	"errors"
	"fmt"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

// ownership is the repository surface the guard needs.
type ownership interface {
	StoreBelongsToUser(ctx context.Context, userID, storeID string) (bool, error)
	OwnerBelongsToUser(ctx context.Context, userID, ownerID string) (bool, error)
	OwnerIDForUser(ctx context.Context, userID string) (string, error)
}

// Guard answers ownership questions for platform/authz.
type Guard struct {
	ownership ownership
}

// NewGuard returns the authz guard backed by the location schema.
func NewGuard(ownership ownership) *Guard { return &Guard{ownership: ownership} }

var _ authz.Guard = (*Guard)(nil)

// OwnerID returns the owner account the calling principal administers.
func (g *Guard) OwnerID(ctx context.Context) (string, error) {
	principal, err := authz.Require(ctx)
	if err != nil {
		return "", err
	}
	ownerID, err := g.ownership.OwnerIDForUser(ctx, principal.UserID)
	if errors.Is(err, ErrNotFound) {
		return "", authz.ErrForbidden
	}
	if err != nil {
		return "", fmt.Errorf("location guard: resolve owner: %w", err)
	}
	return ownerID, nil
}

// EnsureOwnsStore authorises a seller action against storeID.
func (g *Guard) EnsureOwnsStore(ctx context.Context, storeID string) error {
	principal, err := authz.Require(ctx)
	if err != nil {
		return err
	}
	if !principal.Has(authz.RoleSeller) {
		return authz.ErrForbidden
	}
	allowed, err := g.ownership.StoreBelongsToUser(ctx, principal.UserID, storeID)
	if err != nil {
		return fmt.Errorf("location guard: store ownership: %w", err)
	}
	if !allowed {
		return authz.ErrForbidden
	}
	return nil
}

// EnsureOwner authorises an action scoped to ownerID.
func (g *Guard) EnsureOwner(ctx context.Context, ownerID string) error {
	principal, err := authz.Require(ctx)
	if err != nil {
		return err
	}
	allowed, err := g.ownership.OwnerBelongsToUser(ctx, principal.UserID, ownerID)
	if err != nil {
		return fmt.Errorf("location guard: owner scope: %w", err)
	}
	if !allowed {
		return authz.ErrForbidden
	}
	return nil
}
