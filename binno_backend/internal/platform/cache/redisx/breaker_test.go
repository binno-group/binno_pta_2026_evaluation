package redisx

import (
	"context"
	"errors"
	"net"
	"testing"
	"time"

	"github.com/redis/go-redis/v9"
)

// The breaker's job is to make an unreachable Redis fail INSTANTLY, so the
// degradation paths that already exist (the limiter's fail-open, the search
// cache's miss, the idempotency store's refusal) get to run inside the request
// budget instead of losing it to a dial timeout.

func newTestBreaker(t *testing.T, threshold int64, cooldown time.Duration) (*breaker, *fakeClock) {
	t.Helper()
	clk := &fakeClock{now: time.Date(2026, 8, 3, 12, 0, 0, 0, time.UTC)}
	b := newBreaker(threshold, cooldown)
	b.clk = clk
	return b, clk
}

type fakeClock struct{ now time.Time }

func (c *fakeClock) Now() time.Time          { return c.now }
func (c *fakeClock) advance(d time.Duration) { c.now = c.now.Add(d) }

func TestBreaker_OpensAfterConsecutiveFailures(t *testing.T) {
	b, _ := newTestBreaker(t, 3, time.Second)

	for i := range 2 {
		b.fail()
		if !b.allow() {
			t.Fatalf("breaker opened after %d failures, want it to hold until 3", i+1)
		}
	}
	b.fail()
	if b.allow() {
		t.Fatal("breaker still closed after 3 consecutive failures")
	}
	if !b.isOpen() {
		t.Fatal("isOpen() = false while short-circuiting; the metric would lie")
	}
}

// A success between failures means Redis is answering.
func TestBreaker_SuccessResetsTheCount(t *testing.T) {
	b, _ := newTestBreaker(t, 3, time.Second)

	b.fail()
	b.fail()
	b.succeed()
	b.fail()
	b.fail()

	if !b.allow() {
		t.Fatal("breaker opened on 2 failures after a success; the counter did not reset")
	}
}

// Exactly one caller may probe.
func TestBreaker_HalfOpenAdmitsExactlyOneProbe(t *testing.T) {
	b, clk := newTestBreaker(t, 1, 2*time.Second)
	b.fail()

	if b.allow() {
		t.Fatal("open breaker admitted a call before the cooldown elapsed")
	}
	clk.advance(2 * time.Second)

	if !b.allow() {
		t.Fatal("breaker did not admit a probe after the cooldown")
	}
	for i := range 5 {
		if b.allow() {
			t.Fatalf("a second caller (%d) was admitted while a probe was in flight", i)
		}
	}
}

func TestBreaker_ProbeSuccessCloses_ProbeFailureReopens(t *testing.T) {
	b, clk := newTestBreaker(t, 1, time.Second)

	b.fail()
	clk.advance(time.Second)
	if !b.allow() {
		t.Fatal("no probe admitted")
	}
	b.fail() // the probe found Redis still down
	if b.allow() {
		t.Fatal("a failed probe left the breaker closed")
	}

	clk.advance(time.Second)
	if !b.allow() {
		t.Fatal("no second probe admitted after the new cooldown")
	}
	b.succeed()
	if !b.allow() || b.isOpen() {
		t.Fatal("a successful probe did not close the breaker")
	}
}

// Tripping on a reply from Redis would turn one bad command into a fleet-wide
// bypass of rate limiting and idempotency.
func TestCountsAsUnavailable(t *testing.T) {
	tests := []struct {
		name string
		err  error
		want bool
	}{
		{name: "no error", err: nil, want: false},
		{name: "key not found is a normal reply", err: ErrKeyNotFound, want: false},
		{name: "server error reply", err: redis.Error(proto("WRONGTYPE bad kind")), want: false},
		{name: "dial failure", err: &net.OpError{Op: "dial", Err: errors.New("connection refused")}, want: true},
		{name: "context deadline", err: context.DeadlineExceeded, want: true},
		{name: "wrapped dial failure", err: errors.Join(errors.New("redis: get"), &net.OpError{Op: "dial"}), want: true},
		{name: "our own short-circuit", err: ErrCircuitOpen, want: false},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if got := countsAsUnavailable(tc.err); got != tc.want {
				t.Errorf("countsAsUnavailable(%v) = %v, want %v", tc.err, got, tc.want)
			}
		})
	}
}

// proto builds the error type go-redis returns for a server reply.
type proto string

func (p proto) Error() string { return string(p) }
func (proto) RedisError()     {}

// A short-circuited command must carry the error on the Cmder too: callers read
// cmd.Err(), not the hook's return value.
func TestBreakerHook_SetsTheErrorOnTheCommand(t *testing.T) {
	b, _ := newTestBreaker(t, 1, time.Minute)
	b.fail()
	hook := breakerHook{b: b}

	called := false
	process := hook.ProcessHook(func(context.Context, redis.Cmder) error {
		called = true
		return nil
	})

	cmd := redis.NewStringCmd(context.Background(), "get", "k")
	err := process(context.Background(), cmd)

	if called {
		t.Fatal("the hook called through to Redis while the breaker was open")
	}
	if !errors.Is(err, ErrCircuitOpen) || !errors.Is(cmd.Err(), ErrCircuitOpen) {
		t.Fatalf("err = %v, cmd.Err() = %v, want ErrCircuitOpen on both", err, cmd.Err())
	}
	if errors.Is(cmd.Err(), ErrKeyNotFound) {
		t.Fatal("ErrCircuitOpen matched ErrKeyNotFound; an outage would read as an empty cache")
	}
}
