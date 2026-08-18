package httpx

import "sync/atomic"

// Readiness is the switch a process flips to leave load-balancer rotation before
// it stops serving.
type Readiness struct {
	draining atomic.Bool
}

// Drain makes /readyz report unavailable while the process keeps serving.
func (r *Readiness) Drain() {
	if r == nil {
		return
	}
	r.draining.Store(true)
}

// Draining reports whether Drain has been called.
func (r *Readiness) Draining() bool {
	return r != nil && r.draining.Load()
}
