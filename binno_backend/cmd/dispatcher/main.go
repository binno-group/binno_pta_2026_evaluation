// Command dispatcher relays transactional outbox events to analytics.
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

	apiModule "github.com/binnoapp-glitch/binno_backend/internal/modules/api"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/billing"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/identity"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	analyticsclickhouse "github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics/clickhouse"
	analyticspostgres "github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/config"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/otelx"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "-healthcheck" {
		if err := httpx.ProbeHealth(context.Background(), envOrDefault("METRICS_ADDR", ":9090")); err != nil {
			slog.Error("dispatcher: healthcheck failed", "err", err)
			os.Exit(1)
		}
		return
	}
	if err := run(); err != nil {
		slog.Error("dispatcher: fatal", "err", err)
		os.Exit(1)
	}
}

// envOrDefault reads one variable without going through config.Load, so the
// probe still works against a process whose configuration is invalid.
func envOrDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
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

	tracing, err := otelx.NewProvider(ctx, "binno-dispatcher", cfg.OTLPEndpoint)
	if err != nil {
		return fmt.Errorf("dispatcher: init tracing: %w", err)
	}
	defer func() { _ = tracing.Shutdown(context.Background()) }()

	oltpPool, err := postgres.NewPool(ctx, postgres.Config{
		URL:              cfg.OLTPDatabaseURL,
		MaxConns:         cfg.OLTPMaxConns,
		StatementTimeout: cfg.StatementTimeout,
	})
	if err != nil {
		return fmt.Errorf("dispatcher: connect oltp db: %w", err)
	}
	defer oltpPool.Close()

	sink, analyticsReady, closeAnalytics, err := buildAnalyticsSink(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeAnalytics()

	clk := clock.New()
	dispatcher := outbox.NewDispatcher(oltpPool, sink, clk, logger, outbox.DispatcherConfig{
		Interval:         cfg.DispatchInterval,
		BatchSize:        cfg.DispatchBatch,
		ClaimTTL:         cfg.DispatchClaimTTL,
		MaxAttempts:      cfg.DispatchMaxAttempts,
		RetryBase:        cfg.DispatchRetryBase,
		Retention:        cfg.OutboxRetention,
		ReceiptRetention: cfg.MutationReceiptRetention,
		SinkRetention:    cfg.AnalyticsRetention,
		CleanupBatch:     cfg.OutboxCleanupBatch,
		MetricsInterval:  cfg.OutboxMetricsInterval,
	})

	modules := apiModule.New(oltpPool, oltpPool, clk, nil, nil)
	sweeper := modules.OrderSweeper(logger, orders.SweeperConfig{
		Batch:       cfg.SweepBatch,
		ExpiryGrace: cfg.SweepExpiryGrace,
	})
	janitor := modules.SessionJanitor(logger, identity.JanitorConfig{Batch: cfg.SessionPruneBatch})
	rollup := modules.CommissionRollup(logger, billing.RollupConfig{Batch: cfg.CommissionRollupBatch})
	refundSweeper := modules.RefundSweeper(logger, billing.RefundSweepConfig{Batch: cfg.RefundSweepBatch})

	metricsServer := &http.Server{
		Addr:              cfg.MetricsAddr,
		ReadHeaderTimeout: cfg.HTTPTimeout,
		Handler: httpx.NewRouter(httpx.RouterConfig{
			Logger:            logger,
			RequestTimeout:    cfg.HTTPTimeout,
			TracingMiddleware: otelx.TracingMiddleware("binno-dispatcher"),
			MetricsHandler:    otelx.MetricsHandler(),
			ReadyChecks: []httpx.ReadyCheck{
				{Name: "oltp", Probe: oltpPool.Ping, Critical: true},
				analyticsReady,
			},
		}),
	}
	go func() {
		logger.Info("dispatcher: metrics listening", "addr", cfg.MetricsAddr)
		if err := metricsServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("dispatcher: metrics server failed", "err", err)
		}
	}()

	logger.Info("dispatcher: relaying outbox", "interval", cfg.DispatchInterval, "batch_size", cfg.DispatchBatch)

	go sweeper.Run(ctx, cfg.SweepInterval)
	go janitor.Run(ctx, cfg.SessionPruneInterval)
	go rollup.Run(ctx, cfg.CommissionRollupInterval)
	go refundSweeper.Run(ctx, cfg.RefundSweepInterval)

	drainCtx, cancelDrain := context.WithTimeout(context.WithoutCancel(ctx), cfg.ShutdownTimeout)
	defer cancelDrain()
	dispatcher.Run(ctx, drainCtx)

	logger.Info("dispatcher: shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), cfg.ShutdownTimeout)
	defer cancel()
	return metricsServer.Shutdown(shutdownCtx)
}

func buildAnalyticsSink(
	ctx context.Context,
	cfg config.Config,
) (outbox.Sink, httpx.ReadyCheck, func(), error) {
	switch cfg.AnalyticsTarget {
	case "postgres":
		pool, err := postgres.NewPool(ctx, postgres.Config{
			URL:              cfg.AnalyticsDatabaseURL,
			MaxConns:         cfg.AnalyticsMaxConns,
			StatementTimeout: cfg.StatementTimeout,
		})
		if err != nil {
			return nil, httpx.ReadyCheck{}, nil, fmt.Errorf("dispatcher: connect analytics db: %w", err)
		}
		return analyticspostgres.NewSink(pool),
			httpx.ReadyCheck{Name: "analytics-postgres", Probe: pool.Ping},
			pool.Close,
			nil
	case "clickhouse":
		if !cfg.ClickHouseEnabled {
			return nil, httpx.ReadyCheck{}, nil,
				fmt.Errorf("dispatcher: clickhouse target requires CLICKHOUSE_ENABLED=true")
		}
		if cfg.ClickHouseURL == "" {
			return nil, httpx.ReadyCheck{}, nil,
				fmt.Errorf("dispatcher: clickhouse target requires CLICKHOUSE_URL")
		}
		writer, err := analyticsclickhouse.NewHTTPWriter(
			cfg.ClickHouseURL,
			cfg.ClickHouseDatabase,
			&http.Client{Timeout: max(cfg.StatementTimeout, 5*time.Second)},
		)
		if err != nil {
			return nil, httpx.ReadyCheck{}, nil, err
		}
		return analyticsclickhouse.NewSink(writer),
			httpx.ReadyCheck{Name: "analytics-clickhouse", Probe: writer.Ping},
			func() {},
			nil
	default:
		return nil, httpx.ReadyCheck{}, nil,
			fmt.Errorf("dispatcher: unsupported ANALYTICS_TARGET %q", cfg.AnalyticsTarget)
	}
}
