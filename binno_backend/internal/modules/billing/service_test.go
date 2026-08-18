package billing

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const (
	alice    = "018f0f50-0000-7000-8000-00000000a11c"
	bob      = "018f0f50-0000-7000-8000-00000000b0b0"
	ownerOne = "018f0f50-0000-7000-8000-00000000e001"
	ownerTwo = "018f0f50-0000-7000-8000-00000000e002"
	storeOne = "018f0f50-0000-7000-8000-0000000057a1"
	orderOne = "018f0f50-0000-7000-8000-0000000000d1"
)

type fakeRepository struct {
	invoiceCalls   int
	refundCalls    int
	commissionCall int
}

func (f *fakeRepository) GetPaymentInvoice(context.Context, string) (Invoice, error) {
	f.invoiceCalls++
	return Invoice{Number: "INV-1", TotalAmount: 100}, nil
}

func (f *fakeRepository) SubmitRefundEvidence(context.Context, RefundEvidence, time.Time) error {
	f.refundCalls++
	return nil
}

func (f *fakeRepository) ListCommissionInvoices(context.Context, string, string) ([]CommissionInvoice, error) {
	f.commissionCall++
	return []CommissionInvoice{{ID: "c1"}}, nil
}

type fakeSummaries struct{ summary orders.Summary }

func (f fakeSummaries) GetOrderSummary(context.Context, string) (orders.Summary, error) {
	return f.summary, nil
}

type stubGuard struct {
	stores map[string]bool
	owners map[string]bool
}

func (g stubGuard) OwnerID(context.Context) (string, error) { return ownerOne, nil }

func (g stubGuard) EnsureOwnsStore(_ context.Context, storeID string) error {
	if g.stores[storeID] {
		return nil
	}
	return authz.ErrForbidden
}

func (g stubGuard) EnsureOwner(_ context.Context, ownerID string) error {
	if g.owners[ownerID] {
		return nil
	}
	return authz.ErrForbidden
}

func newService(repository repository, summary orders.Summary, guard stubGuard) *Service {
	return NewService(repository, fakeSummaries{summary: summary}, guard,
		clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)))
}

func principal(userID string, roles ...authz.Role) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{UserID: userID, Roles: roles})
}

// The commission endpoint used to return any owner's financial position to any
// authenticated caller: the handler checked that a token existed and then passed
// the path parameter straight through.
func TestListCommissionInvoicesIsScopedToTheCallersOwnerAccount(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(repository, orders.Summary{}, stubGuard{owners: map[string]bool{ownerOne: true}})

	if _, err := service.ListCommissionInvoices(principal(alice, authz.RoleSeller), ownerTwo, ""); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("error = %v, want ErrForbidden for another owner's invoices", err)
	}
	if repository.commissionCall != 0 {
		t.Fatal("an unauthorised request reached the repository")
	}

	if _, err := service.ListCommissionInvoices(principal(alice, authz.RoleSeller), ownerOne, ""); err != nil {
		t.Fatalf("own commission invoices error = %v", err)
	}
}

// An invoice is readable by the order's buyer and by the selling store, and by
// nobody else.
func TestGetPaymentInvoiceAcceptsBothOrderPartiesOnly(t *testing.T) {
	t.Parallel()
	summary := orders.Summary{OrderID: orderOne, BuyerID: alice, StoreID: storeOne}

	t.Run("buyer", func(t *testing.T) {
		repository := &fakeRepository{}
		service := newService(repository, summary, stubGuard{})
		if _, err := service.GetPaymentInvoice(principal(alice, authz.RoleBuyer), orderOne); err != nil {
			t.Fatalf("buyer error = %v", err)
		}
	})

	t.Run("selling store", func(t *testing.T) {
		repository := &fakeRepository{}
		service := newService(repository, summary, stubGuard{stores: map[string]bool{storeOne: true}})
		if _, err := service.GetPaymentInvoice(principal(bob, authz.RoleSeller), orderOne); err != nil {
			t.Fatalf("seller error = %v", err)
		}
	})

	t.Run("unrelated principal", func(t *testing.T) {
		repository := &fakeRepository{}
		service := newService(repository, summary, stubGuard{})
		_, err := service.GetPaymentInvoice(principal(bob, authz.RoleBuyer), orderOne)
		if !errors.Is(err, ErrNotFound) {
			t.Fatalf("error = %v, want ErrNotFound", err)
		}
		if repository.invoiceCalls != 0 {
			t.Fatal("an unauthorised request reached the repository")
		}
	})

	t.Run("anonymous", func(t *testing.T) {
		repository := &fakeRepository{}
		service := newService(repository, summary, stubGuard{})
		if _, err := service.GetPaymentInvoice(context.Background(), orderOne); !errors.Is(err, authz.ErrUnauthenticated) {
			t.Fatalf("error = %v, want ErrUnauthenticated", err)
		}
	})
}

// Refund evidence is the seller's assertion, so only the selling store may file
// it, not the buyer, who has an obvious incentive.
func TestSubmitRefundEvidenceRequiresTheSellingStore(t *testing.T) {
	t.Parallel()
	summary := orders.Summary{OrderID: orderOne, BuyerID: alice, StoreID: storeOne}
	evidence := RefundEvidence{OrderID: orderOne, Amount: 5000, EvidenceURL: "https://example.test/receipt.pdf"}

	repository := &fakeRepository{}
	buyerService := newService(repository, summary, stubGuard{})
	if err := buyerService.SubmitRefundEvidence(principal(alice, authz.RoleBuyer), evidence); !errors.Is(err, authz.ErrForbidden) {
		t.Fatalf("buyer error = %v, want ErrForbidden", err)
	}
	if repository.refundCalls != 0 {
		t.Fatal("an unauthorised request reached the repository")
	}

	sellerRepository := &fakeRepository{}
	sellerService := newService(sellerRepository, summary, stubGuard{stores: map[string]bool{storeOne: true}})
	if err := sellerService.SubmitRefundEvidence(principal(bob, authz.RoleSeller), evidence); err != nil {
		t.Fatalf("seller error = %v", err)
	}
	if sellerRepository.refundCalls != 1 {
		t.Fatalf("refund calls = %d, want 1", sellerRepository.refundCalls)
	}
}

func TestSubmitRefundEvidenceValidation(t *testing.T) {
	t.Parallel()
	summary := orders.Summary{OrderID: orderOne, BuyerID: alice, StoreID: storeOne}
	service := newService(&fakeRepository{}, summary, stubGuard{stores: map[string]bool{storeOne: true}})
	ctx := principal(bob, authz.RoleSeller)

	tests := map[string]RefundEvidence{
		"malformed order":  {OrderID: "nope", Amount: 1, EvidenceURL: "https://x.test"},
		"zero amount":      {OrderID: orderOne, Amount: 0, EvidenceURL: "https://x.test"},
		"negative amount":  {OrderID: orderOne, Amount: -1, EvidenceURL: "https://x.test"},
		"missing evidence": {OrderID: orderOne, Amount: 1},
	}
	for name, evidence := range tests {
		t.Run(name, func(t *testing.T) {
			if err := service.SubmitRefundEvidence(ctx, evidence); !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
		})
	}
}
