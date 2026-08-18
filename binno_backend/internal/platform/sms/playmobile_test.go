package sms_test

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

func TestPlayMobileSendsTheBrokerEnvelopeWithBasicAuth(t *testing.T) {
	var body []byte
	var user, password string
	var authed bool
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/broker-api/send" {
			t.Errorf("path = %q, want /broker-api/send", r.URL.Path)
		}
		user, password, authed = r.BasicAuth()
		body, _ = io.ReadAll(r.Body)
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	sender, err := sms.NewPlayMobile(sms.PlayMobileOptions{
		BaseURL: server.URL + "/broker-api", Login: "binno", Password: "secret",
		Originator: "3700", Client: server.Client(),
	})
	if err != nil {
		t.Fatalf("NewPlayMobile error = %v", err)
	}
	if err := sender.Send(context.Background(), "998901234567", "BINNO kodi: 123456"); err != nil {
		t.Fatalf("Send error = %v", err)
	}

	if !authed || user != "binno" || password != "secret" {
		t.Errorf("basic auth = (%q, %q, %t), want the configured broker credentials", user, password, authed)
	}

	var decoded struct {
		Messages []struct {
			Recipient string `json:"recipient"`
			MessageID string `json:"message-id"`
			SMS       struct {
				Originator string `json:"originator"`
				Content    struct {
					Text string `json:"text"`
				} `json:"content"`
			} `json:"sms"`
		} `json:"messages"`
	}
	if err := json.Unmarshal(body, &decoded); err != nil {
		t.Fatalf("request body %q is not the documented envelope: %v", body, err)
	}
	if len(decoded.Messages) != 1 {
		t.Fatalf("messages = %d, want 1", len(decoded.Messages))
	}
	message := decoded.Messages[0]
	if message.Recipient != "998901234567" {
		t.Errorf("recipient = %q, want the number without a plus", message.Recipient)
	}
	if message.SMS.Originator != "3700" {
		t.Errorf("originator = %q, want the registered sender ID", message.SMS.Originator)
	}
	if message.SMS.Content.Text != "BINNO kodi: 123456" {
		t.Errorf("text = %q, want it passed through unchanged", message.SMS.Content.Text)
	}
	if message.MessageID == "" {
		t.Error("message-id is empty: delivery reports are correlated by it")
	}
}

// The broker correlates delivery reports by message-id, so two messages sharing
// one would make the reports unattributable.
func TestPlayMobileGivesEveryMessageItsOwnID(t *testing.T) {
	seen := map[string]bool{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var decoded struct {
			Messages []struct {
				MessageID string `json:"message-id"`
			} `json:"messages"`
		}
		body, _ := io.ReadAll(r.Body)
		_ = json.Unmarshal(body, &decoded)
		seen[decoded.Messages[0].MessageID] = true
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	sender, err := sms.NewPlayMobile(sms.PlayMobileOptions{
		BaseURL: server.URL, Login: "binno", Password: "secret",
		Originator: "3700", Client: server.Client(),
	})
	if err != nil {
		t.Fatalf("NewPlayMobile error = %v", err)
	}
	for i := 0; i < 8; i++ {
		if err := sender.Send(context.Background(), "998901234567", "kod"); err != nil {
			t.Fatalf("Send %d error = %v", i, err)
		}
	}
	if len(seen) != 8 {
		t.Errorf("distinct message ids = %d, want 8", len(seen))
	}
}

func TestPlayMobileReportsBrokerRefusalWithItsDetail(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte("originator not allowed"))
	}))
	defer server.Close()

	sender, err := sms.NewPlayMobile(sms.PlayMobileOptions{
		BaseURL: server.URL, Login: "binno", Password: "secret",
		Originator: "3700", Client: server.Client(),
	})
	if err != nil {
		t.Fatalf("NewPlayMobile error = %v", err)
	}

	err = sender.Send(context.Background(), "998901234567", "kod")
	if err == nil {
		t.Fatal("Send error = nil, want the broker's refusal reported")
	}
	if errors.Is(err, sms.ErrUndeliverable) {
		t.Errorf("Send error = %v, want a plain failure: this broker cannot attribute a refusal to the recipient", err)
	}
}

func TestNewPlayMobileRejectsIncompleteConfiguration(t *testing.T) {
	complete := sms.PlayMobileOptions{
		BaseURL: "http://broker.local/broker-api", Login: "binno",
		Password: "secret", Originator: "3700",
	}
	withoutBase, withoutLogin := complete, complete
	withoutBase.BaseURL, withoutLogin.Login = "", ""
	withoutPassword, withoutOriginator := complete, complete
	withoutPassword.Password, withoutOriginator.Originator = "", ""
	badScheme := complete
	badScheme.BaseURL = "ftp://broker.local"

	for name, opts := range map[string]sms.PlayMobileOptions{
		"no base URL":    withoutBase,
		"no login":       withoutLogin,
		"no password":    withoutPassword,
		"no originator":  withoutOriginator,
		"bad URL scheme": badScheme,
	} {
		if _, err := sms.NewPlayMobile(opts); err == nil {
			t.Errorf("NewPlayMobile(%s) error = nil, want a refusal at construction", name)
		}
	}
}
