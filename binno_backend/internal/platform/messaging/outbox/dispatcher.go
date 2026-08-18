package outbox

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Record is one relayed outbox row, handed to a Sink.
type Record struct {
	ID           int64
	EventID      uuid.UUID
	Module       string
	EventName    string
	EventVersion int
	AggregateID  string
	Payload      json.RawMessage
	OccurredAt   time.Time
	AttemptCount int
}

// Sink delivers a batch of outbox records.
type Sink interface {
	Send(ctx context.Context, batch []Record) error
}

// Pruner is an optional capability a Sink may implement to bound its own
// retention.
type Pruner interface {
	// Prune removes events older than cutoff, up to batch of them, and reports how
	// many it removed.
	Prune(ctx context.Context, cutoff time.Time, batch int) (int64, error)
}

// PermanentSinkError marks record-specific data that retry cannot repair.
type PermanentSinkError struct {
	EventID uuid.UUID
	Err     error
}

// Error implements error.
func (e *PermanentSinkError) Error() string {
	return fmt.Sprintf("permanent sink error for %s: %v", e.EventID, e.Err)
}

// Unwrap exposes the validation cause.
func (e *PermanentSinkError) Unwrap() error {
	return e.Err
}

// DispatcherConfig holds the polling and lease parameters for a Dispatcher.
type DispatcherConfig struct {
	// Interval is how often a batch is relayed.
	Interval time.Duration
	// BatchSize caps how many rows one pass claims.
	BatchSize int
	// ClaimTTL is how long a claim stays valid before another dispatcher may
	// reclaim the row.
	ClaimTTL time.Duration
	// MaxAttempts moves a repeatedly failing individual event to dead-letter state.
	MaxAttempts int
	// RetryBase is the first exponential retry delay.
	RetryBase time.Duration
	// Retention controls how long successfully relayed rows remain in OLTP.
	Retention time.Duration
	// ReceiptRetention controls how long mutation receipts — the transactional
	// idempotency window — remain before cleanup.
	ReceiptRetention time.Duration
	// SinkRetention controls how long the read model keeps history, for sinks that
	// implement Pruner.
	SinkRetention time.Duration
	// CleanupBatch bounds each retention delete to avoid long vacuum-heavy
	// transactions.
	CleanupBatch int
	// Registerer receives the backlog gauges.
	Registerer prometheus.Registerer
	// MetricsInterval is how often the backlog gauges are refreshed.
	MetricsInterval time.Duration
}

// Dispatcher relays transactional outbox rows to a Sink.
type Dispatcher struct {
	pool        *postgres.Pool
	sink        Sink
	clock       clock.Clock
	logger      *slog.Logger
	cfg         DispatcherConfig
	pending     prometheus.Gauge
	deadLetters prometheus.Gauge

	// metricsMu guards nextMetricsAt.
	metricsMu     sync.Mutex
	nextMetricsAt time.Time

	// failureMu guards the repeated-failure log suppression below.
	failureMu     sync.Mutex
	lastFailure   string
	failureStreak int
	nextFailureAt time.Time
}

// logFailureInterval bounds how often an unchanged, repeating dispatch failure
// is logged.
const logFailureInterval = 30 * time.Second

// logFailure logs a relay failure, collapsing an unchanged error that repeats
// every tick into one line per logFailureInterval.
func (d *Dispatcher) logFailure(ctx context.Context, err error) {
	msg := err.Error()
	now := d.clock.Now()

	d.failureMu.Lock()
	changed := msg != d.lastFailure
	due := !now.Before(d.nextFailureAt)
	suppressed := d.failureStreak
	switch {
	case changed:
		d.lastFailure = msg
		d.failureStreak = 0
		d.nextFailureAt = now.Add(logFailureInterval)
	case due:
		d.failureStreak = 0
		d.nextFailureAt = now.Add(logFailureInterval)
	default:
		d.failureStreak++
	}
	d.failureMu.Unlock()

	if !changed && !due {
		return
	}
	if suppressed > 0 && !changed {
		d.logger.ErrorContext(ctx, "outbox dispatch failed", "err", err,
			"repeated", suppressed, "since", logFailureInterval.String())
		return
	}
	d.logger.ErrorContext(ctx, "outbox dispatch failed", "err", err)
}

// resetFailureLog clears suppression state after a successful pass, so the first
// failure of the next outage is logged immediately rather than being swallowed
// by a window opened during the previous one.
func (d *Dispatcher) resetFailureLog() {
	d.failureMu.Lock()
	d.lastFailure = ""
	d.failureStreak = 0
	d.nextFailureAt = time.Time{}
	d.failureMu.Unlock()
}

// NewDispatcher returns a Dispatcher reading from pool and relaying to sink.
func NewDispatcher(pool *postgres.Pool, sink Sink, c clock.Clock, logger *slog.Logger, cfg DispatcherConfig) *Dispatcher {
	if cfg.MaxAttempts < 1 {
		cfg.MaxAttempts = 1
	}
	if cfg.RetryBase <= 0 {
		cfg.RetryBase = time.Second
	}
	if cfg.Retention <= 0 {
		cfg.Retention = 7 * 24 * time.Hour
	}
	if cfg.ReceiptRetention <= 0 {
		cfg.ReceiptRetention = 48 * time.Hour
	}
	if cfg.CleanupBatch <= 0 {
		cfg.CleanupBatch = 1000
	}
	if cfg.MetricsInterval < time.Second {
		cfg.MetricsInterval = 30 * time.Second
	}
	registerer := cfg.Registerer
	if registerer == nil {
		registerer = prometheus.DefaultRegisterer
	}
	return &Dispatcher{
		pool:   pool,
		sink:   sink,
		clock:  c,
		logger: logger,
		cfg:    cfg,
		pending: registerGauge(registerer, logger, prometheus.GaugeOpts{
			Name: "binno_outbox_pending",
			Help: "Number of outbox events not yet relayed to the analytics sink.",
		}),
		deadLetters: registerGauge(registerer, logger, prometheus.GaugeOpts{
			Name: "binno_outbox_dead_letters",
			Help: "Number of outbox events isolated after bounded delivery failures.",
		}),
	}
}

// registerGauge registers opts, reusing an already-registered collector of the
// same name.
func registerGauge(registerer prometheus.Registerer, logger *slog.Logger, opts prometheus.GaugeOpts) prometheus.Gauge {
	gauge := prometheus.NewGauge(opts)
	err := registerer.Register(gauge)
	if err == nil {
		return gauge
	}
	var already prometheus.AlreadyRegisteredError
	if errors.As(err, &already) {
		if existing, ok := already.ExistingCollector.(prometheus.Gauge); ok {
			return existing
		}
	}
	logger.Warn("outbox: metric not registered; it will not be exported",
		"metric", opts.Name, "err", err)
	return gauge
}

// RunOnce claims up to BatchSize rows, relays them, and marks them dispatched.
func (d *Dispatcher) RunOnce(ctx context.Context) (int, error) {
	batch, err := d.claim(ctx)
	if err != nil {
		return 0, err
	}
	if len(batch) == 0 {
		d.cleanup(ctx)
		d.observePending(ctx)
		return 0, nil
	}

	relayed, relayErr := d.relay(ctx, batch)
	d.cleanup(ctx)
	d.observePending(ctx)
	return relayed, relayErr
}

// relay recursively isolates a failing batch.
func (d *Dispatcher) relay(ctx context.Context, batch []Record) (int, error) {
	err := d.sink.Send(ctx, batch)
	if err == nil {
		if err := d.markDispatched(ctx, batch); err != nil {
			return 0, err
		}
		return len(batch), nil
	}

	var permanent *PermanentSinkError
	if !errors.As(err, &permanent) {
		return 0, errors.Join(err, d.recordBatchFailure(ctx, batch, err))
	}
	if len(batch) == 1 {
		if failureErr := d.recordFailure(ctx, batch[0], err); failureErr != nil {
			return 0, errors.Join(err, failureErr)
		}
		return 0, fmt.Errorf("outbox: relay event %s: %w", batch[0].EventID, err)
	}

	middle := len(batch) / 2
	leftCount, leftErr := d.relay(ctx, batch[:middle])
	rightCount, rightErr := d.relay(ctx, batch[middle:])
	return leftCount + rightCount, errors.Join(leftErr, rightErr)
}

func (d *Dispatcher) recordBatchFailure(ctx context.Context, batch []Record, relayErr error) error {
	var failures []error
	for _, record := range batch {
		if err := d.recordFailure(ctx, record, relayErr); err != nil {
			failures = append(failures, err)
		}
	}
	return errors.Join(failures...)
}

// claim leases a batch of rows to this dispatcher in one short transaction.
func (d *Dispatcher) claim(ctx context.Context) ([]Record, error) {
	tx, err := d.pool.Begin(ctx)
	if err != nil {
		return nil, fmt.Errorf("outbox: begin claim tx: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	rows, err := tx.Query(ctx, `
		UPDATE platform.outbox SET claimed_at = $1
		WHERE id IN (
			SELECT candidate.id FROM platform.outbox AS candidate
			WHERE candidate.dispatched_at IS NULL
			  AND candidate.dead_lettered_at IS NULL
			  AND (candidate.next_attempt_at IS NULL OR candidate.next_attempt_at <= $1)
			  AND (candidate.claimed_at IS NULL OR candidate.claimed_at < $2)
			  AND NOT EXISTS (
			      SELECT 1
			      FROM platform.outbox AS prior
			      WHERE prior.aggregate_id = candidate.aggregate_id
			        AND prior.id < candidate.id
			        AND prior.dispatched_at IS NULL
			        AND prior.dead_lettered_at IS NULL
			  )
			ORDER BY candidate.id
			LIMIT $3
			FOR UPDATE SKIP LOCKED
		)
		RETURNING id, event_id, module, event_name, event_version, aggregate_id,
		          payload, occurred_at, attempt_count`,
		d.clock.Now(), d.clock.Now().Add(-d.cfg.ClaimTTL), d.cfg.BatchSize)
	if err != nil {
		return nil, fmt.Errorf("outbox: claim pending rows: %w", err)
	}

	var batch []Record
	for rows.Next() {
		var rec Record
		if err := rows.Scan(&rec.ID, &rec.EventID, &rec.Module, &rec.EventName, &rec.EventVersion,
			&rec.AggregateID, &rec.Payload, &rec.OccurredAt, &rec.AttemptCount); err != nil {
			rows.Close()
			return nil, fmt.Errorf("outbox: scan claimed row: %w", err)
		}
		batch = append(batch, rec)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("outbox: iterate claimed rows: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, fmt.Errorf("outbox: commit claim tx: %w", err)
	}
	return batch, nil
}

func (d *Dispatcher) cleanup(ctx context.Context) {
	cutoff := d.clock.Now().Add(-d.cfg.Retention)
	if _, err := d.pool.Exec(ctx, `
		DELETE FROM platform.outbox
		WHERE id IN (
			SELECT id FROM platform.outbox
			WHERE dispatched_at < $1
			ORDER BY dispatched_at
			LIMIT $2
		)`, cutoff, d.cfg.CleanupBatch); err != nil {
		d.logger.ErrorContext(ctx, "outbox retention cleanup failed", "err", err)
	}
	if _, err := d.pool.Exec(ctx, `
		DELETE FROM platform.mutation_receipts
		WHERE operation_key IN (
			SELECT operation_key FROM platform.mutation_receipts
			WHERE created_at < $1
			ORDER BY created_at
			LIMIT $2
		)`, d.clock.Now().Add(-d.cfg.ReceiptRetention), d.cfg.CleanupBatch); err != nil {
		d.logger.ErrorContext(ctx, "mutation receipt cleanup failed", "err", err)
	}

	pruner, ok := d.sink.(Pruner)
	if !ok || d.cfg.SinkRetention <= 0 {
		return
	}
	removed, err := pruner.Prune(ctx, d.clock.Now().Add(-d.cfg.SinkRetention), d.cfg.CleanupBatch)
	switch {
	case err != nil:
		d.logger.ErrorContext(ctx, "sink retention cleanup failed", "err", err)
	case removed > 0:
		d.logger.InfoContext(ctx, "sink retention pruned events",
			"removed", removed, "older_than", d.cfg.SinkRetention.String())
	}
}

func (d *Dispatcher) markDispatched(ctx context.Context, batch []Record) error {
	ids := make([]int64, len(batch))
	for i, rec := range batch {
		ids[i] = rec.ID
	}
	if _, err := d.pool.Exec(ctx,
		`UPDATE platform.outbox SET dispatched_at = $1 WHERE id = ANY($2)`,
		d.clock.Now(), ids); err != nil {
		return fmt.Errorf("outbox: mark dispatched: %w", err)
	}
	return nil
}

func (d *Dispatcher) recordFailure(ctx context.Context, record Record, relayErr error) error {
	attempts := record.AttemptCount + 1
	deadLetter := attempts >= d.cfg.MaxAttempts
	delayMillis := d.retryDelay(attempts).Milliseconds()
	message := relayErr.Error()
	if len(message) > 2000 {
		message = message[:2000]
	}

	_, err := d.pool.Exec(ctx, `
		UPDATE platform.outbox
		SET attempt_count = $2,
		    last_error = $3,
		    claimed_at = NULL,
		    next_attempt_at = CASE
		        WHEN $4 THEN NULL
		        ELSE $1::timestamptz + ($5::bigint * interval '1 millisecond')
		    END,
		    dead_lettered_at = CASE WHEN $4 THEN $1::timestamptz ELSE NULL END
		WHERE id = $6`,
		d.clock.Now(), attempts, message, deadLetter, delayMillis, record.ID)
	if err != nil {
		return fmt.Errorf("outbox: record delivery failure for %s: %w", record.EventID, err)
	}
	if deadLetter {
		d.logger.ErrorContext(ctx, "outbox event dead-lettered",
			"event_id", record.EventID,
			"event_name", record.EventName,
			"attempts", attempts,
			"err", relayErr,
		)
	}
	return nil
}

func (d *Dispatcher) retryDelay(attempt int) time.Duration {
	exponent := attempt - 1
	if exponent > 10 {
		exponent = 10
	}
	delay := d.cfg.RetryBase * time.Duration(1<<exponent)
	if delay > time.Hour {
		return time.Hour
	}
	return delay
}

// Run relays a batch every Interval until ctx is canceled.
func (d *Dispatcher) Run(ctx context.Context, drainCtx context.Context) {
	ticker := time.NewTicker(d.cfg.Interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			d.drain(drainCtx)
			return
		case <-ticker.C:
			if _, err := d.RunOnce(ctx); err != nil && !errors.Is(err, context.Canceled) {
				d.logFailure(ctx, err)
			} else if err == nil {
				d.resetFailureLog()
			}
		}
	}
}

// drain relays whatever is already pending so a rolling restart does not leave
// events sitting until the replacement process starts polling.
func (d *Dispatcher) drain(ctx context.Context) {
	relayed, err := d.RunOnce(ctx)
	if err != nil {
		d.logger.ErrorContext(ctx, "outbox drain failed", "err", err)
		return
	}
	d.logger.InfoContext(ctx, "outbox drained", "relayed", relayed)
}

// observePending refreshes the backlog gauges, at most once per MetricsInterval.
func (d *Dispatcher) observePending(ctx context.Context) {
	now := d.clock.Now()
	d.metricsMu.Lock()
	if now.Before(d.nextMetricsAt) {
		d.metricsMu.Unlock()
		return
	}
	d.nextMetricsAt = now.Add(d.cfg.MetricsInterval)
	d.metricsMu.Unlock()

	var pending, deadLetters int64
	if err := d.pool.QueryRow(ctx,
		`SELECT
		    count(*) FILTER (WHERE dispatched_at IS NULL AND dead_lettered_at IS NULL),
		    count(*) FILTER (WHERE dead_lettered_at IS NOT NULL)
		 FROM platform.outbox`).Scan(&pending, &deadLetters); err != nil {
		d.logger.ErrorContext(ctx, "outbox: count pending failed", "err", err)
		return
	}
	d.pending.Set(float64(pending))
	d.deadLetters.Set(float64(deadLetters))
}
