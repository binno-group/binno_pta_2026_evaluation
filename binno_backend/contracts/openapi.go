// Package contracts embeds the public API contract and Swagger UI.
package contracts

import (
	"crypto/sha256"
	_ "embed"
	"encoding/base64"
	"fmt"
	"net/http"
)

//go:embed binno-openapi-v1.yaml
var openAPI []byte

// swaggerUIVersion is pinned exactly, not floated at `@5`.
const (
	swaggerUIVersion  = "5.17.14"
	swaggerCSSHash    = "sha384-wxLW6kwyHktdDGr6Pv1zgm/VGJh99lfUbzSn6HNHBENZlCN7W602k9VkGdxuFvPn"
	swaggerBundleHash = "sha384-wmyclcVGX/WhUkdkATwhaK1X1JtiNrr2EoYJ+diV3vj4v6OC5yCeSu+yW13SYJep"
)

// swaggerBootstrap is the inline script that starts Swagger UI once the bundle
// has loaded.
func swaggerBootstrap() string {
	return `
    SwaggerUIBundle({url: "/docs/openapi.yaml", dom_id: "#swagger-ui", validatorUrl: null});
  `
}

// swaggerCSP confines the docs page to the one CDN it needs.
func swaggerCSP() string {
	sum := sha256.Sum256([]byte(swaggerBootstrap()))
	return "default-src 'none'; " +
		"script-src https://unpkg.com 'sha256-" + base64.StdEncoding.EncodeToString(sum[:]) + "'; " +
		"style-src https://unpkg.com 'unsafe-inline'; " +
		"img-src 'self' data:; " +
		"font-src https://unpkg.com data:; " +
		"connect-src 'self'; " +
		"frame-ancestors 'none'; " +
		"form-action 'none'; " +
		"base-uri 'none'"
}

// swaggerUIPage renders the docs shell.
func swaggerUIPage() string {
	return fmt.Sprintf(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>BINNO API</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@%[1]s/swagger-ui.css"
        integrity="%[2]s" crossorigin="anonymous">
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@%[1]s/swagger-ui-bundle.js"
          integrity="%[3]s" crossorigin="anonymous"></script>
  <script>%[4]s</script>
</body>
</html>`, swaggerUIVersion, swaggerCSSHash, swaggerBundleHash, swaggerBootstrap())
}

func Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Header().Set("Content-Security-Policy", swaggerCSP())
		_, _ = fmt.Fprint(w, swaggerUIPage())
	})
	mux.HandleFunc("GET /openapi.yaml", func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/yaml")
		_, _ = w.Write(openAPI)
	})

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "" {
			r.URL.Path = "/"
		}
		mux.ServeHTTP(w, r)
	})
}
