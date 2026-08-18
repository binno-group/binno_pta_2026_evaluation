#!/usr/bin/env bash
set -euo pipefail
tmp_file=$(mktemp)
dart run tool/dump_tokens.dart > "$tmp_file"
diff -u <(python3 -m json.tool docs/design-tokens.json) \
        <(python3 -m json.tool "$tmp_file")
