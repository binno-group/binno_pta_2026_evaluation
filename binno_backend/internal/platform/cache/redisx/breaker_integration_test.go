package redisx

import (
	"context"
	"errors"
	"io"
	"net"
	"os"
	"sync"
	"testing"
	"time"
)

// The state-machine tests in breaker_test.go drive the breaker directly.

// proxy is a TCP forwarder that can be broken and repaired, standing in for a
// Redis that goes away and comes back.
type proxy struct {
	mu       sync.Mutex
	ln       net.Listener
	upstream string
	addr     string
	closed   bool
	// live connections, so a break drops the ones already established.
	conns []net.Conn
}

func newProxy(t *testing.T, upstream string) *proxy {
	t.Helper()
	p := &proxy{upstream: upstream}
	p.start(t)
	p.addr = p.ln.Addr().String()
	t.Cleanup(func() { p.breakLink() })
	return p
}

func (p *proxy) start(t *testing.T) {
	t.Helper()
	var err error
	addr := "127.0.0.1:0"
	if p.addr != "" {
		addr = p.addr
	}
	p.ln, err = net.Listen("tcp", addr)
	if err != nil {
		t.Fatalf("listen on %s: %v", addr, err)
	}
	p.closed = false
	ln := p.ln
	go func() {
		for {
			client, err := ln.Accept()
			if err != nil {
				return
			}
			p.mu.Lock()
			p.conns = append(p.conns, client)
			p.mu.Unlock()
			go func() {
				defer func() { _ = client.Close() }()
				server, err := net.DialTimeout("tcp", p.upstream, 2*time.Second)
				if err != nil {
					return
				}
				defer func() { _ = server.Close() }()
				go func() { _, _ = io.Copy(server, client) }()
				_, _ = io.Copy(client, server)
			}()
		}
	}()
}

func (p *proxy) breakLink() {
	p.mu.Lock()
	defer p.mu.Unlock()
	if !p.closed && p.ln != nil {
		_ = p.ln.Close()
		for _, c := range p.conns {
			_ = c.Close()
		}
		p.conns = nil
		p.closed = true
	}
}

func (p *proxy) repair(t *testing.T) {
	t.Helper()
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.closed {
		p.start(t)
	}
}

func TestBreaker_RecoversWhenRedisComesBack(t *testing.T) {
	upstream := os.Getenv("TEST_REDIS_ADDR")
	if upstream == "" {
		t.Skip("TEST_REDIS_ADDR not set")
	}

	p := newProxy(t, upstream)
	client := New(Config{
		Addr:             p.addr,
		Timeout:          200 * time.Millisecond,
		BreakerCooldown:  200 * time.Millisecond,
		FailureThreshold: 2,
	})
	t.Cleanup(func() { _ = client.Close() })

	ctx := context.Background()
	if err := client.Ping(ctx); err != nil {
		t.Fatalf("redis unreachable through the proxy: %v", err)
	}
	if client.BreakerOpen() {
		t.Fatal("breaker is open against a healthy redis")
	}

	p.breakLink()
	for i := range 10 {
		if err := client.Ping(ctx); err == nil {
			continue
		}
		if client.BreakerOpen() {
			break
		}
		if i == 9 {
			t.Fatal("breaker never opened after repeated failures")
		}
	}
	if !client.BreakerOpen() {
		t.Fatal("breaker did not open while the dependency was unreachable")
	}

	start := time.Now()
	err := client.Ping(ctx)
	elapsed := time.Since(start)
	if !errors.Is(err, ErrCircuitOpen) {
		t.Fatalf("open breaker returned %v, want ErrCircuitOpen", err)
	}
	if elapsed > 20*time.Millisecond {
		t.Fatalf("short-circuited call took %v; the point is to fail instantly", elapsed)
	}

	p.repair(t)

	deadline := time.Now().Add(10 * time.Second)
	var lastErr error
	for time.Now().Before(deadline) {
		lastErr = client.Ping(ctx)
		if lastErr == nil && !client.BreakerOpen() {
			return // recovered
		}
		time.Sleep(50 * time.Millisecond)
	}
	t.Fatalf("breaker never closed after the dependency recovered: open=%v lastErr=%v",
		client.BreakerOpen(), lastErr)
}
