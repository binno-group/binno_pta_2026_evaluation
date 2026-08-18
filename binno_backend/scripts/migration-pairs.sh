#!/usr/bin/env bash
set -euo pipefail
[ -d migrations ] || { echo "no migrations/ directory yet, skipping"; exit 0; }
missing=0
while IFS= read -r up; do
  down="${up%.up.sql}.down.sql"
  [ -f "$down" ] || { echo "missing rollback: $down"; missing=1; }
done < <(find migrations -name "*.up.sql")
exit "$missing"
