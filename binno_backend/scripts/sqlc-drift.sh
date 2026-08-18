#!/usr/bin/env bash
set -euo pipefail

command -v sqlc >/dev/null 2>&1 || {
  echo "sqlc is required (expected v1.31.1)"
  exit 1
}

version=$(sqlc version)
[ "$version" = "v1.31.1" ] || {
  echo "sqlc v1.31.1 required, found $version"
  exit 1
}

before=$(mktemp)
after=$(mktemp)
trap 'rm -f "$before" "$after"' EXIT

snapshot() {
  find internal/modules -path '*/store/*.go' -type f -print |
    LC_ALL=C sort |
    while IFS= read -r file; do
      shasum -a 256 "$file"
    done
}

snapshot >"$before"
[ -s "$before" ] || {
  echo "no generated sqlc output found under internal/modules/*/store"
  exit 1
}

sqlc generate
snapshot >"$after"

if ! diff -u "$before" "$after"; then
  echo "sqlc drift: run 'make sqlc' and commit generated files"
  exit 1
fi
