#!/usr/bin/env bash
set -euo pipefail
hits=$(grep -rn "image:.*:latest" deploy/ docker-compose*.yml 2>/dev/null || true)
[ -z "$hits" ] || { echo "Floating :latest image tags:"; echo "$hits"; exit 1; }
