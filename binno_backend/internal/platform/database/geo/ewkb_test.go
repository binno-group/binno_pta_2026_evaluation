package geo_test

import (
	"bytes"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
)

func TestEWKBScanCopiesDriverBuffer(t *testing.T) {
	source := []byte{1, 2, 3}
	var value geo.EWKB

	if err := value.Scan(source); err != nil {
		t.Fatalf("Scan error = %v", err)
	}
	source[0] = 9

	if !bytes.Equal(value, []byte{1, 2, 3}) {
		t.Fatalf("EWKB = %v, want defensive copy", value)
	}
}

func TestEWKBValuePreservesBytes(t *testing.T) {
	value := geo.EWKB{1, 2, 3}

	got, err := value.Value()
	if err != nil {
		t.Fatalf("Value error = %v", err)
	}
	if !bytes.Equal(got.([]byte), value) {
		t.Fatalf("Value = %v, want %v", got, value)
	}
}
