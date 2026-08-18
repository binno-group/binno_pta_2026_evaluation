//go:build integration

package otp_test

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

func newStore(t *testing.T) *otp.Store {
	t.Helper()
	addr := os.Getenv("TEST_REDIS_ADDR")
	if addr == "" {
		t.Skip("TEST_REDIS_ADDR not set")
	}
	client := redisx.New(redisx.Config{Addr: addr})
	if err := client.Ping(context.Background()); err != nil {
		t.Skipf("redis unreachable at %s: %v", addr, err)
	}
	t.Cleanup(func() { _ = client.Close() })
	return otp.New(client)
}

// A code is spent by its first successful use; presenting it again is
// indistinguishable from never having had one.
func TestVerifiedCodeIsSingleUse(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	phone := seed.Phone()

	code, err := store.Issue(ctx, phone)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}
	if err := store.Verify(ctx, phone, code); err != nil {
		t.Fatalf("first verify: %v, want success", err)
	}
	if err := store.Verify(ctx, phone, code); !errors.Is(err, otp.ErrNotFound) {
		t.Errorf("second verify: err = %v, want ErrNotFound", err)
	}
}

// Wrong guesses are counted and bounded: past the limit the code is destroyed,
// so even the right code no longer works.
func TestRepeatedWrongGuessesDestroyTheCode(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	phone := seed.Phone()

	code, err := store.Issue(ctx, phone)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}

	var throttled bool
	for attempt := 0; attempt <= otp.MaxAttempts; attempt++ {
		err := store.Verify(ctx, phone, "000000x")
		if errors.Is(err, otp.ErrTooManyAttempts) {
			throttled = true
			break
		}
		if !errors.Is(err, otp.ErrMismatch) {
			t.Fatalf("wrong guess %d: err = %v, want ErrMismatch or ErrTooManyAttempts", attempt, err)
		}
	}
	if !throttled {
		t.Fatalf("%d wrong guesses never tripped the attempt limit", otp.MaxAttempts+1)
	}
	if err := store.Verify(ctx, phone, code); !errors.Is(err, otp.ErrNotFound) {
		t.Errorf("right code after the limit: err = %v, want ErrNotFound (code destroyed)", err)
	}
}

// Re-requesting a code inside the cooldown window is throttled; the throttle
// lifts once the outstanding state is gone.
func TestReissueIsThrottledByCooldownAndRecovers(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	phone := seed.Phone()

	if _, err := store.Issue(ctx, phone); err != nil {
		t.Fatalf("issue: %v", err)
	}
	if _, err := store.Issue(ctx, phone); !errors.Is(err, otp.ErrCooldown) {
		t.Errorf("immediate re-issue: err = %v, want ErrCooldown", err)
	}
	// Cancel clears the outstanding code and cooldown — the state Redis reaches
	// by TTL expiry, without the test waiting for it.
	if err := store.Cancel(ctx, phone); err != nil {
		t.Fatalf("cancel: %v", err)
	}
	if _, err := store.Issue(ctx, phone); err != nil {
		t.Errorf("re-issue after recovery: %v, want success", err)
	}
}

// After expiry Redis holds nothing for the phone; a late submission is
// rejected as unknown, not matched against a stale code.
func TestExpiredCodeIsRejected(t *testing.T) {
	store := newStore(t)
	ctx := context.Background()
	phone := seed.Phone()

	code, err := store.Issue(ctx, phone)
	if err != nil {
		t.Fatalf("issue: %v", err)
	}
	if err := store.Cancel(ctx, phone); err != nil {
		t.Fatalf("cancel (stand-in for TTL expiry): %v", err)
	}
	if err := store.Verify(ctx, phone, code); !errors.Is(err, otp.ErrNotFound) {
		t.Errorf("verify after expiry: err = %v, want ErrNotFound", err)
	}
}
