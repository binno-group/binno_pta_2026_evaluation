package catalog

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
	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/dedup"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// catalogRequestSLA is how long an operator has to resolve a catalogue request.
const catalogRequestSLA = 24 * time.Hour

// Repository persists catalogue state and its domain events in one transaction.
type Repository struct {
	pool   *postgres.Pool
	outbox *outbox.Writer
}

// NewRepository returns a catalog repository over pool.
func NewRepository(pool *postgres.Pool, clk clock.Clock) *Repository {
	return &Repository{pool: pool, outbox: outbox.NewWriter(clk)}
}

// OfferStore returns the store that owns offerID.
func (r *Repository) OfferStore(ctx context.Context, offerID string) (string, error) {
	id, ok := parseUUID(offerID)
	if !ok {
		return "", ErrInvalid
	}
	storeID, err := store.New(r.pool).GetOfferStore(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	if err != nil {
		return "", fmt.Errorf("catalog: offer store: %w", err)
	}
	return uuidString(storeID), nil
}

// CreateCatalogRequest records a request and opens an operator queue item.
func (r *Repository) CreateCatalogRequest(ctx context.Context, in CatalogRequestInput, at time.Time) (string, error) {
	id := newID()
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return "", fmt.Errorf("catalog: begin catalog request: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, resourceID, err := dedup.ReserveNew(ctx, tx, httpx.OperationKey(ctx), id, at)
	if err != nil {
		return "", err
	}
	if replay {
		return resourceID.String(), nil
	}

	storeID, _ := parseUUID(in.StoreID)
	if _, err := store.New(tx).CreateCatalogRequest(ctx, &store.CreateCatalogRequestParams{
		ID: uuidValue(id), StoreID: storeID, Name: in.Name, Unit: in.Unit,
		Description: optional(in.Description), ImageUrl: optional(in.ImageURL),
		CreatedAt: timeValue(at),
	}); err != nil {
		return "", mapError(err)
	}
	if err := r.outbox.Write(ctx, tx, "catalog", id.String(), eventcatalog.CatalogRequestedPayload{
		StoreID: in.StoreID, Name: in.Name, Unit: in.Unit, DueAt: at.Add(catalogRequestSLA),
	}); err != nil {
		return "", err
	}
	if err := tx.Commit(ctx); err != nil {
		return "", fmt.Errorf("catalog: commit catalog request: %w", err)
	}
	return id.String(), nil
}

// ResolveCatalogRequest applies an operator decision to a pending request.
func (r *Repository) ResolveCatalogRequest(ctx context.Context, in CatalogResolution, at time.Time) error {
	requestID, ok := parseUUID(in.ID)
	if !ok {
		return ErrInvalid
	}
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("catalog: begin resolve catalog request: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(requestID.Bytes), at)
	if err != nil {
		return mapDedupError(err)
	}
	if replay {
		return nil
	}

	queries := store.New(tx)
	current, err := queries.GetCatalogRequestForUpdate(ctx, requestID)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return mapError(err)
	}
	if current.Status != "pending" {
		return ErrConflict
	}

	productID, _ := parseUUID(in.ProductID)
	if _, err := queries.ResolveCatalogRequest(ctx, &store.ResolveCatalogRequestParams{
		Status: in.Status, ProductID: productID, RejectReason: optional(in.RejectReason),
		ResolvedAt: timeValue(at), ID: requestID,
	}); err != nil {
		return mapError(err)
	}
	if err := r.outbox.Write(ctx, tx, "catalog", in.ID, eventcatalog.CatalogRequestResolvedPayload{
		StoreID: uuidString(current.StoreID), Status: in.Status,
		ProductID: in.ProductID, RejectReason: in.RejectReason,
	}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

// CreateOffer publishes a new offer.
func (r *Repository) CreateOffer(ctx context.Context, in OfferInput, at time.Time) (string, error) {
	id := newID()
	quantity, err := numeric(in.DeclaredQty)
	if err != nil {
		return "", ErrInvalid
	}
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return "", fmt.Errorf("catalog: begin offer: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, resourceID, err := dedup.ReserveNew(ctx, tx, httpx.OperationKey(ctx), id, at)
	if err != nil {
		return "", err
	}
	if replay {
		return resourceID.String(), nil
	}

	storeID, _ := parseUUID(in.StoreID)
	productID, _ := parseUUID(in.ProductID)
	if _, err := store.New(tx).CreateOffer(ctx, &store.CreateOfferParams{
		ID: uuidValue(id), StoreID: storeID, ProductID: productID,
		Price: in.Price, DeclaredQty: quantity, FreshnessAt: timeValue(at),
	}); err != nil {
		return "", mapError(err)
	}
	if err := r.outbox.Write(ctx, tx, "catalog", id.String(), eventcatalog.OfferCreatedPayload{
		StoreID: in.StoreID, ProductID: in.ProductID, Price: in.Price, DeclaredQty: in.DeclaredQty,
	}); err != nil {
		return "", err
	}
	if err := tx.Commit(ctx); err != nil {
		return "", fmt.Errorf("catalog: commit offer: %w", err)
	}
	return id.String(), nil
}

// UpdateOffer changes an offer's price or declared quantity.
func (r *Repository) UpdateOffer(ctx context.Context, in OfferUpdate, at time.Time) error {
	offerID, ok := parseUUID(in.ID)
	if !ok {
		return ErrInvalid
	}
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("catalog: begin update offer: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(offerID.Bytes), at)
	if err != nil {
		return mapDedupError(err)
	}
	if replay {
		return nil
	}

	queries := store.New(tx)
	current, err := queries.GetOfferForUpdate(ctx, offerID)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return mapError(err)
	}

	price, quantity := current.Price, current.DeclaredQty
	if in.Price != nil {
		price = *in.Price
	}
	if in.DeclaredQty != nil {
		if quantity, err = numeric(*in.DeclaredQty); err != nil {
			return ErrInvalid
		}
	}
	if _, err := queries.UpdateOfferValues(ctx, &store.UpdateOfferValuesParams{
		Price: price, DeclaredQty: quantity, ChangedAt: timeValue(at), ID: offerID,
	}); err != nil {
		return mapError(err)
	}
	status := current.Status
	if in.Status != nil && *in.Status != current.Status {
		updated, err := queries.UpdateOfferStatus(ctx, &store.UpdateOfferStatusParams{
			Status: *in.Status, ID: offerID,
		})
		if errors.Is(err, pgx.ErrNoRows) {
			// The offer is archived; that decision is not reversible here.
			return ErrConflict
		}
		if err != nil {
			return mapError(err)
		}
		status = updated.Status
	}
	if err := r.outbox.Write(ctx, tx, "catalog", in.ID, eventcatalog.OfferUpdatedPayload{
		StoreID:     uuidString(current.StoreID),
		ProductID:   uuidString(current.ProductID),
		Price:       price,
		DeclaredQty: numericText(quantity),
		Status:      status,
	}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

func newID() uuid.UUID {
	id, err := uuid.NewV7()
	if err != nil {
		return uuid.New()
	}
	return id
}

func uuidValue(id uuid.UUID) pgtype.UUID { return pgtype.UUID{Bytes: id, Valid: true} }

func timeValue(value time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: value, Valid: true}
}

func optional(value string) *string {
	if value == "" {
		return nil
	}
	return &value
}

func numeric(value string) (pgtype.Numeric, error) {
	var n pgtype.Numeric
	err := n.Scan(value)
	return n, err
}

func numericText(value pgtype.Numeric) string {
	raw, err := value.Value()
	if err != nil || raw == nil {
		return "0"
	}
	return fmt.Sprint(raw)
}

// mapDedupError turns a reused idempotency key into a catalogue conflict rather
// than a 500: the client did something wrong, and the safe answer is to refuse.
func mapDedupError(err error) error {
	if errors.Is(err, dedup.ErrKeyReuse) {
		return fmt.Errorf("%w: %s", ErrConflict, err)
	}
	return err
}

func mapError(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && (pgErr.Code == "23505" || pgErr.Code == "23514" || pgErr.Code == "23503") {
		return ErrConflict
	}
	return fmt.Errorf("catalog repository: %w", err)
}
