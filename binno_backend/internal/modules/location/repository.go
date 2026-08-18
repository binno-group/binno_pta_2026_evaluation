package location

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/location/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// ErrNotFound reports a location resource that does not exist.
var ErrNotFound = errors.New("location resource not found")

// Repository reads the location schema.
type Repository struct {
	pool *postgres.Pool
}

// NewRepository returns a repository over pool.
func NewRepository(pool *postgres.Pool) *Repository { return &Repository{pool: pool} }

// StoreBelongsToUser reports whether userID administers the owner account that
// owns storeID.
func (r *Repository) StoreBelongsToUser(ctx context.Context, userID, storeID string) (bool, error) {
	target, ok := parseUUID(storeID)
	user, userOK := parseUUID(userID)
	if !ok || !userOK {
		return false, nil
	}
	allowed, err := r.queries().StoreBelongsToUser(ctx, &store.StoreBelongsToUserParams{
		StoreID: target, UserID: user,
	})
	if err != nil {
		return false, fmt.Errorf("location: store ownership probe: %w", err)
	}
	return allowed, nil
}

// OwnerBelongsToUser reports whether userID administers ownerID.
func (r *Repository) OwnerBelongsToUser(ctx context.Context, userID, ownerID string) (bool, error) {
	owner, ok := parseUUID(ownerID)
	user, userOK := parseUUID(userID)
	if !ok || !userOK {
		return false, nil
	}
	allowed, err := r.queries().OwnerBelongsToUser(ctx, &store.OwnerBelongsToUserParams{
		OwnerID: owner, UserID: user,
	})
	if err != nil {
		return false, fmt.Errorf("location: owner probe: %w", err)
	}
	return allowed, nil
}

// OwnerIDForUser returns the owner account userID administers.
func (r *Repository) OwnerIDForUser(ctx context.Context, userID string) (string, error) {
	user, ok := parseUUID(userID)
	if !ok {
		return "", ErrNotFound
	}
	owner, err := r.queries().GetOwnerByUser(ctx, user)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	if err != nil {
		return "", fmt.Errorf("location: owner by user: %w", err)
	}
	return uuid.UUID(owner.ID.Bytes).String(), nil
}

func (r *Repository) queries() *store.Queries { return store.New(r.pool) }

func parseUUID(value string) (pgtype.UUID, bool) {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}, false
	}
	return pgtype.UUID{Bytes: id, Valid: true}, true
}
