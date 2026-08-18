package httpx

import (
	"fmt"
	"net"
	"net/http"
	"net/netip"
	"strings"
)

// TrustedProxies resolves the address a request is attributed to when the
// service runs behind reverse proxies.
type TrustedProxies struct {
	prefixes []netip.Prefix
}

// NewTrustedProxies parses the CIDR blocks whose members may speak for the
// client through X-Forwarded-For.
func NewTrustedProxies(cidrs []string) (*TrustedProxies, error) {
	prefixes := make([]netip.Prefix, 0, len(cidrs))
	for _, raw := range cidrs {
		entry := strings.TrimSpace(raw)
		if entry == "" {
			continue
		}
		prefix, err := parseTrustedEntry(entry)
		if err != nil {
			return nil, err
		}
		prefixes = append(prefixes, prefix)
	}
	if len(prefixes) == 0 {
		return nil, nil
	}
	return &TrustedProxies{prefixes: prefixes}, nil
}

// ClientIP returns the address r should be attributed to.
func (p *TrustedProxies) ClientIP(r *http.Request) string {
	peer := peerIP(r)
	if p == nil || len(p.prefixes) == 0 {
		return peer
	}
	peerAddr, err := netip.ParseAddr(peer)
	if err != nil || !p.trusts(peerAddr) {
		return peer
	}

	hops := forwardedHops(r)
	for i := len(hops) - 1; i >= 0; i-- {
		addr, err := netip.ParseAddr(hops[i])
		if err != nil {
			return peer
		}
		if !p.trusts(addr) {
			return addr.Unmap().String()
		}
	}
	return peer
}

func (p *TrustedProxies) trusts(addr netip.Addr) bool {
	addr = addr.Unmap()
	for _, prefix := range p.prefixes {
		if prefix.Contains(addr) {
			return true
		}
	}
	return false
}

// forwardedHops flattens X-Forwarded-For into hop order.
func forwardedHops(r *http.Request) []string {
	var hops []string
	for _, line := range r.Header.Values("X-Forwarded-For") {
		for _, hop := range strings.Split(line, ",") {
			if hop = strings.TrimSpace(hop); hop != "" {
				hops = append(hops, hop)
			}
		}
	}
	return hops
}

func parseTrustedEntry(entry string) (netip.Prefix, error) {
	if prefix, err := netip.ParsePrefix(entry); err == nil {
		return prefix.Masked(), nil
	}
	addr, err := netip.ParseAddr(entry)
	if err != nil {
		return netip.Prefix{}, fmt.Errorf(
			"httpx: trusted proxy %q is neither an IP address nor a CIDR block", entry)
	}
	addr = addr.Unmap()
	return netip.PrefixFrom(addr, addr.BitLen()), nil
}

// peerIP is the transport peer address, with the ephemeral port stripped.
func peerIP(r *http.Request) string {
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}
