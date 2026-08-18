#!/usr/bin/env bash
set -euo pipefail
file="deploy/monitoring/alerts.yml"
if [ ! -s "$file" ]; then
  echo "$file is missing or empty, add alert rules "
  exit 1
fi
