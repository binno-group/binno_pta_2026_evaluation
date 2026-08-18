//go:build integration

// Package pgtest provisions the PostgreSQL that integration tests run against.
//
// Resolution order:
//  1. TEST_DB_URL — the compose stack `make test-integration` manages, with
//     migrations already applied.
//  2. A disposable PostGIS testcontainer started once per test process, with
//     every module migration applied in the Makefile order.
package pgtest

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"testing"
	"time"

	tcpostgres "github.com/testcontainers/testcontainers-go/modules/postgres"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
)

// Modules lists the OLTP migration directories in apply order; cross-module
// foreign keys only ever point earlier in this list. Mirrors
// OLTP_MIGRATION_DIRS in the Makefile.
var Modules = []string{"platform", "identity", "location", "catalog", "orders", "billing", "trust"}

var (
	mu        sync.Mutex
	sharedURL string
	sharedErr error
)

// URL returns the DSN of a migrated database, starting the fallback container
// on first use. Tests that must not share state should use ScratchURL instead.
func URL(t *testing.T) string {
	t.Helper()
	mu.Lock()
	defer mu.Unlock()
	if sharedURL == "" && sharedErr == nil {
		sharedURL, sharedErr = provision()
	}
	if sharedErr != nil {
		t.Skipf("no test database: %v", sharedErr)
	}
	return sharedURL
}

func provision() (string, error) {
	if env := os.Getenv("TEST_DB_URL"); env != "" {
		return env, nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()
	container, err := tcpostgres.Run(ctx, "postgis/postgis:16-3.4",
		tcpostgres.WithDatabase("binno"),
		tcpostgres.WithUsername("binno"),
		tcpostgres.WithPassword("binno"),
		tcpostgres.BasicWaitStrategies(),
	)
	if err != nil {
		return "", fmt.Errorf("start postgres container: %w", err)
	}
	dsn, err := container.ConnectionString(ctx, "sslmode=disable")
	if err != nil {
		return "", fmt.Errorf("container dsn: %w", err)
	}
	if err := ApplyAllMigrations(ctx, dsn); err != nil {
		return "", err
	}
	return dsn, nil
}

// Pool returns a pool on the shared database, closed with the test.
func Pool(t *testing.T) *postgres.Pool {
	t.Helper()
	return PoolAt(t, URL(t))
}

// PoolAt returns a pool on dsn, closed with the test.
func PoolAt(t *testing.T, dsn string) *postgres.Pool {
	t.Helper()
	pool, err := postgres.NewPool(context.Background(), postgres.Config{
		URL: dsn, MaxConns: 16, StatementTimeout: 30 * time.Second,
	})
	if err != nil {
		t.Fatalf("connect %s: %v", dsn, err)
	}
	t.Cleanup(pool.Close)
	return pool
}

// ScratchURL creates a throwaway database on the same server for tests that
// must own the whole schema (migration cycles). No migrations are applied.
// The database is dropped when the test finishes.
func ScratchURL(t *testing.T) string {
	t.Helper()
	base := URL(t)
	admin := PoolAt(t, base)
	ctx := context.Background()

	suffix := make([]byte, 4)
	if _, err := rand.Read(suffix); err != nil {
		t.Fatalf("scratch suffix: %v", err)
	}
	name := "binno_scratch_" + hex.EncodeToString(suffix)
	if _, err := admin.Exec(ctx, "CREATE DATABASE "+name); err != nil {
		t.Skipf("cannot create scratch database (needs CREATEDB): %v", err)
	}
	t.Cleanup(func() {
		_, _ = admin.Exec(ctx, "DROP DATABASE IF EXISTS "+name+" WITH (FORCE)")
	})

	parsed, err := url.Parse(base)
	if err != nil {
		t.Fatalf("parse base dsn: %v", err)
	}
	parsed.Path = "/" + name
	return parsed.String()
}

// ApplyAllMigrations applies every module's up migrations, in order, to dsn.
func ApplyAllMigrations(ctx context.Context, dsn string) error {
	for _, module := range Modules {
		files, err := MigrationFiles(module, "up")
		if err != nil {
			return err
		}
		if err := ExecFiles(ctx, dsn, files); err != nil {
			return fmt.Errorf("module %s: %w", module, err)
		}
	}
	return nil
}

// MigrationFiles lists a module's migration files of the given direction
// ("up" or "down"), sorted by version.
func MigrationFiles(module, direction string) ([]string, error) {
	root, err := RepoRoot()
	if err != nil {
		return nil, err
	}
	pattern := filepath.Join(root, "migrations", module, "*."+direction+".sql")
	files, err := filepath.Glob(pattern)
	if err != nil {
		return nil, err
	}
	if len(files) == 0 {
		return nil, fmt.Errorf("no %s migrations under %s", direction, pattern)
	}
	sort.Strings(files)
	return files, nil
}

// ExecFiles runs each SQL file against dsn in its own connection, the way the
// migrate CLI would.
func ExecFiles(ctx context.Context, dsn string, files []string) error {
	pool, err := postgres.NewPool(ctx, postgres.Config{
		URL: dsn, MaxConns: 2, StatementTimeout: 2 * time.Minute,
	})
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()
	for _, file := range files {
		raw, err := os.ReadFile(file)
		if err != nil {
			return err
		}
		if _, err := pool.Exec(ctx, string(raw)); err != nil {
			return fmt.Errorf("apply %s: %w", filepath.Base(file), err)
		}
	}
	return nil
}

// RepoRoot walks up from the working directory to the module root.
func RepoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("go.mod not found above %s", dir)
		}
		dir = parent
	}
}
