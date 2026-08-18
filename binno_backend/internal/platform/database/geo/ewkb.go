// Package geo owns geographic transport types.
package geo

import (
	"database/sql/driver"
	"errors"
	"fmt"
)

// EWKB is PostGIS Extended Well-Known Binary.
type EWKB []byte

// Scan implements database/sql.Scanner, which pgx uses for custom sqlc types.
func (e *EWKB) Scan(src any) error {
	switch value := src.(type) {
	case nil:
		*e = nil
		return nil
	case []byte:
		*e = append((*e)[:0], value...)
		return nil
	case string:
		*e = append((*e)[:0], value...)
		return nil
	default:
		return fmt.Errorf("geo: scan EWKB from %T: %w", src, errors.ErrUnsupported)
	}
}

// Value implements driver.Valuer for inserts and updates through pgx.
func (e EWKB) Value() (driver.Value, error) {
	if e == nil {
		return nil, nil
	}
	return []byte(e), nil
}
