package httpx

import (
	"net/http"
)

// LimitInFlight caps concurrent in-flight requests and refuses the excess
// immediately.
func LimitInFlight(limit int, observer ...AdmissionObserver) func(http.Handler) http.Handler {
	if limit <= 0 {
		return func(next http.Handler) http.Handler { return next }
	}
	var obs AdmissionObserver
	if len(observer) > 0 {
		obs = observer[0]
	}
	slots := make(chan struct{}, limit)
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			select {
			case slots <- struct{}{}:
				admitted(obs)
				defer func() {
					<-slots
					released(obs)
				}()
				next.ServeHTTP(w, r)
			default:
				shed(obs)
				inFlightRejected(w, r)
			}
		})
	}
}

// AdmissionObserver receives admission-control transitions.
type AdmissionObserver interface {
	Admitted()
	Released()
	Shed()
}

// Nil-safe helpers: a router built without an observer (routedump, tests) must
// behave exactly as before rather than panicking on a missing dependency.
func admitted(o AdmissionObserver) {
	if o != nil {
		o.Admitted()
	}
}

func released(o AdmissionObserver) {
	if o != nil {
		o.Released()
	}
}

func shed(o AdmissionObserver) {
	if o != nil {
		o.Shed()
	}
}

func inFlightRejected(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Retry-After", "1")
	WriteProblem(w, r, NewAppError(
		ProblemTypeOverloaded,
		"Service Unavailable",
		http.StatusServiceUnavailable,
		"the server is at capacity, retry shortly",
		nil,
	))
}
