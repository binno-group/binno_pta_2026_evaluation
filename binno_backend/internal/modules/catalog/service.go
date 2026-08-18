package catalog

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/money"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Service errors.
var (
	ErrInvalid  = errors.New("invalid catalog input")
	ErrConflict = errors.New("catalog state conflict")
	ErrNotFound = errors.New("catalog resource not found")
)

// Input types.
type (
	// CatalogRequestInput asks the platform to add a missing product.
	CatalogRequestInput struct {
		StoreID, Name, Unit, Description, ImageURL string
	}
	// CatalogResolution is an operator's decision on a catalogue request.
	CatalogResolution struct {
		ID, Status, ProductID, RejectReason string
	}
	// OfferInput publishes a new offer.
	OfferInput struct {
		StoreID, ProductID, DeclaredQty string
		Price                           int64
	}
	// OfferUpdate changes an existing offer's price, declared quantity or
	// visibility.
	OfferUpdate struct {
		ID          string
		Price       *int64
		DeclaredQty *string
		// Status pauses or republishes the offer: 'published' or 'hidden'.
		Status *string
	}
)

// Seller-settable offer statuses; 'archived' is ops-only.
const (
	offerPublished = "published"
	offerHidden    = "hidden"
)

type repository interface {
	CreateCatalogRequest(context.Context, CatalogRequestInput, time.Time) (string, error)
	ResolveCatalogRequest(context.Context, CatalogResolution, time.Time) error
	CreateOffer(context.Context, OfferInput, time.Time) (string, error)
	UpdateOffer(context.Context, OfferUpdate, time.Time) error
	OfferStore(context.Context, string) (string, error)
}

// Service applies catalogue policy: who may publish what, and whether the input
// is well formed, before anything reaches the database.
type Service struct {
	repository repository
	guard      authz.Guard
	clock      clock.Clock
}

// NewService creates a catalog service.
func NewService(repository repository, guard authz.Guard, clk clock.Clock) *Service {
	return &Service{repository: repository, guard: guard, clock: clk}
}

// CreateCatalogRequest records a seller's request for a missing product.
func (s *Service) CreateCatalogRequest(ctx context.Context, in CatalogRequestInput) (string, error) {
	in.Name, in.Unit = strings.TrimSpace(in.Name), strings.TrimSpace(in.Unit)
	if uuid.Validate(in.StoreID) != nil || in.Name == "" || len(in.Name) > 200 ||
		in.Unit == "" || len(in.Unit) > 30 || len(in.Description) > 2000 {
		return "", ErrInvalid
	}
	if err := s.guard.EnsureOwnsStore(ctx, in.StoreID); err != nil {
		return "", err
	}
	return s.repository.CreateCatalogRequest(ctx, in, s.clock.Now())
}

// ResolveCatalogRequest applies an operator decision.
func (s *Service) ResolveCatalogRequest(ctx context.Context, in CatalogResolution) error {
	if _, err := authz.RequireRole(ctx, authz.RoleOperator); err != nil {
		return err
	}
	if uuid.Validate(in.ID) != nil || (in.Status != "added" && in.Status != "rejected") ||
		(in.Status == "added" && uuid.Validate(in.ProductID) != nil) ||
		(in.Status == "rejected" && strings.TrimSpace(in.RejectReason) == "") ||
		len(in.RejectReason) > 1000 {
		return ErrInvalid
	}
	return s.repository.ResolveCatalogRequest(ctx, in, s.clock.Now())
}

// CreateOffer publishes an offer for one of the caller's stores.
func (s *Service) CreateOffer(ctx context.Context, in OfferInput) (string, error) {
	if uuid.Validate(in.StoreID) != nil || uuid.Validate(in.ProductID) != nil ||
		in.Price <= 0 || !money.IsNonNegativeDecimal(in.DeclaredQty) {
		return "", ErrInvalid
	}
	if err := s.guard.EnsureOwnsStore(ctx, in.StoreID); err != nil {
		return "", err
	}
	return s.repository.CreateOffer(ctx, in, s.clock.Now())
}

// UpdateOffer changes price, stock or visibility on an offer one of the
// caller's stores owns.
func (s *Service) UpdateOffer(ctx context.Context, in OfferUpdate) error {
	if uuid.Validate(in.ID) != nil ||
		(in.Price == nil && in.DeclaredQty == nil && in.Status == nil) ||
		(in.Price != nil && *in.Price <= 0) ||
		(in.DeclaredQty != nil && !money.IsNonNegativeDecimal(*in.DeclaredQty)) ||
		(in.Status != nil && *in.Status != offerPublished && *in.Status != offerHidden) {
		return ErrInvalid
	}
	storeID, err := s.repository.OfferStore(ctx, in.ID)
	if err != nil {
		return err
	}
	if err := s.guard.EnsureOwnsStore(ctx, storeID); err != nil {
		return err
	}
	return s.repository.UpdateOffer(ctx, in, s.clock.Now())
}
