// Package billing owns invoices, PSP payments, refunds and the owner commission
// ledger.
package billing

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Module owns billing endpoints.
type Module struct{ handler *Handler }

// New creates a billing module.
func New(pool *postgres.Pool, summaries orders.SummaryPort, guard authz.Guard, clk clock.Clock) *Module {
	return &Module{
		handler: NewHandler(NewService(NewRepository(pool), summaries, guard, clk)),
	}
}

// Mount registers billing routes.
func (m *Module) Mount(r chi.Router) { m.handler.Mount(r) }

// NewSettlementPort returns the billing side of the order lifecycle.
func NewSettlementPort() orders.SettlementPort { return newSettlementPort() }
