package orders_test

import (
	"encoding/json"
	"slices"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders"
)

// GET /orders/{id}/alternatives declares OfferPage, the same schema /search
// returns, so an item has to carry every field that schema marks required.
func TestAlternativeMatchesOfferPageItemSchema(t *testing.T) {
	required := []string{"id", "store_id", "product_id", "price", "declared_qty", "freshness_at"}

	encoded, err := json.Marshal(orders.Alternative{})
	if err != nil {
		t.Fatalf("marshal Alternative: %v", err)
	}
	var decoded map[string]any
	if err := json.Unmarshal(encoded, &decoded); err != nil {
		t.Fatalf("unmarshal Alternative: %v", err)
	}

	for _, name := range required {
		if _, ok := decoded[name]; !ok {
			present := make([]string, 0, len(decoded))
			for k := range decoded {
				present = append(present, k)
			}
			slices.Sort(present)
			t.Errorf("Alternative is missing required Offer field %q; it serialises as %v",
				name, present)
		}
	}
}

// AlternativePage is the OfferPage wrapper, and its own field names are equally
// part of the contract.
func TestAlternativePageMatchesOfferPageSchema(t *testing.T) {
	encoded, err := json.Marshal(orders.AlternativePage{Items: []orders.Alternative{}})
	if err != nil {
		t.Fatalf("marshal AlternativePage: %v", err)
	}
	var decoded map[string]any
	if err := json.Unmarshal(encoded, &decoded); err != nil {
		t.Fatalf("unmarshal AlternativePage: %v", err)
	}
	for _, name := range []string{"items", "next_cursor"} {
		if _, ok := decoded[name]; !ok {
			t.Errorf("AlternativePage is missing contract field %q, got %v", name, decoded)
		}
	}
}
