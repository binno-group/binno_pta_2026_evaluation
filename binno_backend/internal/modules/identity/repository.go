package identity

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/identity/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// Repository is the identity module's persistence.
type Repository struct {
	pool    *postgres.Pool
	queries *store.Queries
}

// NewRepository creates a Repository over pool.
func NewRepository(pool *postgres.Pool) *Repository {
	return &Repository{pool: pool, queries: store.New(pool)}
}

// UpsertUser registers the phone on first sight and records the login.
func (r *Repository) UpsertUser(ctx context.Context, phone string, now time.Time) (User, bool, error) {
	row, err := r.queries.UpsertUserByPhone(ctx, &store.UpsertUserByPhoneParams{
		ID:    newUUID(uuid.NewString()),
		Phone: phone,
		Now:   pgtype.Timestamptz{Time: now, Valid: true},
	})
	if err != nil {
		return User{}, false, fmt.Errorf("identity: upsert user: %w", err)
	}
	return user(row), row.Registered, nil
}

// RolesFor derives the capabilities a user's tokens should carry.
func (r *Repository) RolesFor(ctx context.Context, userID string) (RoleFlags, error) {
	row, err := r.queries.GetUserRoles(ctx, newUUID(userID))
	if errors.Is(err, pgx.ErrNoRows) {
		return RoleFlags{}, nil
	}
	if err != nil {
		return RoleFlags{}, fmt.Errorf("identity: derive roles: %w", err)
	}
	return RoleFlags{Seller: row.IsSeller, Operator: row.IsOperator}, nil
}

// StoreRefreshToken persists an issued refresh token.
func (r *Repository) StoreRefreshToken(ctx context.Context, in RefreshRecord) error {
	var rotatedFrom pgtype.UUID
	if in.RotatedFrom != nil {
		rotatedFrom = newUUID(*in.RotatedFrom)
	}
	if _, err := r.queries.InsertRefreshToken(ctx, &store.InsertRefreshTokenParams{
		ID:          newUUID(in.ID),
		UserID:      newUUID(in.UserID),
		TokenHash:   in.TokenHash,
		IssuedAt:    pgtype.Timestamptz{Time: in.IssuedAt, Valid: true},
		ExpiresAt:   pgtype.Timestamptz{Time: in.ExpiresAt, Valid: true},
		RotatedFrom: rotatedFrom,
	}); err != nil {
		return fmt.Errorf("identity: store refresh token: %w", err)
	}
	return nil
}

// FindRefreshToken looks a token up by its hash.
func (r *Repository) FindRefreshToken(ctx context.Context, hash []byte) (RefreshRecord, error) {
	row, err := r.queries.GetRefreshToken(ctx, hash)
	if errors.Is(err, pgx.ErrNoRows) {
		return RefreshRecord{}, ErrInvalidSession
	}
	if err != nil {
		return RefreshRecord{}, fmt.Errorf("identity: find refresh token: %w", err)
	}
	record := RefreshRecord{
		ID:         row.ID.String(),
		UserID:     row.UserID.String(),
		TokenHash:  row.TokenHash,
		IssuedAt:   row.IssuedAt.Time,
		ExpiresAt:  row.ExpiresAt.Time,
		UserStatus: row.UserStatus,
	}
	if row.RevokedAt.Valid {
		revoked := row.RevokedAt.Time
		record.RevokedAt = &revoked
	}
	if row.RotatedFrom.Valid {
		from := row.RotatedFrom.String()
		record.RotatedFrom = &from
	}
	return record, nil
}

// RevokeRefreshToken revokes one token and reports how many rows changed.
func (r *Repository) RevokeRefreshToken(ctx context.Context, id string, now time.Time) (int64, error) {
	rows, err := r.queries.RevokeRefreshToken(ctx, &store.RevokeRefreshTokenParams{
		ID:  newUUID(id),
		Now: pgtype.Timestamptz{Time: now, Valid: true},
	})
	if err != nil {
		return 0, fmt.Errorf("identity: revoke refresh token: %w", err)
	}
	return rows, nil
}

// RevokeAllUserTokens ends every live session for a user.
func (r *Repository) RevokeAllUserTokens(ctx context.Context, userID string, now time.Time) error {
	if _, err := r.queries.RevokeAllUserTokens(ctx, &store.RevokeAllUserTokensParams{
		UserID: newUUID(userID),
		Now:    pgtype.Timestamptz{Time: now, Valid: true},
	}); err != nil {
		return fmt.Errorf("identity: revoke user sessions: %w", err)
	}
	return nil
}

// PruneExpiredSessions deletes refresh tokens past their expiry, in bounded
// batches.
func (r *Repository) PruneExpiredSessions(ctx context.Context, cutoff time.Time, batch int32) (int64, error) {
	rows, err := r.queries.DeleteExpiredRefreshTokens(ctx, &store.DeleteExpiredRefreshTokensParams{
		Cutoff:    pgtype.Timestamptz{Time: cutoff, Valid: true},
		BatchSize: batch,
	})
	if err != nil {
		return 0, fmt.Errorf("identity: prune sessions: %w", err)
	}
	return rows, nil
}

func user(row *store.UpsertUserByPhoneRow) User {
	u := User{
		ID:        row.ID.String(),
		Phone:     row.Phone,
		Status:    row.Status,
		CreatedAt: row.CreatedAt.Time,
	}
	if row.LastLoginAt.Valid {
		last := row.LastLoginAt.Time
		u.LastLoginAt = &last
	}
	return u
}

func newUUID(value string) pgtype.UUID {
	var id pgtype.UUID
	_ = id.Scan(value)
	return id
}
