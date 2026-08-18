package sms

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"net/url"
	"strings"
	"sync"
)

// EskizBaseURL is the production gateway.
const EskizBaseURL = "https://notify.eskiz.uz/api"

// EskizDefaultFrom is the shared alphanumeric sender Eskiz issues to every
// account before a branded one is approved.
const EskizDefaultFrom = "4546"

// EskizOptions configures the Eskiz adapter.
type EskizOptions struct {
	// BaseURL is the API root, without a trailing slash.
	BaseURL string
	// Email and Password are the account credentials, not an API key: Eskiz
	// exchanges them for a bearer token that the adapter then caches.
	Email    string
	Password string
	// From is the sender name.
	From string
	// Client bounds the call.
	Client *http.Client
}

// Eskiz delivers through notify.eskiz.uz.
type Eskiz struct {
	baseURL  string
	email    string
	password string
	from     string
	client   *http.Client

	// mu guards token and serialises logins.
	mu    sync.Mutex
	token string
}

// NewEskiz builds an Eskiz sender.
func NewEskiz(opts EskizOptions) (*Eskiz, error) {
	base := strings.TrimRight(opts.BaseURL, "/")
	if base == "" {
		base = EskizBaseURL
	}
	parsed, err := url.Parse(base)
	if err != nil {
		return nil, fmt.Errorf("sms: parse eskiz base URL: %w", err)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return nil, fmt.Errorf("sms: eskiz base URL scheme must be http or https, got %q", parsed.Scheme)
	}
	if parsed.Host == "" {
		return nil, fmt.Errorf("sms: eskiz base URL host is required")
	}
	if opts.Email == "" || opts.Password == "" {
		return nil, fmt.Errorf("sms: eskiz requires an email and a password")
	}
	from := opts.From
	if from == "" {
		from = EskizDefaultFrom
	}
	client := opts.Client
	if client == nil {
		client = http.DefaultClient
	}
	return &Eskiz{
		baseURL: base, email: opts.Email, password: opts.Password, from: from, client: client,
	}, nil
}

// Send delivers message to phone.
func (e *Eskiz) Send(ctx context.Context, phone, message string) error {
	token, err := e.authorize(ctx, "")
	if err != nil {
		return err
	}
	status, body, err := e.send(ctx, token, phone, message)
	if err != nil {
		return err
	}
	if status == http.StatusUnauthorized {
		if token, err = e.authorize(ctx, token); err != nil {
			return err
		}
		if status, body, err = e.send(ctx, token, phone, message); err != nil {
			return err
		}
	}
	if status < http.StatusOK || status >= http.StatusMultipleChoices {
		return eskizError(status, body)
	}
	return nil
}

// send posts one message and returns the raw outcome, so the caller can decide
// whether a 401 is worth a retry without this function knowing about tokens.
func (e *Eskiz) send(ctx context.Context, token, phone, message string) (int, []byte, error) {
	body, contentType, err := multipartForm(map[string]string{
		"mobile_phone": strings.TrimPrefix(phone, "+"),
		"message":      message,
		"from":         e.from,
	})
	if err != nil {
		return 0, nil, err
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, e.baseURL+"/message/sms/send", body)
	if err != nil {
		return 0, nil, fmt.Errorf("sms: create eskiz send request: %w", err)
	}
	request.Header.Set("Content-Type", contentType)
	request.Header.Set("Authorization", "Bearer "+token)

	response, err := e.client.Do(request)
	if err != nil {
		return 0, nil, fmt.Errorf("sms: send via eskiz: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	payload, _ := io.ReadAll(io.LimitReader(response.Body, responseLimit))
	return response.StatusCode, payload, nil
}

// authorize returns a usable token, logging in when there is none.
func (e *Eskiz) authorize(ctx context.Context, stale string) (string, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.token != "" && e.token != stale {
		return e.token, nil
	}

	body, contentType, err := multipartForm(map[string]string{
		"email":    e.email,
		"password": e.password,
	})
	if err != nil {
		return "", err
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, e.baseURL+"/auth/login", body)
	if err != nil {
		return "", fmt.Errorf("sms: create eskiz login request: %w", err)
	}
	request.Header.Set("Content-Type", contentType)

	response, err := e.client.Do(request)
	if err != nil {
		return "", fmt.Errorf("sms: log in to eskiz: %w", err)
	}
	defer func() { _ = response.Body.Close() }()
	payload, _ := io.ReadAll(io.LimitReader(response.Body, responseLimit))
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("sms: eskiz login status %d: %s",
			response.StatusCode, strings.TrimSpace(string(payload)))
	}

	var decoded struct {
		Data struct {
			Token string `json:"token"`
		} `json:"data"`
	}
	if err := json.Unmarshal(payload, &decoded); err != nil {
		return "", fmt.Errorf("sms: decode eskiz login response: %w", err)
	}
	if decoded.Data.Token == "" {
		return "", errors.New("sms: eskiz login returned no token")
	}
	e.token = decoded.Data.Token
	return e.token, nil
}

// eskizError turns a refusal into an error the caller can act on.
func eskizError(status int, body []byte) error {
	var decoded struct {
		Message string              `json:"message"`
		Errors  map[string][]string `json:"errors"`
	}
	_ = json.Unmarshal(body, &decoded)
	detail := strings.TrimSpace(decoded.Message)
	if detail == "" {
		detail = strings.TrimSpace(string(body))
	}
	if _, ok := decoded.Errors["mobile_phone"]; ok {
		return fmt.Errorf("%w: eskiz status %d: %s", ErrUndeliverable, status, detail)
	}
	return fmt.Errorf("sms: eskiz status %d: %s", status, detail)
}

// multipartForm encodes fields as multipart/form-data, which is what both Eskiz
// endpoints document.
func multipartForm(fields map[string]string) (io.Reader, string, error) {
	var buf bytes.Buffer
	writer := multipart.NewWriter(&buf)
	for name, value := range fields {
		if err := writer.WriteField(name, value); err != nil {
			return nil, "", fmt.Errorf("sms: encode form field %q: %w", name, err)
		}
	}
	if err := writer.Close(); err != nil {
		return nil, "", fmt.Errorf("sms: finalise form: %w", err)
	}
	return &buf, writer.FormDataContentType(), nil
}

// responseLimit caps how much of a gateway response is read into an error.
const responseLimit = 4096
