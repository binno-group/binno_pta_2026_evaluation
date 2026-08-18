package httpx

import (
	"context"
	"net/http"
	"strconv"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

// Limiter is the fixed-window counter the middleware consumes.
type Limiter interface {
	Allow(ctx context.Context, key string, limit int64, window time.Duration) (bool, error)
}

// RateLimitConfig bounds request rates per caller.
type RateLimitConfig struct {
	// Window is the fixed counting window.
	Window time.Duration
	// AuthenticatedBurst is the per-principal allowance per window.
	AuthenticatedBurst int64
	// AnonymousBurst is the per-IP allowance per window.
	AnonymousBurst int64
	// TrustedProxies resolves that IP when the service runs behind a reverse proxy.
	TrustedProxies *TrustedProxies
}

// RateLimit enforces per-caller request rates.
func RateLimit(limiter Limiter, cfg RateLimitConfig) func(http.Handler) http.Handler {
	if cfg.Window <= 0 {
		cfg.Window = time.Minute
	}
	if cfg.AuthenticatedBurst <= 0 {
		cfg.AuthenticatedBurst = 300
	}
	if cfg.AnonymousBurst <= 0 {
		cfg.AnonymousBurst = 60
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			key, limit := rateLimitKey(r, cfg)
			allowed, err := limiter.Allow(r.Context(), key, limit, cfg.Window)
			if err != nil {
				if isSafeMethod(r.Method) {
					logging.FromContext(r.Context()).WarnContext(r.Context(),
						"rate limiter unavailable, allowing safe request", "err", err)
					next.ServeHTTP(w, r)
					return
				}
				WriteProblem(w, r, NewAppError(ProblemTypeDependencyUnavailable,
					"Service Unavailable", http.StatusServiceUnavailable,
					"rate limiter is unavailable", err))
				return
			}
			if !allowed {
				w.Header().Set("Retry-After", strconv.Itoa(int(cfg.Window.Seconds())))
				WriteProblem(w, r, NewAppError(ProblemTypeRateLimited, "Too Many Requests",
					http.StatusTooManyRequests, "request rate exceeded", nil))
				return
			}
			next.ServeHTTP(w, r)
		})
	}
}

func rateLimitKey(r *http.Request, cfg RateLimitConfig) (string, int64) {
	if subject := authz.Subject(r.Context()); subject != "" {
		return "user:" + subject, cfg.AuthenticatedBurst
	}
	return "ip:" + cfg.TrustedProxies.ClientIP(r), cfg.AnonymousBurst
}

func isSafeMethod(method string) bool {
	switch method {
	case http.MethodGet, http.MethodHead, http.MethodOptions:
		return true
	default:
		return false
	}
}
