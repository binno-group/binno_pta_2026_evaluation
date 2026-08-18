package geo

import (
	"fmt"
	"math"
	"strconv"
)

// Point is an EPSG:4326 latitude/longitude pair.
type Point struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

func ParsePoint(lat, lng string) (Point, error) {
	latitude, err := strconv.ParseFloat(lat, 64)
	if err != nil {
		return Point{}, fmt.Errorf("geo: parse latitude: %w", err)
	}
	longitude, err := strconv.ParseFloat(lng, 64)
	if err != nil {
		return Point{}, fmt.Errorf("geo: parse longitude: %w", err)
	}
	point := Point{Lat: latitude, Lng: longitude}
	if !point.Valid() {
		return Point{}, fmt.Errorf("geo: coordinates outside EPSG:4326 bounds")
	}
	return point, nil
}

func (p Point) Valid() bool {
	return p.Lat >= -90 && p.Lat <= 90 && p.Lng >= -180 && p.Lng <= 180
}

// NullableCoordinates returns SQL-ready coordinate pointers.
func NullableCoordinates(point *Point) (lat, lng *float64) {
	if point == nil {
		return nil, nil
	}
	return &point.Lat, &point.Lng
}

// GridDegrees is the cell size a Point is snapped to for cache keys.
const GridDegrees = 0.005

// SnapToGrid rounds a Point to the nearest GridDegrees cell centre.
func (p Point) SnapToGrid() Point {
	snap := func(v float64) float64 {
		return math.Round(v/GridDegrees) * GridDegrees
	}
	return Point{Lat: snap(p.Lat), Lng: snap(p.Lng)}
}

// GridKey renders the snapped point as a stable string for use in a cache key.
func (p Point) GridKey() string {
	s := p.SnapToGrid()
	return fmt.Sprintf("%.4f:%.4f", s.Lat, s.Lng)
}
