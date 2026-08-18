#!/usr/bin/env bash
set -euo pipefail
hits=$(rg -n "Colors\\.[a-z]|Color\\(0x|TextStyle\\(" lib -g '*.dart' \
  | rg -v "lib/design_system/|\\.g\\.dart|\\.freezed\\.dart" || true)
[ -z "$hits" ] || { echo "Raw colors/styles outside design_system:"; echo "$hits"; exit 1; }
