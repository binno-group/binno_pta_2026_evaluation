#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${DOMAIN:-api.binno.uz}"
EMAIL="${EMAIL:-}"
STAGING="${STAGING:-0}"

cd "$(dirname "$0")/.."

COMPOSE=(docker compose
  -f docker-compose.yml
  -f deploy/compose/prod.yml
  -f "deploy/compose/hetzner/${TIER:-ccx23}.yml")

if [ -z "$EMAIL" ]; then
  echo "EMAIL is required: Let's Encrypt sends expiry warnings there, and those" >&2
  echo "warnings are the only thing that catches a renewal loop that has died." >&2
  echo "  EMAIL=ops@binno.uz $0" >&2
  exit 1
fi

echo "domain : $DOMAIN"
echo "mode   : $([ "$STAGING" = "1" ] && echo 'STAGING (untrusted, for rehearsal)' || echo 'PRODUCTION')"
echo

resolved="$(getent hosts "$DOMAIN" 2>/dev/null | awk '{print $1}' | head -1 || true)"
public="$(curl -fsS --max-time 10 https://api.ipify.org 2>/dev/null || true)"
if [ -n "$resolved" ] && [ -n "$public" ] && [ "$resolved" != "$public" ]; then
  echo "WARNING: $DOMAIN resolves to $resolved but this host's public IP is $public." >&2
  echo "The http-01 challenge will be sent to $resolved and will fail here." >&2
  read -r -p "Continue anyway? [y/N] " reply
  [ "$reply" = "y" ] || exit 1
fi

live="/etc/letsencrypt/live/$DOMAIN"

if ! "${COMPOSE[@]}" run --rm --entrypoint sh certbot -c "[ -f $live/fullchain.pem ]" 2>/dev/null; then
  echo "==> placing a temporary self-signed certificate so nginx can start"
  "${COMPOSE[@]}" run --rm --entrypoint sh certbot -c "
    mkdir -p '$live' &&
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
      -keyout '$live/privkey.pem' \
      -out '$live/fullchain.pem' \
      -subj '/CN=$DOMAIN' &&
    cp '$live/fullchain.pem' '$live/chain.pem'
  "
fi

echo "==> starting nginx"
"${COMPOSE[@]}" up -d nginx
for _ in $(seq 1 30); do
  curl -fsS -o /dev/null "http://127.0.0.1/.well-known/acme-challenge/" 2>/dev/null && break
  curl -sS -o /dev/null "http://127.0.0.1/" 2>/dev/null && break
  sleep 1
done

echo "==> requesting the certificate"
staging_flag=""
[ "$STAGING" = "1" ] && staging_flag="--staging"

"${COMPOSE[@]}" run --rm --entrypoint sh certbot -c "rm -rf '$live' /etc/letsencrypt/archive/$DOMAIN /etc/letsencrypt/renewal/$DOMAIN.conf"

"${COMPOSE[@]}" run --rm --entrypoint certbot certbot \
  certonly --webroot -w /var/www/certbot \
  -d "$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos --no-eff-email \
  --non-interactive \
  $staging_flag

echo "==> reloading nginx"
"${COMPOSE[@]}" exec nginx nginx -s reload

echo
if [ "$STAGING" = "1" ]; then
  echo "STAGING certificate installed. Browsers will not trust it, that is expected."
  echo "Re-run without STAGING=1 to get the real one."
else
  echo "Done. Verify from another machine, not from the box:"
  echo "  curl -vI https://$DOMAIN/healthz"
  echo
  echo "Then raise HSTS: deploy/nginx/conf.d-tls/binno.conf ships max-age=300 so a"
  echo "mistake here is recoverable in five minutes. Once a renewal has succeeded,"
  echo "change it to 31536000 and reload."
fi
