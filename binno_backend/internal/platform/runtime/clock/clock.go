// Package clock is the one legal home of time.Now.
package clock

import "time"

// Clock returns the current time.
type Clock interface {
	Now() time.Time
}

type real struct{}

// New returns the production Clock, backed by the system clock in UTC.
func New() Clock {
	return real{}
}

func (real) Now() time.Time {
	return time.Now().UTC()
}

// Fixed is a Clock that always returns the same instant, for deterministic
// tests.
type Fixed struct {
	At time.Time
}

// NewFixed returns a Clock pinned to at, for deterministic tests.
func NewFixed(at time.Time) Clock {
	return Fixed{At: at.UTC()}
}

// Now returns the pinned instant.
func (f Fixed) Now() time.Time {
	return f.At
}
