// Package postgres wraps pgxpool with connection quotas and statement timeouts.
package postgres

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strconv"
	"strings"
	"sync/atomic"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Config configures a single quota- and timeout-bounded connection pool.
type Config struct {
	URL              string
	MaxConns         int32
	StatementTimeout time.Duration
	// Tracer observes every query.
	Tracer pgx.QueryTracer
	// Warmup runs once on every newly established connection, before the pool hands
	// it to a caller.
	Warmup []string
	// Logger reports warm-up failures.
	Logger *slog.Logger
}

// minConnRatio keeps this fraction of MaxConns permanently established.
const minConnRatio = 2

// connLifetime bounds how long one backend is reused, and connLifetimeJitter
// spreads the replacements out.
const (
	connLifetime       = 30 * time.Minute
	connLifetimeJitter = 5 * time.Minute
	connIdleTime       = 15 * time.Minute
)

// Pool is a quota- and timeout-bounded pgx connection pool.
type Pool struct {
	*pgxpool.Pool
}

// NewPool connects using cfg, applying MaxConns and statement_timeout before the
// first connection is established, and keeps part of the pool permanently warm.
func NewPool(ctx context.Context, cfg Config) (*Pool, error) {
	pgxCfg, err := pgxpool.ParseConfig(cfg.URL)
	if err != nil {
		return nil, fmt.Errorf("db: parse config: %w", err)
	}
	if cfg.MaxConns > 0 {
		pgxCfg.MaxConns = cfg.MaxConns
		pgxCfg.MinConns = max(cfg.MaxConns/minConnRatio, 1)
	}
	pgxCfg.MaxConnLifetime = connLifetime
	pgxCfg.MaxConnLifetimeJitter = connLifetimeJitter
	pgxCfg.MaxConnIdleTime = connIdleTime
	if cfg.StatementTimeout > 0 {
		pgxCfg.ConnConfig.RuntimeParams["statement_timeout"] = strconv.Itoa(int(cfg.StatementTimeout.Milliseconds()))
	}
	// Pin the session timezone so date_trunc/::date casts in SQL agree with the
	// UTC arithmetic in Go (commission month rollup) regardless of server config.
	pgxCfg.ConnConfig.RuntimeParams["timezone"] = "UTC"
	if cfg.Tracer != nil {
		pgxCfg.ConnConfig.Tracer = cfg.Tracer
	}
	if len(cfg.Warmup) > 0 {
		pgxCfg.AfterConnect = warmupHook(cfg.Warmup, cfg.Logger)
	}

	pool, err := pgxpool.NewWithConfig(ctx, pgxCfg)
	if err != nil {
		return nil, fmt.Errorf("db: connect: %w", err)
	}
	return &Pool{Pool: pool}, nil
}

// warmupHook runs statements on each new connection.
func warmupHook(statements []string, logger *slog.Logger) func(context.Context, *pgx.Conn) error {
	var reported atomic.Bool
	return func(ctx context.Context, conn *pgx.Conn) error {
		for _, stmt := range statements {
			_, err := conn.Exec(ctx, stmt)
			if err == nil {
				continue
			}
			if logger != nil && reported.CompareAndSwap(false, true) {
				logger.WarnContext(ctx, "db: connection warm-up statement failed, continuing",
					"err", err, "statement", stmt,
					"effect", "first query on each new connection pays the cold-backend cost")
			}
		}
		return nil
	}
}

// Ping satisfies httpx.ReadyCheck.
func (p *Pool) Ping(ctx context.Context) error {
	return p.Pool.Ping(ctx)
}

// SchemaPresent reports whether the database holds any migration history at all.
func (p *Pool) SchemaPresent(ctx context.Context) error {
	tables, err := p.migrationTables(ctx)
	if err != nil {
		return err
	}
	if len(tables) == 0 {
		return errors.New("db: no migrations have been applied")
	}
	return nil
}

// SchemaReady reports whether any module's migration history is dirty, i.e.
func (p *Pool) SchemaReady(ctx context.Context) error {
	tables, err := p.migrationTables(ctx)
	if err != nil {
		return err
	}
	if len(tables) == 0 {
		return nil
	}

	parts := make([]string, 0, len(tables))
	for _, table := range tables {
		parts = append(parts, fmt.Sprintf(
			"SELECT %s AS module, dirty FROM public.%s",
			quoteLiteral(table), pgx.Identifier{table}.Sanitize()))
	}
	var module string
	err = p.Pool.QueryRow(ctx,
		"SELECT module, dirty FROM ("+strings.Join(parts, " UNION ALL ")+
			") m WHERE dirty LIMIT 1").Scan(&module, new(bool))
	switch {
	case errors.Is(err, pgx.ErrNoRows):
		return nil // nothing dirty
	case err != nil:
		return fmt.Errorf("db: read migration state: %w", err)
	default:
		return fmt.Errorf("db: %s is dirty: a migration failed part-way", module)
	}
}

// migrationTables lists the per-module golang-migrate history tables.
func (p *Pool) migrationTables(ctx context.Context) ([]string, error) {
	rows, err := p.Query(ctx, `
		SELECT c.relname
		FROM pg_catalog.pg_class c
		JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
		WHERE n.nspname = 'public'
		  AND c.relkind = 'r'
		  AND c.relname LIKE 'schema_migrations\_%'
		ORDER BY c.relname`)
	if err != nil {
		return nil, fmt.Errorf("db: list migration tables: %w", err)
	}
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var name string
		if err := rows.Scan(&name); err != nil {
			return nil, fmt.Errorf("db: scan migration tables: %w", err)
		}
		tables = append(tables, name)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("db: list migration tables: %w", err)
	}
	return tables, nil
}

func quoteLiteral(s string) string {
	return "'" + strings.ReplaceAll(s, "'", "''") + "'"
}

func (p *Pool) Stats() *pgxpool.Stat { return p.Stat() }
