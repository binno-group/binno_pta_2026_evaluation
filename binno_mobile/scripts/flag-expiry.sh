#!/usr/bin/env bash
set -euo pipefail
registry="lib/core/flags/registry.yml"
[ -f "$registry" ] || { echo "Missing feature flag registry"; exit 1; }
python3 - "$registry" <<'PY'
import datetime, re, sys
text = open(sys.argv[1]).read()
today = datetime.date.today()
for value in re.findall(r"remove_by:\s*['\"]?(\d{4}-\d{2}-\d{2})", text):
    if datetime.date.fromisoformat(value) < today:
        raise SystemExit(f"expired feature flag: {value}")
print("flag expiry: OK")
PY
