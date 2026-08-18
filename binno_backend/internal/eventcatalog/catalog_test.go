package eventcatalog_test

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
)

func TestUnregisteredNamesAreRejected(t *testing.T) {
	t.Parallel()
	for _, name := range []string{"", "order.maybe", "Order.Created", "order.created "} {
		if eventcatalog.Valid(name) {
			t.Errorf("Valid(%q) = true, want false", name)
		}
	}
	if !eventcatalog.Valid(string(eventcatalog.OrderCreated)) {
		t.Error("Valid(order.created) = false, want true")
	}
}

// Version support is per event, not a global constant.
func TestVersionSupportIsPerEvent(t *testing.T) {
	t.Parallel()
	for name, definition := range eventcatalog.All() {
		if len(definition.Versions) == 0 {
			t.Errorf("%s: no versions declared", name)
			continue
		}
		current := definition.Current()
		if !eventcatalog.ValidVersion(string(name), current) {
			t.Errorf("%s: current version %d is not accepted", name, current)
		}
		if eventcatalog.ValidVersion(string(name), current+1) {
			t.Errorf("%s: version %d accepted before any consumer declares it", name, current+1)
		}
		if eventcatalog.ValidVersion(string(name), 0) {
			t.Errorf("%s: version 0 accepted", name)
		}
	}
}

// Names in the taxonomy that no code publishes are marked reserved.
func TestReservedEventsHaveNoProducer(t *testing.T) {
	t.Parallel()
	root := filepath.Join("..", "..")
	moduleSources, err := filepath.Glob(filepath.Join(root, "internal", "modules", "*", "*.go"))
	if err != nil {
		t.Fatalf("glob module sources: %v", err)
	}

	var published strings.Builder
	for _, path := range moduleSources {
		if strings.HasSuffix(path, "_test.go") {
			continue
		}
		raw, err := os.ReadFile(path)
		if err != nil {
			t.Fatalf("read %s: %v", path, err)
		}
		published.Write(raw)
	}
	sources := published.String()

	for name, definition := range eventcatalog.All() {
		identifier := goIdentifier(name)
		mentioned := strings.Contains(sources, "eventcatalog."+identifier)

		if definition.Producer == "" && mentioned {
			t.Errorf("%s is marked reserved but %s appears in module code: "+
				"give it a Producer in the registry", name, identifier)
		}
		if definition.Producer != "" && !mentioned {
			t.Errorf("%s claims producer %q but %s appears nowhere in module code: "+
				"either wire the producer or mark the entry reserved",
				name, definition.Producer, identifier)
		}
		if definition.Description == "" {
			t.Errorf("%s has no description", name)
		}
	}
}

// Payload bodies must serialise to JSON objects: the outbox refuses anything
// else, and the analytics sink stores them as jsonb.
func TestPayloadsMarshalToObjects(t *testing.T) {
	t.Parallel()
	payloads := []eventcatalog.Payload{
		eventcatalog.OrderCreatedPayload{},
		eventcatalog.OrderSLAEscalatedPayload{},
		eventcatalog.OrderConfirmationChasePayload{},
		eventcatalog.CatalogRequestedPayload{},
		eventcatalog.CatalogRequestResolvedPayload{},
		eventcatalog.OfferCreatedPayload{},
		eventcatalog.OfferUpdatedPayload{},
		eventcatalog.FeedbackCreatedPayload{},
		eventcatalog.RefundBecameOverduePayload{},
		eventcatalog.NewOrderStatusChanged(eventcatalog.OrderAccepted,
			eventcatalog.OrderStatusChangedPayload{}),
	}
	for _, payload := range payloads {
		body, err := json.Marshal(payload)
		if err != nil {
			t.Errorf("%T: marshal error = %v", payload, err)
			continue
		}
		if len(body) == 0 || body[0] != '{' {
			t.Errorf("%T: payload is not a JSON object: %s", payload, body)
		}
	}
}

// analytics.operator_queue projects payload->>'due_at' for every event that
// opens a queue item, so those payloads must carry the field.
func TestQueueOpeningPayloadsCarryDueAt(t *testing.T) {
	t.Parallel()
	payloads := []eventcatalog.Payload{
		eventcatalog.OrderSLAEscalatedPayload{},
		eventcatalog.OrderConfirmationChasePayload{},
		eventcatalog.CatalogRequestedPayload{},
		eventcatalog.RefundBecameOverduePayload{},
	}
	for _, payload := range payloads {
		body, err := json.Marshal(payload)
		if err != nil {
			t.Fatalf("%T: marshal error = %v", payload, err)
		}
		var fields map[string]any
		if err := json.Unmarshal(body, &fields); err != nil {
			t.Fatalf("%T: unmarshal error = %v", payload, err)
		}
		if _, ok := fields["due_at"]; !ok {
			t.Errorf("%T: missing due_at, which analytics.operator_queue selects", payload)
		}
	}
}

// goIdentifier maps "order.sla_escalated" to the exported constant name used in
// this package, so the producer check can look for it in module sources.
func goIdentifier(name eventcatalog.Name) string {
	known := map[eventcatalog.Name]string{
		eventcatalog.OrderCreated:                    "OrderCreated",
		eventcatalog.OrderAccepted:                   "OrderAccepted",
		eventcatalog.OrderDeclined:                   "OrderDeclined",
		eventcatalog.OrderExpired:                    "OrderExpired",
		eventcatalog.OrderPaid:                       "OrderPaid",
		eventcatalog.OrderPreparing:                  "OrderPreparing",
		eventcatalog.OrderReady:                      "OrderReady",
		eventcatalog.OrderDelivered:                  "OrderDelivered",
		eventcatalog.OrderClosed:                     "OrderClosed",
		eventcatalog.OrderCancelled:                  "OrderCancelled",
		eventcatalog.OrderPickupConfirmed:            "OrderPickupConfirmed",
		eventcatalog.OrderSLAEscalated:               "OrderSLAEscalated",
		eventcatalog.OrderConfirmationChaseRequested: "OrderConfirmationChaseRequested",
		eventcatalog.PaymentReviewStarted:            "PaymentReviewStarted",
		eventcatalog.RefundRequested:                 "RefundRequested",
		eventcatalog.RefundBecameOverdue:             "RefundBecameOverdue",
		eventcatalog.CatalogRequested:                "CatalogRequested",
		eventcatalog.CatalogRequestResolved:          "CatalogRequestResolved",
		eventcatalog.OfferCreated:                    "OfferCreated",
		eventcatalog.OfferUpdated:                    "OfferUpdated",
		eventcatalog.FeedbackCreated:                 "FeedbackCreated",
		eventcatalog.OperatorQueueItemResolved:       "OperatorQueueItemResolved",
	}
	return known[name]
}
