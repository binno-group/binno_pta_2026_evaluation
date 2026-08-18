// Package tin verifies STIR (taxpayer identification) numbers.
package tin

import (
	"context"
	"errors"
	"regexp"
)

// ErrInvalid marks a number this verifier will not accept.
var ErrInvalid = errors.New("tin: invalid taxpayer number")

// Pattern is the STIR format: exactly nine digits.
var Pattern = regexp.MustCompile(`^[0-9]{9}$`)

// Verifier checks a STIR against an authoritative source.
type Verifier interface {
	// Verify returns nil when the number may be registered.
	Verify(ctx context.Context, number string) error
}

// FormatVerifier accepts any correctly formed number.
type FormatVerifier struct{}

// Verify checks the format only.
func (FormatVerifier) Verify(_ context.Context, number string) error {
	if !Pattern.MatchString(number) {
		return ErrInvalid
	}
	return nil
}
