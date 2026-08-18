package orders

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

const (
	buyerAlice = "018f0f50-0000-7000-8000-00000000a11c"
	buyerBob   = "018f0f50-0000-7000-8000-00000000b0b0"
	storeOne   = "018f0f50-0000-7000-8000-0000000057a1"
	productOne = "018f0f50-0000-7000-8000-000000000401"
	orderOne   = "018f0f50-0000-7000-8000-0000000000d1"
)

// fakeRepository records what the service asked for without touching a database.
type fakeRepository struct {
	summary    Summary
	summaryErr error
	applied    []TransitionCommand
	created    []CreateCommand
}

func (f *fakeRepository) Create(_ context.Context, cmd CreateCommand) (Created, error) {
	f.created = append(f.created, cmd)
	return Created{OrderID: orderOne, Status: string(StatusCreated)}, nil
}

func (f *fakeRepository) Apply(_ context.Context, cmd TransitionCommand) error {
	f.applied = append(f.applied, cmd)
	return nil
}

func (f *fakeRepository) ConfirmToken(context.Context, string, string, time.Time) error { return nil }

func (f *fakeRepository) Summary(context.Context, string) (Summary, error) {
	return f.summary, f.summaryErr
}

func (f *fakeRepository) Alternatives(context.Context, string, string) (AlternativePage, error) {
	return AlternativePage{Items: []Alternative{}}, nil
}

func (f *fakeRepository) ListByBuyer(context.Context, string, string) (OrderPage, error) {
	return OrderPage{Items: []OrderView{}}, nil
}

func (f *fakeRepository) ListStoreOpen(context.Context, string, string) (OrderPage, error) {
	return OrderPage{Items: []OrderView{}}, nil
}

func (f *fakeRepository) Detail(context.Context, string) (OrderDetail, error) {
	return OrderDetail{}, nil
}

// stubGuard answers store ownership from a fixed allow list.
type stubGuard struct{ ownedStores map[string]bool }

func (g stubGuard) OwnerID(context.Context) (string, error) { return "", authz.ErrForbidden }

func (g stubGuard) EnsureOwnsStore(_ context.Context, storeID string) error {
	if g.ownedStores[storeID] {
		return nil
	}
	return authz.ErrForbidden
}

func (g stubGuard) EnsureOwner(context.Context, string) error { return authz.ErrForbidden }

func newService(t *testing.T, repository *fakeRepository, owned ...string) *Service {
	t.Helper()
	stores := make(map[string]bool, len(owned))
	for _, id := range owned {
		stores[id] = true
	}
	return NewService(repository, stubGuard{ownedStores: stores},
		clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)))
}

func principalContext(userID string, roles ...authz.Role) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{UserID: userID, Roles: roles})
}

func validCreateInput() CreateInput {
	return CreateInput{
		StoreID:     storeOne,
		BuyerType:   buyerIndividual,
		Fulfillment: fulfilPickup,
		DistrictID:  1,
		Items:       []ItemInput{{ProductID: productOne, Qty: "2"}},
	}
}

// The buyer is taken from the verified principal, never from the request body.
func TestCreateOrderUsesAuthenticatedPrincipalAsBuyer(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(t, repository)

	if _, err := service.CreateOrder(principalContext(buyerAlice, authz.RoleBuyer), validCreateInput()); err != nil {
		t.Fatalf("CreateOrder error = %v", err)
	}
	if len(repository.created) != 1 {
		t.Fatalf("created %d orders, want 1", len(repository.created))
	}
	if got := repository.created[0].BuyerID; got != buyerAlice {
		t.Fatalf("BuyerID = %q, want the authenticated principal %q", got, buyerAlice)
	}
}

func TestCreateOrderRequiresBuyerRole(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(t, repository)

	tests := []struct {
		name string
		ctx  context.Context
		want error
	}{
		{"anonymous", context.Background(), authz.ErrUnauthenticated},
		{"seller only", principalContext(buyerAlice, authz.RoleSeller), authz.ErrForbidden},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if _, err := service.CreateOrder(test.ctx, validCreateInput()); !errors.Is(err, test.want) {
				t.Fatalf("CreateOrder error = %v, want %v", err, test.want)
			}
			if len(repository.created) != 0 {
				t.Fatal("an unauthorised request reached the repository")
			}
		})
	}
}

// A seller may only act on orders placed against a store it owns.
func TestSupplierActionsRequireStoreOwnership(t *testing.T) {
	t.Parallel()
	otherStore := "018f0f50-0000-7000-8000-0000000057a2"

	actions := map[string]func(*Service, context.Context) error{
		"supplier confirm": func(s *Service, ctx context.Context) error {
			return s.SupplierConfirm(ctx, orderOne)
		},
		"decline": func(s *Service, ctx context.Context) error {
			return s.Decline(ctx, orderOne)
		},
	}

	for name, action := range actions {
		t.Run(name, func(t *testing.T) {
			repository := &fakeRepository{summary: Summary{
				OrderID: orderOne, BuyerID: buyerBob, StoreID: otherStore, Status: StatusCreated,
			}}
			service := newService(t, repository, storeOne)
			ctx := principalContext(buyerAlice, authz.RoleSeller)

			if err := action(service, ctx); !errors.Is(err, authz.ErrForbidden) {
				t.Fatalf("error = %v, want ErrForbidden", err)
			}
			if len(repository.applied) != 0 {
				t.Fatal("an unauthorised transition reached the repository")
			}
		})
	}
}

func TestSupplierConfirmSucceedsForOwnedStore(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{summary: Summary{
		OrderID: orderOne, BuyerID: buyerBob, StoreID: storeOne, Status: StatusCreated,
	}}
	service := newService(t, repository, storeOne)

	if err := service.SupplierConfirm(principalContext(buyerAlice, authz.RoleSeller), orderOne); err != nil {
		t.Fatalf("SupplierConfirm error = %v", err)
	}
	if len(repository.applied) != 1 || repository.applied[0].Trigger != TriggerSupplierConfirm {
		t.Fatalf("applied = %+v, want one supplier_confirm", repository.applied)
	}
}

// A buyer may only act on their own order, and a foreign order is reported as
// not found so the endpoint cannot be used to enumerate order ids.
func TestBuyerActionsAreScopedToTheOrdersOwnBuyer(t *testing.T) {
	t.Parallel()
	actions := map[string]func(*Service, context.Context) error{
		"cancel": func(s *Service, ctx context.Context) error {
			return s.Cancel(ctx, orderOne, "changed my mind")
		},
		"confirm pickup": func(s *Service, ctx context.Context) error {
			return s.ConfirmPickup(ctx, orderOne, PickupInput{Code: "1234"})
		},
		"alternatives": func(s *Service, ctx context.Context) error {
			_, err := s.Alternatives(ctx, orderOne, "")
			return err
		},
	}

	for name, action := range actions {
		t.Run(name, func(t *testing.T) {
			repository := &fakeRepository{summary: Summary{
				OrderID: orderOne, BuyerID: buyerBob, StoreID: storeOne,
				Status: StatusBuyerDecisionPending,
			}}
			service := newService(t, repository)

			err := action(service, principalContext(buyerAlice, authz.RoleBuyer))
			if !errors.Is(err, ErrNotFound) {
				t.Fatalf("error = %v, want ErrNotFound (existence must not leak)", err)
			}
			if len(repository.applied) != 0 {
				t.Fatal("an unauthorised transition reached the repository")
			}
		})
	}
}

func TestCancelSucceedsForOwnOrder(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{summary: Summary{
		OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusCreated,
	}}
	service := newService(t, repository)

	if err := service.Cancel(principalContext(buyerAlice, authz.RoleBuyer), orderOne, "changed my mind"); err != nil {
		t.Fatalf("Cancel error = %v", err)
	}
	if len(repository.applied) != 1 || repository.applied[0].Trigger != TriggerBuyerCancel {
		t.Fatalf("applied = %+v, want one buyer_cancel", repository.applied)
	}
	if repository.applied[0].Reason == "" {
		t.Error("cancellation reason must reach the repository for the audit log")
	}
}

// The SMS confirmation link carries no principal: the single-use token is the
// credential, so this path must work for an anonymous request.
func TestTokenConfirmDoesNotRequireAPrincipal(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(t, repository)

	if err := service.TokenConfirm(context.Background(), orderOne, "secret-token"); err != nil {
		t.Fatalf("TokenConfirm error = %v", err)
	}
}

func TestCreateOrderValidation(t *testing.T) {
	t.Parallel()
	dropoff := geo.Point{Lat: 41.31, Lng: 69.24}

	tests := map[string]func(*CreateInput){
		"unknown buyer type":       func(in *CreateInput) { in.BuyerType = "corporation" },
		"unknown fulfilment":       func(in *CreateInput) { in.Fulfillment = "teleport" },
		"no items":                 func(in *CreateInput) { in.Items = nil },
		"duplicate product":        func(in *CreateInput) { in.Items = append(in.Items, in.Items[0]) },
		"zero quantity":            func(in *CreateInput) { in.Items[0].Qty = "0" },
		"negative quantity":        func(in *CreateInput) { in.Items[0].Qty = "-1" },
		"malformed store":          func(in *CreateInput) { in.StoreID = "not-a-uuid" },
		"missing district":         func(in *CreateInput) { in.DistrictID = 0 },
		"delivery without dropoff": func(in *CreateInput) { in.Fulfillment = fulfilDelivery },
		"legal entity without TIN": func(in *CreateInput) { in.BuyerType = buyerLegalEntity },
		"legal entity short TIN":   func(in *CreateInput) { in.BuyerType = buyerLegalEntity; in.BuyerTIN = "123" },
		"legal entity nonnumeric":  func(in *CreateInput) { in.BuyerType = buyerLegalEntity; in.BuyerTIN = "12345678x" },
	}

	for name, mutate := range tests {
		t.Run(name, func(t *testing.T) {
			repository := &fakeRepository{}
			service := newService(t, repository)
			in := validCreateInput()
			mutate(&in)

			if _, err := service.CreateOrder(principalContext(buyerAlice, authz.RoleBuyer), in); !errors.Is(err, ErrInvalid) {
				t.Fatalf("CreateOrder error = %v, want ErrInvalid", err)
			}
			if len(repository.created) != 0 {
				t.Fatal("invalid input reached the repository")
			}
		})
	}

	repository := &fakeRepository{}
	service := newService(t, repository)
	in := validCreateInput()
	in.Fulfillment = fulfilDelivery
	in.Dropoff = &dropoff
	in.DropoffAddress = "Chilanzar 12"
	if _, err := service.CreateOrder(principalContext(buyerAlice, authz.RoleBuyer), in); err != nil {
		t.Fatalf("valid delivery order rejected: %v", err)
	}
}

// Pickup proof is exactly one of a code or a signature; neither and both are
// refused.
func TestConfirmPickupRequiresExactlyOneProof(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{summary: Summary{
		OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusReady,
	}}
	service := newService(t, repository)
	ctx := principalContext(buyerAlice, authz.RoleBuyer)

	for name, input := range map[string]PickupInput{
		"neither": {},
		"both":    {Code: "1234", SignatureURL: "https://example.test/s.png"},
	} {
		t.Run(name, func(t *testing.T) {
			if err := service.ConfirmPickup(ctx, orderOne, input); !errors.Is(err, ErrInvalid) {
				t.Fatalf("ConfirmPickup error = %v, want ErrInvalid", err)
			}
		})
	}
	if err := service.ConfirmPickup(ctx, orderOne, PickupInput{Code: "1234"}); err != nil {
		t.Fatalf("ConfirmPickup with a code error = %v", err)
	}
}

// Alternatives are only meaningful while the buyer is choosing a replacement.
func TestAlternativesRequireBuyerDecisionPending(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{summary: Summary{
		OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusAccepted,
	}}
	service := newService(t, repository)

	_, err := service.Alternatives(principalContext(buyerAlice, authz.RoleBuyer), orderOne, "")
	if !errors.Is(err, ErrConflict) {
		t.Fatalf("Alternatives error = %v, want ErrConflict", err)
	}
}

func TestValidateReceiptURL(t *testing.T) {
	t.Parallel()
	cases := map[string]struct {
		value string
		valid bool
	}{
		"https":              {"https://cdn.binno.uz/receipts/a.pdf", true},
		"http":               {"http://localhost:9000/r/a.png", true},
		"empty":              {"", false},
		"relative":           {"/receipts/a.pdf", false},
		"no host":            {"https://", false},
		"javascript scheme":  {"javascript:alert(1)", false},
		"file scheme":        {"file:///etc/passwd", false},
		"data uri":           {"data:text/html;base64,PHNjcmlwdD4=", false},
		"over the maxLength": {"https://x/" + strings.Repeat("a", 2048), false},
	}
	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			err := validateReceiptURL(tc.value)
			if tc.valid && err != nil {
				t.Errorf("validateReceiptURL(%q) = %v, want nil", tc.value, err)
			}
			if !tc.valid && err == nil {
				t.Errorf("validateReceiptURL(%q) = nil, want an error", tc.value)
			}
		})
	}
}

// The blended rate stored on a ledger row is derived from the exact accrual, not
// the other way round.
func TestEffectiveRateBps(t *testing.T) {
	t.Parallel()
	cases := []struct {
		name          string
		base, accrued int64
		want          int32
	}{
		{"uniform 2.5%", 100_000, 2_500, 250},
		{"zero base is not a division", 0, 0, 0},
		{"nothing accrued", 100_000, 0, 0},
		{"rounds half up", 3, 1, 3333},
		{"whole rate", 1_000, 1_000, 10_000},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if got := effectiveRateBps(tc.base, tc.accrued); got != tc.want {
				t.Errorf("effectiveRateBps(%d, %d) = %d, want %d", tc.base, tc.accrued, got, tc.want)
			}
		})
	}
}

// A uniform basket records the rate that was agreed.
func TestRateForLinesPrefersTheAgreedRate(t *testing.T) {
	t.Parallel()
	uniform := []*store.OrdersOrderItem{
		{LineAmount: 5252, CommissionBps: 250},
	}
	if got := rateForLines(uniform, 5252, 131); got != 250 {
		t.Errorf("uniform basket: rateForLines = %d, want 250 (the agreed rate)", got)
	}

	mixed := []*store.OrdersOrderItem{
		{LineAmount: 10_000, CommissionBps: 250},
		{LineAmount: 10_000, CommissionBps: 750},
	}
	if got := rateForLines(mixed, 20_000, 1_000); got != 500 {
		t.Errorf("mixed basket: rateForLines = %d, want the blended 500", got)
	}

	if got := rateForLines(nil, 0, 0); got != 0 {
		t.Errorf("no lines: rateForLines = %d, want 0", got)
	}
}

// fulfilmentActions is the seller-driven half of the lifecycle: everything the
// order passes through between "the money arrived" and "the goods left".
var fulfilmentActions = map[string]func(*Service, context.Context) error{
	"confirm payment": func(s *Service, ctx context.Context) error {
		return s.ConfirmPayment(ctx, orderOne)
	},
	"reject payment": func(s *Service, ctx context.Context) error {
		return s.RejectPayment(ctx, orderOne, "the reference does not match")
	},
	"start preparing": func(s *Service, ctx context.Context) error {
		return s.StartPreparing(ctx, orderOne)
	},
	"mark ready": func(s *Service, ctx context.Context) error {
		return s.MarkReady(ctx, orderOne)
	},
	"confirm delivery": func(s *Service, ctx context.Context) error {
		return s.ConfirmDelivery(ctx, orderOne)
	},
}

// Each one reaches the repository as its own trigger. A copy-paste that pointed
// two of these at the same trigger would still pass every ownership test, and
// would quietly move orders to the wrong state.
func TestFulfilmentActionsApplyTheirOwnTrigger(t *testing.T) {
	t.Parallel()
	want := map[string]Trigger{
		"confirm payment":  TriggerConfirmPayment,
		"reject payment":   TriggerRejectPayment,
		"start preparing":  TriggerStartPreparing,
		"mark ready":       TriggerMarkReady,
		"confirm delivery": TriggerConfirmDelivery,
	}
	seen := make(map[Trigger]string, len(want))

	for name, action := range fulfilmentActions {
		t.Run(name, func(t *testing.T) {
			repository := &fakeRepository{summary: Summary{
				OrderID: orderOne, BuyerID: buyerBob, StoreID: storeOne, Status: StatusPaid,
			}}
			service := newService(t, repository, storeOne)

			if err := action(service, principalContext(buyerAlice, authz.RoleSeller)); err != nil {
				t.Fatalf("%s: %v", name, err)
			}
			if len(repository.applied) != 1 {
				t.Fatalf("%s applied %d transitions, want 1", name, len(repository.applied))
			}
			got := repository.applied[0]
			if got.Trigger != want[name] {
				t.Errorf("%s applied %q, want %q", name, got.Trigger, want[name])
			}
			if got.OrderID != orderOne {
				t.Errorf("%s applied to order %q, want %q", name, got.OrderID, orderOne)
			}
		})
	}

	// Run again outside the subtests so the uniqueness check sees every trigger.
	for name, action := range fulfilmentActions {
		repository := &fakeRepository{summary: Summary{
			OrderID: orderOne, BuyerID: buyerBob, StoreID: storeOne, Status: StatusPaid,
		}}
		service := newService(t, repository, storeOne)
		if err := action(service, principalContext(buyerAlice, authz.RoleSeller)); err != nil {
			t.Fatalf("%s: %v", name, err)
		}
		trigger := repository.applied[0].Trigger
		if other, clash := seen[trigger]; clash {
			t.Errorf("%s and %s both apply %q", name, other, trigger)
		}
		seen[trigger] = name
	}
}

// The store that sold the order is the only store allowed to move it on.
func TestFulfilmentActionsRequireTheSellingStore(t *testing.T) {
	t.Parallel()
	otherStore := "018f0f50-0000-7000-8000-0000000057a2"

	for name, action := range fulfilmentActions {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			repository := &fakeRepository{summary: Summary{
				OrderID: orderOne, BuyerID: buyerBob, StoreID: otherStore, Status: StatusPaid,
			}}
			service := newService(t, repository, storeOne)

			err := action(service, principalContext(buyerAlice, authz.RoleSeller))
			if !errors.Is(err, authz.ErrForbidden) {
				t.Fatalf("error = %v, want ErrForbidden", err)
			}
			if len(repository.applied) != 0 {
				t.Fatal("an unauthorised transition reached the repository")
			}
		})
	}
}

// A malformed id must be refused before the repository is asked anything: the
// order id comes straight off the URL.
func TestFulfilmentActionsRejectAMalformedOrderID(t *testing.T) {
	t.Parallel()
	for name, action := range map[string]func(*Service, context.Context, string) error{
		"confirm payment": func(s *Service, ctx context.Context, id string) error {
			return s.ConfirmPayment(ctx, id)
		},
		"start preparing": func(s *Service, ctx context.Context, id string) error {
			return s.StartPreparing(ctx, id)
		},
		"mark ready": func(s *Service, ctx context.Context, id string) error {
			return s.MarkReady(ctx, id)
		},
		"confirm delivery": func(s *Service, ctx context.Context, id string) error {
			return s.ConfirmDelivery(ctx, id)
		},
		"submit receipt": func(s *Service, ctx context.Context, id string) error {
			return s.SubmitPaymentReceipt(ctx, id, "https://cdn.binno.uz/r/a.pdf")
		},
	} {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			repository := &fakeRepository{}
			service := newService(t, repository, storeOne)

			err := action(service, principalContext(buyerAlice, authz.RoleSeller), "not-a-uuid")
			if !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
			if len(repository.applied) != 0 {
				t.Fatal("a malformed id reached the repository")
			}
		})
	}
}

// A rejection reason is free text from the seller and lands in a bounded column.
func TestRejectPaymentBoundsTheReason(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{summary: Summary{
		OrderID: orderOne, BuyerID: buyerBob, StoreID: storeOne, Status: StatusPaymentReview,
	}}
	service := newService(t, repository, storeOne)
	ctx := principalContext(buyerAlice, authz.RoleSeller)

	if err := service.RejectPayment(ctx, orderOne, strings.Repeat("x", maxCancelReason+1)); !errors.Is(err, ErrInvalid) {
		t.Fatalf("over-long reason: error = %v, want ErrInvalid", err)
	}
	if len(repository.applied) != 0 {
		t.Fatal("an over-long reason reached the repository")
	}

	reason := "the reference does not match the invoice"
	if err := service.RejectPayment(ctx, orderOne, reason); err != nil {
		t.Fatalf("RejectPayment: %v", err)
	}
	if got := repository.applied[0].Reason; got != reason {
		t.Errorf("Reason = %q, want %q", got, reason)
	}

	// An empty reason is allowed where cancelling demands one: rejecting a
	// receipt is already self-explanatory, cancelling an order is not.
	repository.applied = nil
	if err := service.RejectPayment(ctx, orderOne, ""); err != nil {
		t.Fatalf("empty reason: %v", err)
	}
}

// The receipt is the buyer's own to file, and its URL is validated before the
// order is even looked up.
func TestSubmitPaymentReceipt(t *testing.T) {
	t.Parallel()

	t.Run("buyer files their own receipt", func(t *testing.T) {
		t.Parallel()
		repository := &fakeRepository{summary: Summary{
			OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusAwaitingPayment,
		}}
		service := newService(t, repository, storeOne)

		receipt := "https://cdn.binno.uz/receipts/a.pdf"
		err := service.SubmitPaymentReceipt(principalContext(buyerAlice, authz.RoleBuyer), orderOne, receipt)
		if err != nil {
			t.Fatalf("SubmitPaymentReceipt: %v", err)
		}
		if len(repository.applied) != 1 {
			t.Fatalf("applied %d transitions, want 1", len(repository.applied))
		}
		got := repository.applied[0]
		if got.Trigger != TriggerSubmitReceipt {
			t.Errorf("Trigger = %q, want %q", got.Trigger, TriggerSubmitReceipt)
		}
		if got.ReceiptURL != receipt {
			t.Errorf("ReceiptURL = %q, want %q", got.ReceiptURL, receipt)
		}
	})

	t.Run("another buyer cannot file it", func(t *testing.T) {
		t.Parallel()
		repository := &fakeRepository{summary: Summary{
			OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusAwaitingPayment,
		}}
		service := newService(t, repository, storeOne)

		err := service.SubmitPaymentReceipt(principalContext(buyerBob, authz.RoleBuyer), orderOne,
			"https://cdn.binno.uz/receipts/a.pdf")
		// Not found, not forbidden: whether that order exists is not Bob's to learn.
		if !errors.Is(err, ErrNotFound) {
			t.Fatalf("error = %v, want ErrNotFound", err)
		}
		if len(repository.applied) != 0 {
			t.Fatal("an unauthorised receipt reached the repository")
		}
	})

	t.Run("a hostile URL is refused before the order is loaded", func(t *testing.T) {
		t.Parallel()
		for _, bad := range []string{
			"javascript:alert(1)",
			"file:///etc/passwd",
			"/etc/passwd",
			"",
			"https://x/" + strings.Repeat("a", maxReceiptURL),
		} {
			repository := &fakeRepository{summary: Summary{
				OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusAwaitingPayment,
			}}
			service := newService(t, repository, storeOne)

			err := service.SubmitPaymentReceipt(principalContext(buyerAlice, authz.RoleBuyer), orderOne, bad)
			if !errors.Is(err, ErrInvalid) {
				t.Errorf("SubmitPaymentReceipt(%q) = %v, want ErrInvalid", bad, err)
			}
			if len(repository.applied) != 0 {
				t.Errorf("SubmitPaymentReceipt(%q) reached the repository", bad)
			}
		}
	})
}

func TestGetOrderSummary(t *testing.T) {
	t.Parallel()

	t.Run("returns what the repository holds", func(t *testing.T) {
		t.Parallel()
		want := Summary{OrderID: orderOne, BuyerID: buyerAlice, StoreID: storeOne, Status: StatusPaid}
		service := newService(t, &fakeRepository{summary: want}, storeOne)

		got, err := service.GetOrderSummary(context.Background(), orderOne)
		if err != nil {
			t.Fatalf("GetOrderSummary: %v", err)
		}
		if got != want {
			t.Errorf("summary = %+v, want %+v", got, want)
		}
	})

	t.Run("a malformed id never reaches the repository", func(t *testing.T) {
		t.Parallel()
		repository := &fakeRepository{summaryErr: errors.New("the repository was queried")}
		service := newService(t, repository, storeOne)

		if _, err := service.GetOrderSummary(context.Background(), "not-a-uuid"); !errors.Is(err, ErrInvalid) {
			t.Fatalf("error = %v, want ErrInvalid", err)
		}
	})

	t.Run("a repository failure is passed through", func(t *testing.T) {
		t.Parallel()
		service := newService(t, &fakeRepository{summaryErr: ErrNotFound}, storeOne)

		if _, err := service.GetOrderSummary(context.Background(), orderOne); !errors.Is(err, ErrNotFound) {
			t.Fatalf("error = %v, want ErrNotFound", err)
		}
	})
}
