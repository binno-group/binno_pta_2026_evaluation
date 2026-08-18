package sms_test

import (
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// The log sender prints every one-time code.
func TestNewRefusesTheLogSenderOutsideDevelopment(t *testing.T) {
	for _, env := range []string{"production", "staging", ""} {
		if _, err := sms.New(sms.Options{Provider: sms.ProviderLog, Env: env}); err == nil {
			t.Errorf("New(log, ENV=%q) error = nil, want a refusal", env)
		}
	}
	sender, err := sms.New(sms.Options{Provider: sms.ProviderLog, Env: "development"})
	if err != nil {
		t.Fatalf("New(log, ENV=development) error = %v", err)
	}
	if _, ok := sender.(sms.LogSender); !ok {
		t.Errorf("New(log) = %T, want sms.LogSender", sender)
	}
}

// A provider name with no adapter behind it must fail the boot rather than fall
// through to whatever the code happens to construct.
func TestNewRefusesAnUnknownProvider(t *testing.T) {
	_, err := sms.New(sms.Options{Provider: "twilio", Env: "production"})
	if err == nil {
		t.Fatal("New(twilio) error = nil, want a refusal")
	}
	for _, provider := range sms.Providers() {
		if !strings.Contains(err.Error(), provider) {
			t.Errorf("New(twilio) error = %v, want it to list %q", err, provider)
		}
	}
}

func TestNewBuildsTheConfiguredGatewayAdapters(t *testing.T) {
	eskiz, err := sms.New(sms.Options{
		Provider: sms.ProviderEskiz, Env: "production",
		Eskiz: sms.EskizOptions{Email: "ops@binno.uz", Password: "secret"},
	})
	if err != nil {
		t.Fatalf("New(eskiz) error = %v", err)
	}
	if _, ok := eskiz.(*sms.Eskiz); !ok {
		t.Errorf("New(eskiz) = %T, want *sms.Eskiz", eskiz)
	}

	playMobile, err := sms.New(sms.Options{
		Provider: sms.ProviderPlayMobile, Env: "production",
		PlayMobile: sms.PlayMobileOptions{
			BaseURL: "http://broker.local/broker-api", Login: "binno",
			Password: "secret", Originator: "3700",
		},
	})
	if err != nil {
		t.Fatalf("New(playmobile) error = %v", err)
	}
	if _, ok := playMobile.(*sms.PlayMobile); !ok {
		t.Errorf("New(playmobile) = %T, want *sms.PlayMobile", playMobile)
	}
}

// Missing credentials must stop the boot, not surface as a failed login on the
// first user's OTP.
func TestNewRefusesAGatewayWithoutCredentials(t *testing.T) {
	if _, err := sms.New(sms.Options{Provider: sms.ProviderEskiz, Env: "production"}); err == nil {
		t.Error("New(eskiz) with no credentials error = nil, want a refusal")
	}
	if _, err := sms.New(sms.Options{Provider: sms.ProviderPlayMobile, Env: "production"}); err == nil {
		t.Error("New(playmobile) with no credentials error = nil, want a refusal")
	}
}
