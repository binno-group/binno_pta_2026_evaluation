// Package otp issues and verifies one-time SMS codes.
package otp

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"fmt"
	"math/big"
	"strconv"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
)

// Errors a caller must distinguish.
var (
	// ErrNotFound means no live code exists for that phone: never requested, or
	// already expired, or already consumed.
	ErrNotFound = errors.New("otp: no code outstanding")
	// ErrMismatch means the code was wrong.
	ErrMismatch = errors.New("otp: code does not match")
	// ErrTooManyAttempts means the code was destroyed after repeated wrong guesses;
	// the caller must request a new one.
	ErrTooManyAttempts = errors.New("otp: too many attempts")
	// ErrCooldown means a code was requested too recently for this phone.
	ErrCooldown = errors.New("otp: a code was already sent recently")
	// ErrUnavailable means Redis could not be reached.
	ErrUnavailable = errors.New("otp: store unavailable")
)

const (
	// CodeTTL is how long a code stays valid.
	CodeTTL = 5 * time.Minute
	// Cooldown bounds how often one phone may be sent a code.
	Cooldown = 60 * time.Second
	// MaxAttempts is how many wrong guesses destroy the code.
	MaxAttempts = 5
	// codeDigits is the code length.
	codeDigits = 6
)

// Store issues and verifies codes.
type Store struct{ client *redisx.Client }

// New creates a Store backed by client.
func New(client *redisx.Client) *Store { return &Store{client: client} }

// Issue creates a code for phone and returns it for delivery.
func (s *Store) Issue(ctx context.Context, phone string) (string, error) {
	ok, err := s.client.SetNX(ctx, cooldownKey(phone), "1", Cooldown).Result()
	if err != nil {
		return "", fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	if !ok {
		return "", ErrCooldown
	}

	code, err := generateCode()
	if err != nil {
		return "", err
	}
	digest := hash(phone, code)

	pipe := s.client.TxPipeline()
	pipe.Set(ctx, codeKey(phone), digest, CodeTTL)
	pipe.Set(ctx, attemptsKey(phone), "0", CodeTTL)
	if _, err := pipe.Exec(ctx); err != nil {
		return "", fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	return code, nil
}

// Verify consumes the code for phone.
func (s *Store) Verify(ctx context.Context, phone, code string) error {
	stored, err := s.client.Get(ctx, codeKey(phone)).Result()
	if errors.Is(err, redisx.ErrKeyNotFound) {
		return ErrNotFound
	}
	if err != nil {
		return fmt.Errorf("%w: %v", ErrUnavailable, err)
	}

	attempts, err := s.client.Incr(ctx, attemptsKey(phone)).Result()
	if err != nil {
		return fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	if attempts > MaxAttempts {
		s.discard(ctx, phone)
		return ErrTooManyAttempts
	}

	if subtle.ConstantTimeCompare([]byte(stored), []byte(hash(phone, code))) != 1 {
		return ErrMismatch
	}
	s.discard(ctx, phone)
	return nil
}

// discard removes the code and its attempt counter.
func (s *Store) discard(ctx context.Context, phone string) {
	s.client.Del(ctx, codeKey(phone), attemptsKey(phone))
}

// Cancel withdraws an issued code and its cooldown, so a phone whose code was
// never delivered may request another immediately. Only for delivery failures
// the user cannot act on; a refused (undeliverable) number keeps its cooldown.
func (s *Store) Cancel(ctx context.Context, phone string) error {
	if err := s.client.Del(ctx, cooldownKey(phone), codeKey(phone), attemptsKey(phone)).Err(); err != nil {
		return fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	return nil
}

// generateCode returns a uniformly distributed decimal code.
func generateCode() (string, error) {
	upper := new(big.Int).Exp(big.NewInt(10), big.NewInt(codeDigits), nil)
	n, err := rand.Int(rand.Reader, upper)
	if err != nil {
		return "", fmt.Errorf("otp: generate code: %w", err)
	}
	return fmt.Sprintf("%0*d", codeDigits, n), nil
}

// hash binds the digest to the phone number, so a digest lifted from one entry
// cannot be replayed against another.
func hash(phone, code string) string {
	sum := sha256.Sum256([]byte(phone + ":" + code))
	return hex.EncodeToString(sum[:])
}

func codeKey(phone string) string     { return "otp:code:" + phone }
func attemptsKey(phone string) string { return "otp:attempts:" + phone }
func cooldownKey(phone string) string { return "otp:cooldown:" + phone }

// RemainingCooldown reports how long until phone may request another code, so
// the API can answer with a Retry-After rather than a bare refusal.
func (s *Store) RemainingCooldown(ctx context.Context, phone string) (time.Duration, error) {
	ttl, err := s.client.TTL(ctx, cooldownKey(phone)).Result()
	if err != nil {
		return 0, fmt.Errorf("%w: %v", ErrUnavailable, err)
	}
	if ttl < 0 {
		return 0, nil
	}
	return ttl, nil
}

// RetryAfterSeconds renders a cooldown as an HTTP Retry-After value.
func RetryAfterSeconds(d time.Duration) string {
	seconds := int(d.Round(time.Second).Seconds())
	if seconds < 1 {
		seconds = 1
	}
	return strconv.Itoa(seconds)
}
