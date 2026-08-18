package search

import "testing"

func TestCursorRoundTrip(t *testing.T) {
	t.Parallel()
	encoded := encodeCursor(12500, 730, "018f47f0-7b5b-7cc3-98d7-3ef2863aa742")
	decoded, err := decodeCursor(encoded)
	if err != nil {
		t.Fatalf("decodeCursor() error = %v", err)
	}
	if decoded.Price == nil || *decoded.Price != 12500 {
		t.Fatalf("price = %v, want 12500", decoded.Price)
	}
	if decoded.Distance == nil || *decoded.Distance != 730 {
		t.Fatalf("distance = %v, want 730", decoded.Distance)
	}
	if decoded.ID != "018f47f0-7b5b-7cc3-98d7-3ef2863aa742" {
		t.Fatalf("id = %q", decoded.ID)
	}
}

func TestCursorRejectsIncompleteSortKey(t *testing.T) {
	t.Parallel()
	if _, err := decodeCursor("eyJpZCI6IjAxOGY0N2YwLTdiNWItN2NjMy05OGQ3LTNlZjI4NjNhYTc0MiJ9"); err == nil {
		t.Fatal("decodeCursor() accepted cursor without price and distance")
	}
}
