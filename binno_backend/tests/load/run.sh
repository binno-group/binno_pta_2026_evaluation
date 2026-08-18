#!/usr/bin/env bash
# Runs one capacity profile and then the SQL invariants; the run fails if
# either fails. Never wired into unit CI — capacity runs need a dedicated
# environment.
#
# Usage:
#   BASE_URL=http://host:8080 DB_URL=postgres://... tests/load/run.sh baseline
#
# Environment:
#   BASE_URL      target service (required)
#   DB_URL        PostgreSQL DSN for the invariant checks (required)
#   ENV_JSON      k6 environment file (default tests/load/out/env.json;
#                 produce it with `go run ./tests/load/seed`)
#   METRICS_URL   optional Prometheus endpoint; sampled before/after for the
#                 endurance drift check (goroutines, heap, DB connections)
#   K6_BIN        k6 binary (default: k6)
set -euo pipefail

profile="${1:-}"
case "$profile" in
  baseline|burst|endurance) ;;
  *) echo "usage: $0 {baseline|burst|endurance}" >&2; exit 2 ;;
esac

: "${BASE_URL:?BASE_URL is required}"
: "${DB_URL:?DB_URL is required}"
here="$(cd "$(dirname "$0")" && pwd)"
env_json="${ENV_JSON:-$here/out/env.json}"
k6_bin="${K6_BIN:-k6}"

[ -f "$env_json" ] || { echo "no $env_json; run: go run ./tests/load/seed" >&2; exit 2; }

sample_metric() { # $1 metric prefix -> first sample value, or empty
  [ -n "${METRICS_URL:-}" ] || return 0
  curl -sf --max-time 10 "$METRICS_URL" | awk -v m="$1" '$1 ~ "^"m {print $2; exit}' || true
}

goroutines_before="$(sample_metric go_goroutines)"
heap_before="$(sample_metric go_memstats_heap_alloc_bytes)"

rc=0
"$k6_bin" run -e BASE_URL="$BASE_URL" -e ENV_JSON="$env_json" \
  "$here/k6/$profile.js" || rc=$?

goroutines_after="$(sample_metric go_goroutines)"
heap_after="$(sample_metric go_memstats_heap_alloc_bytes)"

if [ -n "$goroutines_before" ] && [ -n "$goroutines_after" ]; then
  echo "goroutines: $goroutines_before -> $goroutines_after"
  echo "heap bytes: ${heap_before:-?} -> ${heap_after:-?}"
  # Drift gate, meaningful on the endurance profile: a settled service returns
  # near its starting goroutine count once load stops.
  if [ "$profile" = "endurance" ]; then
    drift_limit=$(( ${goroutines_before%.*} * 2 + 100 ))
    if [ "${goroutines_after%.*}" -gt "$drift_limit" ]; then
      echo "FAIL: goroutine count drifted upward past $drift_limit" >&2
      rc=1
    fi
  fi
fi

echo "running post-run invariants..."
if ! psql "$DB_URL" -v ON_ERROR_STOP=1 -q -f "$here/sql/invariants.sql"; then
  echo "FAIL: capacity invariants violated" >&2
  rc=1
fi

exit "$rc"
