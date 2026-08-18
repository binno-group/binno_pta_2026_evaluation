// Package identity issues the credentials the rest of the API validates.
package identity

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// Service errors.
var (
	ErrInvalidPhone   = errors.New("identity: invalid phone number")
	ErrInvalidCode    = errors.New("identity: invalid or expired code")
	ErrCooldown       = errors.New("identity: a code was already sent recently")
	ErrInvalidSession = errors.New("identity: refresh token is not valid")
	ErrBlocked        = errors.New("identity: account is blocked")
)

// RefreshTokenTTL is how long a session survives without use.
const RefreshTokenTTL = 30 * 24 * time.Hour

// phonePattern accepts Uzbek numbers in normalised form: 998 followed by nine
// digits.
var phonePattern = regexp.MustCompile(`^998[0-9]{9}$`)

// nonDigits strips everything a human might type between digits.
var nonDigits = regexp.MustCompile(`[^0-9]`)

// NormalizePhone reduces user input to the single stored form.
func NormalizePhone(raw string) (string, error) {
	digits := nonDigits.ReplaceAllString(strings.TrimSpace(raw), "")
	switch {
	case len(digits) == 9:
		digits = "998" + digits
	case len(digits) == 10 && strings.HasPrefix(digits, "0"):
		digits = "998" + digits[1:]
	}
	if !phonePattern.MatchString(digits) {
		return "", ErrInvalidPhone
	}
	return digits, nil
}

// Tokens is one issued session.
type Tokens struct {
	AccessToken  string
	RefreshToken string
	ExpiresIn    int64
}

// Session is what a successful verification produces: the tokens, plus the one
// fact about the account a client cannot work out for itself.
type Session struct {
	Tokens
	// IsNewUser reports that this verification created the account rather than
	// logging in to an existing one, so the client can route a first-time user into
	// onboarding instead of straight to the feed.
	IsNewUser bool
}

type repository interface {
	UpsertUser(ctx context.Context, phone string, now time.Time) (User, bool, error)
	RolesFor(ctx context.Context, userID string) (RoleFlags, error)
	StoreRefreshToken(ctx context.Context, in RefreshRecord) error
	FindRefreshToken(ctx context.Context, hash []byte) (RefreshRecord, error)
	RevokeRefreshToken(ctx context.Context, id string, now time.Time) (int64, error)
	RevokeAllUserTokens(ctx context.Context, userID string, now time.Time) error
}

// signer mints access tokens.
type signer interface {
	Sign(subject string, roles []authz.Role, now time.Time) (string, error)
	TTL() time.Duration
}

// codes issues and consumes one-time codes.
type codes interface {
	Issue(ctx context.Context, phone string) (string, error)
	Verify(ctx context.Context, phone, code string) error
	// Cancel withdraws an undelivered code and its cooldown.
	Cancel(ctx context.Context, phone string) error
}

// Service implements phone + OTP authentication.
type Service struct {
	repository repository
	otp        codes
	sender     sms.Sender
	signer     signer
	clock      clock.Clock
}

// NewService wires the identity service.
func NewService(r repository, c codes, sender sms.Sender, s signer, clk clock.Clock) *Service {
	return &Service{repository: r, otp: c, sender: sender, signer: s, clock: clk}
}

// RequestCode sends a one-time code to phone.
func (s *Service) RequestCode(ctx context.Context, rawPhone string) error {
	phone, err := NormalizePhone(rawPhone)
	if err != nil {
		return err
	}
	code, err := s.otp.Issue(ctx, phone)
	switch {
	case errors.Is(err, otp.ErrCooldown):
		return ErrCooldown
	case err != nil:
		return fmt.Errorf("identity: issue code: %w", err)
	}

	if err := s.sender.Send(ctx, phone, "BINNO tasdiqlash kodi: "+code); err != nil {
		if errors.Is(err, sms.ErrUndeliverable) {
			// The number itself was refused; keeping the cooldown throttles
			// probing of invalid numbers.
			return fmt.Errorf("%w: %v", ErrInvalidPhone, err)
		}
		// A gateway hiccup is not the user's fault: withdraw the cooldown so
		// they can retry immediately instead of waiting it out codeless. The
		// rate limiter still bounds how often that retry can happen.
		if cancelErr := s.otp.Cancel(ctx, phone); cancelErr != nil {
			return fmt.Errorf("identity: deliver code: %w (cooldown not withdrawn: %v)", err, cancelErr)
		}
		return fmt.Errorf("identity: deliver code: %w", err)
	}
	return nil
}

// VerifyCode consumes a code and issues a session.
func (s *Service) VerifyCode(ctx context.Context, rawPhone, code string) (Session, error) {
	phone, err := NormalizePhone(rawPhone)
	if err != nil {
		return Session{}, err
	}
	switch err := s.otp.Verify(ctx, phone, code); {
	case errors.Is(err, otp.ErrNotFound),
		errors.Is(err, otp.ErrMismatch),
		errors.Is(err, otp.ErrTooManyAttempts):
		return Session{}, ErrInvalidCode
	case err != nil:
		return Session{}, fmt.Errorf("identity: verify code: %w", err)
	}

	now := s.clock.Now()
	user, registered, err := s.repository.UpsertUser(ctx, phone, now)
	if err != nil {
		return Session{}, err
	}
	if user.Status == StatusBlocked {
		return Session{}, ErrBlocked
	}
	tokens, err := s.issue(ctx, user.ID, now, nil)
	if err != nil {
		return Session{}, err
	}
	return Session{Tokens: tokens, IsNewUser: registered}, nil
}

// Refresh rotates a session.
func (s *Service) Refresh(ctx context.Context, presented string) (Tokens, error) {
	hash := hashToken(presented)
	record, err := s.repository.FindRefreshToken(ctx, hash)
	if errors.Is(err, ErrInvalidSession) {
		return Tokens{}, ErrInvalidSession
	}
	if err != nil {
		return Tokens{}, err
	}

	now := s.clock.Now()
	if record.RevokedAt != nil {
		if err := s.repository.RevokeAllUserTokens(ctx, record.UserID, now); err != nil {
			return Tokens{}, err
		}
		return Tokens{}, ErrInvalidSession
	}
	if record.UserStatus == StatusBlocked {
		// A block ends every session, not just this refresh attempt.
		if err := s.repository.RevokeAllUserTokens(ctx, record.UserID, now); err != nil {
			return Tokens{}, err
		}
		return Tokens{}, ErrBlocked
	}
	if !now.Before(record.ExpiresAt) {
		return Tokens{}, ErrInvalidSession
	}

	rotated, err := s.repository.RevokeRefreshToken(ctx, record.ID, now)
	if err != nil {
		return Tokens{}, err
	}
	if rotated == 0 {
		return Tokens{}, ErrInvalidSession
	}
	return s.issue(ctx, record.UserID, now, &record.ID)
}

// Logout revokes one session.
func (s *Service) Logout(ctx context.Context, presented string) error {
	record, err := s.repository.FindRefreshToken(ctx, hashToken(presented))
	if errors.Is(err, ErrInvalidSession) {
		return nil
	}
	if err != nil {
		return err
	}
	if _, err := s.repository.RevokeRefreshToken(ctx, record.ID, s.clock.Now()); err != nil {
		return err
	}
	return nil
}

// issue mints an access token and a refresh token for a user.
func (s *Service) issue(ctx context.Context, userID string, now time.Time, rotatedFrom *string) (Tokens, error) {
	roles, err := s.rolesFor(ctx, userID)
	if err != nil {
		return Tokens{}, err
	}
	access, err := s.signer.Sign(userID, roles, now)
	if err != nil {
		return Tokens{}, err
	}
	refresh, err := newRefreshToken()
	if err != nil {
		return Tokens{}, err
	}
	if err := s.repository.StoreRefreshToken(ctx, RefreshRecord{
		ID:          uuid.NewString(),
		UserID:      userID,
		TokenHash:   hashToken(refresh),
		IssuedAt:    now,
		ExpiresAt:   now.Add(RefreshTokenTTL),
		RotatedFrom: rotatedFrom,
	}); err != nil {
		return Tokens{}, err
	}
	return Tokens{
		AccessToken:  access,
		RefreshToken: refresh,
		ExpiresIn:    int64(s.signer.TTL().Seconds()),
	}, nil
}

// rolesFor derives the roles a token should carry.
func (s *Service) rolesFor(ctx context.Context, userID string) ([]authz.Role, error) {
	roles := []authz.Role{authz.RoleBuyer}
	flags, err := s.repository.RolesFor(ctx, userID)
	if err != nil {
		return nil, err
	}
	if flags.Seller {
		roles = append(roles, authz.RoleSeller)
	}
	if flags.Operator {
		roles = append(roles, authz.RoleOperator)
	}
	return roles, nil
}
