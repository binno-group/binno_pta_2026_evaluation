package clock_test

import (
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

func TestFixed_ReturnsPinnedInstant(t *testing.T) {
	at := time.Date(2026, 1, 2, 3, 4, 5, 0, time.FixedZone("UTC+5", 5*60*60))
	c := clock.NewFixed(at)

	got := c.Now()

	if !got.Equal(at) {
		t.Fatalf("Now() = %v, want %v", got, at)
	}
	if got.Location() != time.UTC {
		t.Fatalf("Now() location = %v, want UTC ", got.Location())
	}
}

func TestReal_ReturnsUTC(t *testing.T) {
	c := clock.New()

	got := c.Now()

	if got.Location() != time.UTC {
		t.Fatalf("Now() location = %v, want UTC ", got.Location())
	}
	if time.Since(got) > time.Second {
		t.Fatalf("Now() = %v, too far in the past", got)
	}
}
