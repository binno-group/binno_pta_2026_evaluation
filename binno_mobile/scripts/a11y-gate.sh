#!/usr/bin/env bash
set -euo pipefail
fail=0
while IFS= read -r screen; do
  name=$(basename "$screen" .dart)
  tf=$(rg -l "$name" test -g '*_test.dart' | head -1 || true)
  if [ -z "$tf" ] || ! rg -q "expectBinnoA11y" "$tf"; then
    echo "no a11y contract test for $screen"
    fail=1
  fi
done < <(find lib/features -path '*/presentation/screens/*_screen.dart')
exit "$fail"
