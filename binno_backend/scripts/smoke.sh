#!/usr/bin/env bash
set -euo pipefail
ADDR="${BINNO_ADDR:-http://localhost:8080}"

echo "GET /healthz"
curl -fsS "$ADDR/healthz"
echo
echo "GET /readyz"
curl -fsS "$ADDR/readyz"
echo
echo "smoke OK"
