// Package api assembles the public HTTP modules and wires the contracts they
// share.
package api

import (
	"log/slog"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/identity"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/search"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/trust"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

type routeModule interface {
	Mount(chi.Router)
}

// Module owns the non-operator public API modules.
type Module struct {
	modules  []routeModule
	orders   *orders.Module
	identity *identity.Module
	pool     *postgres.Pool
	clock    clock.Clock
}

// AuthDeps are the collaborators the identity module needs.
type AuthDeps struct {
	Codes  *otp.Store
	Sender sms.Sender
	Signer *httpx.Signer
	// ConfirmLinkBase is the public URL prefix order-confirmation SMS embed.
	ConfirmLinkBase string
}

// New creates the public API module graph.
func New(
	pool, readPool *postgres.Pool, clk clock.Clock,
	auth *AuthDeps, searchCache *search.RedisCache,
) *Module {
	if readPool == nil {
		readPool = pool
	}
	locationModule := location.New(pool)
	guard := locationModule.Guard()

	var notifier *orders.SMSNotifier
	if auth != nil && auth.Sender != nil {
		notifier = orders.NewSMSNotifier(auth.Sender, auth.ConfirmLinkBase, slog.Default())
	}

	catalogModule := catalog.New(pool, guard, clk)
	ordersModule := orders.New(
		pool, catalogModule.OrderLines(), locationModule.SaleGate(),
		billing.NewSettlementPort(), notifier, guard, clk,
	)

	searchModule := search.New(readPool, clk)
	if searchCache != nil {
		searchModule = search.New(readPool, clk, searchCache)
	}

	mounted := []routeModule{
		searchModule,
		locationModule,
		catalogModule,
		ordersModule,
		billing.New(pool, ordersModule.Summaries(), guard, clk),
		trust.New(pool, ordersModule.Summaries(), clk),
	}

	module := &Module{orders: ordersModule, pool: pool, clock: clk}
	if auth != nil {
		module.identity = identity.New(pool, auth.Codes, auth.Sender, auth.Signer, clk)
		mounted = append(mounted, module.identity)
	}
	module.modules = mounted
	return module
}

// Mount registers public API routes.
func (m *Module) Mount(r chi.Router) {
	for _, module := range m.modules {
		module.Mount(r)
	}
}

// OrderSweeper returns the supplier-confirmation and payment SLA sweeper.
func (m *Module) OrderSweeper(logger *slog.Logger, cfg orders.SweeperConfig) *orders.Sweeper {
	return m.orders.Sweeper(logger, cfg)
}

// SessionJanitor returns the expired-session cleanup job.
func (m *Module) SessionJanitor(logger *slog.Logger, cfg identity.JanitorConfig) *identity.Janitor {
	return identity.NewJanitor(identity.NewRepository(m.pool), m.clock, logger, cfg)
}

// CommissionRollup returns the monthly commission statement job.
func (m *Module) CommissionRollup(logger *slog.Logger, cfg billing.RollupConfig) *billing.Rollup {
	return billing.NewRollup(m.pool, m.clock, logger, cfg)
}

// RefundSweeper returns the refund SLA sweeper, wired to move the owning
// order to refund_overdue alongside the billing-side flip.
func (m *Module) RefundSweeper(logger *slog.Logger, cfg billing.RefundSweepConfig) *billing.RefundSweeper {
	cfg.OnOverdue = m.orders.RefundOverdue
	return billing.NewRefundSweeper(m.pool, m.clock, logger, cfg)
}
