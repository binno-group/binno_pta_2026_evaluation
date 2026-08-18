#!/usr/bin/env bash
set -euo pipefail
flutter analyze > /dev/null
assets=$(rg -o "assets/[^[:space:]]+" pubspec.yaml || true)
for asset in $assets; do
  rg -q "$asset" lib test || { echo "unused asset: $asset"; exit 1; }
done
python3 - <<'PY'
import json, pathlib, re
arb = json.loads(pathlib.Path('lib/l10n/app_uz.arb').read_text())
source = '\n'.join(p.read_text() for p in pathlib.Path('lib').rglob('*.dart') if not p.name.startswith('app_localizations'))
for key in arb:
    if key.startswith('@'): continue
    if not re.search(rf'\b{re.escape(key)}\b', source):
        raise SystemExit(f"unused l10n key: {key}")
print("unused code/assets/l10n: OK")
PY
