package httpx

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"time"
)

// HealthProbeTimeout bounds the whole probe.
const HealthProbeTimeout = 2 * time.Second

// ProbeHealth performs the liveness check a container healthcheck runs.
func ProbeHealth(ctx context.Context, addr string) error {
	url := "http://" + probeHost(addr) + "/healthz"

	ctx, cancel := context.WithTimeout(ctx, HealthProbeTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("healthcheck: build request for %s: %w", url, err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("healthcheck: %s: %w", url, err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("healthcheck: %s returned %d, want 200", url, resp.StatusCode)
	}
	return nil
}

// probeHost turns a listen address into one that can be dialled from inside the
// same container.
func probeHost(addr string) string {
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		return addr
	}
	if host == "" || host == "0.0.0.0" || host == "::" || host == "[::]" {
		host = "127.0.0.1"
	}
	return net.JoinHostPort(host, port)
}
