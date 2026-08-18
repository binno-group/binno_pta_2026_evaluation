package httpx

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

// Signer mints the access tokens that Identity validates.
type Signer struct {
	key []byte
	ttl time.Duration
}

// NewSigner returns a Signer for the given HS256 key and access-token lifetime.
func NewSigner(signingKey string, ttl time.Duration) (*Signer, error) {
	if signingKey == "" {
		return nil, fmt.Errorf("httpx: refusing to sign with an empty key")
	}
	if ttl <= 0 {
		return nil, fmt.Errorf("httpx: access token ttl must be positive, got %s", ttl)
	}
	return &Signer{key: []byte(signingKey), ttl: ttl}, nil
}

// TTL is the access-token lifetime, so a handler can report expires_in without
// re-deriving it.
func (s *Signer) TTL() time.Duration { return s.ttl }

// Sign issues an access token for a principal.
func (s *Signer) Sign(subject string, roles []authz.Role, now time.Time) (string, error) {
	if subject == "" {
		return "", fmt.Errorf("httpx: refusing to sign a token with no subject")
	}
	names := make([]string, 0, len(roles))
	for _, role := range roles {
		if authz.ValidRole(string(role)) {
			names = append(names, string(role))
		}
	}

	header, err := encodeSegment(map[string]string{"alg": "HS256", "typ": "JWT"})
	if err != nil {
		return "", err
	}
	payload, err := encodeSegment(map[string]any{
		"sub":   subject,
		"iat":   now.Unix(),
		"exp":   now.Add(s.ttl).Unix(),
		"roles": names,
	})
	if err != nil {
		return "", err
	}
	signing := header + "." + payload
	mac := hmac.New(sha256.New, s.key)
	_, _ = mac.Write([]byte(signing))
	return signing + "." + base64.RawURLEncoding.EncodeToString(mac.Sum(nil)), nil
}

func encodeSegment(v any) (string, error) {
	raw, err := json.Marshal(v)
	if err != nil {
		return "", fmt.Errorf("httpx: encode jwt segment: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(raw), nil
}
