// Package location owns the responsibility axis: owner accounts, trade
// complexes, blocks and stores.
package location

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/tin"
)

// Module owns the location schema.
type Module struct {
	repository *Repository
	seller     *SellerHandler
}

// New creates the location module against the OLTP pool.
func New(pool *postgres.Pool, verifier ...tin.Verifier) *Module {
	repository := NewRepository(pool)
	var v tin.Verifier = tin.FormatVerifier{}
	if len(verifier) > 0 && verifier[0] != nil {
		v = verifier[0]
	}
	clk := clock.New()
	return &Module{
		repository: repository,
		seller:     &SellerHandler{repository: repository, verifier: v, now: clk.Now},
	}
}

// Mount registers seller onboarding.
func (m *Module) Mount(r chi.Router) { m.seller.Mount(r) }

// Guard returns the authorization guard backed by owner/store ownership.
func (m *Module) Guard() authz.Guard { return NewGuard(m.repository) }

// SaleGate returns the sale-eligibility port the order path calls before it
// reserves stock.
func (m *Module) SaleGate() SaleGatePort { return newSalePort() }
