//go:build routedump

// Command routedump prints every registered "METHOD /path" line by walking the
// real router construction with noop dependencies.
package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/contracts"
	apiModule "github.com/binnoapp-glitch/binno_backend/internal/modules/api"
	operatorModule "github.com/binnoapp-glitch/binno_backend/internal/modules/operator"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

func main() {
	router := httpx.NewRouter(httpx.RouterConfig{
		Logger:         slog.Default(),
		RequestTimeout: 0,
		DocsHandler:    contracts.Handler(),
		Mount: func(r chi.Router) {
			signer, err := httpx.NewSigner("routedump", time.Hour)
			if err != nil {
				panic(err)
			}
			apiModule.New(nil, nil, clock.New(), &apiModule.AuthDeps{
				Codes:  nil,
				Sender: sms.NoopSender{},
				Signer: signer,
			}, nil).Mount(r)
			operatorModule.NewPostgres(nil).Mount(r)
		},
	})

	err := chi.Walk(router, func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		_, err := fmt.Fprintf(os.Stdout, "%s %s\n", method, route)
		return err
	})
	if err != nil {
		_, _ = fmt.Fprintf(os.Stderr, "routedump: walk routes: %v\n", err)
		os.Exit(1)
	}
}
