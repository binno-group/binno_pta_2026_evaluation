// Package trust owns binary, transaction-bound feedback on completed orders.
package trust

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Module owns trust endpoints.
type Module struct{ handler *Handler }

// New creates a trust module.
func New(pool *postgres.Pool, summaries orders.SummaryPort, clk clock.Clock) *Module {
	return &Module{handler: NewHandler(NewService(NewRepository(pool, clk), summaries, clk))}
}

// Mount registers trust routes.
func (m *Module) Mount(r chi.Router) { m.handler.Mount(r) }
