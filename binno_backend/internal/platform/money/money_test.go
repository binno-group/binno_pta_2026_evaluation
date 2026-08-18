package money_test

import (
	"errors"
	"math"
	"strconv"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/money"
)

func TestMultiplyIsExactAndRoundsHalfUp(t *testing.T) {
	t.Parallel()
	tests := []struct {
		quantity  string
		unitPrice int64
		want      int64
		reason    string
	}{
		{"1", 250_000, 250_000, "whole quantity"},
		{"2.5", 100_000, 250_000, "exact half quantity"},
		{"0.1", 3, 0, "0.3 rounds down"},
		{"0.5", 3, 2, "1.5 rounds half away from zero"},
		{"0.5", 1, 1, "0.5 rounds up, not to even"},
		{"1.5", 1, 2, "1.5 rounds up, not to even"},
		{"0.005", 100, 1, "0.5 at the boundary rounds up"},
		{"3.33", 30_000, 99_900, "no binary representation error"},
		{"0.1", 30, 3, "decimal that has no exact float64 form"},
	}
	for _, test := range tests {
		got, err := money.Multiply(test.quantity, test.unitPrice)
		if err != nil {
			t.Errorf("Multiply(%q, %d) error = %v", test.quantity, test.unitPrice, err)
			continue
		}
		if got != test.want {
			t.Errorf("Multiply(%q, %d) = %d, want %d (%s)",
				test.quantity, test.unitPrice, got, test.want, test.reason)
		}
	}
}

func TestMultiplyRejectsUnrepresentable(t *testing.T) {
	t.Parallel()
	for _, quantity := range []string{"", "abc", "-1", "1e5", "1,5", "nan"} {
		if _, err := money.Multiply(quantity, 100); !errors.Is(err, money.ErrNotRepresentable) {
			t.Errorf("Multiply(%q, 100) error = %v, want ErrNotRepresentable", quantity, err)
		}
	}
}

// A quantity large enough to overflow int64 tiyin must be refused rather than
// silently wrapping into a negative amount.
func TestMultiplyRefusesOverflowInsteadOfWrapping(t *testing.T) {
	t.Parallel()
	huge := strconv.FormatInt(math.MaxInt64, 10)
	if _, err := money.Multiply(huge, math.MaxInt64); !errors.Is(err, money.ErrNotRepresentable) {
		t.Fatalf("Multiply(maxint, maxint) error = %v, want ErrNotRepresentable", err)
	}
}

func TestApplyBasisPoints(t *testing.T) {
	t.Parallel()
	tests := []struct {
		amount int64
		bps    int32
		want   int64
	}{
		{1_000_000, 250, 25_000}, // 2.5%
		{999, 250, 25},           // 24.975 rounds up
		{0, 250, 0},
		{1_000_000, 0, 0},
	}
	for _, test := range tests {
		got, err := money.ApplyBasisPoints(test.amount, test.bps)
		if err != nil {
			t.Errorf("ApplyBasisPoints(%d, %d) error = %v", test.amount, test.bps, err)
			continue
		}
		if got != test.want {
			t.Errorf("ApplyBasisPoints(%d, %d) = %d, want %d", test.amount, test.bps, got, test.want)
		}
	}
}

func TestDecimalValidation(t *testing.T) {
	t.Parallel()
	positive := []string{"1", "0.5", "12.25", "100"}
	for _, value := range positive {
		if !money.IsPositiveDecimal(value) {
			t.Errorf("IsPositiveDecimal(%q) = false, want true", value)
		}
	}
	rejected := []string{"", "0", "0.0", ".5", "5.", "1.2.3", "-1", "1e3", " 1"}
	for _, value := range rejected {
		if money.IsPositiveDecimal(value) {
			t.Errorf("IsPositiveDecimal(%q) = true, want false", value)
		}
	}
	if !money.IsNonNegativeDecimal("0") {
		t.Error("IsNonNegativeDecimal(\"0\") = false, want true")
	}
	if money.IsNonNegativeDecimal(".5") {
		t.Error("IsNonNegativeDecimal(\".5\") = true, want false")
	}
}
