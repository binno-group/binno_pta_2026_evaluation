#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=80

profile=$(mktemp)
policy=$(mktemp)
trap 'rm -f "$profile" "$policy"' EXIT

go test ./internal/... -tags=integration -count=1 \
  -coverpkg=./internal/... \
  -coverprofile="$profile" >/dev/null

awk 'NR==1 ||
     /internal\/modules\/[a-z]+\/(service|status|guard|port)\.go/ ||
     /internal\/platform\/(authz|money)\// { print }' "$profile" >"$policy"

lines=$(grep -c . "$policy")
[ "$lines" -gt 1 ] || {
  echo "coverage-gate matched no policy files, check the filter in this script"
  exit 1
}

total=$(go tool cover -func="$policy" | awk '/^total:/ { gsub("%","",$3); print $3 }')

awk -v t="$total" -v th="$THRESHOLD" 'BEGIN {
  if (t+0 < th) { printf "policy coverage %.1f%% < %d%%\n", t, th; exit 1 }
  printf "policy coverage %.1f%% OK (threshold %d%%)\n", t, th
}'
