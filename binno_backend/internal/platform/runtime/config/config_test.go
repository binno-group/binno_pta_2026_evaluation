package config_test

import (
	"context"
	"os"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/config"
)

func unsetForTest(t *testing.T, key string) {
	t.Helper()
	prev, was := os.LookupEnv(key)
	if err := os.Unsetenv(key); err != nil {
		t.Fatalf("unset %s: %v", key, err)
	}
	t.Cleanup(func() {
		if was {
			_ = os.Setenv(key, prev)
		}
	})
}

func TestLoad_FailsFastOnMissingRequiredVars(t *testing.T) {
	for _, key := range []string{"OLTP_DATABASE_URL", "ANALYTICS_DATABASE_URL", "REDIS_ADDR", "JWT_SIGNING_KEY"} {
		unsetForTest(t, key)
	}

	if _, err := config.Load(context.Background()); err == nil {
		t.Fatal("Load() with no required env vars set, want a fail-fast error")
	}
}

func TestLoad_AppliesDefaultsWhenRequiredVarsPresent(t *testing.T) {
	t.Setenv("OLTP_DATABASE_URL", "postgres://localhost/oltp")
	t.Setenv("ANALYTICS_DATABASE_URL", "postgres://localhost/analytics")
	t.Setenv("REDIS_ADDR", "localhost:6379")
	t.Setenv("JWT_SIGNING_KEY", "test-key")

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load() error = %v", err)
	}

	if cfg.HTTPAddr != ":8080" {
		t.Errorf("HTTPAddr = %q, want default :8080", cfg.HTTPAddr)
	}
	if cfg.Env != "development" {
		t.Errorf("Env = %q, want default development", cfg.Env)
	}
	if cfg.AnalyticsTarget != "postgres" {
		t.Errorf("AnalyticsTarget = %q, want default postgres", cfg.AnalyticsTarget)
	}
	if cfg.ClickHouseEnabled {
		t.Error("ClickHouseEnabled = true, want gated default false")
	}
}

func TestLoad_AllowsGatedClickHouseWithoutPostgresAnalyticsURL(t *testing.T) {
	t.Setenv("OLTP_DATABASE_URL", "postgres://localhost/oltp")
	t.Setenv("ANALYTICS_DATABASE_URL", "")
	t.Setenv("ANALYTICS_TARGET", "clickhouse")
	t.Setenv("CLICKHOUSE_ENABLED", "true")
	t.Setenv("CLICKHOUSE_URL", "http://clickhouse:8123")
	t.Setenv("REDIS_ADDR", "localhost:6379")
	t.Setenv("JWT_SIGNING_KEY", "test-key")

	cfg, err := config.Load(context.Background())
	if err != nil {
		t.Fatalf("Load error = %v", err)
	}
	if cfg.AnalyticsTarget != "clickhouse" {
		t.Fatalf("AnalyticsTarget = %q, want clickhouse", cfg.AnalyticsTarget)
	}
}

// SMS_PROVIDER is an allowlist.
func TestLoad_RejectsUnimplementedSMSProvider(t *testing.T) {
	for _, provider := range []string{"twilio", "sms.uz", ""} {
		t.Run(provider, func(t *testing.T) {
			requiredEnv(t)
			t.Setenv("ENV", "production")
			t.Setenv("SMS_PROVIDER", provider)

			if _, err := config.Load(context.Background()); err == nil {
				t.Fatalf("Load() with SMS_PROVIDER=%q accepted it, but no adapter exists", provider)
			}
		})
	}
}

// A gateway account is configuration.
func TestLoad_RejectsGatewayProviderWithoutCredentials(t *testing.T) {
	for provider, complete := range map[string]map[string]string{
		"eskiz": {
			"SMS_ESKIZ_EMAIL":    "ops@binno.uz",
			"SMS_ESKIZ_PASSWORD": "secret",
		},
		"playmobile": {
			"SMS_PLAYMOBILE_BASE_URL":   "http://broker.local/broker-api",
			"SMS_PLAYMOBILE_LOGIN":      "binno",
			"SMS_PLAYMOBILE_PASSWORD":   "secret",
			"SMS_PLAYMOBILE_ORIGINATOR": "3700",
		},
	} {
		t.Run(provider+"/complete", func(t *testing.T) {
			requiredEnv(t)
			t.Setenv("ENV", "production")
			t.Setenv("SMS_PROVIDER", provider)
			for key, value := range complete {
				t.Setenv(key, value)
			}
			if _, err := config.Load(context.Background()); err != nil {
				t.Fatalf("Load() with a fully configured %s account: %v", provider, err)
			}
		})

		for missing := range complete {
			t.Run(provider+"/without/"+missing, func(t *testing.T) {
				requiredEnv(t)
				t.Setenv("ENV", "production")
				t.Setenv("SMS_PROVIDER", provider)
				for key, value := range complete {
					if key == missing {
						value = ""
					}
					t.Setenv(key, value)
				}
				if _, err := config.Load(context.Background()); err == nil {
					t.Fatalf("Load() accepted SMS_PROVIDER=%s with %s unset", provider, missing)
				}
			})
		}
	}
}

// Delivery happens inside the /auth/otp/request handler, so the gateway is a
// dependency on the request path and its timeout has to fit the budget like any
// other.
func TestLoad_RejectsSMSTimeoutAtOrAboveTheRequestBudget(t *testing.T) {
	for _, timeout := range []string{"2s", "5s", "0s"} {
		t.Run(timeout, func(t *testing.T) {
			requiredEnv(t)
			t.Setenv("HTTP_TIMEOUT", "2s")
			t.Setenv("SMS_TIMEOUT", timeout)

			if _, err := config.Load(context.Background()); err == nil {
				t.Fatalf("Load() accepted SMS_TIMEOUT=%s inside a 2s HTTP_TIMEOUT", timeout)
			}
		})
	}
}

// The pre-existing rule still holds: the log sender is development-only.
func TestLoad_RejectsLogSMSProviderOutsideDevelopment(t *testing.T) {
	requiredEnv(t)
	t.Setenv("ENV", "production")
	t.Setenv("SMS_PROVIDER", "log")

	if _, err := config.Load(context.Background()); err == nil {
		t.Fatal("Load() accepted SMS_PROVIDER=log with ENV=production, want an error")
	}
}

// And development still works, or nobody can run the service locally.
func TestLoad_AllowsLogSMSProviderInDevelopment(t *testing.T) {
	requiredEnv(t)
	t.Setenv("ENV", "development")
	t.Setenv("SMS_PROVIDER", "log")

	if _, err := config.Load(context.Background()); err != nil {
		t.Fatalf("Load() with the development defaults: %v", err)
	}
}
