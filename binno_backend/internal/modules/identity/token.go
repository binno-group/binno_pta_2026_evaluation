package identity

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"time"
)

// refreshTokenBytes is the entropy in a refresh token.
const refreshTokenBytes = 32

// newRefreshToken returns a fresh opaque token.
func newRefreshToken() (string, error) {
	buf := make([]byte, refreshTokenBytes)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("identity: generate refresh token: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

// hashToken digests a token for storage and lookup.
func hashToken(token string) []byte {
	sum := sha256.Sum256([]byte(token))
	return sum[:]
}

// User is an account.
type User struct {
	ID          string
	Phone       string
	Status      string
	CreatedAt   time.Time
	LastLoginAt *time.Time
}

// Account statuses.
const (
	StatusActive  = "active"
	StatusBlocked = "blocked"
)

// RefreshRecord is one stored refresh token.
type RefreshRecord struct {
	ID          string
	UserID      string
	TokenHash   []byte
	IssuedAt    time.Time
	ExpiresAt   time.Time
	RevokedAt   *time.Time
	RotatedFrom *string
	// UserStatus is the owning account's status at lookup time, so the refresh
	// path can refuse a blocked user.
	UserStatus string
}

// RoleFlags are the capabilities the repository derives for a user.
type RoleFlags struct {
	Seller   bool
	Operator bool
}
