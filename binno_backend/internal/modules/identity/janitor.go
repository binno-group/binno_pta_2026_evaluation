package identity

import (
	"context"
	"errors"
	"log/slog"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// JanitorConfig tunes the expired-session cleanup.
type JanitorConfig struct {
	// Batch caps how many rows one delete removes, so cleanup never holds a long
	// snapshot on a table that grows with every login.
	Batch int32
}

type sessionPruner interface {
	PruneExpiredSessions(ctx context.Context, cutoff time.Time, batch int32) (int64, error)
}

// Janitor bounds the refresh-token table by deleting rows past their expiry.
type Janitor struct {
	sessions sessionPruner
	clock    clock.Clock
	logger   *slog.Logger
	cfg      JanitorConfig
}

// NewJanitor returns the session janitor.
func NewJanitor(sessions sessionPruner, clk clock.Clock, logger *slog.Logger, cfg JanitorConfig) *Janitor {
	if cfg.Batch <= 0 {
		cfg.Batch = 1000
	}
	return &Janitor{sessions: sessions, clock: clk, logger: logger, cfg: cfg}
}

// RunOnce deletes expired sessions until a batch comes back short.
func (j *Janitor) RunOnce(ctx context.Context) (int64, error) {
	var pruned int64
	for {
		removed, err := j.sessions.PruneExpiredSessions(ctx, j.clock.Now(), j.cfg.Batch)
		pruned += removed
		if err != nil {
			return pruned, err
		}
		if removed < int64(j.cfg.Batch) {
			return pruned, nil
		}
	}
}

// Run prunes every interval until ctx is canceled.
func (j *Janitor) Run(ctx context.Context, interval time.Duration) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			pruned, err := j.RunOnce(ctx)
			if err != nil && !errors.Is(err, context.Canceled) {
				j.logger.ErrorContext(ctx, "session cleanup failed", "err", err)
			}
			if pruned > 0 {
				j.logger.InfoContext(ctx, "expired sessions pruned", "removed", pruned)
			}
		}
	}
}
