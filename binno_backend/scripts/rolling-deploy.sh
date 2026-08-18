#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
REPLICAS="${1:-2}"
SERVICE=binno
PROBE_URL="${PROBE_URL:-http://localhost:8080/healthz}"

if [ "$REPLICAS" -lt 2 ]; then
  echo "refusing to roll a single replica: with N=1 there is no survivor to serve" >&2
  echo "traffic during the swap, so downtime is unavoidable. Scale to >=2 first." >&2
  exit 1
fi

DRAIN=$(grep -E '^SHUTDOWN_DRAIN_DELAY=' .env 2>/dev/null | cut -d= -f2 || echo 5s)
DRAIN_S=${DRAIN%s}

SETTLE=$(( DRAIN_S > 1 ? DRAIN_S - 1 : 1 ))

log() { printf '\033[36m>>\033[0m %s\n' "$*"; }

reload_nginx() {
  if ! docker compose exec -T nginx nginx -s reload >/dev/null 2>&1; then
    echo "nginx reload failed; refusing to fall back to a restart because that" >&2
    echo "would drop live client connections. Fix nginx, then re-run." >&2
    exit 1
  fi
}

log "building the new image before touching any replica"
docker compose build "$SERVICE"

log "ensuring the fleet is at $REPLICAS before rolling"
docker compose up -d --no-recreate --scale "$SERVICE=$REPLICAS" "$SERVICE"

OLD_IFS=$IFS
IFS=$'\n'
# shellcheck disable=SC2207
TARGETS=($(docker compose ps "$SERVICE" --format '{{.Name}}'))
IFS=$OLD_IFS

if [ "${#TARGETS[@]}" -eq 0 ]; then
  echo "no $SERVICE replicas found to roll" >&2
  exit 1
fi
log "replicas to replace: ${TARGETS[*]}"

for target in "${TARGETS[@]}"; do
  log "--- $target ---"

  log "SIGTERM -> draining (readyz 503, listener open for ${DRAIN})"
  docker kill -s TERM "$target" >/dev/null 2>&1 || true
  sleep "$SETTLE"

  log "removing the drained replica and re-resolving the upstream"
  docker rm -f "$target" >/dev/null 2>&1 || true
  reload_nginx

  log "starting the replacement on the new image"
  docker compose up -d --no-deps --scale "$SERVICE=$REPLICAS" "$SERVICE" >/dev/null
  reload_nginx

  log "waiting for the fleet to answer"
  for i in $(seq 1 60); do
    if curl -sf -m 2 "$PROBE_URL" >/dev/null 2>&1; then
      log "healthy after ${i}s"
      break
    fi
    [ "$i" = 60 ] && { echo "replacement never became healthy; stopping roll" >&2; exit 1; }
    sleep 1
  done
done

log "verifying every replica runs the new image"
docker compose ps "$SERVICE" --format '{{.Name}} {{.Image}}'
log "done, ${#TARGETS[@]} replicas replaced"
