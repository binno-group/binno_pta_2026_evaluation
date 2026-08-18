package identity

import (
	"testing"
)

// The UNIQUE constraint on users.phone is only worth as much as the
// normalisation in front of it.
func TestNormalizePhoneCollapsesEquivalentForms(t *testing.T) {
	t.Parallel()
	const want = "998901234567"
	for _, raw := range []string{
		"998901234567",
		"+998901234567",
		"+998 90 123 45 67",
		"998-90-123-45-67",
		"901234567",  // local, no country code
		"0901234567", // national prefix
		" 998901234567 ",
	} {
		got, err := NormalizePhone(raw)
		if err != nil {
			t.Errorf("NormalizePhone(%q) error = %v", raw, err)
			continue
		}
		if got != want {
			t.Errorf("NormalizePhone(%q) = %q, want %q", raw, got, want)
		}
	}
}

func TestNormalizePhoneRejectsNonUzbekAndMalformed(t *testing.T) {
	t.Parallel()
	for _, raw := range []string{
		"",
		"99890123456",   // one digit short
		"9989012345678", // one digit long
		"79001234567",   // wrong country
		"abcdefghijkl",
		"+1 555 010 9999",
	} {
		if got, err := NormalizePhone(raw); err == nil {
			t.Errorf("NormalizePhone(%q) = %q, want an error", raw, got)
		}
	}
}

// A refresh token is a bearer credential with a 30-day life.
func TestRefreshTokensAreUniqueAndStoredHashed(t *testing.T) {
	t.Parallel()
	seen := make(map[string]bool, 512)
	for i := 0; i < 512; i++ {
		token, err := newRefreshToken()
		if err != nil {
			t.Fatalf("newRefreshToken: %v", err)
		}
		if seen[token] {
			t.Fatal("newRefreshToken produced a duplicate")
		}
		seen[token] = true

		digest := hashToken(token)
		if len(digest) != 32 {
			t.Fatalf("hashToken length = %d, want 32", len(digest))
		}
		if string(digest) == token {
			t.Fatal("hashToken returned the token itself")
		}
	}
}

func TestHashTokenIsDeterministicAndDistinguishing(t *testing.T) {
	t.Parallel()
	first, second := string(hashToken("a")), string(hashToken("a"))
	if first != second {
		t.Error("hashToken is not deterministic; stored tokens could never be found")
	}
	if first == string(hashToken("b")) {
		t.Error("hashToken collides on distinct inputs")
	}
}
