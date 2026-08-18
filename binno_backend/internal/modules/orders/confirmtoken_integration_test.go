//go:build integration

package orders_test

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"testing"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/testutil/seed"
)

// insertConfirmToken files a token for the order the way Create does, with the
// expiry the test needs, and returns the plaintext the SMS would have carried.
func insertConfirmToken(t *testing.T, s *stack, orderID, storeID string, ttl time.Duration) string {
	t.Helper()
	token := uuid.NewString()
	digest := sha256.Sum256([]byte(token))
	if _, err := s.pool.Exec(context.Background(),
		`INSERT INTO orders.confirm_tokens (token_hash, order_id, store_id, expires_at)
		 VALUES ($1, $2, $3, $4)`,
		hex.EncodeToString(digest[:]), orderID, storeID, time.Now().UTC().Add(ttl)); err != nil {
		t.Fatalf("insert confirm token: %v", err)
	}
	return token
}

// The SMS confirmation token is a bearer credential: it must die on its expiry
// and on its first use, whichever comes first.
func TestConfirmTokenRejectsExpiredAndUsedTokens(t *testing.T) {
	s := newStack(t)
	w := seed.Marketplace(t, s.pool, seed.Config{})
	orderID := placeOrder(t, s, w, w.ProductID, "1")
	now := time.Now().UTC()

	expired := insertConfirmToken(t, s, orderID, w.StoreID, -time.Hour)
	if err := s.repo.ConfirmToken(opCtx(), orderID, expired, now); !errors.Is(err, orders.ErrGone) {
		t.Errorf("expired token: err = %v, want ErrGone", err)
	}
	if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusCreated) {
		t.Errorf("expired token moved the order to %q", got)
	}

	unknown := uuid.NewString()
	if err := s.repo.ConfirmToken(opCtx(), orderID, unknown, now); !errors.Is(err, orders.ErrGone) {
		t.Errorf("unknown token: err = %v, want ErrGone", err)
	}

	valid := insertConfirmToken(t, s, orderID, w.StoreID, time.Hour)
	if err := s.repo.ConfirmToken(opCtx(), orderID, valid, now); err != nil {
		t.Fatalf("valid token: %v, want confirmation", err)
	}
	if got := orderStatus(t, s.pool, orderID); got != string(orders.StatusAwaitingPayment) {
		t.Errorf("confirmed order status = %q, want awaiting_payment", got)
	}

	// The same token again — a forwarded SMS, a retried link — is spent.
	if err := s.repo.ConfirmToken(opCtx(), orderID, valid, now.Add(time.Second)); !errors.Is(err, orders.ErrGone) {
		t.Errorf("reused token: err = %v, want ErrGone", err)
	}
}
