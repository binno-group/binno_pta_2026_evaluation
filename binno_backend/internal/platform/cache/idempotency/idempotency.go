// Package idempotency implements Redis-backed Idempotency-Key handling for
// financial/business mutations : a 24h TTL response cache keyed by the client-
// supplied key, so a retried request replays the original result instead of re-
// executing the mutation.
package idempotency

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
)

// responseTTL is the replay window mandated by
const responseTTL = 24 * time.Hour

// reservationTTL bounds how long a crashed request can block retries of the same
// key.
const reservationTTL = 5 * time.Minute

// ErrUnavailable is returned when Redis cannot be reached.
var ErrUnavailable = errors.New("idempotency: store unavailable")

// Outcome tells the caller what to do with an Idempotency-Key.
type Outcome int

const (
	// Acquired means the caller owns the key and must execute the mutation.
	Acquired Outcome = iota
	// Replay means a completed response is cached and must be returned as-is.
	Replay
	// InFlight means another request owns the key and has not completed yet.
	InFlight
	// Mismatch means the key was first used for a DIFFERENT request body.
	Mismatch
)

// LegacyFingerprint is the reservation value written before fingerprinting
// existed.
const LegacyFingerprint = "1"

// Fingerprint reduces a request body to a value that can be compared cheaply
// against the one the key was first used with.
func Fingerprint(body []byte) string {
	sum := sha256.Sum256(body)
	return hex.EncodeToString(sum[:])
}

// StoredResponse is the cached outcome of the first request for a given key.
type StoredResponse struct {
	Status int    `json:"status"`
	Body   []byte `json:"body"`
}

// Store reserves idempotency keys and caches their resulting response.
type Store struct {
	redis *redisx.Client
}

// New returns a Store backed by client.
func New(client *redisx.Client) *Store {
	return &Store{redis: client}
}

// Reserve claims key for the caller, binding it to fingerprint.
func (s *Store) Reserve(ctx context.Context, key, fingerprint string) (Outcome, StoredResponse, error) {
	acquired, err := s.redis.SetNX(ctx, reserveKey(key), fingerprint, reservationTTL).Result()
	if err != nil {
		return InFlight, StoredResponse{}, fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	if acquired {
		return Acquired, StoredResponse{}, nil
	}

	seen, err := s.redis.Get(ctx, reserveKey(key)).Result()
	switch {
	case errors.Is(err, redisx.ErrKeyNotFound):
		return InFlight, StoredResponse{}, nil
	case err != nil:
		return InFlight, StoredResponse{}, fmt.Errorf("%w: %w", ErrUnavailable, err)
	case seen != LegacyFingerprint && seen != fingerprint:
		return Mismatch, StoredResponse{}, nil
	}

	stored, found, err := s.getResponse(ctx, key)
	if err != nil {
		return InFlight, StoredResponse{}, err
	}
	if !found {
		return InFlight, StoredResponse{}, nil
	}
	return Replay, stored, nil
}

// SaveResponse records the response produced for key so replays return it
// verbatim instead of re-running the mutation.
func (s *Store) SaveResponse(ctx context.Context, key string, response StoredResponse) error {
	encoded, err := json.Marshal(response)
	if err != nil {
		return fmt.Errorf("idempotency: encode response for %s: %w", key, err)
	}
	if err := s.redis.Set(ctx, responseKey(key), encoded, responseTTL).Err(); err != nil {
		return fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	if err := s.redis.Expire(ctx, reserveKey(key), responseTTL).Err(); err != nil {
		return fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	return nil
}

// Release drops the reservation for key after a mutation failed, so the client
// may retry immediately instead of waiting out reservationTTL.
func (s *Store) Release(ctx context.Context, key string) error {
	if err := s.redis.Del(ctx, reserveKey(key)).Err(); err != nil {
		return fmt.Errorf("%w: %w", ErrUnavailable, err)
	}
	return nil
}

func (s *Store) getResponse(ctx context.Context, key string) (StoredResponse, bool, error) {
	encoded, err := s.redis.Get(ctx, responseKey(key)).Bytes()
	if errors.Is(err, redisx.ErrKeyNotFound) {
		return StoredResponse{}, false, nil
	}
	if err != nil {
		return StoredResponse{}, false, fmt.Errorf("%w: %w", ErrUnavailable, err)
	}

	var response StoredResponse
	if err := json.Unmarshal(encoded, &response); err != nil {
		return StoredResponse{}, false, fmt.Errorf("idempotency: decode response for %s: %w", key, err)
	}
	return response, true, nil
}

func reserveKey(key string) string  { return "idempotency:reserve:" + key }
func responseKey(key string) string { return "idempotency:response:" + key }
