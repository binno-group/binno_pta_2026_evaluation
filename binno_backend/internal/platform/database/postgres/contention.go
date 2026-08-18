package postgres

import (
	"errors"

	"github.com/jackc/pgx/v5/pgconn"
)

// PostgreSQL SQLSTATEs that mean "another transaction was in the way", not "this
// request was wrong".
const (
	sqlstateSerializationFailure = "40001"
	sqlstateDeadlockDetected     = "40P01"
	sqlstateLockNotAvailable     = "55P03"
	sqlstateQueryCanceled        = "57014"
)

// IsRetryableConflict reports a transaction that lost a race and rolled back
// cleanly.
func IsRetryableConflict(err error) bool {
	return hasSQLState(err, sqlstateSerializationFailure, sqlstateDeadlockDetected)
}

// IsContentionTimeout reports a statement that ran out of time waiting, almost
// always on a row lock held by another writer.
func IsContentionTimeout(err error) bool {
	return hasSQLState(err, sqlstateLockNotAvailable, sqlstateQueryCanceled)
}

func hasSQLState(err error, states ...string) bool {
	var pgErr *pgconn.PgError
	if !errors.As(err, &pgErr) {
		return false
	}
	for _, state := range states {
		if pgErr.Code == state {
			return true
		}
	}
	return false
}
