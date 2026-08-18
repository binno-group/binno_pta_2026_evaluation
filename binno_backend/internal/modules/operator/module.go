// Package operator wires the analytics-backed operator queue module.
package operator

import (
	"context"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/operator/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// Module owns the operator HTTP surface.
type Module struct {
	handler *Handler
	ready   func(context.Context) error
}

// NewPostgres constructs the module against the analytics PostgreSQL pool.
func NewPostgres(pool *postgres.Pool) *Module {
	queries := store.New(pool)
	return &Module{
		handler: NewHandler(NewService(NewPostgresRepository(queries))),
		ready:   pool.Ping,
	}
}

// NewClickHouse constructs the module against ClickHouse.
func NewClickHouse(endpoint, database string, client *http.Client) (*Module, error) {
	repository, err := NewClickHouseRepository(endpoint, database, client)
	if err != nil {
		return nil, err
	}
	return &Module{
		handler: NewHandler(NewService(repository)),
		ready:   repository.Ping,
	}, nil
}

// Mount registers operator routes.
func (m *Module) Mount(r chi.Router) {
	m.handler.Mount(r)
}

// Ready verifies the selected analytics read target.
func (m *Module) Ready(ctx context.Context) error {
	return m.ready(ctx)
}
