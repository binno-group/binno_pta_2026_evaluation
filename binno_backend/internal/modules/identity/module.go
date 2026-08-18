// Package identity owns authentication: phone + SMS OTP in, tokens out.
package identity

import (
	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// Module owns the authentication endpoints.
type Module struct {
	handler    *Handler
	repository *Repository
}

// New creates the identity module.
func New(pool *postgres.Pool, codes *otp.Store, sender sms.Sender, signer *httpx.Signer, clk clock.Clock) *Module {
	repository := NewRepository(pool)
	return &Module{
		handler:    NewHandler(NewService(repository, codes, sender, signer, clk)),
		repository: repository,
	}
}

// Mount registers the authentication routes.
func (m *Module) Mount(r chi.Router) { m.handler.Mount(r) }

// Sessions exposes session maintenance to the scheduled worker.
func (m *Module) Sessions() *Repository { return m.repository }
