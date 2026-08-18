#!/usr/bin/env bash
set -euo pipefail
base="${GITHUB_BASE_REF:+origin/$GITHUB_BASE_REF}"
base="${base:-origin/main}"
git rev-parse "$base" >/dev/null 2>&1 || { echo "golden budget: base unavailable, skipped locally"; exit 0; }
changed=$(git diff --name-only "$base"...HEAD -- '**/goldens/**' | wc -l | tr -d ' ')
[ "$changed" -eq 0 ] && { echo "golden budget: no golden changes"; exit 0; }
messages=$(git log "$base"..HEAD --format=%B)
echo "$messages" | rg -q "^Golden-Change:" || { echo "Golden-Change trailer required"; exit 1; }
[ "$changed" -le 15 ] || echo "$messages" | rg -q "^Golden-Change-Approved:"
