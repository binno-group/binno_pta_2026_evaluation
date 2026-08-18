package operator

import (
	"context"
	"encoding/base64"
	"errors"
	"testing"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// encodeRaw base64url-encodes a raw cursor payload the way encodeCursor would,
// so a test can hand decodeCursor a deliberately malformed shape.
func encodeRaw(payload string) string {
	return base64.RawURLEncoding.EncodeToString([]byte(payload))
}

// encodeNoDelim encodes a payload that lacks the "|" separator entirely.
func encodeNoDelim(payload string) string { return encodeRaw(payload) }

// resolvingRepository is a queueRepository that also satisfies queueResolver,
// recording the resolution it was handed.
type resolvingRepository struct {
	fakeQueueRepository
	got    Resolution
	called bool
	err    error
}

func (r *resolvingRepository) Resolve(_ context.Context, res Resolution) error {
	r.called = true
	r.got = res
	return r.err
}

func validResolution() Resolution {
	return Resolution{
		QueueType:    "payment_review",
		QueueEventID: "018f0f50-0000-7000-8000-000000000001",
		Action:       "approve",
		Note:         "receipt matches the invoice",
		ActorID:      "018f0f50-0000-7000-8000-0000000000aa",
		OperationKey: "op-key-1",
	}
}

func newResolvingService(repo *resolvingRepository) *Service {
	return NewService(repo, clock.NewFixed(time.Date(2026, 8, 2, 12, 0, 0, 0, time.UTC)))
}

func TestResolveStampsTimeAndForwards(t *testing.T) {
	repo := &resolvingRepository{}
	if err := newResolvingService(repo).Resolve(context.Background(), validResolution()); err != nil {
		t.Fatalf("Resolve error = %v", err)
	}
	if !repo.called {
		t.Fatal("repository resolver was never called")
	}
	if repo.got.OccurredAt.IsZero() {
		t.Error("OccurredAt was not stamped from the clock")
	}
	if repo.got.Action != "approve" {
		t.Errorf("Action = %q, want forwarded unchanged", repo.got.Action)
	}
}

func TestResolveRejectsInvalidBeforeIO(t *testing.T) {
	base := validResolution()
	cases := map[string]func(*Resolution){
		"bad queue type": func(r *Resolution) { r.QueueType = "nonsense" },
		"empty event id": func(r *Resolution) { r.QueueEventID = "" },
		"blank action":   func(r *Resolution) { r.Action = "   " },
		"action too long": func(r *Resolution) {
			r.Action = string(make([]byte, 101))
		},
		"empty actor":         func(r *Resolution) { r.ActorID = "" },
		"empty operation key": func(r *Resolution) { r.OperationKey = "" },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			repo := &resolvingRepository{}
			res := base
			mutate(&res)
			if err := newResolvingService(repo).Resolve(context.Background(), res); !errors.Is(err, ErrInvalidResolution) {
				t.Fatalf("error = %v, want ErrInvalidResolution", err)
			}
			if repo.called {
				t.Error("an invalid resolution still reached the repository")
			}
		})
	}
}

func TestResolveNeedsAResolvingRepository(t *testing.T) {
	// A plain queueRepository that cannot resolve must produce a clear error, not a panic.
	svc := NewService(&fakeQueueRepository{}, clock.NewFixed(time.Now()))
	if err := svc.Resolve(context.Background(), validResolution()); err == nil {
		t.Fatal("Resolve returned nil against a repository that cannot resolve")
	}
}

func TestResolvePropagatesRepositoryError(t *testing.T) {
	repo := &resolvingRepository{err: errors.New("write failed")}
	if err := newResolvingService(repo).Resolve(context.Background(), validResolution()); err == nil {
		t.Fatal("Resolve swallowed a repository error")
	}
}

func TestCursorRoundTripsThroughDecode(t *testing.T) {
	at := time.Date(2026, 8, 2, 12, 30, 0, 0, time.UTC)
	id := "018f0f50-0000-7000-8000-000000000abc"
	gotAt, gotID, err := decodeCursor(encodeCursor(at, id))
	if err != nil {
		t.Fatalf("decodeCursor error = %v", err)
	}
	if gotAt == nil || !gotAt.Equal(at) {
		t.Errorf("time = %v, want %v", gotAt, at)
	}
	if gotID != id {
		t.Errorf("id = %q, want %q", gotID, id)
	}
}

func TestDecodeCursorEmptyIsNilNotError(t *testing.T) {
	at, id, err := decodeCursor("")
	if err != nil || at != nil || id != "" {
		t.Fatalf("empty cursor = (%v, %q, %v), want (nil, \"\", nil)", at, id, err)
	}
}

func TestDecodeCursorRejectsMalformed(t *testing.T) {
	cases := map[string]string{
		"not base64": "!!!not-base64!!!",
		"no delim":   encodeNoDelim("only-one-part"),
		"empty id":   encodeRaw("2026-08-02T12:00:00Z|"),
		"bad uuid":   encodeRaw("2026-08-02T12:00:00Z|not-a-uuid"),
		"bad time":   encodeRaw("not-a-time|018f0f50-0000-7000-8000-000000000abc"),
	}
	for name, cursor := range cases {
		t.Run(name, func(t *testing.T) {
			if _, _, err := decodeCursor(cursor); err == nil {
				t.Fatalf("decodeCursor(%q) accepted a malformed cursor", cursor)
			}
		})
	}
}
