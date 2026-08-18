#!/usr/bin/env bash
set -euo pipefail
hits=$(grep -rnE "TODO|FIXME" --include="*.go" --include="*.sql" \
    --exclude="*.sql.go" --exclude="*_gen.go" \
    --exclude-dir=vendor --exclude-dir=.git \
    internal/ cmd/ tests/ migrations/ scripts/ 2>/dev/null \
  | grep -vE "TODO\(#[0-9]+\)" || true)
[ -z "$hits" ] || { echo "Orphan TODOs (add issue ref or delete):"; echo "$hits"; exit 1; }
