#!/usr/bin/env bash
set -euo pipefail
hits=$(rg -n "Text\\(\\s*['\\\"][^'\\\"]*[A-Za-z]{3}" lib/features lib/design_system \
  -g '*.dart' | rg -v "l10n:ignore" || true)
[ -z "$hits" ] || { echo "Hard-coded UI strings:"; echo "$hits"; exit 1; }
