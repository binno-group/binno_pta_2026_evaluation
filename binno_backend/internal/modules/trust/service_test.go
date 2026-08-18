package trust

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
	storeOne = "018f0f50-0000-7000-8000-0000000057a1"
	orderOne = "018f0f50-0000-7000-8000-0000000000d1"
)

type fakeRepository struct{ saved []Feedback }

func (f *fakeRepository) CreateOrderFeedback(_ context.Context, in Feedback, _ time.Time) error {
	f.saved = append(f.saved, in)
	return nil
}

type fakeSummaries struct {
	summary orders.Summary
	err     error
}

func (f fakeSummaries) GetOrderSummary(context.Context, string) (orders.Summary, error) {
	return f.summary, f.err
}

func newService(repository repository, summaries orders.SummaryPort) *Service {
	return NewService(repository, summaries,
		clock.NewFixed(time.Date(2026, 7, 29, 10, 0, 0, 0, time.UTC)))
}

func principal(userID string) context.Context {
	return authz.WithPrincipal(context.Background(), authz.Principal{
		UserID: userID, Roles: []authz.Role{authz.RoleBuyer},
	})
}

func validFeedback() FeedbackInput {
	return FeedbackInput{OrderID: orderOne, HadProblem: false, Channel: "app", Tags: []string{"late"}}
}

func closedOrder() orders.Summary {
	return orders.Summary{OrderID: orderOne, BuyerID: alice, StoreID: storeOne, Status: orders.StatusClosed}
}

// The store is taken from the order, not from the request, so feedback can never
// be attributed to a store the order was not placed with.
func TestFeedbackTakesTheStoreFromTheOrder(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(repository, fakeSummaries{summary: closedOrder()})

	if err := service.CreateOrderFeedback(principal(alice), validFeedback()); err != nil {
		t.Fatalf("CreateOrderFeedback error = %v", err)
	}
	if len(repository.saved) != 1 {
		t.Fatalf("saved %d records, want 1", len(repository.saved))
	}
	if got := repository.saved[0].StoreID; got != storeOne {
		t.Fatalf("StoreID = %q, want %q from the order summary", got, storeOne)
	}
}

// Only the buyer who placed the order may rate it, and a foreign order reports
// not found so the endpoint cannot enumerate order ids.
func TestFeedbackIsScopedToTheOrdersBuyer(t *testing.T) {
	t.Parallel()
	repository := &fakeRepository{}
	service := newService(repository, fakeSummaries{summary: closedOrder()})

	if err := service.CreateOrderFeedback(principal(bob), validFeedback()); !errors.Is(err, ErrNotFound) {
		t.Fatalf("error = %v, want ErrNotFound", err)
	}
	if len(repository.saved) != 0 {
		t.Fatal("an unauthorised feedback record reached the repository")
	}

	if err := service.CreateOrderFeedback(context.Background(), validFeedback()); !errors.Is(err, authz.ErrUnauthenticated) {
		t.Fatalf("anonymous error = %v, want ErrUnauthenticated", err)
	}
}

// Feedback is only meaningful once the order has settled.
func TestFeedbackRequiresAClosedOrder(t *testing.T) {
	t.Parallel()
	for _, status := range []orders.Status{
		orders.StatusCreated, orders.StatusAccepted, orders.StatusPaid,
		orders.StatusCancelledByBuyerSLA,
	} {
		repository := &fakeRepository{}
		summary := closedOrder()
		summary.Status = status
		service := newService(repository, fakeSummaries{summary: summary})

		if err := service.CreateOrderFeedback(principal(alice), validFeedback()); !errors.Is(err, ErrConflict) {
			t.Errorf("status %q: error = %v, want ErrConflict", status, err)
		}
		if len(repository.saved) != 0 {
			t.Errorf("status %q: feedback was stored for an unfinished order", status)
		}
	}
}

// A missing order must not surface the orders module's own error vocabulary.
func TestUnknownOrderIsReportedAsNotFound(t *testing.T) {
	t.Parallel()
	service := newService(&fakeRepository{}, fakeSummaries{err: orders.ErrNotFound})

	if err := service.CreateOrderFeedback(principal(alice), validFeedback()); !errors.Is(err, ErrNotFound) {
		t.Fatalf("error = %v, want trust.ErrNotFound", err)
	}
}

func TestFeedbackValidation(t *testing.T) {
	t.Parallel()
	service := newService(&fakeRepository{}, fakeSummaries{summary: closedOrder()})
	ctx := principal(alice)

	tests := map[string]func(*FeedbackInput){
		"unknown tag":     func(in *FeedbackInput) { in.Tags = []string{"rude"} },
		"duplicate tag":   func(in *FeedbackInput) { in.Tags = []string{"late", "late"} },
		"unknown channel": func(in *FeedbackInput) { in.Channel = "carrier_pigeon" },
		"empty channel":   func(in *FeedbackInput) { in.Channel = "" },
		"malformed order": func(in *FeedbackInput) { in.OrderID = "nope" },
		"long comment": func(in *FeedbackInput) {
			in.Comment = string(make([]byte, maxFeedbackComment+1))
		},
	}
	for name, mutate := range tests {
		t.Run(name, func(t *testing.T) {
			in := validFeedback()
			mutate(&in)
			if err := service.CreateOrderFeedback(ctx, in); !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
		})
	}
}
