package httpx

import (
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

func TestSignedTokenValidates(t *testing.T) {
	s, err := NewSigner("k", time.Hour)
	if err != nil {
		t.Fatal(err)
	}
	tok, err := s.Sign("018f47f0-7b5b-7cc3-98d7-3ef2863aa742",
		[]authz.Role{authz.RoleBuyer, authz.RoleSeller}, time.Now())
	if err != nil {
		t.Fatal(err)
	}
	p, ok := validateJWT(tok, "k", time.Now())
	if !ok {
		t.Fatal("signer produced a token its own verifier rejects")
	}
	if p.UserID != "018f47f0-7b5b-7cc3-98d7-3ef2863aa742" || len(p.Roles) != 2 {
		t.Fatalf("principal = %+v", p)
	}
	if _, ok := validateJWT(tok, "wrong", time.Now()); ok {
		t.Fatal("token validated under the wrong key")
	}
	if _, ok := validateJWT(tok, "k", time.Now().Add(2*time.Hour)); ok {
		t.Fatal("expired token still validated")
	}
}
