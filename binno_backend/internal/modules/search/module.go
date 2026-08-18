// Package search is the public offer discovery read model.
package search

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Module owns search endpoints.
type Module struct{ handler *Handler }

// New creates a search module.
func New(pool *postgres.Pool, clk clock.Clock, cache ...offerCache) *Module {
	return &Module{handler: NewHandler(NewService(NewRepository(pool, clk), cache...))}
}

// Mount registers search routes.
func (m *Module) Mount(r chi.Router) { m.handler.Mount(r) }
