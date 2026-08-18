#!/usr/bin/env bash
set -euo pipefail
hits=$(rg -ni "escrow|kafolatga olindi|daqiqada yetib|yetib boradi: [0-9]|trust score|ishonch bali|hisob-faktura|pul kafolati|pul himoyada" \
  lib/l10n -g '*.arb' || true)
[ -z "$hits" ] || { echo "Banned product copy:"; echo "$hits"; exit 1; }
