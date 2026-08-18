package orders

import (
	"os"
	"regexp"
	"slices"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
)

const statusMigration = "../../../migrations/orders/000001_create_orders.up.sql"

// The lifecycle exists in two places by design: Go decides transitions, SQL
// keeps a CHECK constraint as a last-resort guard.
func TestStatusCheckMatchesStateMachine(t *testing.T) {
	t.Parallel()
	raw, err := os.ReadFile(statusMigration)
	if err != nil {
		t.Fatalf("read migration: %v", err)
	}
	constraint := regexp.MustCompile(`(?s)CONSTRAINT chk_orders_status CHECK \(status IN \((.*?)\)\)`)
	match := constraint.FindSubmatch(raw)
	if match == nil {
		t.Fatalf("chk_orders_status not found in %s", statusMigration)
	}

	var sqlStatuses []Status
	for _, literal := range regexp.MustCompile(`'([a-z_]+)'`).FindAllStringSubmatch(string(match[1]), -1) {
		sqlStatuses = append(sqlStatuses, Status(literal[1]))
	}

	goStatuses := AllStatuses()
	if !slices.Equal(sqlStatuses, goStatuses) {
		t.Errorf("order status lists diverged.\n  SQL: %v\n   Go: %v\n"+
			"Update internal/modules/orders/status.go and the CHECK together.",
			sqlStatuses, goStatuses)
	}
}

// Every status must be spelled exactly once.
func TestAllStatusesAreUnique(t *testing.T) {
	t.Parallel()
	seen := make(map[Status]bool)
	for _, status := range AllStatuses() {
		if seen[status] {
			t.Errorf("status %q declared twice", status)
		}
		seen[status] = true
		if strings.TrimSpace(string(status)) == "" {
			t.Error("empty status constant")
		}
	}
}

// Every transition must be internally consistent: known source and target
// states, a registered event, and an actor/source pair the order_events CHECK
// accepts.
func TestTransitionsAreWellFormed(t *testing.T) {
	t.Parallel()
	known := make(map[Status]bool)
	for _, status := range AllStatuses() {
		known[status] = true
	}
	actors := map[Actor]bool{ActorBuyer: true, ActorSeller: true, ActorOperator: true, ActorSystem: true}
	sources := map[Source]bool{
		SourceApp: true, SourceSMSToken: true, SourcePhoneCall: true,
		SourceWebhook: true, SourceCron: true,
	}

	for _, trigger := range Triggers() {
		transition, ok := TransitionFor(trigger)
		if !ok {
			t.Fatalf("trigger %q disappeared between listing and lookup", trigger)
		}
		if len(transition.From) == 0 {
			t.Errorf("%s: no source states", trigger)
		}
		for _, from := range transition.From {
			if !known[from] {
				t.Errorf("%s: unknown source status %q", trigger, from)
			}
			if from == transition.To {
				t.Errorf("%s: self-transition on %q", trigger, from)
			}
		}
		if !known[transition.To] {
			t.Errorf("%s: unknown target status %q", trigger, transition.To)
		}
		if !actors[transition.Actor] {
			t.Errorf("%s: actor %q is not in the order_events CHECK", trigger, transition.Actor)
		}
		if !sources[transition.Source] {
			t.Errorf("%s: source %q is not in the order_events CHECK", trigger, transition.Source)
		}
		if transition.Event != "" && !eventcatalog.Valid(string(transition.Event)) {
			t.Errorf("%s: event %q is not registered", trigger, transition.Event)
		}
	}
}

// Reaching a cancelled, declined or expired state must release the order's
// reserved stock.
func TestTerminalNonSaleTransitionsReleaseStock(t *testing.T) {
	t.Parallel()
	mustRelease := map[Trigger]bool{
		TriggerSupplierDecline: true,
		TriggerBuyerCancel:     true,
		TriggerOperatorCancel:  true,
		TriggerExpire:          true,
	}
	for trigger, want := range mustRelease {
		transition, ok := TransitionFor(trigger)
		if !ok {
			t.Fatalf("trigger %q is not registered", trigger)
		}
		if transition.ReleasesStock != want {
			t.Errorf("%s: ReleasesStock = %v, want %v; the order stops progressing, "+
				"so its reservation must go back to the catalogue",
				trigger, transition.ReleasesStock, want)
		}
	}
	accept, _ := TransitionFor(TriggerSupplierConfirm)
	if accept.ReleasesStock {
		t.Error("supplier_confirm must not release stock: the sale is proceeding")
	}
}

func TestPermitsOnlyDeclaredSourceStates(t *testing.T) {
	t.Parallel()
	confirm, _ := TransitionFor(TriggerSupplierConfirm)

	if !confirm.Permits(StatusCreated) {
		t.Error("supplier_confirm must be permitted from created")
	}
	if confirm.Permits(StatusClosed) {
		t.Error("supplier_confirm must not be permitted from closed")
	}
	if confirm.Permits(StatusCancelledByBuyerSLA) {
		t.Error("supplier_confirm must not be permitted from a cancelled order")
	}
}

// A follow-on may not declare its own.
func TestFollowOnTransitionsDoNotChain(t *testing.T) {
	t.Parallel()
	for _, trigger := range Triggers() {
		transition, _ := TransitionFor(trigger)
		if transition.Then == "" {
			continue
		}
		follow, ok := TransitionFor(transition.Then)
		if !ok {
			t.Errorf("%s: declares unknown follow-on %q", trigger, transition.Then)
			continue
		}
		if follow.Then != "" {
			t.Errorf("%s -> %s -> %s: follow-on chains are not applied",
				trigger, transition.Then, follow.Then)
		}
		if !follow.Permits(transition.To) {
			t.Errorf("%s lands on %q but its follow-on %s does not accept that state",
				trigger, transition.To, transition.Then)
		}
	}
}

// The settled state must be reachable from a created order.
func TestClosedIsReachableFromCreated(t *testing.T) {
	t.Parallel()
	reachable := map[Status]bool{StatusCreated: true}
	for changed := true; changed; {
		changed = false
		for _, trigger := range Triggers() {
			transition, _ := TransitionFor(trigger)
			if reachable[transition.To] {
				continue
			}
			for _, from := range transition.From {
				if reachable[from] {
					reachable[transition.To] = true
					changed = true
					break
				}
			}
		}
	}

	for _, want := range []Status{
		StatusAccepted, StatusAwaitingPayment, StatusPaymentReview, StatusPaid,
		StatusPreparing, StatusReady, StatusPickedUpByBuyer, StatusDelivered, StatusClosed,
	} {
		if !reachable[want] {
			t.Errorf("%q is unreachable from a created order: the lifecycle is declared but not connected", want)
		}
	}
}

// Every externally-triggered edge must depart from a state an order can
// actually rest in: the initial state, or the To of some transition that
// commits without a follow-on. A From entry on a pass-through state is dead
// code masquerading as a capability. Follow-on triggers are exempt — they run
// inside the transaction that created the transient state.
func TestTriggersDepartFromRestingStates(t *testing.T) {
	t.Parallel()
	resting := map[Status]bool{StatusCreated: true}
	followOns := map[Trigger]bool{}
	for _, trigger := range Triggers() {
		transition, _ := TransitionFor(trigger)
		if transition.Then == "" {
			resting[transition.To] = true
		} else {
			followOns[transition.Then] = true
		}
	}
	for _, trigger := range Triggers() {
		if followOns[trigger] {
			continue
		}
		transition, _ := TransitionFor(trigger)
		for _, from := range transition.From {
			if !resting[from] {
				t.Errorf("%s departs from %q, which no committed order can rest in", trigger, from)
			}
		}
	}
}

// Settlement must not give stock back.
func TestSettlementTransitionsKeepStockReserved(t *testing.T) {
	t.Parallel()
	for _, trigger := range []Trigger{
		TriggerIssueInvoice, TriggerSubmitReceipt, TriggerConfirmPayment, TriggerRejectPayment,
		TriggerStartPreparing, TriggerMarkReady, TriggerConfirmPickup, TriggerConfirmDelivery,
		TriggerCloseOrder,
	} {
		transition, ok := TransitionFor(trigger)
		if !ok {
			t.Fatalf("trigger %q is not registered", trigger)
		}
		if transition.ReleasesStock {
			t.Errorf("%s: must not release stock; the sale is proceeding or complete", trigger)
		}
	}
}
