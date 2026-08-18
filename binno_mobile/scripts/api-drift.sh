#!/usr/bin/env bash
set -euo pipefail
openapi-generator-cli generate -i docs/binno-openapi-v1.yaml -g dart-dio \
  -o packages/binno_api --skip-validate-spec -p pubName=binno_api >/dev/null
dart format packages/binno_api/lib packages/binno_api/test >/dev/null
(cd packages/binno_api && dart pub get >/dev/null && dart run build_runner build >/dev/null)
git diff --exit-code packages/binno_api
