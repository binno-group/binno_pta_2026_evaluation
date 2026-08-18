#!/usr/bin/env bash
set -euo pipefail
[ -d internal/modules ] || { echo "no modules yet, mutating-routes has nothing to check"; exit 0; }
EXEMPT='"/auth/(otp/request|otp/verify|refresh|logout)"'

hits=$(grep -rnE '\.(Post|Put|Patch|Delete)\("' --include="*.go" \
    --exclude="*_test.go" internal/modules/ 2>/dev/null \
  | grep -v 'httpx\.Mutating(' \
  | { grep -vE "$EXEMPT" || true; })
[ -z "$hits" ] || {
  echo "Mutating routes not wrapped in httpx.Mutating:"
  echo "$hits"; exit 1; }

computed=$(grep -rnE '\.(Post|Put|Patch|Delete)\(' --include="*.go" \
    --exclude="*_test.go" internal/modules/ 2>/dev/null \
  | grep -vE '\.(Post|Put|Patch|Delete)\("' \
  | grep -vE '\.(Post|Put|Patch|Delete)\((ctx|context\.|_ context)' || true)
[ -z "$computed" ] || {
  echo "Route registered with a non-literal path, mutating-routes cannot verify it:"
  echo "$computed"; exit 1; }
