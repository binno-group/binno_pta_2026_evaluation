package search

import (
	"testing"

	"github.com/google/uuid"
)

// The pagination cursor is the second of the two parsers in this service that
// read attacker-controlled bytes (geo.ParsePoint is the other).
func FuzzDecodeCursor(f *testing.F) {
	f.Add("")
	f.Add(encodeCursor(1000, 250, "0197a1f1-0000-7000-8000-000000000001"))
	f.Add(encodeCursor(0, 0, uuid.Nil.String()))
	f.Add(encodeCursor(-1, -1, "0197a1f1-0000-7000-8000-000000000001"))
	f.Add("bm90LWpzb24")                      // "not-json"
	f.Add("e30")                              // {}
	f.Add("eyJwcmljZSI6MX0")                  // {"price":1}
	f.Add("eyJpZCI6ImFiYyJ9")                 // {"id":"abc"}
	f.Add("eyJwcmljZSI6MSwiZGlzdGFuY2UiOjJ9") // no id
	f.Add("!!!not base64!!!")
	f.Add("eyJwcmljZSI6OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OTk5OX0") // integer overflow

	f.Fuzz(func(t *testing.T, encoded string) {
		decoded, err := decodeCursor(encoded)
		if err != nil {
			if decoded != (cursor{}) {
				t.Fatalf("decodeCursor(%q) failed but returned %+v", encoded, decoded)
			}
			return
		}

		if encoded == "" {
			if decoded != (cursor{}) {
				t.Fatalf("the empty cursor decoded to %+v, want the zero value", decoded)
			}
			return
		}

		if decoded.Price == nil || decoded.Distance == nil {
			t.Fatalf("decodeCursor(%q) accepted a cursor missing a bound: %+v", encoded, decoded)
		}
		if err := uuid.Validate(decoded.ID); err != nil {
			t.Fatalf("decodeCursor(%q) accepted id %q, which is not a UUID: %v", encoded, decoded.ID, err)
		}

		again, err := decodeCursor(encodeCursor(*decoded.Price, *decoded.Distance, decoded.ID))
		if err != nil {
			t.Fatalf("re-encoding an accepted cursor %+v produced one that will not decode: %v", decoded, err)
		}
		if *again.Price != *decoded.Price || *again.Distance != *decoded.Distance || again.ID != decoded.ID {
			t.Fatalf("cursor round-trip changed the bounds: %+v -> %+v", decoded, again)
		}
	})
}
