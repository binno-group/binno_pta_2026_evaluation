// Package dedup provides transactional mutation deduplication.
//
// ReserveNew guards a creation, where a replay legitimately finds a different
// id. ReserveFor guards an action on an existing resource, where a replay must
// find the same id; a mismatch is one Idempotency-Key used for two resources
// and is reported as ErrKeyReuse rather than silently skipped.
package dedup

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
)

// ErrKeyReuse reports one operation key presented for two different resources.
var ErrKeyReuse = errors.New("dedup: operation key already used for a different resource")

// ReserveNew claims operationKey for a resource this attempt is creating.
func ReserveNew(
	ctx context.Context,
	tx pgx.Tx,
	operationKey string,
	newResourceID uuid.UUID,
	at time.Time,
) (replay bool, resourceID uuid.UUID, err error) {
	stored, claimed, err := claim(ctx, tx, operationKey, newResourceID, at)
	if err != nil {
		return false, uuid.Nil, err
	}
	if claimed {
		return false, newResourceID, nil
	}
	return true, stored, nil
}

// ReserveFor claims operationKey for an action on an existing resource.
func ReserveFor(
	ctx context.Context,
	tx pgx.Tx,
	operationKey string,
	resourceID uuid.UUID,
	at time.Time,
) (replay bool, err error) {
	stored, claimed, err := claim(ctx, tx, operationKey, resourceID, at)
	if err != nil {
		return false, err
	}
	if claimed {
		return false, nil
	}
	if stored != resourceID {
		return false, fmt.Errorf("%w: key bound to %s, presented for %s",
			ErrKeyReuse, stored, resourceID)
	}
	return true, nil
}

// claim inserts the receipt.
func claim(
	ctx context.Context,
	tx pgx.Tx,
	operationKey string,
	resourceID uuid.UUID,
	at time.Time,
) (stored uuid.UUID, claimed bool, err error) {
	if operationKey == "" {
		return uuid.Nil, false, fmt.Errorf("dedup: operation key is required")
	}
	var inserted uuid.UUID
	err = tx.QueryRow(ctx, `
		INSERT INTO platform.mutation_receipts (operation_key, resource_id, created_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (operation_key) DO NOTHING
		RETURNING resource_id`,
		operationKey, nullableUUID(resourceID), at,
	).Scan(&inserted)
	if err == nil {
		return inserted, true, nil
	}
	if !errors.Is(err, pgx.ErrNoRows) {
		return uuid.Nil, false, fmt.Errorf("dedup: reserve mutation: %w", err)
	}
	var existing *uuid.UUID
	if err := tx.QueryRow(ctx,
		`SELECT resource_id FROM platform.mutation_receipts WHERE operation_key = $1`,
		operationKey,
	).Scan(&existing); err != nil {
		return uuid.Nil, false, fmt.Errorf("dedup: read mutation receipt: %w", err)
	}
	if existing != nil {
		stored = *existing
	}
	return stored, false, nil
}

func nullableUUID(id uuid.UUID) *uuid.UUID {
	if id == uuid.Nil {
		return nil
	}
	return &id
}
