// Package sms delivers one-time codes to a phone number.
package sms

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"time"
)

// Provider names.
const (
	// ProviderLog writes the message to the log instead of sending it.
	ProviderLog = "log"
	// ProviderEskiz is notify.eskiz.uz.
	ProviderEskiz = "eskiz"
	// ProviderPlayMobile is a Play Mobile broker.
	ProviderPlayMobile = "playmobile"
)

// Providers lists every implemented adapter, for error messages that tell an
// operator what they may actually set.
func Providers() []string { return []string{ProviderLog, ProviderEskiz, ProviderPlayMobile} }

// ErrUndeliverable marks a number this provider will never deliver to: a
// malformed number, or one on a network the gateway does not serve.
var ErrUndeliverable = errors.New("sms: undeliverable recipient")

// Sender delivers a message to a phone number.
type Sender interface {
	Send(ctx context.Context, phone, message string) error
}

// Options selects and configures the adapter New builds.
type Options struct {
	// Provider is one of Providers().
	Provider string
	// Env gates the log sender.
	Env string
	// Timeout bounds one gateway call, including connection setup.
	Timeout time.Duration
	// Logger is used by the log sender.
	Logger *slog.Logger

	Eskiz      EskizOptions
	PlayMobile PlayMobileOptions
}

// New builds the sender named by Provider.
func New(opts Options) (Sender, error) {
	client := &http.Client{Timeout: opts.Timeout}
	switch opts.Provider {
	case ProviderLog:
		if opts.Env != "development" {
			return nil, fmt.Errorf(
				"sms: provider %q writes one-time codes to the log and must not run with ENV=%s",
				ProviderLog, opts.Env)
		}
		return LogSender{Logger: opts.Logger}, nil
	case ProviderEskiz:
		if opts.Eskiz.Client == nil {
			opts.Eskiz.Client = client
		}
		return NewEskiz(opts.Eskiz)
	case ProviderPlayMobile:
		if opts.PlayMobile.Client == nil {
			opts.PlayMobile.Client = client
		}
		return NewPlayMobile(opts.PlayMobile)
	default:
		return nil, fmt.Errorf("sms: unsupported provider %q, want one of %v", opts.Provider, Providers())
	}
}

// LogSender writes the message to the log instead of sending it.
type LogSender struct{ Logger *slog.Logger }

// Send logs the message.
func (s LogSender) Send(ctx context.Context, phone, message string) error {
	logger := s.Logger
	if logger == nil {
		logger = slog.Default()
	}
	logger.InfoContext(ctx, "sms: delivering via log sender (development only)",
		"phone", phone, "message", message)
	return nil
}

// NoopSender discards messages silently.
type NoopSender struct{}

// Send discards.
func (NoopSender) Send(context.Context, string, string) error { return nil }
