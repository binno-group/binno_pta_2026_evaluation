// Package ratelimit implements fixed-window rate limiting backed by Redis.
package ratelimit

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/redisx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// countInWindow increments a window bucket and gives it an expiry the first time
// it is seen, as one atomic server-side step.
const countInWindow = `
local count = redis.call('INCR', KEYS[1])
if count == 1 then
  redis.call('PEXPIRE', KEYS[1], ARGV[1])
end
return count
`

// Limiter enforces a fixed-window request count per key.
type Limiter struct {
	redis  *redisx.Client
	clock  clock.Clock
	script *redis.Script
}

// New returns a Limiter backed by client, using c to compute window buckets.
func New(client *redisx.Client, c clock.Clock) *Limiter {
	return &Limiter{redis: client, clock: c, script: redis.NewScript(countInWindow)}
}

// Allow reports whether the caller identified by key may proceed, given at most
// limit requests per window.
func (l *Limiter) Allow(ctx context.Context, key string, limit int64, window time.Duration) (bool, error) {
	bucket := l.clock.Now().UnixNano() / window.Nanoseconds()
	redisKey := fmt.Sprintf("ratelimit:%s:%d", key, bucket)

	count, err := l.script.Run(
		ctx, l.redis, []string{redisKey}, window.Milliseconds(),
	).Int64()
	if err != nil {
		return false, fmt.Errorf("ratelimit: unavailable, failing closed: %w", err)
	}
	return count <= limit, nil
}
