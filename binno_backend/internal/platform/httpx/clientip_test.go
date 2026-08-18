package httpx_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

func mustTrustedProxies(t *testing.T, cidrs ...string) *httpx.TrustedProxies {
	t.Helper()
	proxies, err := httpx.NewTrustedProxies(cidrs)
	if err != nil {
		t.Fatalf("NewTrustedProxies(%v) = %v", cidrs, err)
	}
	return proxies
}

func requestFrom(peer string, forwarded ...string) *http.Request {
	r := httptest.NewRequest(http.MethodGet, "/api/v1/thing", nil)
	r.RemoteAddr = peer
	for _, line := range forwarded {
		r.Header.Add("X-Forwarded-For", line)
	}
	return r
}

// The zero configuration is the directly-exposed deployment, where the header is
// attacker-controlled and the peer is the only address that means anything.
func TestClientIP_WithoutTrustedProxiesIgnoresForwardedFor(t *testing.T) {
	var none *httpx.TrustedProxies

	got := none.ClientIP(requestFrom("203.0.113.7:54321", "198.51.100.99"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the transport peer", got)
	}
}

// A peer outside the trusted set is an ordinary client, so anything it claims
// about earlier hops is its own invention and must not be read.
func TestClientIP_IgnoresForwardedForFromUntrustedPeer(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("203.0.113.7:54321", "198.51.100.99"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the transport peer", got)
	}
}

func TestClientIP_UsesForwardedForFromTrustedPeer(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "203.0.113.7"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the address the proxy observed", got)
	}
}

// The spoof this whole type exists to defeat.
func TestClientIP_IgnoresHopsPrependedByTheCaller(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "1.1.1.1, 2.2.2.2, 203.0.113.7"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the address the trusted proxy appended", got)
	}
}

// Two proxies in front of the service: the inner one is trusted and is crossed,
// the walk stops on the client the outer one recorded.
func TestClientIP_CrossesEveryTrustedHop(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8", "192.168.0.0/16")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "203.0.113.7, 192.168.10.2"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the client behind both proxies", got)
	}
}

// The header may arrive as several lines; their concatenation in order is the
// chain, so a client cannot hide a hop by splitting the header.
func TestClientIP_FlattensRepeatedHeaderLines(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "1.1.1.1", "203.0.113.7"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the last hop across both header lines", got)
	}
}

// A chain that cannot be parsed cannot be vouched for.
func TestClientIP_FallsBackToPeerOnMalformedHop(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "203.0.113.7, not-an-ip"))

	if got != "10.1.0.4" {
		t.Fatalf("ClientIP = %q, want the transport peer", got)
	}
}

// Every hop being a trusted proxy means the request never carried a client
// address this deployment can tell apart, so the peer stays the answer.
func TestClientIP_FallsBackToPeerWhenEveryHopIsTrusted(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "10.2.0.9, 10.3.0.1"))

	if got != "10.1.0.4" {
		t.Fatalf("ClientIP = %q, want the transport peer", got)
	}
}

// A dual-stack listener reports an IPv4 proxy as ::ffff:10.1.0.4.
func TestClientIP_TrustsIPv4MappedProxyAddress(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.0.0.0/8")

	got := proxies.ClientIP(requestFrom("[::ffff:10.1.0.4]:41000", "203.0.113.7"))

	if got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the proxy to be trusted despite the v4-mapped form", got)
	}
}

func TestNewTrustedProxies_AcceptsBareAddresses(t *testing.T) {
	proxies := mustTrustedProxies(t, "10.1.0.4")

	if got := proxies.ClientIP(requestFrom("10.1.0.4:41000", "203.0.113.7")); got != "203.0.113.7" {
		t.Fatalf("ClientIP = %q, want the bare address to be trusted", got)
	}
	if got := proxies.ClientIP(requestFrom("10.1.0.5:41000", "203.0.113.7")); got != "10.1.0.5" {
		t.Fatalf("ClientIP = %q, want a bare address to trust exactly one host", got)
	}
}

// Trusting nothing is a valid configuration, not an error: it is what a service
// on a public port wants.
func TestNewTrustedProxies_EmptyListTrustsNothing(t *testing.T) {
	proxies, err := httpx.NewTrustedProxies([]string{"", "   "})
	if err != nil {
		t.Fatalf("NewTrustedProxies = %v, want no error", err)
	}
	if proxies != nil {
		t.Fatal("an empty list must yield a nil *TrustedProxies")
	}
}

// A typo must stop the boot.
func TestNewTrustedProxies_RejectsMalformedEntries(t *testing.T) {
	for _, entry := range []string{"10.0.0.0/99", "not-an-ip", "10.0.0.0/8extra"} {
		if _, err := httpx.NewTrustedProxies([]string{entry}); err == nil {
			t.Errorf("NewTrustedProxies(%q) accepted a malformed entry", entry)
		}
	}
}
