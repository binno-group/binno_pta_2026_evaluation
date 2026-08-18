// Command binno runs the BINNO HTTP API.
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/binnoapp-glitch/binno_backend/contracts"
	apiModule "github.com/binnoapp-glitch/binno_backend/internal/modules/api"
	operatorModule "github.com/binnoapp-glitch/binno_backend/internal/modules/operator"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/search"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/idempotency"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/ratelimit"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/config"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/otelx"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "-healthcheck" {
		if err := httpx.ProbeHealth(context.Background(), envOrDefault("HTTP_ADDR", ":8080")); err != nil {
			slog.Error("binno: healthcheck failed", "err", err)
			os.Exit(1)
		}
		return
	}
	if err := run(); err != nil {
		slog.Error("binno: fatal", "err", err)
		os.Exit(1)
	}
}

// docsHandler returns the Swagger UI / OpenAPI handler, or nil in production.
func docsHandler(env string) http.Handler {
	if env == "production" {
		return nil
	}
	return contracts.Handler()
}

// envOrDefault reads one variable without going through config.Load.
func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// oltpWarmup is run once on every new OLTP connection, before the pool hands it
// to a request.
func oltpWarmup() []string {
	return []string{
		`SELECT ST_Distance(
		ST_SetSRID(ST_MakePoint(0, 0), 4326)::geography,
		ST_SetSRID(ST_MakePoint(1, 1), 4326)::geography)`,
		`SELECT 1 FROM location.stores LIMIT 1`,
		`SELECT 1 FROM catalog.offers LIMIT 1`,
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	cfg, err := config.Load(ctx)
	if err != nil {
		return err
	}

	logger := logging.New(os.Stdout, slog.LevelInfo)
	slog.SetDefault(logger)

	tracing, err := otelx.NewProvider(ctx, "binno-api", cfg.OTLPEndpoint)
	if err != nil {
		return fmt.Errorf("binno: init tracing: %w", err)
	}
	defer func() { _ = tracing.Shutdown(context.Background()) }()

	oltpPool, err := postgres.NewPool(ctx, postgres.Config{
		URL:              cfg.OLTPDatabaseURL,
		MaxConns:         cfg.OLTPMaxConns,
		StatementTimeout: cfg.StatementTimeout,
		Tracer:           otelx.NewQueryTracer("postgres_oltp"),
		Warmup:           oltpWarmup(),
		Logger:           logger,
	})
	if err != nil {
		return fmt.Errorf("binno: connect oltp db: %w", err)
	}
	defer oltpPool.Close()

	prometheus.MustRegister(otelx.NewPoolCollector("oltp", func() otelx.PoolStats {
		s := oltpPool.Stats()
		return otelx.PoolStats{
			Acquired:             s.AcquiredConns(),
			Idle:                 s.IdleConns(),
			Total:                s.TotalConns(),
			Max:                  s.MaxConns(),
			AcquireWaitTotal:     s.AcquireDuration(),
			EmptyAcquireTotal:    s.EmptyAcquireCount(),
			CanceledAcquireTotal: s.CanceledAcquireCount(),
		}
	}))

	operator, closeAnalytics, err := buildOperatorModule(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeAnalytics()

	readPool := oltpPool
	if cfg.OLTPReadDatabaseURL != "" {
		readPool, err = postgres.NewPool(ctx, postgres.Config{
			URL:              cfg.OLTPReadDatabaseURL,
			MaxConns:         cfg.OLTPReadMaxConns,
			StatementTimeout: cfg.StatementTimeout,
			Tracer:           otelx.NewQueryTracer("postgres_oltp_read"),
			Warmup:           oltpWarmup(),
			Logger:           logger,
		})
		if err != nil {
			return fmt.Errorf("binno: connect oltp read replica: %w", err)
		}
		defer readPool.Close()
		prometheus.MustRegister(otelx.NewPoolCollector("oltp_read", func() otelx.PoolStats {
			s := readPool.Stats()
			return otelx.PoolStats{
				Acquired:             s.AcquiredConns(),
				Idle:                 s.IdleConns(),
				Total:                s.TotalConns(),
				Max:                  s.MaxConns(),
				AcquireWaitTotal:     s.AcquireDuration(),
				EmptyAcquireTotal:    s.EmptyAcquireCount(),
				CanceledAcquireTotal: s.CanceledAcquireCount(),
			}
		}))
		logger.Info("binno: read replica configured", "max_conns", cfg.OLTPReadMaxConns)
	}

	clk := clock.New()

	redisClient := redisx.New(redisx.Config{
		Addr:     cfg.RedisAddr,
		Password: cfg.RedisPassword,
		DB:       cfg.RedisDB,
		Timeout:  cfg.RedisTimeout,
		PoolSize: cfg.RedisPoolSize,
	})
	defer func() { _ = redisClient.Close() }()

	redisClient.AddHook(otelx.NewRedisHook())
	prometheus.MustRegister(otelx.NewRedisPoolCollector(func() otelx.RedisPoolStats {
		s := redisClient.PoolStats()
		return otelx.RedisPoolStats{
			Total:    s.TotalConns,
			Idle:     s.IdleConns,
			Stale:    s.StaleConns,
			Hits:     s.Hits,
			Misses:   s.Misses,
			Timeouts: s.Timeouts,
			Max:      cfg.RedisPoolSize,
		}
	}))
	prometheus.MustRegister(otelx.NewRedisBreakerCollector(redisClient.BreakerOpen))

	signer, err := httpx.NewSigner(cfg.JWTSigningKey, cfg.AccessTokenTTL)
	if err != nil {
		return fmt.Errorf("binno: build token signer: %w", err)
	}
	sender, err := sms.New(sms.Options{
		Provider: cfg.SMSProvider,
		Env:      cfg.Env,
		Timeout:  cfg.SMSTimeout,
		Logger:   logger,
		Eskiz: sms.EskizOptions{
			BaseURL:  cfg.EskizBaseURL,
			Email:    cfg.EskizEmail,
			Password: cfg.EskizPassword,
			From:     cfg.EskizFrom,
		},
		PlayMobile: sms.PlayMobileOptions{
			BaseURL:    cfg.PlayMobileBaseURL,
			Login:      cfg.PlayMobileLogin,
			Password:   cfg.PlayMobilePassword,
			Originator: cfg.PlayMobileOriginator,
		},
	})
	if err != nil {
		return fmt.Errorf("binno: build sms sender: %w", err)
	}
	logger.Info("binno: sms delivery configured", "provider", cfg.SMSProvider, "timeout", cfg.SMSTimeout.String())
	var searchCache *search.RedisCache
	if cfg.SearchCacheTTL > 0 {
		searchCache = search.NewRedisCache(redisClient, cfg.SearchCacheTTL)
		logger.Info("binno: search cache enabled", "ttl", cfg.SearchCacheTTL.String())
	}

	publicAPI := apiModule.New(oltpPool, readPool, clk, &apiModule.AuthDeps{
		Codes:           otp.New(redisClient),
		Sender:          sender,
		Signer:          signer,
		ConfirmLinkBase: cfg.ConfirmLinkBase,
	}, searchCache)

	metrics := otelx.NewREDMetrics(clk)
	admission := otelx.NewAdmission(cfg.HTTPMaxInFlight)

	trustedProxies, err := httpx.NewTrustedProxies(cfg.TrustedProxyCIDRs)
	if err != nil {
		return fmt.Errorf("binno: TRUSTED_PROXY_CIDRS: %w", err)
	}

	readiness := &httpx.Readiness{}

	router := httpx.NewRouter(httpx.RouterConfig{
		Logger:             logger,
		RequestTimeout:     cfg.HTTPTimeout,
		TracingMiddleware:  otelx.TracingMiddleware("binno-api"),
		MetricsMiddleware:  metrics.Middleware,
		MetricsHandler:     otelx.MetricsHandler(),
		DocsHandler:        docsHandler(cfg.Env),
		IdentityMiddleware: httpx.Identity(cfg.JWTSigningKey),
		RateLimitMiddleware: httpx.RateLimit(
			ratelimit.New(redisClient, clk),
			httpx.RateLimitConfig{
				Window:             cfg.RateLimitWindow,
				AuthenticatedBurst: cfg.RateLimitAuthenticatedBurst,
				AnonymousBurst:     cfg.RateLimitAnonymousBurst,
				TrustedProxies:     trustedProxies,
			},
		),
		MaxInFlight: cfg.HTTPMaxInFlight,
		Admission:   admission,
		Readiness:   readiness,
		ReadyChecks: []httpx.ReadyCheck{
			{Name: "oltp", Probe: oltpPool.Ping, Critical: true},
			{Name: "redis", Probe: redisClient.Ping, Critical: false},
			{Name: "schema-present", Probe: oltpPool.SchemaPresent, Critical: true},
			{Name: "schema-clean", Probe: oltpPool.SchemaReady, Critical: false},
			{Name: "analytics", Probe: operator.Ready, Critical: false},
		},
		Mutations: &httpx.MutationSupport{
			Audit:       httpx.NewLogAuditRecorder(),
			Idempotency: idempotency.New(redisClient),
			Clock:       clk,
			Subject:     httpx.Subject,
		},
		Mount: func(r chi.Router) {
			publicAPI.Mount(r)
			operator.Mount(r)
		},
	})

	server := &http.Server{
		Addr:              cfg.HTTPAddr,
		Handler:           router,
		ReadHeaderTimeout: cfg.HTTPTimeout,
	}

	serverErr := make(chan error, 1)
	go func() {
		logger.Info("binno: listening", "addr", cfg.HTTPAddr)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			serverErr <- err
			return
		}
		serverErr <- nil
	}()

	select {
	case err := <-serverErr:
		return err
	case <-ctx.Done():
	}

	readiness.Drain()
	logger.Info("binno: draining", "delay", cfg.ShutdownDrainDelay)
	select {
	case err := <-serverErr:
		return err
	case <-time.After(cfg.ShutdownDrainDelay):
	}

	logger.Info("binno: shutting down", "timeout", cfg.ShutdownTimeout)
	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	if err := server.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("binno: graceful shutdown: %w", err)
	}
	return nil
}

func buildOperatorModule(
	ctx context.Context,
	cfg config.Config,
) (*operatorModule.Module, func(), error) {
	switch cfg.AnalyticsTarget {
	case "postgres":
		pool, err := postgres.NewPool(ctx, postgres.Config{
			URL:              cfg.AnalyticsDatabaseURL,
			MaxConns:         cfg.AnalyticsMaxConns,
			StatementTimeout: cfg.StatementTimeout,
		})
		if err != nil {
			return nil, nil, fmt.Errorf("binno: connect analytics db: %w", err)
		}
		return operatorModule.NewPostgres(pool), pool.Close, nil
	case "clickhouse":
		if !cfg.ClickHouseEnabled {
			return nil, nil, fmt.Errorf("binno: clickhouse target requires CLICKHOUSE_ENABLED=true")
		}
		if cfg.ClickHouseURL == "" {
			return nil, nil, fmt.Errorf("binno: clickhouse target requires CLICKHOUSE_URL")
		}
		module, err := operatorModule.NewClickHouse(
			cfg.ClickHouseURL,
			cfg.ClickHouseDatabase,
			&http.Client{Timeout: max(cfg.StatementTimeout, 5*time.Second)},
		)
		if err != nil {
			return nil, nil, fmt.Errorf("binno: create clickhouse operator module: %w", err)
		}
		return module, func() {}, nil
	default:
		return nil, nil, fmt.Errorf("binno: unsupported ANALYTICS_TARGET %q", cfg.AnalyticsTarget)
	}
}
