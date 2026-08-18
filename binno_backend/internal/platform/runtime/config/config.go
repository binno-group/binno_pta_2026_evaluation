// Package config loads process configuration from the environment only,
// validated at boot so the process fails fast instead of misbehaving at runtime.
package config

import (
	"context"
	"fmt"
	"time"

	"github.com/sethvargo/go-envconfig"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// Config is the full set of environment-driven settings for cmd/binno and
// cmd/dispatcher.
type Config struct {
	Env      string `env:"ENV,default=development"`
	HTTPAddr string `env:"HTTP_ADDR,default=:8080"`
	// HTTPTimeout is the per-request server budget.
	HTTPTimeout     time.Duration `env:"HTTP_TIMEOUT,default=2s"`
	ShutdownTimeout time.Duration `env:"SHUTDOWN_TIMEOUT,default=30s"`
	// ShutdownDrainDelay is how long the listener stays open after /readyz starts
	// failing.
	ShutdownDrainDelay time.Duration `env:"SHUTDOWN_DRAIN_DELAY,default=5s"`
	// TrustedProxyCIDRs names the reverse proxies allowed to speak for the client
	// through X-Forwarded-For.
	TrustedProxyCIDRs []string `env:"TRUSTED_PROXY_CIDRS"`
	// HTTPMaxInFlight caps concurrent business requests before they reach a
	// handler: 0 derives it from OLTPMaxConns, a positive value is used as-is,
	// and a negative value disables admission control entirely.
	HTTPMaxInFlight int `env:"HTTP_MAX_IN_FLIGHT,default=0"`
	// HTTPInFlightPerConn is how many requests may be in flight per database
	// connection when HTTPMaxInFlight is derived.
	HTTPInFlightPerConn int `env:"HTTP_MAX_IN_FLIGHT_PER_CONN,default=4"`

	OLTPDatabaseURL string `env:"OLTP_DATABASE_URL,required"`
	OLTPMaxConns    int32  `env:"OLTP_MAX_CONNS,default=20"`
	// OLTPReadDatabaseURL points read-only modules at a replica.
	OLTPReadDatabaseURL string `env:"OLTP_READ_DATABASE_URL"`
	// OLTPReadMaxConns sizes the replica pool.
	OLTPReadMaxConns     int32  `env:"OLTP_READ_MAX_CONNS,default=20"`
	AnalyticsDatabaseURL string `env:"ANALYTICS_DATABASE_URL"`
	AnalyticsMaxConns    int32  `env:"ANALYTICS_MAX_CONNS,default=10"`
	AnalyticsTarget      string `env:"ANALYTICS_TARGET,default=postgres"`
	ClickHouseEnabled    bool   `env:"CLICKHOUSE_ENABLED,default=false"`
	ClickHouseURL        string `env:"CLICKHOUSE_URL"`
	ClickHouseDatabase   string `env:"CLICKHOUSE_DATABASE,default=analytics"`
	// StatementTimeout must be strictly below HTTPTimeout.
	StatementTimeout time.Duration `env:"DB_STATEMENT_TIMEOUT,default=1500ms"`

	RedisAddr     string `env:"REDIS_ADDR,required"`
	RedisPassword string `env:"REDIS_PASSWORD"`
	RedisDB       int    `env:"REDIS_DB,default=0"`
	// RedisTimeout bounds one dial, read or write.
	RedisTimeout  time.Duration `env:"REDIS_TIMEOUT,default=500ms"`
	RedisPoolSize int           `env:"REDIS_POOL_SIZE,default=32"`
	// SearchCacheTTL bounds how stale a cached search ranking may be.
	SearchCacheTTL time.Duration `env:"SEARCH_CACHE_TTL,default=0"`

	JWTSigningKey string `env:"JWT_SIGNING_KEY,required"`
	// AccessTokenTTL is how long an issued access token is accepted.
	AccessTokenTTL time.Duration `env:"ACCESS_TOKEN_TTL,default=15m"`
	// SMSProvider selects the delivery adapter; see sms.Providers().
	SMSProvider string `env:"SMS_PROVIDER,default=log"`
	// SMSTimeout bounds one gateway call.
	SMSTimeout time.Duration `env:"SMS_TIMEOUT,default=1500ms"`
	// Eskiz (notify.eskiz.uz).
	EskizBaseURL  string `env:"SMS_ESKIZ_BASE_URL"`
	EskizEmail    string `env:"SMS_ESKIZ_EMAIL"`
	EskizPassword string `env:"SMS_ESKIZ_PASSWORD"`
	// EskizFrom is the sender name.
	EskizFrom string `env:"SMS_ESKIZ_FROM"`
	// Play Mobile broker.
	PlayMobileBaseURL    string `env:"SMS_PLAYMOBILE_BASE_URL"`
	PlayMobileLogin      string `env:"SMS_PLAYMOBILE_LOGIN"`
	PlayMobilePassword   string `env:"SMS_PLAYMOBILE_PASSWORD"`
	PlayMobileOriginator string `env:"SMS_PLAYMOBILE_ORIGINATOR"`

	OTLPEndpoint string `env:"OTLP_ENDPOINT"`
	MetricsAddr  string `env:"METRICS_ADDR,default=:9090"`
	// DispatchInterval and DispatchBatch set the relay ceiling at
	// BatchSize/Interval events per second, and nothing on the write path respects
	// that ceiling.
	DispatchInterval    time.Duration `env:"DISPATCH_INTERVAL,default=500ms"`
	DispatchBatch       int           `env:"DISPATCH_BATCH_SIZE,default=500"`
	DispatchMaxAttempts int           `env:"DISPATCH_MAX_ATTEMPTS,default=8"`
	DispatchRetryBase   time.Duration `env:"DISPATCH_RETRY_BASE,default=2s"`
	OutboxRetention     time.Duration `env:"OUTBOX_RETENTION,default=168h"`
	OutboxCleanupBatch  int           `env:"OUTBOX_CLEANUP_BATCH,default=1000"`
	// AnalyticsRetention bounds how far back the analytics read model keeps events.
	AnalyticsRetention time.Duration `env:"ANALYTICS_RETENTION,default=4320h"`
	// DispatchClaimTTL is how long a dispatcher's claim on an outbox row stays
	// valid.
	DispatchClaimTTL time.Duration `env:"DISPATCH_CLAIM_TTL,default=1m"`
	// MutationReceiptRetention bounds the transactional idempotency window: a
	// mutation key replayed after this window creates a new resource. Must
	// cover the Redis response cache (24h) and every sweeper's dedup cycle.
	MutationReceiptRetention time.Duration `env:"MUTATION_RECEIPT_RETENTION,default=48h"`
	// OutboxMetricsInterval is how often the backlog gauges are sampled.
	OutboxMetricsInterval time.Duration `env:"OUTBOX_METRICS_INTERVAL,default=30s"`

	// Rate limiting.
	RateLimitWindow             time.Duration `env:"RATE_LIMIT_WINDOW,default=1m"`
	RateLimitAuthenticatedBurst int64         `env:"RATE_LIMIT_AUTHENTICATED_BURST,default=300"`
	RateLimitAnonymousBurst     int64         `env:"RATE_LIMIT_ANONYMOUS_BURST,default=60"`

	// Supplier confirmation SLA sweeper, run by cmd/dispatcher.
	SweepInterval    time.Duration `env:"ORDER_SWEEP_INTERVAL,default=1m"`
	SweepBatch       int32         `env:"ORDER_SWEEP_BATCH,default=100"`
	SweepExpiryGrace time.Duration `env:"ORDER_SWEEP_EXPIRY_GRACE,default=2h"`

	// Expired-session cleanup, run by cmd/dispatcher.
	SessionPruneInterval time.Duration `env:"SESSION_PRUNE_INTERVAL,default=1h"`
	SessionPruneBatch    int32         `env:"SESSION_PRUNE_BATCH,default=1000"`

	// Monthly commission statement job, run by cmd/dispatcher.
	CommissionRollupInterval time.Duration `env:"COMMISSION_ROLLUP_INTERVAL,default=1h"`
	CommissionRollupBatch    int32         `env:"COMMISSION_ROLLUP_BATCH,default=50"`

	// Refund SLA sweeper, run by cmd/dispatcher.
	RefundSweepInterval time.Duration `env:"REFUND_SWEEP_INTERVAL,default=5m"`
	RefundSweepBatch    int32         `env:"REFUND_SWEEP_BATCH,default=100"`

	// ConfirmLinkBase is the public URL prefix embedded in order-confirmation
	// SMS sent to stores.
	ConfirmLinkBase string `env:"CONFIRM_LINK_BASE,default=https://binno.uz/confirm"`
}

// Load reads and validates Config from the environment.
func Load(ctx context.Context) (Config, error) {
	var cfg Config
	if err := envconfig.Process(ctx, &cfg); err != nil {
		return Config{}, fmt.Errorf("config: load: %w", err)
	}
	switch cfg.AnalyticsTarget {
	case "postgres":
		if cfg.AnalyticsDatabaseURL == "" {
			return Config{}, fmt.Errorf("config: ANALYTICS_DATABASE_URL is required for postgres target")
		}
	case "clickhouse":
		if !cfg.ClickHouseEnabled {
			return Config{}, fmt.Errorf("config: clickhouse target requires CLICKHOUSE_ENABLED=true")
		}
		if cfg.ClickHouseURL == "" {
			return Config{}, fmt.Errorf("config: CLICKHOUSE_URL is required for clickhouse target")
		}
	default:
		return Config{}, fmt.Errorf("config: unsupported ANALYTICS_TARGET %q", cfg.AnalyticsTarget)
	}
	if err := cfg.validateSMS(); err != nil {
		return Config{}, err
	}
	if cfg.AccessTokenTTL <= 0 {
		return Config{}, fmt.Errorf("config: ACCESS_TOKEN_TTL must be positive, got %s", cfg.AccessTokenTTL)
	}
	if err := cfg.validateRateLimit(); err != nil {
		return Config{}, err
	}
	if err := cfg.resolveAdmissionLimit(); err != nil {
		return Config{}, err
	}
	if err := cfg.validateTimeoutBudget(); err != nil {
		return Config{}, err
	}
	if err := cfg.validateReceiptRetention(); err != nil {
		return Config{}, err
	}
	return cfg, nil
}

// minReceiptRetention is the floor for the transactional idempotency window:
// it must outlive the 24h Redis response cache, or a client retrying inside
// the documented replay window would duplicate the mutation.
const minReceiptRetention = 24 * time.Hour

// validateReceiptRetention refuses an idempotency window shorter than the
// replay guarantees layered on top of it.
func (c Config) validateReceiptRetention() error {
	if c.MutationReceiptRetention < minReceiptRetention {
		return fmt.Errorf(
			"config: MUTATION_RECEIPT_RETENTION (%s) must be at least %s: the Redis response "+
				"cache promises replays for that long, and the receipt table is its durable backstop",
			c.MutationReceiptRetention, minReceiptRetention)
	}
	for _, sweep := range []struct {
		name  string
		value time.Duration
	}{
		{"ORDER_SWEEP_INTERVAL", c.SweepInterval},
		{"REFUND_SWEEP_INTERVAL", c.RefundSweepInterval},
	} {
		if sweep.value > 0 && c.MutationReceiptRetention < 2*sweep.value {
			return fmt.Errorf(
				"config: MUTATION_RECEIPT_RETENTION (%s) must be at least twice %s (%s), or a "+
					"sweeper's dedup receipt can expire between two passes and the pass repeats its work",
				c.MutationReceiptRetention, sweep.name, sweep.value)
		}
	}
	return nil
}

// validateRateLimit refuses a rate-limit budget that cannot mean what it says.
func (c Config) validateRateLimit() error {
	if c.RateLimitWindow <= 0 {
		return fmt.Errorf(
			"config: RATE_LIMIT_WINDOW must be positive, got %s: a non-positive window is "+
				"silently replaced with 1m, so the limiter would meter on a budget nobody configured",
			c.RateLimitWindow)
	}
	if c.RateLimitAuthenticatedBurst <= 0 {
		return fmt.Errorf(
			"config: RATE_LIMIT_AUTHENTICATED_BURST must be positive, got %d",
			c.RateLimitAuthenticatedBurst)
	}
	if c.RateLimitAnonymousBurst <= 0 {
		return fmt.Errorf(
			"config: RATE_LIMIT_ANONYMOUS_BURST must be positive, got %d: to refuse anonymous "+
				"traffic, take the routes off the public surface rather than setting a zero budget",
			c.RateLimitAnonymousBurst)
	}
	return nil
}

// validateSMS refuses a delivery configuration that cannot send.
func (c Config) validateSMS() error {
	switch c.SMSProvider {
	case sms.ProviderLog:
		if c.Env != "development" {
			return fmt.Errorf(
				"config: SMS_PROVIDER=log writes one-time codes to the log and must not run with ENV=%s", c.Env)
		}
	case sms.ProviderEskiz:
		if c.EskizEmail == "" || c.EskizPassword == "" {
			return fmt.Errorf(
				"config: SMS_PROVIDER=eskiz requires SMS_ESKIZ_EMAIL and SMS_ESKIZ_PASSWORD")
		}
	case sms.ProviderPlayMobile:
		if c.PlayMobileBaseURL == "" || c.PlayMobileLogin == "" ||
			c.PlayMobilePassword == "" || c.PlayMobileOriginator == "" {
			return fmt.Errorf(
				"config: SMS_PROVIDER=playmobile requires SMS_PLAYMOBILE_BASE_URL, SMS_PLAYMOBILE_LOGIN, " +
					"SMS_PLAYMOBILE_PASSWORD and SMS_PLAYMOBILE_ORIGINATOR")
		}
	default:
		return fmt.Errorf(
			"config: unsupported SMS_PROVIDER %q: implemented providers are %v, and any other value "+
				"would leave the service unable to deliver a single one-time code",
			c.SMSProvider, sms.Providers())
	}
	return nil
}

// AdmissionDisabled reports that admission control was explicitly turned off.
func (c Config) AdmissionDisabled() bool { return c.HTTPMaxInFlight < 0 }

// resolveAdmissionLimit turns HTTPMaxInFlight into a concrete value.
func (c *Config) resolveAdmissionLimit() error {
	switch {
	case c.HTTPMaxInFlight < 0:
		c.HTTPMaxInFlight = 0
		return nil
	case c.HTTPMaxInFlight > 0:
		if ratio := c.HTTPMaxInFlight / int(c.OLTPMaxConns); c.OLTPMaxConns > 0 && ratio > maxInFlightPerConn {
			return fmt.Errorf(
				"config: HTTP_MAX_IN_FLIGHT=%d is %dx OLTP_MAX_CONNS=%d; above %dx, admitted requests "+
					"queue past HTTP_TIMEOUT and are cancelled after the database has already done their "+
					"work. Lower it, raise OLTP_MAX_CONNS, or set HTTP_MAX_IN_FLIGHT=0 to derive it",
				c.HTTPMaxInFlight, ratio, c.OLTPMaxConns, maxInFlightPerConn)
		}
		return nil
	}

	if c.OLTPMaxConns <= 0 {
		return fmt.Errorf("config: cannot derive HTTP_MAX_IN_FLIGHT from OLTP_MAX_CONNS=%d", c.OLTPMaxConns)
	}
	if c.HTTPInFlightPerConn <= 0 {
		return fmt.Errorf("config: HTTP_MAX_IN_FLIGHT_PER_CONN must be positive, got %d", c.HTTPInFlightPerConn)
	}
	c.HTTPMaxInFlight = int(c.OLTPMaxConns) * c.HTTPInFlightPerConn
	return nil
}

// maxInFlightPerConn bounds the explicit-value sanity check.
const maxInFlightPerConn = 16

// validateTimeoutBudget refuses a configuration whose dependency timeouts do not
// fit inside the request budget.
func (c Config) validateTimeoutBudget() error {
	if c.HTTPTimeout <= 0 {
		return fmt.Errorf("config: HTTP_TIMEOUT must be positive, got %s", c.HTTPTimeout)
	}
	for _, dep := range []struct {
		name  string
		value time.Duration
	}{
		{"DB_STATEMENT_TIMEOUT", c.StatementTimeout},
		{"REDIS_TIMEOUT", c.RedisTimeout},
		{"SMS_TIMEOUT", c.SMSTimeout},
	} {
		if dep.value <= 0 {
			return fmt.Errorf("config: %s must be positive, got %s", dep.name, dep.value)
		}
		if dep.value >= c.HTTPTimeout {
			return fmt.Errorf(
				"config: %s (%s) must be below HTTP_TIMEOUT (%s), otherwise a slow "+
					"dependency exhausts the request budget and the graceful-degradation "+
					"paths never run", dep.name, dep.value, c.HTTPTimeout)
		}
	}
	if c.HTTPMaxInFlight < 0 {
		return fmt.Errorf("config: HTTP_MAX_IN_FLIGHT must not be negative, got %d", c.HTTPMaxInFlight)
	}
	if c.ShutdownDrainDelay < 0 {
		return fmt.Errorf("config: SHUTDOWN_DRAIN_DELAY must not be negative, got %s", c.ShutdownDrainDelay)
	}
	if c.ShutdownDrainDelay >= c.ShutdownTimeout {
		return fmt.Errorf(
			"config: SHUTDOWN_DRAIN_DELAY (%s) must be below SHUTDOWN_TIMEOUT (%s), otherwise "+
				"draining consumes the window in-flight requests need to finish",
			c.ShutdownDrainDelay, c.ShutdownTimeout)
	}
	return nil
}
