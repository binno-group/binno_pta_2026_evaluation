#!/usr/bin/env bash
set -euo pipefail

SPEC="contracts/binno-openapi-v1.yaml"

python3 -c "import yaml" 2>/dev/null || {
  echo "openapi-drift.sh requires PyYAML (pip install pyyaml)"
  exit 1
}

OPERATIONAL='^(GET /healthz|GET /readyz|GET /metrics|[A-Z]+ /docs/.*)$'

go run -tags=routedump ./scripts/routedump |
  { grep -vE "$OPERATIONAL" || true; } | sort >/tmp/code-routes.txt

python3 - "$SPEC" <<'PY' | sort >/tmp/spec-routes.txt
import sys
from urllib.parse import urlsplit

import yaml

spec = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
servers = spec.get("servers") or [{"url": ""}]
base = urlsplit(servers[0]["url"]).path.rstrip("/")
methods = ("get", "post", "patch", "put", "delete")

for path, ops in spec["paths"].items():
    for method in ops:
        if method in methods:
            print(method.upper(), base + path)
PY

if ! diff -u /tmp/spec-routes.txt /tmp/code-routes.txt; then
  echo "OpenAPI drift: update the contract and routes together"
  exit 1
fi
