//go:build integration

// Package migrations_test proves the schema history replays: from nothing to
// HEAD, from HEAD−1 to HEAD, and down and back up again. Everything runs on a
// scratch database created for the test, never on the shared one.
package migrations_test

import (
	"context"
	"slices"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/pgtest"
)

func tableCount(t *testing.T, pool *postgres.Pool, schema string) int {
	t.Helper()
	var n int
	if err := pool.QueryRow(context.Background(),
		`SELECT count(*) FROM pg_tables WHERE schemaname = $1`, schema).Scan(&n); err != nil {
		t.Fatalf("count tables in %s: %v", schema, err)
	}
	return n
}

func TestMigrationsApplyFromEmptyToHead(t *testing.T) {
	dsn := pgtest.ScratchURL(t)
	ctx := context.Background()

	if err := pgtest.ApplyAllMigrations(ctx, dsn); err != nil {
		t.Fatalf("apply from empty: %v", err)
	}
	pool := pgtest.PoolAt(t, dsn)
	for _, module := range pgtest.Modules {
		if n := tableCount(t, pool, module); n == 0 {
			t.Errorf("schema %s has no tables after migrating to HEAD", module)
		}
	}
}

func TestMigrationsCycleUpDownUp(t *testing.T) {
	dsn := pgtest.ScratchURL(t)
	ctx := context.Background()

	if err := pgtest.ApplyAllMigrations(ctx, dsn); err != nil {
		t.Fatalf("first up: %v", err)
	}

	// Down in reverse module order, newest version first within a module.
	reversed := slices.Clone(pgtest.Modules)
	slices.Reverse(reversed)
	for _, module := range reversed {
		files, err := pgtest.MigrationFiles(module, "down")
		if err != nil {
			t.Fatalf("list %s down migrations: %v", module, err)
		}
		slices.Reverse(files)
		if err := pgtest.ExecFiles(ctx, dsn, files); err != nil {
			t.Fatalf("down %s: %v", module, err)
		}
	}
	pool := pgtest.PoolAt(t, dsn)
	for _, module := range pgtest.Modules {
		if n := tableCount(t, pool, module); n != 0 {
			t.Errorf("schema %s still has %d tables after down -all", module, n)
		}
	}

	if err := pgtest.ApplyAllMigrations(ctx, dsn); err != nil {
		t.Fatalf("re-apply after down: %v", err)
	}
	for _, module := range pgtest.Modules {
		if n := tableCount(t, pool, module); n == 0 {
			t.Errorf("schema %s has no tables after the up/down/up cycle", module)
		}
	}
}

func TestMigrationsApplyFromHeadMinusOneToHead(t *testing.T) {
	dsn := pgtest.ScratchURL(t)
	ctx := context.Background()

	// First bring every module to HEAD−1, then apply each HEAD on top. While a
	// module has a single squashed migration (the intentional pre-deploy
	// state), its HEAD−1 is the empty schema and this equals empty→HEAD; the
	// test grows teeth automatically once second versions land.
	type pending struct{ module, file string }
	var heads []pending
	for _, module := range pgtest.Modules {
		files, err := pgtest.MigrationFiles(module, "up")
		if err != nil {
			t.Fatalf("list %s up migrations: %v", module, err)
		}
		if len(files) == 1 {
			t.Logf("module %s has one squashed migration; HEAD-1 is empty", module)
		}
		if err := pgtest.ExecFiles(ctx, dsn, files[:len(files)-1]); err != nil {
			t.Fatalf("bring %s to HEAD-1: %v", module, err)
		}
		heads = append(heads, pending{module: module, file: files[len(files)-1]})
	}
	for _, head := range heads {
		if err := pgtest.ExecFiles(ctx, dsn, []string{head.file}); err != nil {
			t.Fatalf("apply %s HEAD on top of HEAD-1: %v", head.module, err)
		}
	}

	pool := pgtest.PoolAt(t, dsn)
	for _, module := range pgtest.Modules {
		if n := tableCount(t, pool, module); n == 0 {
			t.Errorf("schema %s has no tables after HEAD-1 -> HEAD", module)
		}
	}
}
