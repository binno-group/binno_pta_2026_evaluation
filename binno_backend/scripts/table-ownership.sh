#!/usr/bin/env bash
set -euo pipefail

command -v python3 >/dev/null 2>&1 || {
  echo "python3 with PyYAML is required"
  exit 1
}

python3 - "$@" <<'PY'
import glob
import os
import re
import sys

try:
    import yaml
except ImportError:
    sys.exit("PyYAML is required: pip install pyyaml")

MANIFEST = "table-ownership.yml"
if not os.path.exists(MANIFEST):
    sys.exit(f"{MANIFEST} is missing: schema ownership must be declared")

with open(MANIFEST, encoding="utf-8") as handle:
    manifest = yaml.safe_load(handle)

schemas = manifest.get("schemas") or {}
owner_of = {name: entry.get("owner") for name, entry in schemas.items()}
readers_of = {name: set(entry.get("readers") or []) for name, entry in schemas.items()}

COMMENT = re.compile(r"--[^\n]*")
STRING = re.compile(r"'(?:[^']|'')*'")

QUALIFIED = re.compile(r"(?<![\w.])([a-z_][a-z0-9_]*)\.[a-z_][a-z0-9_]*", re.IGNORECASE)

WRITES = re.compile(
    r"\b(?:INSERT\s+INTO|(?<!FOR )UPDATE|DELETE\s+FROM)\s+(?:ONLY\s+)?([a-z_][a-z0-9_]*)\.[a-z_][a-z0-9_]*",
    re.IGNORECASE,
)

failures = []
checked = 0

for path in sorted(glob.glob("internal/modules/*/store/*.sql")):
    module = path.split(os.sep)[2]
    checked += 1
    with open(path, encoding="utf-8") as handle:
        raw = handle.read()
    sql = STRING.sub("''", COMMENT.sub("", raw))

    for match in QUALIFIED.finditer(sql):
        schema = match.group(1).lower()
        if schema not in schemas:
            continue
        if owner_of[schema] == module or module in readers_of[schema]:
            continue
        failures.append(
            f"{path}: module {module!r} references schema {schema!r} "
            f"(owned by {owner_of[schema]!r}) and is not a declared reader"
        )

    for match in WRITES.finditer(sql):
        schema = match.group(1).lower()
        if schema not in schemas:
            continue
        if owner_of[schema] == module:
            continue
        failures.append(
            f"{path}: module {module!r} WRITES schema {schema!r} "
            f"(owned by {owner_of[schema]!r}): cross-module writes go through "
            f"the owning module's port"
        )

UNQUALIFIED = re.compile(
    r"\b(?:FROM|JOIN|INSERT\s+INTO|(?<!FOR )UPDATE|DELETE\s+FROM)\s+(?!ONLY\b)([a-z_][a-z0-9_]*)(?![\w.])",
    re.IGNORECASE,
)
SQL_KEYWORDS = {"select", "lateral", "unnest", "generate_series", "only", "values", "of", "set"}

for path in sorted(glob.glob("internal/modules/*/store/*.sql")):
    with open(path, encoding="utf-8") as handle:
        sql = STRING.sub("''", COMMENT.sub("", handle.read()))
    ctes = {name.lower() for name in re.findall(r"(?:WITH|,)\s+([a-z_][a-z0-9_]*)\s+AS\s*\(", sql, re.IGNORECASE)}
    for match in UNQUALIFIED.finditer(sql):
        name = match.group(1).lower()
        if name in SQL_KEYWORDS or name in ctes:
            continue
        failures.append(
            f"{path}: unqualified table {name!r}; qualify it as <schema>.{name} "
            f"so ownership is checkable"
        )

if not checked:
    sys.exit("no module query files found under internal/modules/*/store")

if failures:
    print("Schema ownership violations:")
    for failure in sorted(set(failures)):
        print(f"  {failure}")
    sys.exit(1)

print(f"table-ownership: {checked} query files, ownership respected")
PY
