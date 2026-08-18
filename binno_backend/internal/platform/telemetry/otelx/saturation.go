package otelx

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/redis/go-redis/v9"
)

// This file is the USE half of the dashboard: Utilization and Saturation of the
// resources a request depends on.

// PoolStats is the snapshot a connection-pool collector needs.
type PoolStats struct {
	// Acquired is connections currently checked out by callers.
	Acquired int32
	// Idle is established connections sitting unused.
	Idle int32
	// Total is Acquired + Idle + connections still being constructed.
	Total int32
	// Max is the configured ceiling.
	Max int32
	// AcquireWaitTotal is cumulative time callers have spent waiting for a free
	// connection.
	AcquireWaitTotal time.Duration
	// EmptyAcquireTotal counts acquisitions that had to wait because the pool was
	// exhausted.
	EmptyAcquireTotal int64
	// CanceledAcquireTotal counts acquisitions abandoned because the caller's
	// context expired first: the pool-level view of a shed request.
	CanceledAcquireTotal int64
}

// NewPoolCollector publishes pool utilization for one named pool.
func NewPoolCollector(pool string, snapshot func() PoolStats) prometheus.Collector {
	labels := prometheus.Labels{"pool": pool}
	return &poolCollector{
		snapshot: snapshot,
		acquired: prometheus.NewDesc("binno_db_pool_acquired_connections",
			"Connections currently checked out of the pool.", nil, labels),
		idle: prometheus.NewDesc("binno_db_pool_idle_connections",
			"Established connections sitting unused.", nil, labels),
		total: prometheus.NewDesc("binno_db_pool_total_connections",
			"Connections currently established or being constructed.", nil, labels),
		max: prometheus.NewDesc("binno_db_pool_max_connections",
			"Configured connection ceiling for the pool.", nil, labels),
		waitSeconds: prometheus.NewDesc("binno_db_pool_acquire_wait_seconds_total",
			"Cumulative time callers spent waiting for a free connection.", nil, labels),
		empty: prometheus.NewDesc("binno_db_pool_empty_acquire_total",
			"Acquisitions that had to wait because the pool was exhausted.", nil, labels),
		canceled: prometheus.NewDesc("binno_db_pool_canceled_acquire_total",
			"Acquisitions abandoned because the caller's context expired first.", nil, labels),
	}
}

type poolCollector struct {
	snapshot                     func() PoolStats
	acquired, idle, total, max   *prometheus.Desc
	waitSeconds, empty, canceled *prometheus.Desc
}

func (c *poolCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- c.acquired
	ch <- c.idle
	ch <- c.total
	ch <- c.max
	ch <- c.waitSeconds
	ch <- c.empty
	ch <- c.canceled
}

func (c *poolCollector) Collect(ch chan<- prometheus.Metric) {
	s := c.snapshot()
	g := func(d *prometheus.Desc, v float64) {
		ch <- prometheus.MustNewConstMetric(d, prometheus.GaugeValue, v)
	}
	cnt := func(d *prometheus.Desc, v float64) {
		ch <- prometheus.MustNewConstMetric(d, prometheus.CounterValue, v)
	}
	g(c.acquired, float64(s.Acquired))
	g(c.idle, float64(s.Idle))
	g(c.total, float64(s.Total))
	g(c.max, float64(s.Max))
	cnt(c.waitSeconds, s.AcquireWaitTotal.Seconds())
	cnt(c.empty, float64(s.EmptyAcquireTotal))
	cnt(c.canceled, float64(s.CanceledAcquireTotal))
}

// RedisPoolStats is the snapshot a Redis pool collector needs.
type RedisPoolStats struct {
	Total, Idle, Stale uint32
	Hits, Misses       uint32
	// Timeouts counts waits that gave up because the pool stayed full.
	Timeouts uint32
	Max      int
}

// NewRedisPoolCollector publishes Redis connection-pool utilization.
func NewRedisPoolCollector(snapshot func() RedisPoolStats) prometheus.Collector {
	return &redisPoolCollector{
		snapshot: snapshot,
		total: prometheus.NewDesc("binno_redis_pool_total_connections",
			"Redis connections currently established.", nil, nil),
		idle: prometheus.NewDesc("binno_redis_pool_idle_connections",
			"Redis connections sitting unused.", nil, nil),
		max: prometheus.NewDesc("binno_redis_pool_max_connections",
			"Configured Redis connection ceiling.", nil, nil),
		timeouts: prometheus.NewDesc("binno_redis_pool_timeout_total",
			"Waits for a Redis connection that gave up because the pool stayed full.", nil, nil),
		poolMiss: prometheus.NewDesc("binno_redis_pool_miss_total",
			"Connection requests that found no free connection in the pool.", nil, nil),
	}
}

type redisPoolCollector struct {
	snapshot                             func() RedisPoolStats
	total, idle, max, timeouts, poolMiss *prometheus.Desc
}

func (c *redisPoolCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- c.total
	ch <- c.idle
	ch <- c.max
	ch <- c.timeouts
	ch <- c.poolMiss
}

func (c *redisPoolCollector) Collect(ch chan<- prometheus.Metric) {
	s := c.snapshot()
	ch <- prometheus.MustNewConstMetric(c.total, prometheus.GaugeValue, float64(s.Total))
	ch <- prometheus.MustNewConstMetric(c.idle, prometheus.GaugeValue, float64(s.Idle))
	ch <- prometheus.MustNewConstMetric(c.max, prometheus.GaugeValue, float64(s.Max))
	ch <- prometheus.MustNewConstMetric(c.timeouts, prometheus.CounterValue, float64(s.Timeouts))
	ch <- prometheus.MustNewConstMetric(c.poolMiss, prometheus.CounterValue, float64(s.Misses))
}

// Admission publishes the state of the in-flight semaphore.
type Admission struct {
	inFlight prometheus.Gauge
	limit    prometheus.Gauge
	shed     *prometheus.CounterVec
}

// NewAdmission registers the admission-control series.
func NewAdmission(limit int) *Admission {
	a := &Admission{
		inFlight: promauto.NewGauge(prometheus.GaugeOpts{
			Name: "binno_http_in_flight_requests",
			Help: "Business requests currently holding an admission-control slot.",
		}),
		limit: promauto.NewGauge(prometheus.GaugeOpts{
			Name: "binno_http_in_flight_limit",
			Help: "Configured concurrent-request ceiling (HTTP_MAX_IN_FLIGHT).",
		}),
		shed: promauto.NewCounterVec(prometheus.CounterOpts{
			Name: "binno_http_shed_total",
			Help: "Requests refused before handling, by reason.",
		}, []string{"reason"}),
	}
	a.limit.Set(float64(limit))
	a.shed.WithLabelValues("at_capacity")
	return a
}

// Admitted reports that a request took a slot.
func (a *Admission) Admitted() {
	if a != nil {
		a.inFlight.Inc()
	}
}

// Released reports that a request gave its slot back.
func (a *Admission) Released() {
	if a != nil {
		a.inFlight.Dec()
	}
}

// Shed reports a request refused because the instance was at capacity.
func (a *Admission) Shed() {
	if a != nil {
		a.shed.WithLabelValues("at_capacity").Inc()
	}
}

// dependencyLatency is the per-dependency call latency every request pays.
var dependencyLatency = promauto.NewHistogramVec(prometheus.HistogramOpts{
	Name: "binno_dependency_duration_seconds",
	Help: "Duration of a single call to an external dependency, by dependency and outcome.",
	// Tighter than DefBuckets at the short end: these calls are expected in the
	// sub-millisecond to low-millisecond range, and DefBuckets' first bucket (5ms)
	// would put almost every healthy call in one bin.
	Buckets: []float64{
		0.0005, 0.001, 0.0025, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5,
	},
}, []string{"dependency", "outcome"})

// ObserveDependency records one dependency call.
func ObserveDependency(dependency string, d time.Duration, err error) {
	outcome := "ok"
	if err != nil {
		outcome = "error"
	}
	dependencyLatency.WithLabelValues(dependency, outcome).Observe(d.Seconds())
}

// NewQueryTracer instruments every pgx query with its duration.
func NewQueryTracer(dependency string) pgx.QueryTracer {
	return &queryTracer{dependency: dependency}
}

type queryTracer struct{ dependency string }

type queryStartedAt struct{}

func (t *queryTracer) TraceQueryStart(
	ctx context.Context, _ *pgx.Conn, _ pgx.TraceQueryStartData,
) context.Context {
	return context.WithValue(ctx, queryStartedAt{}, time.Now())
}

func (t *queryTracer) TraceQueryEnd(
	ctx context.Context, _ *pgx.Conn, data pgx.TraceQueryEndData,
) {
	start, ok := ctx.Value(queryStartedAt{}).(time.Time)
	if !ok {
		return
	}
	ObserveDependency(t.dependency, time.Since(start), data.Err)
}

// NewRedisHook instruments every Redis command with its duration.
func NewRedisHook() redis.Hook { return redisHook{} }

type redisHook struct{}

func (redisHook) DialHook(next redis.DialHook) redis.DialHook { return next }

func (redisHook) ProcessHook(next redis.ProcessHook) redis.ProcessHook {
	return func(ctx context.Context, cmd redis.Cmder) error {
		start := time.Now()
		err := next(ctx, cmd)
		observed := err
		if observed == redis.Nil {
			observed = nil
		}
		ObserveDependency("redis", time.Since(start), observed)
		return err
	}
}

func (redisHook) ProcessPipelineHook(next redis.ProcessPipelineHook) redis.ProcessPipelineHook {
	return func(ctx context.Context, cmds []redis.Cmder) error {
		start := time.Now()
		err := next(ctx, cmds)
		ObserveDependency("redis_pipeline", time.Since(start), err)
		return err
	}
}

// cacheOutcome counts read-through cache hits and misses.
var cacheOutcome = promauto.NewCounterVec(prometheus.CounterOpts{
	Name: "binno_cache_lookups_total",
	Help: "Read-through cache lookups by cache name and outcome.",
}, []string{"cache", "outcome"})

// ObserveCache records one cache lookup.
func ObserveCache(cache string, hit bool) {
	outcome := "miss"
	if hit {
		outcome = "hit"
	}
	cacheOutcome.WithLabelValues(cache, outcome).Inc()
}

// stockNoop counts stock adjustments that matched no offer row. The order
// state machine drives each adjustment exactly once, so a zero-row release or
// consume is always accounting drift and worth an immediate alert.
var stockNoop = promauto.NewCounterVec(prometheus.CounterOpts{
	Name: "binno_stock_adjust_noop_total",
	Help: "Stock adjustments (release/consume) that matched no offer row.",
}, []string{"op"})

// ObserveStockNoop records one zero-row stock adjustment.
func ObserveStockNoop(op string) {
	stockNoop.WithLabelValues(op).Inc()
}

// NewRedisBreakerCollector publishes whether Redis calls are being short-
// circuited.
func NewRedisBreakerCollector(open func() bool) prometheus.Collector {
	desc := prometheus.NewDesc("binno_redis_circuit_open",
		"1 while Redis calls are short-circuited by the breaker, 0 otherwise.", nil, nil)
	return &redisBreakerCollector{open: open, desc: desc}
}

type redisBreakerCollector struct {
	open func() bool
	desc *prometheus.Desc
}

func (c *redisBreakerCollector) Describe(ch chan<- *prometheus.Desc) { ch <- c.desc }

func (c *redisBreakerCollector) Collect(ch chan<- prometheus.Metric) {
	value := 0.0
	if c.open() {
		value = 1
	}
	ch <- prometheus.MustNewConstMetric(c.desc, prometheus.GaugeValue, value)
}
