package httpx

import (
	"bytes"
	"context"
	"net/http"
	"sync"
	"time"
)

// Timeout bounds request handling to d.
func Timeout(d time.Duration) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx, cancel := context.WithTimeout(r.Context(), d)
			defer cancel()

			buffered := &bufferedWriter{header: make(http.Header), status: http.StatusOK}
			done := make(chan struct{})
			panicked := make(chan any, 1)

			go func() {
				defer func() {
					if p := recover(); p != nil {
						panicked <- p
					}
				}()
				next.ServeHTTP(buffered, r.WithContext(ctx))
				close(done)
			}()

			select {
			case p := <-panicked:
				panic(p)
			case <-done:
				buffered.flushTo(w)
			case <-ctx.Done():
				buffered.abandon()
				writeProblemBody(w, Problem{
					Type:     ProblemTypeTimeout,
					Title:    "Request Timeout",
					Status:   http.StatusServiceUnavailable,
					Detail:   "the server did not produce a response within its time budget",
					Instance: r.URL.Path,
				})
			}
		})
	}
}

// bufferedWriter collects a handler's response so it can either be replayed on
// completion or discarded when the timeout wins the race.
type bufferedWriter struct {
	mu        sync.Mutex
	header    http.Header
	body      bytes.Buffer
	status    int
	abandoned bool
}

func (b *bufferedWriter) Header() http.Header {
	return b.header
}

func (b *bufferedWriter) WriteHeader(status int) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.abandoned {
		return
	}
	b.status = status
}

func (b *bufferedWriter) Write(p []byte) (int, error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.abandoned {
		return len(p), nil
	}
	return b.body.Write(p)
}

func (b *bufferedWriter) abandon() {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.abandoned = true
}

func (b *bufferedWriter) flushTo(w http.ResponseWriter) {
	b.mu.Lock()
	defer b.mu.Unlock()
	dst := w.Header()
	for k, v := range b.header {
		dst[k] = v
	}
	w.WriteHeader(b.status)
	_, _ = w.Write(b.body.Bytes())
}
