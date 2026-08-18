package trust

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/trust/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/dedup"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Repository persists feedback and its domain event in one transaction.
type Repository struct {
	pool   *postgres.Pool
	outbox *outbox.Writer
}

// NewRepository returns a trust repository over pool.
func NewRepository(pool *postgres.Pool, clk clock.Clock) *Repository {
	return &Repository{pool: pool, outbox: outbox.NewWriter(clk)}
}

// CreateOrderFeedback stores one feedback record.
func (r *Repository) CreateOrderFeedback(ctx context.Context, in Feedback, at time.Time) error {
	orderID, ok := parseUUID(in.OrderID)
	if !ok {
		return ErrInvalid
	}
	storeID, ok := parseUUID(in.StoreID)
	if !ok {
		return ErrInvalid
	}

	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("trust: begin feedback: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(orderID.Bytes), at)
	if err != nil {
		if errors.Is(err, dedup.ErrKeyReuse) {
			return fmt.Errorf("%w: %s", ErrConflict, err)
		}
		return err
	}
	if replay {
		return nil
	}

	tags := in.Tags
	if tags == nil {
		tags = []string{}
	}
	if _, err := store.New(tx).CreateOrderFeedback(ctx, &store.CreateOrderFeedbackParams{
		OrderID: orderID, StoreID: storeID, HadProblem: in.HadProblem,
		Tags: tags, Comment: optional(in.Comment), Channel: in.Channel,
		CreatedAt: pgtype.Timestamptz{Time: at, Valid: true},
	}); err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			return ErrConflict
		}
		return fmt.Errorf("trust: create feedback: %w", err)
	}

	if err := r.outbox.Write(ctx, tx, "trust", in.OrderID, eventcatalog.FeedbackCreatedPayload{
		StoreID: in.StoreID, BuyerID: in.BuyerID, HadProblem: in.HadProblem,
		Tags: tags, Channel: in.Channel,
	}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func parseUUID(value string) (pgtype.UUID, bool) {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}, false
	}
	return pgtype.UUID{Bytes: id, Valid: true}, true
}

func optional(value string) *string {
	if value == "" {
		return nil
	}
	return &value
}
