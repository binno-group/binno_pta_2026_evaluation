package identity

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/go-chi/chi/v5"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/cache/otp"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// fakeRepository records what the service asked of persistence and answers with
// whatever the test needs, so the login flow can be exercised without a
// database.
type fakeRepository struct {
	registered bool
	status     string
	upserted   string
	stored     []RefreshRecord
	seller     bool
	err        error
	// live, when set, is the record FindRefreshToken answers with.
	live *RefreshRecord
}

func (f *fakeRepository) UpsertUser(_ context.Context, phone string, now time.Time) (User, bool, error) {
	if f.err != nil {
		return User{}, false, f.err
	}
	f.upserted = phone
	status := f.status
	if status == "" {
		status = StatusActive
	}
	return User{ID: "user-1", Phone: phone, Status: status, CreatedAt: now}, f.registered, nil
}

func (f *fakeRepository) RolesFor(context.Context, string) (RoleFlags, error) {
	return RoleFlags{Seller: f.seller}, nil
}

func (f *fakeRepository) StoreRefreshToken(_ context.Context, in RefreshRecord) error {
	f.stored = append(f.stored, in)
	return nil
}

func (f *fakeRepository) FindRefreshToken(context.Context, []byte) (RefreshRecord, error) {
	if f.live == nil {
		return RefreshRecord{}, ErrInvalidSession
	}
	return *f.live, nil
}

func (f *fakeRepository) RevokeRefreshToken(context.Context, string, time.Time) (int64, error) {
	return 1, nil
}

func (f *fakeRepository) RevokeAllUserTokens(context.Context, string, time.Time) error { return nil }

// fakeCodes stands in for the Redis-backed OTP store.
type fakeCodes struct {
	issue     string
	issueErr  error
	verifyErr error
	issuedTo  string
	cancelled string
}

func (f *fakeCodes) Issue(_ context.Context, phone string) (string, error) {
	f.issuedTo = phone
	if f.issueErr != nil {
		return "", f.issueErr
	}
	code := f.issue
	if code == "" {
		code = "123456"
	}
	return code, nil
}

func (f *fakeCodes) Verify(context.Context, string, string) error { return f.verifyErr }

func (f *fakeCodes) Cancel(_ context.Context, phone string) error {
	f.cancelled = phone
	return nil
}

type fakeSender struct {
	sentTo  string
	message string
	err     error
}

func (f *fakeSender) Send(_ context.Context, phone, message string) error {
	f.sentTo, f.message = phone, message
	return f.err
}

type fakeSigner struct{ roles []authz.Role }

func (f *fakeSigner) Sign(subject string, roles []authz.Role, _ time.Time) (string, error) {
	f.roles = roles
	return "access-for-" + subject, nil
}

func (f *fakeSigner) TTL() time.Duration { return 15 * time.Minute }

type harness struct {
	service    *Service
	repository *fakeRepository
	codes      *fakeCodes
	sender     *fakeSender
	signer     *fakeSigner
}

func newHarness() *harness {
	h := &harness{
		repository: &fakeRepository{},
		codes:      &fakeCodes{},
		sender:     &fakeSender{},
		signer:     &fakeSigner{},
	}
	h.service = NewService(h.repository, h.codes, h.sender, h.signer,
		clock.NewFixed(time.Date(2026, 8, 2, 12, 0, 0, 0, time.UTC)))
	return h
}

// The whole point of the flag: a first-time verification IS the registration,
// and the client has to be able to tell so it can ask for the rest of a profile.
func TestVerifyCodeReportsANewlyRegisteredAccount(t *testing.T) {
	h := newHarness()
	h.repository.registered = true

	session, err := h.service.VerifyCode(context.Background(), "+998 90 123 45 67", "123456")
	if err != nil {
		t.Fatalf("VerifyCode error = %v", err)
	}
	if !session.IsNewUser {
		t.Error("IsNewUser = false, want true when the verification created the account")
	}
	if session.AccessToken == "" || session.RefreshToken == "" {
		t.Error("VerifyCode returned an incomplete session")
	}
	if h.repository.upserted != "998901234567" {
		t.Errorf("upserted phone = %q, want the normalised form", h.repository.upserted)
	}
}

func TestVerifyCodeReportsAReturningAccount(t *testing.T) {
	h := newHarness()
	h.repository.registered = false

	session, err := h.service.VerifyCode(context.Background(), "998901234567", "123456")
	if err != nil {
		t.Fatalf("VerifyCode error = %v", err)
	}
	if session.IsNewUser {
		t.Error("IsNewUser = true, want false when the account already existed")
	}
}

// Every wrong-code outcome has to answer alike.
func TestVerifyCodeCollapsesEveryCodeFailureIntoOneError(t *testing.T) {
	for name, cause := range map[string]error{
		"no code outstanding": otp.ErrNotFound,
		"wrong code":          otp.ErrMismatch,
		"attempts exhausted":  otp.ErrTooManyAttempts,
	} {
		h := newHarness()
		h.codes.verifyErr = cause
		if _, err := h.service.VerifyCode(context.Background(), "998901234567", "000000"); !errors.Is(err, ErrInvalidCode) {
			t.Errorf("VerifyCode(%s) error = %v, want ErrInvalidCode", name, err)
		}
	}
}

func TestVerifyCodeRefusesABlockedAccount(t *testing.T) {
	h := newHarness()
	h.repository.status = StatusBlocked

	if _, err := h.service.VerifyCode(context.Background(), "998901234567", "123456"); !errors.Is(err, ErrBlocked) {
		t.Fatalf("VerifyCode error = %v, want ErrBlocked", err)
	}
	if len(h.repository.stored) != 0 {
		t.Error("a blocked account was issued a refresh token")
	}
}

// The seller role is derived at issue time from the ownership tables, so a token
// can never claim a capability those tables disagree with.
func TestIssuedTokenCarriesTheDerivedSellerRole(t *testing.T) {
	h := newHarness()
	if _, err := h.service.VerifyCode(context.Background(), "998901234567", "123456"); err != nil {
		t.Fatalf("VerifyCode error = %v", err)
	}
	if len(h.signer.roles) != 1 || h.signer.roles[0] != authz.RoleBuyer {
		t.Errorf("roles = %v, want just buyer", h.signer.roles)
	}

	h = newHarness()
	h.repository.seller = true
	if _, err := h.service.VerifyCode(context.Background(), "998901234567", "123456"); err != nil {
		t.Fatalf("VerifyCode error = %v", err)
	}
	if len(h.signer.roles) != 2 || h.signer.roles[1] != authz.RoleSeller {
		t.Errorf("roles = %v, want buyer and seller", h.signer.roles)
	}
}

// The stored token must be the digest, never the credential itself: a database
// dump has to yield no usable session.
func TestIssuedRefreshTokenIsStoredHashed(t *testing.T) {
	h := newHarness()
	session, err := h.service.VerifyCode(context.Background(), "998901234567", "123456")
	if err != nil {
		t.Fatalf("VerifyCode error = %v", err)
	}
	if len(h.repository.stored) != 1 {
		t.Fatalf("stored refresh tokens = %d, want 1", len(h.repository.stored))
	}
	stored := h.repository.stored[0]
	if string(stored.TokenHash) == session.RefreshToken {
		t.Fatal("the refresh token was stored in presentable form")
	}
	if string(stored.TokenHash) != string(hashToken(session.RefreshToken)) {
		t.Error("the stored digest does not match the issued token, so no refresh could ever find it")
	}
}

func TestRequestCodeSendsTheCodeToTheNormalisedNumber(t *testing.T) {
	h := newHarness()
	h.codes.issue = "482913"

	if err := h.service.RequestCode(context.Background(), "+998 90 123 45 67"); err != nil {
		t.Fatalf("RequestCode error = %v", err)
	}
	if h.codes.issuedTo != "998901234567" || h.sender.sentTo != "998901234567" {
		t.Errorf("issued to %q and sent to %q, want the normalised form",
			h.codes.issuedTo, h.sender.sentTo)
	}
	if !strings.Contains(h.sender.message, "482913") {
		t.Errorf("message = %q, want it to carry the issued code", h.sender.message)
	}
}

// A number no network carries is the caller's problem and does not improve on a
// retry, so it answers with the same 422 any other invalid phone gets rather
// than as a fault on BINNO's side.
func TestRequestCodeTreatsAnUndeliverableNumberAsAnInvalidPhone(t *testing.T) {
	h := newHarness()
	h.sender.err = sms.ErrUndeliverable

	err := h.service.RequestCode(context.Background(), "998901234567")
	if !errors.Is(err, ErrInvalidPhone) {
		t.Fatalf("RequestCode error = %v, want ErrInvalidPhone", err)
	}
	if status := statusFor(t, err); status != http.StatusUnprocessableEntity {
		t.Errorf("status = %d, want 422", status)
	}
	if h.codes.cancelled != "" {
		t.Error("cooldown withdrawn for a refused number: it should stay, to throttle probing")
	}
}

// A gateway having a bad minute is NOT the caller's fault and must not tell them
// their number is invalid.
func TestRequestCodeReportsAGatewayOutageAsAFailure(t *testing.T) {
	h := newHarness()
	h.sender.err = errors.New("connection reset")

	err := h.service.RequestCode(context.Background(), "998901234567")
	if err == nil {
		t.Fatal("RequestCode error = nil, want the delivery failure reported")
	}
	if errors.Is(err, ErrInvalidPhone) {
		t.Fatalf("RequestCode error = %v, want it kept distinct from an invalid number", err)
	}
	if h.codes.cancelled != "998901234567" {
		t.Errorf("cooldown cancelled for %q, want %q: the user got no code and must be able to retry at once",
			h.codes.cancelled, "998901234567")
	}
}

func TestRequestCodeSurfacesTheCooldown(t *testing.T) {
	h := newHarness()
	h.codes.issueErr = otp.ErrCooldown

	err := h.service.RequestCode(context.Background(), "998901234567")
	if !errors.Is(err, ErrCooldown) {
		t.Fatalf("RequestCode error = %v, want ErrCooldown", err)
	}
	if h.sender.sentTo != "" {
		t.Error("an SMS was sent despite the cooldown: the endpoint is a billing amplifier without that guard")
	}
	recorder := serve(t, h, http.MethodPost, "/auth/otp/request", `{"phone":"998901234567"}`)
	if recorder.Code != http.StatusTooManyRequests {
		t.Errorf("status = %d, want 429", recorder.Code)
	}
	if recorder.Header().Get("Retry-After") == "" {
		t.Error("Retry-After is missing, so the client cannot tell the user how long to wait")
	}
}

// The wire shape is part of the contract: a client routing a first-time user
// into onboarding reads this field, and the flag must be present on every
// verification rather than only when it is true.
func TestVerifyEndpointAlwaysCarriesIsNewUser(t *testing.T) {
	for _, registered := range []bool{true, false} {
		h := newHarness()
		h.repository.registered = registered

		recorder := serve(t, h, http.MethodPost, "/auth/otp/verify",
			`{"phone":"998901234567","code":"123456"}`)
		if recorder.Code != http.StatusOK {
			t.Fatalf("status = %d, want 200", recorder.Code)
		}

		var body map[string]any
		if err := json.Unmarshal(recorder.Body.Bytes(), &body); err != nil {
			t.Fatalf("response is not JSON: %v", err)
		}
		got, present := body["is_new_user"]
		if !present {
			t.Fatalf("is_new_user missing from %s", recorder.Body.String())
		}
		if got != registered {
			t.Errorf("is_new_user = %v, want %v", got, registered)
		}
		if body["token_type"] != "Bearer" {
			t.Errorf("token_type = %v, want Bearer", body["token_type"])
		}
	}
}

// Refresh has no opinion on how the account began, so it must not answer a
// question it did not ask.
func TestRefreshEndpointOmitsIsNewUser(t *testing.T) {
	h := newHarness()
	h.repository.live = &RefreshRecord{
		ID:        "session-1",
		UserID:    "user-1",
		IssuedAt:  time.Date(2026, 8, 1, 12, 0, 0, 0, time.UTC),
		ExpiresAt: time.Date(2026, 9, 1, 12, 0, 0, 0, time.UTC),
	}

	recorder := serve(t, h, http.MethodPost, "/auth/refresh", `{"refresh_token":"whatever"}`)
	if recorder.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200: %s", recorder.Code, recorder.Body.String())
	}

	var body map[string]any
	if err := json.Unmarshal(recorder.Body.Bytes(), &body); err != nil {
		t.Fatalf("response is not JSON: %v", err)
	}
	if _, present := body["is_new_user"]; present {
		t.Errorf("is_new_user present on a refresh: %s", recorder.Body.String())
	}
	if body["access_token"] == "" || body["refresh_token"] == "" {
		t.Errorf("refresh returned an incomplete pair: %s", recorder.Body.String())
	}
}

// An unknown, expired or already-rotated token is one answer: 401.
func TestRefreshEndpointRefusesAnUnknownToken(t *testing.T) {
	h := newHarness()
	recorder := serve(t, h, http.MethodPost, "/auth/refresh", `{"refresh_token":"whatever"}`)
	if recorder.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want 401", recorder.Code)
	}
}

func serve(t *testing.T, h *harness, method, target, body string) *httptest.ResponseRecorder {
	t.Helper()
	router := chi.NewRouter()
	NewHandler(h.service).Mount(router)
	recorder := httptest.NewRecorder()
	router.ServeHTTP(recorder, httptest.NewRequest(method, target, strings.NewReader(body)))
	return recorder
}

// statusFor renders err through the handler's mapping, which is where the
// service's error vocabulary becomes an HTTP answer.
func statusFor(t *testing.T, err error) int {
	t.Helper()
	recorder := httptest.NewRecorder()
	writeError(recorder, httptest.NewRequest(http.MethodPost, "/auth/otp/request", nil), err)
	return recorder.Code
}
