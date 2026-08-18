package search_test

import (
	"encoding/json"
	"slices"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/modules/search"
)

// The wire shape of Offer is the contract's Offer schema.
func TestOfferMatchesContractFieldNames(t *testing.T) {
	want := []string{
		"id", "store_id", "product_id", "price", "declared_qty", "freshness_at",
		"freshness_label", "distance_meters", "other_owner_store_count",
	}

	encoded, err := json.Marshal(search.Offer{})
	if err != nil {
		t.Fatalf("marshal Offer: %v", err)
	}
	var decoded map[string]any
	if err := json.Unmarshal(encoded, &decoded); err != nil {
		t.Fatalf("unmarshal Offer: %v", err)
	}

	got := make([]string, 0, len(decoded))
	for name := range decoded {
		got = append(got, name)
	}
	slices.Sort(got)
	sortedWant := slices.Clone(want)
	slices.Sort(sortedWant)

	if !slices.Equal(got, sortedWant) {
		t.Errorf("Offer JSON fields = %v, contract requires %v", got, sortedWant)
	}
}

// OfferPage wraps Offer, and ComplexAggregate wraps OfferPage, so the same
// mismatch would surface on GET /complexes/{id}/aggregate too.
func TestOfferPageMatchesContractFieldNames(t *testing.T) {
	encoded, err := json.Marshal(search.OfferPage{Items: []search.Offer{}})
	if err != nil {
		t.Fatalf("marshal OfferPage: %v", err)
	}
	var decoded map[string]any
	if err := json.Unmarshal(encoded, &decoded); err != nil {
		t.Fatalf("unmarshal OfferPage: %v", err)
	}
	for _, name := range []string{"items", "next_cursor"} {
		if _, ok := decoded[name]; !ok {
			t.Errorf("OfferPage is missing contract field %q, got %v", name, decoded)
		}
	}
}
