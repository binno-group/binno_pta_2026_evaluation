package sms_test

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// eskizServer is a stand-in for notify.eskiz.uz that counts what it was asked to
// do, which is the only way to assert on the token caching that exists to keep
// logins off the request path.
type eskizServer struct {
	mu       sync.Mutex
	logins   int
	sends    int
	token    string
	sendCode int
	sendBody string
	lastForm map[string]string
	server   *httptest.Server
}

func newEskizServer(t *testing.T) *eskizServer {
	t.Helper()
	e := &eskizServer{token: "token-1", sendCode: http.StatusOK, sendBody: `{"status":"waiting"}`}
	mux := http.NewServeMux()
	mux.HandleFunc("/auth/login", func(w http.ResponseWriter, r *http.Request) {
		e.mu.Lock()
		defer e.mu.Unlock()
		e.logins++
		form, err := parseForm(r)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		if form["email"] != "ops@binno.uz" || form["password"] != "secret" {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		_, _ = w.Write([]byte(`{"message":"token_generated","data":{"token":"` + e.token + `"}}`))
	})
	mux.HandleFunc("/message/sms/send", func(w http.ResponseWriter, r *http.Request) {
		e.mu.Lock()
		defer e.mu.Unlock()
		e.sends++
		if r.Header.Get("Authorization") != "Bearer "+e.token {
			w.WriteHeader(http.StatusUnauthorized)
			_, _ = w.Write([]byte(`{"message":"Unauthenticated."}`))
			return
		}
		e.lastForm, _ = parseForm(r)
		w.WriteHeader(e.sendCode)
		_, _ = w.Write([]byte(e.sendBody))
	})
	e.server = httptest.NewServer(mux)
	t.Cleanup(e.server.Close)
	return e
}

// parseForm collects the multipart fields the adapter sent.
func parseForm(r *http.Request) (map[string]string, error) {
	reader, err := r.MultipartReader()
	if err != nil {
		return nil, err
	}
	fields := map[string]string{}
	for {
		part, err := reader.NextPart()
		if errors.Is(err, io.EOF) {
			return fields, nil
		}
		if err != nil {
			return nil, err
		}
		value, err := io.ReadAll(io.LimitReader(part, 1<<16))
		if err != nil {
			return nil, err
		}
		fields[part.FormName()] = string(value)
	}
}

func (e *eskizServer) sender(t *testing.T) *sms.Eskiz {
	t.Helper()
	sender, err := sms.NewEskiz(sms.EskizOptions{
		BaseURL:  e.server.URL,
		Email:    "ops@binno.uz",
		Password: "secret",
		From:     "BINNO",
		Client:   e.server.Client(),
	})
	if err != nil {
		t.Fatalf("NewEskiz error = %v", err)
	}
	return sender
}

func TestEskizSendsTheNormalisedNumberAndConfiguredSender(t *testing.T) {
	server := newEskizServer(t)
	sender := server.sender(t)

	if err := sender.Send(context.Background(), "998901234567", "BINNO kodi: 123456"); err != nil {
		t.Fatalf("Send error = %v", err)
	}

	server.mu.Lock()
	defer server.mu.Unlock()
	if got := server.lastForm["mobile_phone"]; got != "998901234567" {
		t.Errorf("mobile_phone = %q, want the number without a plus", got)
	}
	if got := server.lastForm["from"]; got != "BINNO" {
		t.Errorf("from = %q, want the configured sender name", got)
	}
	if got := server.lastForm["message"]; got != "BINNO kodi: 123456" {
		t.Errorf("message = %q, want it passed through unchanged", got)
	}
}

// A login per message would double OTP latency against a token that stays valid
// for weeks, so the token has to survive between sends.
func TestEskizLogsInOnceAcrossManySends(t *testing.T) {
	server := newEskizServer(t)
	sender := server.sender(t)

	for i := 0; i < 5; i++ {
		if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
			t.Fatalf("Send %d error = %v", i, err)
		}
	}

	server.mu.Lock()
	defer server.mu.Unlock()
	if server.logins != 1 {
		t.Errorf("logins = %d, want 1: the token must be cached across sends", server.logins)
	}
	if server.sends != 5 {
		t.Errorf("sends = %d, want 5", server.sends)
	}
}

// An expired token must cost one re-login and one retry, not a failed OTP.
func TestEskizReauthenticatesOnceWhenTheTokenIsRejected(t *testing.T) {
	server := newEskizServer(t)
	sender := server.sender(t)

	if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
		t.Fatalf("first Send error = %v", err)
	}

	server.mu.Lock()
	server.token = "token-2"
	server.mu.Unlock()

	if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
		t.Fatalf("Send after token rotation error = %v", err)
	}

	server.mu.Lock()
	defer server.mu.Unlock()
	if server.logins != 2 {
		t.Errorf("logins = %d, want 2: one at start, one after the 401", server.logins)
	}
	if server.sends != 3 {
		t.Errorf("sends = %d, want 3: first, the rejected one, then the retry", server.sends)
	}
}

// Credentials that stay wrong must fail rather than loop: the retry budget is
// exactly one, so a permanently rejected token surfaces as an error.
func TestEskizGivesUpWhenTheFreshTokenIsAlsoRejected(t *testing.T) {
	var logins, sends int
	mux := http.NewServeMux()
	mux.HandleFunc("/auth/login", func(w http.ResponseWriter, _ *http.Request) {
		logins++
		_, _ = w.Write([]byte(`{"data":{"token":"stale"}}`))
	})
	mux.HandleFunc("/message/sms/send", func(w http.ResponseWriter, _ *http.Request) {
		sends++
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = w.Write([]byte(`{"message":"Unauthenticated."}`))
	})
	server := httptest.NewServer(mux)
	defer server.Close()

	sender, err := sms.NewEskiz(sms.EskizOptions{
		BaseURL: server.URL, Email: "ops@binno.uz", Password: "secret", Client: server.Client(),
	})
	if err != nil {
		t.Fatalf("NewEskiz error = %v", err)
	}
	if err := sender.Send(context.Background(), "998901234567", "kod"); err == nil {
		t.Fatal("Send error = nil, want a failure when the gateway keeps refusing the token")
	}
	if sends != 2 {
		t.Errorf("sends = %d, want 2: the original and exactly one retry", sends)
	}
	if logins != 2 {
		t.Errorf("logins = %d, want 2", logins)
	}
}

// A number the gateway will never deliver to is a different fact from an outage,
// and the identity module turns it into a 422 rather than a 500.
func TestEskizReportsRejectedRecipientAsUndeliverable(t *testing.T) {
	server := newEskizServer(t)
	server.sendCode = http.StatusBadRequest
	server.sendBody = `{"message":"The given data was invalid.","errors":{"mobile_phone":["invalid"]}}`
	sender := server.sender(t)

	err := sender.Send(context.Background(), "998901234567", "kod")
	if !errors.Is(err, sms.ErrUndeliverable) {
		t.Fatalf("Send error = %v, want ErrUndeliverable", err)
	}
}

// Every other 4xx is a fault in the account, the template or the request.
func TestEskizDoesNotCallTemplateRejectionUndeliverable(t *testing.T) {
	server := newEskizServer(t)
	server.sendCode = http.StatusBadRequest
	server.sendBody = `{"status":"error","message":"Message text is not allowed"}`
	sender := server.sender(t)

	err := sender.Send(context.Background(), "998901234567", "kod")
	if err == nil {
		t.Fatal("Send error = nil, want a failure")
	}
	if errors.Is(err, sms.ErrUndeliverable) {
		t.Fatalf("Send error = %v, want a plain failure, not ErrUndeliverable", err)
	}
	if !strings.Contains(err.Error(), "Message text is not allowed") {
		t.Errorf("Send error = %v, want the gateway's own detail preserved", err)
	}
}

// A 200 with no token is not a session.
func TestEskizRejectsALoginResponseWithoutAToken(t *testing.T) {
	mux := http.NewServeMux()
	mux.HandleFunc("/auth/login", func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(`{"message":"ok","data":{}}`))
	})
	server := httptest.NewServer(mux)
	defer server.Close()

	sender, err := sms.NewEskiz(sms.EskizOptions{
		BaseURL: server.URL, Email: "ops@binno.uz", Password: "secret", Client: server.Client(),
	})
	if err != nil {
		t.Fatalf("NewEskiz error = %v", err)
	}
	if err := sender.Send(context.Background(), "998901234567", "kod"); err == nil {
		t.Fatal("Send error = nil, want a failure when the login carries no token")
	}
}

// One expiry must not become one login per in-flight request.
func TestEskizCollapsesConcurrentLogins(t *testing.T) {
	server := newEskizServer(t)
	sender := server.sender(t)

	var wg sync.WaitGroup
	for i := 0; i < 16; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
				t.Errorf("Send error = %v", err)
			}
		}()
	}
	wg.Wait()

	server.mu.Lock()
	defer server.mu.Unlock()
	if server.logins != 1 {
		t.Errorf("logins = %d, want 1: concurrent first sends must share one login", server.logins)
	}
}

func TestNewEskizRejectsIncompleteConfiguration(t *testing.T) {
	for name, opts := range map[string]sms.EskizOptions{
		"no email":       {Password: "secret"},
		"no password":    {Email: "ops@binno.uz"},
		"bad scheme":     {BaseURL: "ftp://notify.eskiz.uz", Email: "ops@binno.uz", Password: "secret"},
		"no host":        {BaseURL: "https://", Email: "ops@binno.uz", Password: "secret"},
		"not a URL":      {BaseURL: "://nope", Email: "ops@binno.uz", Password: "secret"},
		"nothing at all": {},
	} {
		if _, err := sms.NewEskiz(opts); err == nil {
			t.Errorf("NewEskiz(%s) error = nil, want a refusal at construction", name)
		}
	}
}

func TestNewEskizDefaultsTheSenderName(t *testing.T) {
	server := newEskizServer(t)
	sender, err := sms.NewEskiz(sms.EskizOptions{
		BaseURL: server.server.URL, Email: "ops@binno.uz", Password: "secret", Client: server.server.Client(),
	})
	if err != nil {
		t.Fatalf("NewEskiz error = %v", err)
	}
	if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
		t.Fatalf("Send error = %v", err)
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if got := server.lastForm["from"]; got != sms.EskizDefaultFrom {
		t.Errorf("from = %q, want the default %q", got, sms.EskizDefaultFrom)
	}
}
