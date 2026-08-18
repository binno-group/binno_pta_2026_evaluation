package geo_test

import (
	"math"
	"testing"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
)

// ParsePoint is one of only two parsers in this service that read untrusted
// input directly off the wire (the other is the search cursor).
func FuzzParsePoint(f *testing.F) {
	seeds := [][2]string{
		{"41.311081", "69.240562"}, // Tashkent, the ordinary case
		{"0", "0"},
		{"-90", "-180"}, // the corners of EPSG:4326
		{"90", "180"},
		{"", ""},
		{"abc", "69.2"},
		{"41.3", ""},
		{"90.0000001", "0"}, // just outside
		{"1e309", "0"},      // overflows float64 to +Inf
		{"-1e309", "0"},     // overflows to -Inf
		{"NaN", "0"},        // ParseFloat accepts this spelling
		{"nan", "nan"},      //
		{"Inf", "Inf"},      //
		{"+41.3", "+69.2"},  // signs ParseFloat allows
		{"0x1p4", "0"},      // hexadecimal float literal
		{"41.3\n", "69.2"},  // trailing whitespace
		{"41,3", "69,2"},    // comma decimal separator
		{"41.311081000000000", "69.240562000000000"},
	}
	for _, s := range seeds {
		f.Add(s[0], s[1])
	}

	f.Fuzz(func(t *testing.T, lat, lng string) {
		point, err := geo.ParsePoint(lat, lng)
		if err != nil {
			if point != (geo.Point{}) {
				t.Fatalf("ParsePoint(%q, %q) rejected the input but returned %+v", lat, lng, point)
			}
			return
		}

		if !point.Valid() {
			t.Fatalf("ParsePoint(%q, %q) accepted an invalid point %+v", lat, lng, point)
		}
		if math.IsNaN(point.Lat) || math.IsNaN(point.Lng) {
			t.Fatalf("ParsePoint(%q, %q) accepted NaN: %+v", lat, lng, point)
		}
		if math.IsInf(point.Lat, 0) || math.IsInf(point.Lng, 0) {
			t.Fatalf("ParsePoint(%q, %q) accepted an infinity: %+v", lat, lng, point)
		}
		if point.Lat < -90 || point.Lat > 90 || point.Lng < -180 || point.Lng > 180 {
			t.Fatalf("ParsePoint(%q, %q) accepted out-of-range %+v", lat, lng, point)
		}

		snapped := point.SnapToGrid()
		if snapped.Lat < -90 || snapped.Lat > 90 || snapped.Lng < -180 || snapped.Lng > 180 {
			t.Fatalf("SnapToGrid() of %+v left EPSG:4326 bounds: %+v", point, snapped)
		}
		if math.IsNaN(snapped.Lat) || math.IsNaN(snapped.Lng) {
			t.Fatalf("SnapToGrid() of %+v produced NaN: %+v", point, snapped)
		}
	})
}
