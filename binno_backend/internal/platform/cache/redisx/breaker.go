package redisx

import (
	"context"
	"errors"
	"sync/atomic"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// ErrCircuitOpen is returned instead of contacting Redis while the breaker is
// open.
var ErrCircuitOpen = errors.New("redisx: circuit open, redis is unavailable")

// Breaker defaults.
const (
	DefaultFailureThreshold = 5
	DefaultCooldown         = 2 * time.Second
)

// Breaker states.
const (
	breakerClosed int32 = iota
	breakerOpen
	breakerHalfOpen
)

// breaker short-circuits Redis calls after consecutive availability failures.
type breaker struct {
	state     atomic.Int32
	openUntil atomic.Int64 // unix nanoseconds
	failures  atomic.Int64

	threshold int64
	cooldown  time.Duration
	// clk is injected rather than calling time.Now directly, both because the repo
	// forbids that outside package clock and because a breaker whose cooldown can
	// only be observed by sleeping is a breaker with slow, flaky tests.
	clk clock.Clock
}

func newBreaker(threshold int64, cooldown time.Duration) *breaker {
	if threshold <= 0 {
		threshold = DefaultFailureThreshold
	}
	if cooldown <= 0 {
		cooldown = DefaultCooldown
	}
	return &breaker{threshold: threshold, cooldown: cooldown, clk: clock.New()}
}

// allow reports whether a call may reach Redis.
func (b *breaker) allow() bool {
	switch b.state.Load() {
	case breakerClosed:
		return true
	case breakerOpen:
		if b.clk.Now().UnixNano() < b.openUntil.Load() {
			return false
		}
		return b.state.CompareAndSwap(breakerOpen, breakerHalfOpen)
	default: // breakerHalfOpen: a probe is already in flight
		return false
	}
}

// succeed closes the breaker.
func (b *breaker) succeed() {
	b.failures.Store(0)
	b.state.Store(breakerClosed)
}

func (b *breaker) fail() {
	if b.state.Load() == breakerHalfOpen {
		b.trip()
		return
	}
	if b.failures.Add(1) >= b.threshold {
		b.trip()
	}
}

func (b *breaker) trip() {
	b.openUntil.Store(b.clk.Now().Add(b.cooldown).UnixNano())
	b.failures.Store(0)
	b.state.Store(breakerOpen)
}

func (b *breaker) isOpen() bool { return b.state.Load() != breakerClosed }

// countsAsUnavailable decides which errors move the breaker.
func countsAsUnavailable(err error) bool {
	if err == nil || errors.Is(err, ErrKeyNotFound) || errors.Is(err, ErrCircuitOpen) {
		return false
	}
	var replied redis.Error
	return !errors.As(err, &replied)
}

// probeKey marks the context of the half-open probe.
type probeKey struct{}

// withProbe marks ctx as belonging to the single admitted probe.
func withProbe(ctx context.Context) context.Context {
	return context.WithValue(ctx, probeKey{}, true)
}

func isProbe(ctx context.Context) bool {
	probe, _ := ctx.Value(probeKey{}).(bool)
	return probe
}

// breakerHook wires the breaker into go-redis.
type breakerHook struct{ b *breaker }

func (h breakerHook) DialHook(next redis.DialHook) redis.DialHook {
	return next
}

func (h breakerHook) ProcessHook(next redis.ProcessHook) redis.ProcessHook {
	return func(ctx context.Context, cmd redis.Cmder) error {
		if isProbe(ctx) {
			return next(ctx, cmd)
		}
		if !h.b.allow() {
			cmd.SetErr(ErrCircuitOpen)
			return ErrCircuitOpen
		}
		var err error
		defer func() { h.record(err) }()
		err = next(withProbe(ctx), cmd)
		return err
	}
}

func (h breakerHook) ProcessPipelineHook(next redis.ProcessPipelineHook) redis.ProcessPipelineHook {
	return func(ctx context.Context, cmds []redis.Cmder) error {
		if isProbe(ctx) {
			return next(ctx, cmds)
		}
		if !h.b.allow() {
			for _, cmd := range cmds {
				cmd.SetErr(ErrCircuitOpen)
			}
			return ErrCircuitOpen
		}
		var err error
		defer func() { h.record(err) }()
		err = next(withProbe(ctx), cmds)
		return err
	}
}

func (h breakerHook) record(err error) {
	if countsAsUnavailable(err) {
		h.b.fail()
		return
	}
	h.b.succeed()
}
