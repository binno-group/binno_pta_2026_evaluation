package contracts_test

import (
	"crypto/sha256"
	"encoding/base64"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/contracts"
)

func TestHandlerServesSwaggerUI(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/", nil)
	response := httptest.NewRecorder()

	contracts.Handler().ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	if !strings.Contains(response.Body.String(), "SwaggerUIBundle") {
		t.Fatal("Swagger UI bootstrap is missing")
	}
}

func TestHandlerServesEmbeddedOpenAPI(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/openapi.yaml", nil)
	response := httptest.NewRecorder()

	contracts.Handler().ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", response.Code, http.StatusOK)
	}
	if !strings.Contains(response.Body.String(), "openapi: 3.1.0") {
		t.Fatal("embedded OpenAPI document is missing")
	}
}

// The page's Content-Security-Policy must permit the page's own bootstrap.
func TestSwaggerCSPAllowsItsOwnBootstrap(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/", nil)
	response := httptest.NewRecorder()

	contracts.Handler().ServeHTTP(response, request)

	body := response.Body.String()
	open := strings.LastIndex(body, "<script>")
	if open < 0 {
		t.Fatal("page has no inline script to bootstrap Swagger UI")
	}
	inline := body[open+len("<script>"):]
	close := strings.Index(inline, "</script>")
	if close < 0 {
		t.Fatal("inline script is unterminated")
	}
	inline = inline[:close]

	if !strings.Contains(inline, "SwaggerUIBundle(") {
		t.Fatalf("inline script does not start Swagger UI: %q", inline)
	}

	sum := sha256.Sum256([]byte(inline))
	want := "'sha256-" + base64.StdEncoding.EncodeToString(sum[:]) + "'"

	csp := response.Header().Get("Content-Security-Policy")
	if !strings.Contains(csp, want) {
		t.Fatalf("CSP does not allow the page's own inline script.\n"+
			"want hash: %s\nscript:    %q\nCSP:       %s", want, inline, csp)
	}
}
