package orders

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

type fakeSweeperRepository struct {
	due          []DueOrder
	paymentDue   []DueOrder
	escalated    []string
	escalateKeys []string
	applied      []TransitionCommand
	applyErr     error
	escalateSeen map[string]bool
}

func (f *fakeSweeperRepository) AwaitingConfirmation(context.Context, time.Time, int32) ([]DueOrder, error) {
	return f.due, nil
}

func (f *fakeSweeperRepository) PaymentOverdue(context.Context, time.Time, int32) ([]DueOrder, error) {
	return f.paymentDue, nil
}

func (f *fakeSweeperRepository) RecordEscalation(ctx context.Context, order DueOrder, _ time.Time) (bool, error) {
	key := httpx.OperationKey(ctx)
	f.escalated = append(f.escalated, order.OrderID)
	f.escalateKeys = append(f.escalateKeys, key)
	if f.escalateSeen == nil {
		f.escalateSeen = map[string]bool{}
	}
	if f.escalateSeen[key] {
		return false, nil // dedup replay, like the real repository
	}
	f.escalateSeen[key] = true
	return true, nil
}

func (f *fakeSweeperRepository) Apply(ctx context.Context, cmd TransitionCommand) error {
	if f.applyErr != nil {
		return f.applyErr
	}
	f.applied = append(f.applied, cmd)
	return nil
}

func newSweeper(t *testing.T, repository sweeperRepository, now time.Time, grace time.Duration) *Sweeper {
	t.Helper()
	return NewSweeper(repository, clock.NewFixed(now),
		slog.New(slog.NewTextHandler(io.Discard, nil)),
		SweeperConfig{Batch: 10, ExpiryGrace: grace})
}

// The sweep is two-stage: an overdue order is escalated so an operator can still
// rescue the sale, and only after the grace period does it expire.
func TestSweepEscalatesBeforeExpiring(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 7, 29, 12, 0, 0, 0, time.UTC)
	repository := &fakeSweeperRepository{due: []DueOrder{
		{OrderID: orderOne, StoreID: storeOne, BuyerID: buyerAlice, DueAt: now.Add(-30 * time.Minute)},
	}}
	sweeper := newSweeper(t, repository, now, 2*time.Hour)

	result, err := sweeper.RunOnce(context.Background())
	if err != nil {
		t.Fatalf("RunOnce error = %v", err)
	}
	if result.Escalated != 1 {
		t.Fatalf("escalated = %d, want 1", result.Escalated)
	}
	if result.Expired != 0 {
		t.Fatalf("expired = %d, want 0 while inside the grace window", result.Expired)
	}
	if len(repository.applied) != 0 {
		t.Fatal("an order was expired before its grace period elapsed")
	}
}

func TestSweepExpiresAfterGracePeriod(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 7, 29, 12, 0, 0, 0, time.UTC)
	repository := &fakeSweeperRepository{due: []DueOrder{
		{OrderID: orderOne, StoreID: storeOne, BuyerID: buyerAlice, DueAt: now.Add(-3 * time.Hour)},
	}}
	sweeper := newSweeper(t, repository, now, 2*time.Hour)

	result, err := sweeper.RunOnce(context.Background())
	if err != nil {
		t.Fatalf("RunOnce error = %v", err)
	}
	if result.Expired != 1 {
		t.Fatalf("expired = %d, want 1", result.Expired)
	}
	if len(repository.applied) != 1 || repository.applied[0].Trigger != TriggerExpire {
		t.Fatalf("applied = %+v, want one expire", repository.applied)
	}
}

// Both stages carry a deterministic operation key derived from the order and its
// deadline.
func TestSweepUsesDeterministicOperationKeys(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 7, 29, 12, 0, 0, 0, time.UTC)
	due := DueOrder{OrderID: orderOne, StoreID: storeOne, BuyerID: buyerAlice, DueAt: now.Add(-3 * time.Hour)}

	first := &fakeSweeperRepository{due: []DueOrder{due}}
	second := &fakeSweeperRepository{due: []DueOrder{due}}
	if _, err := newSweeper(t, first, now, time.Hour).RunOnce(context.Background()); err != nil {
		t.Fatalf("first sweep error = %v", err)
	}
	if _, err := newSweeper(t, second, now.Add(17*time.Minute), time.Hour).RunOnce(context.Background()); err != nil {
		t.Fatalf("second sweep error = %v", err)
	}

	if len(first.escalateKeys) != 1 || len(second.escalateKeys) != 1 {
		t.Fatalf("escalation keys = %v / %v, want one each", first.escalateKeys, second.escalateKeys)
	}
	if first.escalateKeys[0] != second.escalateKeys[0] {
		t.Fatalf("escalation key changed between ticks: %q vs %q",
			first.escalateKeys[0], second.escalateKeys[0])
	}
	if first.escalateKeys[0] == "" {
		t.Fatal("escalation ran with an empty operation key: dedup cannot apply")
	}
}

// An order that moved on between the scan and the write is not a failure: a
// supplier confirmation that landed first is the expected race.
func TestSweepTreatsLostRacesAsNormal(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 7, 29, 12, 0, 0, 0, time.UTC)
	repository := &fakeSweeperRepository{
		due:      []DueOrder{{OrderID: orderOne, StoreID: storeOne, DueAt: now.Add(-3 * time.Hour)}},
		applyErr: ErrConflict,
	}
	sweeper := newSweeper(t, repository, now, time.Hour)

	result, err := sweeper.RunOnce(context.Background())
	if err != nil {
		t.Fatalf("RunOnce error = %v, want nil for a lost race", err)
	}
	if result.Expired != 0 {
		t.Fatalf("expired = %d, want 0", result.Expired)
	}
}

// One failing order must not stop the rest of the batch.
func TestSweepContinuesPastAFailingOrder(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 7, 29, 12, 0, 0, 0, time.UTC)
	repository := &fakeSweeperRepository{
		due: []DueOrder{
			{OrderID: orderOne, StoreID: storeOne, DueAt: now.Add(-3 * time.Hour)},
			{OrderID: "018f0f50-0000-7000-8000-0000000000d2", StoreID: storeOne, DueAt: now.Add(-3 * time.Hour)},
		},
		applyErr: errors.New("database down"),
	}
	sweeper := newSweeper(t, repository, now, time.Hour)

	result, err := sweeper.RunOnce(context.Background())
	if err == nil {
		t.Fatal("RunOnce error = nil, want the aggregated failure")
	}
	if result.Escalated != 2 {
		t.Fatalf("escalated = %d, want both orders attempted", result.Escalated)
	}
}
