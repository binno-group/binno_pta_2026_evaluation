#!/usr/bin/env bash
set -euo pipefail
file="build/perf/scroll_timeline.timeline_summary.json"
if [[ ! -f "$file" ]]; then
  if [[ "${CI:-}" == "true" ]]; then
    echo "performance report missing: $file"
    exit 1
  fi
  echo "performance report unavailable, skipped locally"
  exit 0
fi
python3 - "$file" <<'PY'
import json, sys
s = json.load(open(sys.argv[1]))
frames = s["frame_count"] or 1
checks = [
    ("avg build ms", s["average_frame_build_time_millis"], 8.0),
    ("p90 build ms", s["90th_percentile_frame_build_time_millis"], 12.0),
    ("p90 raster ms", s["90th_percentile_frame_rasterizer_time_millis"], 12.0),
    ("jank %", 100*s["missed_frame_build_budget_count"]/frames, 5.0),
]
failed = False
for name, value, budget in checks:
    ok = value <= budget
    print(f"{name}: {value:.2f} (budget {budget}) {'OK' if ok else 'FAIL'}")
    failed |= not ok
raise SystemExit(1 if failed else 0)
PY
