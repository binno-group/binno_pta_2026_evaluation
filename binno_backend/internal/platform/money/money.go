// Package money implements exact arithmetic on integer tiyin amounts.
package money

import (
	"errors"
	"fmt"
	"math/big"
)

// ErrNotRepresentable reports a quantity that is not a finite decimal or a
// product that does not fit in int64 tiyin.
var ErrNotRepresentable = errors.New("money: amount is not representable")

// Multiply returns quantity * unitPrice in tiyin, rounded half-up.
func Multiply(quantity string, unitPrice int64) (int64, error) {
	if !IsNonNegativeDecimal(quantity) {
		return 0, fmt.Errorf("%w: quantity %q is not a plain decimal", ErrNotRepresentable, quantity)
	}
	rat, ok := new(big.Rat).SetString(quantity)
	if !ok {
		return 0, fmt.Errorf("%w: quantity %q", ErrNotRepresentable, quantity)
	}
	rat.Mul(rat, new(big.Rat).SetInt64(unitPrice))
	return roundHalfUp(rat)
}

// ApplyBasisPoints returns amount * bps / 10000 rounded half-up.
func ApplyBasisPoints(amount int64, bps int32) (int64, error) {
	if bps < 0 {
		return 0, fmt.Errorf("%w: negative basis points %d", ErrNotRepresentable, bps)
	}
	rat := new(big.Rat).SetFrac(
		new(big.Int).Mul(big.NewInt(amount), big.NewInt(int64(bps))),
		big.NewInt(10_000),
	)
	return roundHalfUp(rat)
}

// roundHalfUp reduces an exact rational to int64, rounding halves away from
// zero.
func roundHalfUp(rat *big.Rat) (int64, error) {
	numerator, denominator := rat.Num(), rat.Denom()
	quotient, remainder := new(big.Int).QuoRem(numerator, denominator, new(big.Int))
	if new(big.Int).Lsh(new(big.Int).Abs(remainder), 1).Cmp(denominator) >= 0 {
		if rat.Sign() < 0 {
			quotient.Sub(quotient, big.NewInt(1))
		} else {
			quotient.Add(quotient, big.NewInt(1))
		}
	}
	if !quotient.IsInt64() {
		return 0, fmt.Errorf("%w: %s overflows int64 tiyin", ErrNotRepresentable, quotient)
	}
	return quotient.Int64(), nil
}

// IsPositiveDecimal reports whether value is a well-formed decimal quantity
// greater than zero: digits, at most one interior dot, no sign, no exponent.
func IsPositiveDecimal(value string) bool {
	if value == "" {
		return false
	}
	var seenDot, nonZero bool
	for i, r := range value {
		switch {
		case r >= '0' && r <= '9':
			nonZero = nonZero || r != '0'
		case r == '.':
			if seenDot || i == 0 || i == len(value)-1 {
				return false
			}
			seenDot = true
		default:
			return false
		}
	}
	return nonZero
}

// IsNonNegativeDecimal is IsPositiveDecimal without the "greater than zero"
// requirement: a seller may declare a zero stock quantity.
func IsNonNegativeDecimal(value string) bool {
	if value == "" {
		return false
	}
	var seenDot bool
	for i, r := range value {
		switch {
		case r >= '0' && r <= '9':
		case r == '.':
			if seenDot || i == 0 || i == len(value)-1 {
				return false
			}
			seenDot = true
		default:
			return false
		}
	}
	return true
}
