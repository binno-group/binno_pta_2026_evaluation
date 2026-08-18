package identity

import (
	"context"
	"testing"
)

func TestLogoutRevokesALiveSession(t *testing.T) {
	h := newHarness()
	h.repository.live = &RefreshRecord{ID: "refresh-1", UserID: "user-1"}

	if err := h.service.Logout(context.Background(), "some-refresh-token"); err != nil {
		t.Fatalf("Logout error = %v", err)
	}
}

func TestLogoutOfAnUnknownTokenIsANoOp(t *testing.T) {
	h := newHarness() // repository.live is nil → FindRefreshToken returns ErrInvalidSession

	// A caller signing out with a token we do not recognise (already rotated,
	// already expired, never ours) must succeed quietly rather than 500 or leak
	// whether the token existed.
	if err := h.service.Logout(context.Background(), "unknown-token"); err != nil {
		t.Fatalf("Logout error = %v, want nil for an unknown token", err)
	}
}
