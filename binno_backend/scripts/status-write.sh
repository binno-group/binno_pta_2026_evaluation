#!/usr/bin/env bash
set -euo pipefail

ALLOWED="internal/modules/orders/store/statemachine.sql"

[ -f "$ALLOWED" ] || {
  echo "state machine query file is missing: $ALLOWED"
  exit 1
}

python3 - "$ALLOWED" <<'PY'
import glob
import re
import sys

allowed = sys.argv[1]

COMMENT = re.compile(r"--[^\n]*")
PATTERN = re.compile(
    r"\bUPDATE\s+(?:[a-z_][a-z0-9_]*\.)?orders\b[^;]*?\bSET\b[^;]*?\bstatus\b",
    re.IGNORECASE | re.DOTALL,
)

paths = sorted(
    glob.glob("internal/**/*.sql", recursive=True)
    + glob.glob("migrations/**/*.sql", recursive=True)
)

violations = []
for path in paths:
    if path == allowed:
        continue
    with open(path, encoding="utf-8") as handle:
        sql = COMMENT.sub("", handle.read())
    for match in PATTERN.finditer(sql):
        line = sql[: match.start()].count("\n") + 1
        violations.append(f"{path}:{line}: {match.group(0).splitlines()[0].strip()}")

if violations:
    print(f"Direct orders.status write outside {allowed}:")
    for violation in violations:
        print(f"  {violation}")
    sys.exit(1)

print(f"status-write: orders.status is written only by {allowed}")
PY
