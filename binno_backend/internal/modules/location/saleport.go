package location

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/location/store"
)

// Owner and store status values.
const (
	ownerActive = "active"
	storeActive = "active"
)

// Sale-gate errors.
var (
	// ErrOwnerBlocked reports that the owning account may not trade.
	ErrOwnerBlocked = errors.New("location: owner account is blocked")
	// ErrStoreUnavailable reports that the store itself is out of service.
	ErrStoreUnavailable = errors.New("location: store is not active")
)

// Seller is the answer to "may this store sell, and who gets billed for it".
type Seller struct {
	StoreID     string
	StoreName   string
	OwnerID     string
	TIN         string
	LegalName   string
	BankAccount string
	MFO         string
	// Phone is the store's contact number, empty when none was registered; the
	// order path uses it for the SMS confirmation fallback.
	Phone string
}

// SaleGatePort is the sale-eligibility check the order path runs before it
// reserves any stock.
type SaleGatePort interface {
	ResolveSellerForOrder(ctx context.Context, tx pgx.Tx, storeID string) (Seller, error)
}

// salePort implements SaleGatePort.
type salePort struct{}

func newSalePort() *salePort { return &salePort{} }

var _ SaleGatePort = (*salePort)(nil)

// ResolveSellerForOrder refuses the sale unless both the store and its owner are
// active, and returns the owner account to bill.
func (p *salePort) ResolveSellerForOrder(ctx context.Context, tx pgx.Tx, storeID string) (Seller, error) {
	id, ok := parseUUID(storeID)
	if !ok {
		return Seller{}, ErrStoreUnavailable
	}
	state, err := store.New(tx).GetStoreSaleState(ctx, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return Seller{}, ErrStoreUnavailable
	}
	if err != nil {
		return Seller{}, fmt.Errorf("location: store sale state: %w", err)
	}
	seller := Seller{
		StoreID:     uuid.UUID(state.StoreID.Bytes).String(),
		StoreName:   state.StoreName,
		OwnerID:     uuid.UUID(state.OwnerID.Bytes).String(),
		TIN:         strings.TrimSpace(state.OwnerTin),
		LegalName:   state.OwnerLegalName,
		BankAccount: strings.TrimSpace(deref(state.OwnerBankAccount)),
		MFO:         strings.TrimSpace(deref(state.OwnerMfo)),
		Phone:       strings.TrimSpace(deref(state.StorePhone)),
	}
	if state.StoreStatus != storeActive {
		return seller, ErrStoreUnavailable
	}
	if state.OwnerStatus != ownerActive {
		return seller, ErrOwnerBlocked
	}
	return seller, nil
}

// deref reads an optional text column.
func deref(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}
