package otelx

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// REDMetrics records Rate/Errors/Duration per route+method, the baseline
// dashboard for every endpoint.
type REDMetrics struct {
	clock    clock.Clock
	requests *prometheus.CounterVec
	duration *prometheus.HistogramVec
}

// NewREDMetrics registers the RED series on the default Prometheus registry,
// using c to measure request duration.
func NewREDMetrics(c clock.Clock) *REDMetrics {
	return &REDMetrics{
		clock: c,
		requests: promauto.NewCounterVec(prometheus.CounterOpts{
			Name: "binno_http_requests_total",
			Help: "Total HTTP requests by route, method and status.",
		}, []string{"route", "method", "status"}),
		duration: promauto.NewHistogramVec(prometheus.HistogramOpts{
			Name:    "binno_http_request_duration_seconds",
			Help:    "HTTP request duration in seconds by route and method.",
			Buckets: prometheus.DefBuckets,
		}, []string{"route", "method"}),
	}
}

// Middleware records RED metrics for every request handled by a chi router.
func (m *REDMetrics) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := m.clock.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)

		route := chi.RouteContext(r.Context()).RoutePattern()
		if route == "" {
			route = r.URL.Path
		}
		m.requests.WithLabelValues(route, r.Method, strconv.Itoa(rec.status)).Inc()
		m.duration.WithLabelValues(route, r.Method).Observe(m.clock.Now().Sub(start).Seconds())
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(status int) {
	r.status = status
	r.ResponseWriter.WriteHeader(status)
}

// MetricsHandler exposes the default Prometheus registry over /metrics.
func MetricsHandler() http.Handler {
	return promhttp.Handler()
}
