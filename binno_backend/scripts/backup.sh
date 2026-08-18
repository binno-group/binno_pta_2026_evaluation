#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
DEST="${1:-./backups}"
RETAIN="${BACKUP_RETAIN_DAYS:-14}"
VERIFY="${BACKUP_VERIFY:-1}"
PASSFILE="${BACKUP_PASSPHRASE_FILE:-}"
UPLOAD="${BACKUP_UPLOAD_CMD:-}"
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
FILE="$DEST/binno-oltp-$STAMP.dump"

mkdir -p "$DEST"

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

echo ">> dumping binno -> $FILE"
start=$(date +%s)
docker compose exec -T postgres-oltp \
  pg_dump -U binno -d binno -Fc --no-owner > "$FILE"
echo ">> dumped in $(( $(date +%s) - start ))s, $(du -h "$FILE" | cut -f1)"

if [ "$VERIFY" = "1" ]; then
  echo ">> verifying by restoring into a scratch database"
  SCRATCH="binno_verify_$$"
  cleanup() {
    docker compose exec -T postgres-oltp \
      psql -U binno -d postgres -q -c "DROP DATABASE IF EXISTS $SCRATCH" >/dev/null 2>&1 || true
  }
  trap cleanup EXIT

  docker compose exec -T postgres-oltp psql -U binno -d postgres -q \
    -c "DROP DATABASE IF EXISTS $SCRATCH" >/dev/null
  docker compose exec -T postgres-oltp psql -U binno -d postgres -q \
    -c "CREATE DATABASE $SCRATCH" >/dev/null
  docker compose exec -T postgres-oltp psql -U binno -d "$SCRATCH" -q \
    -c "CREATE EXTENSION IF NOT EXISTS postgis" >/dev/null

  rstart=$(date +%s)
  docker compose exec -T -i postgres-oltp \
    pg_restore -U binno -d "$SCRATCH" --no-owner < "$FILE" >/dev/null
  echo ">> restored in $(( $(date +%s) - rstart ))s (measured RTO for this size)"

  orders=$(docker compose exec -T postgres-oltp psql -U binno -d "$SCRATCH" -tAc \
    "SELECT count(*) FROM orders.orders" | tr -d ' ')
  offers=$(docker compose exec -T postgres-oltp psql -U binno -d "$SCRATCH" -tAc \
    "SELECT count(*) FROM catalog.offers" | tr -d ' ')
  dirty=$(docker compose exec -T postgres-oltp psql -U binno -d "$SCRATCH" -tAc \
    "SELECT count(*) FROM public.schema_migrations_platform WHERE dirty" | tr -d ' ')
  echo ">> verified: orders=$orders offers=$offers dirty_migrations=$dirty"
  [ "$dirty" = "0" ] || { echo "!! restored schema is dirty" >&2; exit 1; }
fi

echo ">> checksumming"
SUM=$(sha256_of "$FILE")
printf '%s  %s\n' "$SUM" "$(basename "$FILE")" > "$FILE.sha256"
if [ "$(sha256_of "$FILE")" != "$SUM" ]; then
  echo "!! $FILE changed between two reads; the volume is not trustworthy" >&2
  exit 1
fi
echo ">> sha256 $SUM"

ARTEFACTS=("$FILE" "$FILE.sha256")

if [ -n "$PASSFILE" ]; then
  [ -r "$PASSFILE" ] || { echo "!! BACKUP_PASSPHRASE_FILE $PASSFILE is not readable" >&2; exit 1; }
  command -v gpg >/dev/null 2>&1 || {
    echo "!! BACKUP_PASSPHRASE_FILE is set but gpg is not installed; refusing to write an unencrypted backup" >&2
    exit 1
  }
  echo ">> encrypting"
  gpg --batch --yes --quiet --symmetric --cipher-algo AES256 \
      --passphrase-file "$PASSFILE" --output "$FILE.gpg" "$FILE"
  rm -f "$FILE"
  printf '%s  %s\n' "$(sha256_of "$FILE.gpg")" "$(basename "$FILE.gpg")" > "$FILE.gpg.sha256"
  rm -f "$FILE.sha256"
  ARTEFACTS=("$FILE.gpg" "$FILE.gpg.sha256")
  echo ">> encrypted -> $FILE.gpg (plaintext removed)"
fi

if [ -n "$UPLOAD" ]; then
  for artefact in "${ARTEFACTS[@]}"; do
    echo ">> uploading $(basename "$artefact")"
    if ! sh -c "$UPLOAD" _ "$artefact"; then
      echo "!! off-host upload failed for $artefact; this backup exists only on the database host" >&2
      exit 1
    fi
  done
  echo ">> off-host copy complete"
else
  echo "!! BACKUP_UPLOAD_CMD is not set: this backup lives only on the database host," \
       "so losing the host loses it too" >&2
fi

echo ">> pruning dumps older than ${RETAIN} days"
find "$DEST" \( -name 'binno-oltp-*.dump' -o -name 'binno-oltp-*.dump.gpg' \
             -o -name 'binno-oltp-*.sha256' \) -type f -mtime "+$RETAIN" -print -delete

echo ">> backups on disk:"
ls -lh "$DEST" | tail -n +2 | awk '{printf "   %s  %s\n", $5, $9}'
