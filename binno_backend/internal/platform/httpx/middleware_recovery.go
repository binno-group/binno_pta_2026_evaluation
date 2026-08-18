package httpx

import (
	"net/http"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/telemetry/logging"
)

// Recoverer converts a handler panic into a 500 problem response.
func Recoverer(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if rec := recover(); rec != nil {
				logging.FromContext(r.Context()).ErrorContext(
					r.Context(),
					"panic recovered",
					"panic",
					rec,
				)
				WriteProblem(w, r, NewAppError(
					ProblemTypeInternal,
					"Internal Server Error",
					http.StatusInternalServerError,
					"",
					nil,
				))
			}
		}()
		next.ServeHTTP(w, r)
	})
}
