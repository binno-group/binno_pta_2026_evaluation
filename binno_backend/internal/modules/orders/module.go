// Package orders owns the order aggregate and its lifecycle.
package orders

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Module owns order endpoints, the SLA sweeper and the order summary port.
type Module struct {
	handler    *Handler
	service    *Service
	repository *Repository
	clock      clock.Clock
}

// New creates an order module. notify may be nil when the process has no SMS
// delivery (the dispatcher).
func New(
	pool *postgres.Pool,
	lines catalog.OrderLinePort,
	saleGate location.SaleGatePort,
	settlement SettlementPort,
	notify *SMSNotifier,
	guard authz.Guard,
	clk clock.Clock,
) *Module {
	repository := NewRepository(pool, lines, saleGate, settlement, notify, clk)
	service := NewService(repository, guard, clk)
	return &Module{
		handler:    NewHandler(service),
		service:    service,
		repository: repository,
		clock:      clk,
	}
}

// Mount registers order routes.
func (m *Module) Mount(r chi.Router) { m.handler.Mount(r) }

// Summaries returns the cross-module order read surface.
func (m *Module) Summaries() SummaryPort { return m.service }

// Sweeper returns the supplier-confirmation SLA sweeper, to be run by a
// background process rather than by the API.
func (m *Module) Sweeper(logger *slog.Logger, cfg SweeperConfig) *Sweeper {
	return NewSweeper(m.repository, m.clock, logger, cfg)
}

// RefundOverdue applies the system refund-overdue transition for one order.
// It is called by the refund SLA sweep through cmd/dispatcher composition,
// never over HTTP; an order that already moved on is not an error.
func (m *Module) RefundOverdue(ctx context.Context, orderID string, dueAt time.Time) error {
	ctx = httpx.WithOperationKey(ctx,
		fmt.Sprintf("orders:refund_overdue:%s:%d", orderID, dueAt.Unix()))
	err := m.repository.Apply(ctx, TransitionCommand{
		OrderID: orderID, Trigger: TriggerRefundOverdue, At: m.clock.Now(),
	})
	if errors.Is(err, ErrConflict) || errors.Is(err, ErrNotFound) {
		return nil
	}
	return err
}
