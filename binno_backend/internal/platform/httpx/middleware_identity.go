package httpx

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Subject returns the authenticated user ID, or an empty string for a public
// request.
func Subject(ctx context.Context) string { return authz.Subject(ctx) }

// Identity validates optional HS256 bearer tokens and puts the resulting
// principal in the request context.
func Identity(signingKey string, clocks ...clock.Clock) func(http.Handler) http.Handler {
	clk := clock.New()
	if len(clocks) > 0 {
		clk = clocks[0]
	}
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if header == "" {
				next.ServeHTTP(w, r)
				return
			}
			const prefix = "Bearer "
			if !strings.HasPrefix(header, prefix) {
				writeUnauthorized(w, r)
				return
			}
			principal, ok := validateJWT(strings.TrimPrefix(header, prefix), signingKey, clk.Now())
			if !ok {
				writeUnauthorized(w, r)
				return
			}
			next.ServeHTTP(w, r.WithContext(authz.WithPrincipal(r.Context(), principal)))
		})
	}
}

func validateJWT(token, signingKey string, now time.Time) (authz.Principal, bool) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 || signingKey == "" {
		return authz.Principal{}, false
	}

	var header struct {
		Algorithm string `json:"alg"`
		Type      string `json:"typ"`
	}
	headerJSON, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil || json.Unmarshal(headerJSON, &header) != nil ||
		header.Algorithm != "HS256" || (header.Type != "" && header.Type != "JWT") {
		return authz.Principal{}, false
	}

	mac := hmac.New(sha256.New, []byte(signingKey))
	_, _ = mac.Write([]byte(parts[0] + "." + parts[1]))
	signature, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil || !hmac.Equal(signature, mac.Sum(nil)) {
		return authz.Principal{}, false
	}

	var claims struct {
		Subject   string   `json:"sub"`
		Expiry    int64    `json:"exp"`
		NotBefore int64    `json:"nbf"`
		Roles     []string `json:"roles"`
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil || json.Unmarshal(payload, &claims) != nil ||
		uuid.Validate(claims.Subject) != nil {
		return authz.Principal{}, false
	}
	if claims.Expiry <= 0 || now.Unix() >= claims.Expiry {
		return authz.Principal{}, false
	}
	if claims.NotBefore > 0 && now.Unix() < claims.NotBefore {
		return authz.Principal{}, false
	}

	roles := make([]authz.Role, 0, len(claims.Roles))
	for _, role := range claims.Roles {
		if authz.ValidRole(role) {
			roles = append(roles, authz.Role(role))
		}
	}
	return authz.Principal{UserID: claims.Subject, Roles: roles}, true
}

func writeUnauthorized(w http.ResponseWriter, r *http.Request) {
	WriteProblem(w, r, NewAppError("https://binno.uz/problems/unauthorized", "Unauthorized",
		http.StatusUnauthorized, "invalid bearer token", nil))
}
