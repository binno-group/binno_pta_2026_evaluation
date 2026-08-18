// Package analytics defines the shared event model and sink contract.
package analytics

import (
	"context"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
)

// EventSink is the dispatcher output port.
type EventSink interface {
	Send(ctx context.Context, batch []outbox.Record) error
}
