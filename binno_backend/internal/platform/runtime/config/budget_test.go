package config_test

import (
	"context"
	"os"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/config"
)

// requiredEnv sets the minimum that Load needs, so each case below varies only
// the budget it is about. It also clears the optional overrides these tests
// assert defaults for, so a value leaked from the developer's shell (e.g.
// `source .env` before `go test`) cannot turn a default-path assertion red.
func requiredEnv(t *testing.T) {
	t.Helper()
	t.Setenv("OLTP_DATABASE_URL", "postgres://localhost/oltp")
	t.Setenv("ANALYTICS_DATABASE_URL", "postgres://localhost/analytics")
	t.Setenv("REDIS_ADDR", "localhost:6379")
	t.Setenv("JWT_SIGNING_KEY", "test-key")
	unsetEnv(t, "TRUSTED_PROXY_CIDRS")
}

// unsetEnv removes key for the duration of the test and restores it afterwards,
// so the case reads the shipped default rather than an ambient override. Go's
// testing has no t.Unsetenv, so this is the hermetic equivalent.
func unsetEnv(t *testing.T, key string) {
	t.Helper()
	prev, had := os.LookupEnv(key)
	if err := os.Unsetenv(key); err != nil {
		t.Fatalf("unset %s: %v", key, err)
	}
	t.Cleanup(func() {
		if had {
			_ = os.Setenv(key, prev)
		}
	})
}

// The shipped defaults must satisfy the rule they exist to express.
func TestLoad_DefaultDependencyTimeoutsFitTheRequestBudget(t *testing.T) {
	requiredEnv(t)

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if cfg.StatementTimeout >= cfg.HTTPTimeout {
		t.Errorf("DB_STATEMENT_TIMEOUT default %s is not below HTTP_TIMEOUT %s",
			cfg.StatementTimeout, cfg.HTTPTimeout)
	}
	if cfg.RedisTimeout >= cfg.HTTPTimeout {
		t.Errorf("REDIS_TIMEOUT default %s is not below HTTP_TIMEOUT %s",
			cfg.RedisTimeout, cfg.HTTPTimeout)
	}
	if cfg.HTTPMaxInFlight <= 0 {
		t.Errorf("HTTP_MAX_IN_FLIGHT default = %d, want admission control on by default",
			cfg.HTTPMaxInFlight)
	}
}

// An inverted budget is refused at boot.
func TestLoad_RefusesTimeoutsThatExceedTheRequestBudget(t *testing.T) {
	tests := []struct {
		name  string
		key   string
		value string
	}{
		{"statement timeout equal to the budget", "DB_STATEMENT_TIMEOUT", "2s"},
		{"statement timeout above the budget", "DB_STATEMENT_TIMEOUT", "5s"},
		{"redis timeout equal to the budget", "REDIS_TIMEOUT", "2s"},
		{"redis timeout above the budget", "REDIS_TIMEOUT", "3s"},
		{"redis timeout at the go-redis default", "REDIS_TIMEOUT", "5s"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			requiredEnv(t)
			t.Setenv("HTTP_TIMEOUT", "2s")
			t.Setenv(tc.key, tc.value)

			_, err := config.Load(context.Background())
			if err == nil {
				t.Fatalf("Load() with %s=%s succeeded, want a startup failure", tc.key, tc.value)
			}
			if !strings.Contains(err.Error(), tc.key) {
				t.Errorf("error should name the offending setting %s, got %v", tc.key, err)
			}
		})
	}
}

func TestLoad_RefusesNonPositiveBudgets(t *testing.T) {
	for _, key := range []string{"DB_STATEMENT_TIMEOUT", "REDIS_TIMEOUT"} {
		t.Run(key, func(t *testing.T) {
			requiredEnv(t)
			t.Setenv(key, "0s")
			if _, err := config.Load(context.Background()); err == nil {
				t.Fatalf("Load() with %s=0s succeeded, want a startup failure", key)
			}
		})
	}
}

// A raised request budget legitimises a larger dependency timeout: the rule is
// relative, not a fixed ceiling.
func TestLoad_AcceptsLargerTimeoutsUnderALargerBudget(t *testing.T) {
	requiredEnv(t)
	t.Setenv("HTTP_TIMEOUT", "10s")
	t.Setenv("DB_STATEMENT_TIMEOUT", "8s")
	t.Setenv("REDIS_TIMEOUT", "2s")

	if _, err := config.Load(context.Background()); err != nil {
		t.Fatalf("Load() error = %v, want success", err)
	}
}

// The drain window is carved out of the same shutdown that has to finish the in-
// flight requests, so it cannot be the whole of it.
func TestLoad_RefusesDrainDelayThatConsumesTheShutdownWindow(t *testing.T) {
	requiredEnv(t)
	t.Setenv("SHUTDOWN_TIMEOUT", "10s")
	t.Setenv("SHUTDOWN_DRAIN_DELAY", "10s")

	_, err := config.Load(context.Background())
	if err == nil {
		t.Fatal("Load() succeeded, want a startup failure")
	}
	if !strings.Contains(err.Error(), "SHUTDOWN_DRAIN_DELAY") {
		t.Fatalf("error = %v, want it to name the offending setting", err)
	}
}

// The default must actually drain.
func TestLoad_DefaultDrainDelayLeavesRotationBeforeShutdown(t *testing.T) {
	requiredEnv(t)

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if cfg.ShutdownDrainDelay <= 0 {
		t.Errorf("SHUTDOWN_DRAIN_DELAY default = %s, want a real drain window",
			cfg.ShutdownDrainDelay)
	}
	if cfg.ShutdownDrainDelay >= cfg.ShutdownTimeout {
		t.Errorf("SHUTDOWN_DRAIN_DELAY default %s is not below SHUTDOWN_TIMEOUT %s",
			cfg.ShutdownDrainDelay, cfg.ShutdownTimeout)
	}
}

// Trusting no proxy is the shipped default: it is the safe answer on a public
// port, and the one deployment that must not read a client-supplied header.
func TestLoad_TrustsNoProxyByDefault(t *testing.T) {
	requiredEnv(t)

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if len(cfg.TrustedProxyCIDRs) != 0 {
		t.Errorf("TRUSTED_PROXY_CIDRS default = %v, want empty", cfg.TrustedProxyCIDRs)
	}
}

func TestLoad_ParsesTrustedProxyList(t *testing.T) {
	requiredEnv(t)
	t.Setenv("TRUSTED_PROXY_CIDRS", "10.0.0.0/8,192.168.0.0/16")

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}
	if len(cfg.TrustedProxyCIDRs) != 2 {
		t.Fatalf("TRUSTED_PROXY_CIDRS = %v, want two entries", cfg.TrustedProxyCIDRs)
	}
}
