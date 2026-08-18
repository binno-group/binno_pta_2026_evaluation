// Package catalog owns the platform product catalogue, seller offers and their
// stock, delivery tariffs and catalogue requests.
package catalog

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Module owns catalog and offer endpoints plus the order-line port.
type Module struct {
	handler *Handler
	port    *linePort
}

// New creates a catalog module.
func New(pool *postgres.Pool, guard authz.Guard, clk clock.Clock) *Module {
	return &Module{
		handler: NewHandler(NewService(NewRepository(pool, clk), guard, clk)),
		port:    newLinePort(pool),
	}
}

// Mount registers catalog routes.
func (m *Module) Mount(r chi.Router) {
	m.handler.Mount(r)
}

// OrderLines returns the pricing and reservation port consumed by the order
// module.
func (m *Module) OrderLines() OrderLinePort { return m.port }
