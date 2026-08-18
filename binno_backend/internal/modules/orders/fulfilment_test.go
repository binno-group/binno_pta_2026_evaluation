package orders

import (
	"errors"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
)

// buyerSummary is what the repository returns for an order the fulfilment flow
// acts on: placed by buyerAlice, sold from storeOne.
func buyerSummary() Summary {
	return Summary{BuyerID: buyerAlice, StoreID: storeOne}
}

func lastApplied(t *testing.T, r *fakeRepository) TransitionCommand {
	t.Helper()
	if len(r.applied) != 1 {
		t.Fatalf("applied %d transitions, want exactly 1", len(r.applied))
	}
	return r.applied[0]
}

// --- SubmitPaymentReceipt: buyer-authorized, URL-validated ---

func TestSubmitPaymentReceiptAppliesTriggerWithURL(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo)

	const receipt = "https://cdn.example.uz/receipts/abc.jpg"
	err := service.SubmitPaymentReceipt(principalContext(buyerAlice, authz.RoleBuyer), orderOne, receipt)
	if err != nil {
		t.Fatalf("SubmitPaymentReceipt error = %v", err)
	}
	cmd := lastApplied(t, repo)
	if cmd.Trigger != TriggerSubmitReceipt {
		t.Errorf("Trigger = %q, want %q", cmd.Trigger, TriggerSubmitReceipt)
	}
	if cmd.ReceiptURL != receipt {
		t.Errorf("ReceiptURL = %q, want %q", cmd.ReceiptURL, receipt)
	}
}

func TestSubmitPaymentReceiptRejectsBadURL(t *testing.T) {
	t.Parallel()
	cases := map[string]string{
		"empty":        "",
		"relative":     "/receipts/abc.jpg",
		"no host":      "https://",
		"wrong schema": "ftp://cdn.example.uz/a.jpg",
		"too long":     "https://cdn.example.uz/" + strings.Repeat("a", maxReceiptURL),
	}
	for name, url := range cases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			repo := &fakeRepository{summary: buyerSummary()}
			service := newService(t, repo)

			err := service.SubmitPaymentReceipt(principalContext(buyerAlice, authz.RoleBuyer), orderOne, url)
			if !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
			if len(repo.applied) != 0 {
				t.Errorf("a bad receipt URL still applied a transition: %+v", repo.applied)
			}
		})
	}
}

func TestSubmitPaymentReceiptHidesOthersOrders(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo)

	// Bob tries to file a receipt against Alice's order.
	err := service.SubmitPaymentReceipt(principalContext(buyerBob, authz.RoleBuyer), orderOne, "https://cdn.example.uz/r.jpg")
	if !errors.Is(err, ErrNotFound) {
		t.Fatalf("error = %v, want ErrNotFound (another buyer's order must look absent)", err)
	}
	if len(repo.applied) != 0 {
		t.Errorf("cross-buyer receipt still applied a transition: %+v", repo.applied)
	}
}

// --- seller-side transitions: ownership-gated ---

func TestSellerTransitionsApplyExpectedTrigger(t *testing.T) {
	t.Parallel()
	cases := []struct {
		name    string
		call    func(*Service) error
		trigger Trigger
	}{
		{"confirm payment", func(s *Service) error { return s.ConfirmPayment(principalContext(""), orderOne) }, TriggerConfirmPayment},
		{"start preparing", func(s *Service) error { return s.StartPreparing(principalContext(""), orderOne) }, TriggerStartPreparing},
		{"mark ready", func(s *Service) error { return s.MarkReady(principalContext(""), orderOne) }, TriggerMarkReady},
		{"confirm delivery", func(s *Service) error { return s.ConfirmDelivery(principalContext(""), orderOne) }, TriggerConfirmDelivery},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			repo := &fakeRepository{summary: buyerSummary()}
			service := newService(t, repo, storeOne) // caller owns the selling store

			if err := tc.call(service); err != nil {
				t.Fatalf("%s error = %v", tc.name, err)
			}
			if got := lastApplied(t, repo).Trigger; got != tc.trigger {
				t.Errorf("Trigger = %q, want %q", got, tc.trigger)
			}
		})
	}
}

func TestSellerTransitionsRequireStoreOwnership(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo) // owns no store

	if err := service.ConfirmPayment(principalContext(""), orderOne); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("error = %v, want ErrForbidden for a non-owning seller", err)
	}
	if len(repo.applied) != 0 {
		t.Errorf("a non-owner still applied a transition: %+v", repo.applied)
	}
}

func TestSellerTransitionsRejectMalformedID(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo, storeOne)

	if err := service.MarkReady(principalContext(""), "not-a-uuid"); !errors.Is(err, ErrInvalid) {
		t.Fatalf("error = %v, want ErrInvalid for a malformed order id", err)
	}
}

// --- RejectPayment: reason-bounded, ownership-gated ---

func TestRejectPaymentCarriesReason(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo, storeOne)

	const reason = "receipt amount does not match the invoice"
	if err := service.RejectPayment(principalContext(""), orderOne, reason); err != nil {
		t.Fatalf("RejectPayment error = %v", err)
	}
	cmd := lastApplied(t, repo)
	if cmd.Trigger != TriggerRejectPayment {
		t.Errorf("Trigger = %q, want %q", cmd.Trigger, TriggerRejectPayment)
	}
	if cmd.Reason != reason {
		t.Errorf("Reason = %q, want %q", cmd.Reason, reason)
	}
}

func TestRejectPaymentBoundsReasonLength(t *testing.T) {
	t.Parallel()
	repo := &fakeRepository{summary: buyerSummary()}
	service := newService(t, repo, storeOne)

	err := service.RejectPayment(principalContext(""), orderOne, strings.Repeat("x", maxCancelReason+1))
	if !errors.Is(err, ErrInvalid) {
		t.Fatalf("error = %v, want ErrInvalid for an over-long reason", err)
	}
	if len(repo.applied) != 0 {
		t.Errorf("an over-long reason still applied a transition: %+v", repo.applied)
	}
}
