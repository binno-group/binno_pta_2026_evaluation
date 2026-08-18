package httpx

import (
	"net/http"
)

// SecurityHeaders sets the response headers that are the server's to set,
// regardless of what sits in front of it.
func SecurityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := w.Header()
		h.Set("X-Content-Type-Options", "nosniff")
		h.Set("X-Frame-Options", "DENY")
		h.Set("Referrer-Policy", "no-referrer")
		h.Set("Cross-Origin-Resource-Policy", "same-origin")
		h.Set("Cross-Origin-Opener-Policy", "same-origin")
		h.Set("Cross-Origin-Embedder-Policy", "require-corp")
		h.Set("Permissions-Policy", "geolocation=(), camera=(), microphone=(), payment=()")
		h.Set("Content-Security-Policy",
			"default-src 'none'; frame-ancestors 'none'; form-action 'none'; base-uri 'none'")
		next.ServeHTTP(w, r)
	})
}

// NoStore marks business responses uncacheable.
func NoStore(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
