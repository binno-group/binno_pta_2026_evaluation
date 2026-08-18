package sms

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
)

// PlayMobileOptions configures the Play Mobile adapter.
type PlayMobileOptions struct {
	// BaseURL is the broker root, e.g.
	BaseURL string
	// Login and Password are the broker credentials, sent as HTTP Basic on every
	// request.
	Login    string
	Password string
	// Originator is the registered sender ID, e.g.
	Originator string
	// Client bounds the call.
	Client *http.Client
}

// PlayMobile delivers through a Play Mobile broker.
type PlayMobile struct {
	endpoint   string
	login      string
	password   string
	originator string
	client     *http.Client
}

// NewPlayMobile builds a Play Mobile sender.
func NewPlayMobile(opts PlayMobileOptions) (*PlayMobile, error) {
	base := strings.TrimRight(opts.BaseURL, "/")
	if base == "" {
		return nil, fmt.Errorf("sms: play mobile requires a base URL")
	}
	parsed, err := url.Parse(base)
	if err != nil {
		return nil, fmt.Errorf("sms: parse play mobile base URL: %w", err)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return nil, fmt.Errorf("sms: play mobile base URL scheme must be http or https, got %q", parsed.Scheme)
	}
	if parsed.Host == "" {
		return nil, fmt.Errorf("sms: play mobile base URL host is required")
	}
	if opts.Login == "" || opts.Password == "" {
		return nil, fmt.Errorf("sms: play mobile requires a login and a password")
	}
	if opts.Originator == "" {
		return nil, fmt.Errorf("sms: play mobile requires an originator")
	}
	client := opts.Client
	if client == nil {
		client = http.DefaultClient
	}
	return &PlayMobile{
		endpoint:   base + "/send",
		login:      opts.Login,
		password:   opts.Password,
		originator: opts.Originator,
		client:     client,
	}, nil
}

// playMobileRequest is the broker's send envelope.
type playMobileRequest struct {
	Messages []playMobileMessage `json:"messages"`
}

type playMobileMessage struct {
	Recipient string        `json:"recipient"`
	MessageID string        `json:"message-id"`
	SMS       playMobileSMS `json:"sms"`
}

type playMobileSMS struct {
	Originator string            `json:"originator"`
	Content    playMobileContent `json:"content"`
}

type playMobileContent struct {
	Text string `json:"text"`
}

// Send delivers message to phone.
func (p *PlayMobile) Send(ctx context.Context, phone, message string) error {
	messageID, err := newMessageID()
	if err != nil {
		return err
	}
	body, err := json.Marshal(playMobileRequest{Messages: []playMobileMessage{{
		Recipient: strings.TrimPrefix(phone, "+"),
		MessageID: messageID,
		SMS: playMobileSMS{
			Originator: p.originator,
			Content:    playMobileContent{Text: message},
		},
	}}})
	if err != nil {
		return fmt.Errorf("sms: encode play mobile request: %w", err)
	}

	request, err := http.NewRequestWithContext(ctx, http.MethodPost, p.endpoint, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("sms: create play mobile request: %w", err)
	}
	request.Header.Set("Content-Type", "application/json")
	request.SetBasicAuth(p.login, p.password)

	response, err := p.client.Do(request)
	if err != nil {
		return fmt.Errorf("sms: send via play mobile: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	if response.StatusCode < http.StatusOK || response.StatusCode >= http.StatusMultipleChoices {
		detail, _ := io.ReadAll(io.LimitReader(response.Body, responseLimit))
		return fmt.Errorf("sms: play mobile status %d: %s",
			response.StatusCode, strings.TrimSpace(string(detail)))
	}
	return nil
}

// newMessageID returns the identifier the broker echoes in delivery reports.
func newMessageID() (string, error) {
	buf := make([]byte, 10)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("sms: generate message id: %w", err)
	}
	return hex.EncodeToString(buf), nil
}
