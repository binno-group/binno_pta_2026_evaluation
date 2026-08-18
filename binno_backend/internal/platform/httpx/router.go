package httpx

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

// ReadyCheck reports whether a dependency (DB, Redis, ...) is currently healthy.
type ReadyCheck struct {
	// Name identifies the dependency in logs, e.g.
	Name  string
	Probe func(ctx context.Context) error
	// Critical marks a dependency the process cannot serve its core traffic
	// without.
	Critical bool
}

// ProbeTimeout bounds a single readiness probe.
const ProbeTimeout = 750 * time.Millisecond

// RouterConfig assembles the shared HTTP surface: health endpoints, metrics and
// cross-cutting middleware.
type RouterConfig struct {
	Logger             *slog.Logger
	RequestTimeout     time.Duration
	TracingMiddleware  func(http.Handler) http.Handler
	MetricsMiddleware  func(http.Handler) http.Handler
	MetricsHandler     http.Handler
	DocsHandler        http.Handler
	IdentityMiddleware func(http.Handler) http.Handler
	// RateLimitMiddleware bounds per-caller request rates.
	RateLimitMiddleware func(http.Handler) http.Handler
	// MaxInFlight caps concurrent business requests.
	MaxInFlight int
	// Admission publishes in-flight depth and shed counts.
	Admission   AdmissionObserver
	ReadyChecks []ReadyCheck
	// Readiness lets the process take itself out of load-balancer rotation before
	// shutdown.
	Readiness *Readiness
	// Mutations carries the audit and idempotency dependencies that every route
	// registered through Mutating needs.
	Mutations *MutationSupport
	Mount     func(chi.Router)
}

// NewRouter builds the chi.Mux used by cmd/binno and inspected by
// scripts/routedump.
func NewRouter(cfg RouterConfig) *chi.Mux {
	r := chi.NewRouter()
	if cfg.MetricsMiddleware != nil {
		r.Use(cfg.MetricsMiddleware)
	}
	if cfg.TracingMiddleware != nil {
		r.Use(cfg.TracingMiddleware)
	}
	r.Use(RequestID(cfg.Logger))
	r.Use(Recoverer)
	r.Use(SecurityHeaders)
	r.Use(Timeout(cfg.RequestTimeout))
	if cfg.IdentityMiddleware != nil {
		r.Use(cfg.IdentityMiddleware)
	}
	if cfg.Mutations != nil {
		r.Use(WithMutationSupport(*cfg.Mutations))
	}

	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	})
	r.Get("/readyz", readyHandler(cfg.Readiness, cfg.ReadyChecks))
	if cfg.MetricsHandler != nil {
		r.Handle("/metrics", cfg.MetricsHandler)
	}
	if cfg.DocsHandler != nil {
		r.Mount("/docs", http.StripPrefix("/docs", cfg.DocsHandler))
	}

	r.Route("/api/v1", func(api chi.Router) {
		api.Use(LimitInFlight(cfg.MaxInFlight, cfg.Admission))
		if cfg.RateLimitMiddleware != nil {
			api.Use(cfg.RateLimitMiddleware)
		}
		api.Use(NoStore)
		if cfg.Mount != nil {
			cfg.Mount(api)
		}
	})

	return r
}

// probe runs one readiness check under its own deadline, so a hanging dependency
// cannot consume the request budget that the verdict needs.
func probe(ctx context.Context, check ReadyCheck) error {
	ctx, cancel := context.WithTimeout(ctx, ProbeTimeout)
	defer cancel()
	return check.Probe(ctx)
}

// readyHandler reports readiness without disclosing why it failed.
func readyHandler(readiness *Readiness, checks []ReadyCheck) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if readiness.Draining() {
			writeProblemBody(w, Problem{
				Type:     ProblemTypeNotReady,
				Title:    "Service Unavailable",
				Status:   http.StatusServiceUnavailable,
				Detail:   "the instance is shutting down",
				Instance: r.URL.Path,
			})
			return
		}

		degraded := false
		for _, check := range checks {
			err := probe(r.Context(), check)
			if err == nil {
				continue
			}
			logging.FromContext(r.Context()).ErrorContext(r.Context(),
				"readiness check failed", "dependency", check.Name,
				"critical", check.Critical, "err", err)
			if !check.Critical {
				degraded = true
				continue
			}
			writeProblemBody(w, Problem{
				Type:     ProblemTypeNotReady,
				Title:    "Service Unavailable",
				Status:   http.StatusServiceUnavailable,
				Detail:   "a required dependency is unavailable",
				Instance: r.URL.Path,
			})
			return
		}
		if degraded {
			w.Header().Set("X-Readiness", "degraded")
		}
		w.WriteHeader(http.StatusOK)
	}
}
