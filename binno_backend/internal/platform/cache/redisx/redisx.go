// Package redisx wraps go-redis with BINNO's fail-closed contract: Redis is
// never a source of truth.
package redisx

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
)

// ErrKeyNotFound reports a missing key.
var ErrKeyNotFound = redis.Nil

// Config configures the shared Redis client.
type Config struct {
	Addr     string
	Password string
	DB       int
	// Timeout bounds a single dial, read or write.
	Timeout time.Duration
	// PoolSize caps connections per process.
	PoolSize int
	// FailureThreshold is how many consecutive availability failures open the
	// circuit breaker.
	FailureThreshold int64
	// BreakerCooldown is how long the breaker stays open before admitting one
	// probe.
	BreakerCooldown time.Duration
}

// Client defaults.
const (
	DefaultTimeout  = 500 * time.Millisecond
	DefaultPoolSize = 32
)

// Client is the Redis client used by OTP, idempotency and rate-limit stores.
type Client struct {
	*redis.Client
	breaker *breaker
}

// New builds a Client from cfg.
func New(cfg Config) *Client {
	timeout := cfg.Timeout
	if timeout <= 0 {
		timeout = DefaultTimeout
	}
	poolSize := cfg.PoolSize
	if poolSize <= 0 {
		poolSize = DefaultPoolSize
	}
	client := redis.NewClient(&redis.Options{
		Addr:         cfg.Addr,
		Password:     cfg.Password,
		DB:           cfg.DB,
		DialTimeout:  timeout,
		ReadTimeout:  timeout,
		WriteTimeout: timeout,
		PoolTimeout:  timeout,
		PoolSize:     poolSize,
	})
	b := newBreaker(cfg.FailureThreshold, cfg.BreakerCooldown)
	client.AddHook(breakerHook{b: b})
	return &Client{Client: client, breaker: b}
}

// BreakerOpen reports whether Redis calls are currently being short-circuited.
func (c *Client) BreakerOpen() bool { return c.breaker.isOpen() }

// Ping satisfies httpx.ReadyCheck.
func (c *Client) Ping(ctx context.Context) error {
	return c.Client.Ping(ctx).Err()
}
