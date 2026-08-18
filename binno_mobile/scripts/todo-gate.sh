#!/usr/bin/env bash
set -euo pipefail
hits=$(rg -n "TODO|FIXME" lib test -g '*.dart' \
  -g '!packages/binno_api/**' | rg -v "TODO\\(#[0-9]+\\)" || true)
[ -z "$hits" ] || { echo "Orphan TODOs:"; echo "$hits"; exit 1; }
