#!/usr/bin/env bash
set -euo pipefail
flutter test --coverage > /dev/null
pct=$(python3 - <<'PY'
hit = tot = 0
take = False
for line in open('coverage/lcov.info'):
    if line.startswith('SF:'):
        take = '/presentation/controllers/' in line or '/domain/' in line
    elif take and line.startswith('LF:'):
        tot += int(line[3:])
    elif take and line.startswith('LH:'):
        hit += int(line[3:])
print(round(100 * hit / max(tot, 1), 1))
PY
)
awk -v p="$pct" 'BEGIN { if (p+0 < 80) { printf "coverage %.1f%% < 80%%\n", p; exit 1 } else printf "coverage %.1f%% OK\n", p }'
