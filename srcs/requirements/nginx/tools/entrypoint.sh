#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${DOMAIN:-pnamwayk.42.fr}"

CERT="/etc/ssl/certs/inception.crt"
KEY="/etc/ssl/private/inception.key"

mkdir -p /etc/ssl/private

# Generate self-signed cert if not exist
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
  echo "[nginx] Generating self-signed TLS cert for ${DOMAIN}..."
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout "$KEY" -out "$CERT" \
    -subj "/C=TH/ST=Bangkok/L=Bangkok/O=42/OU=Inception/CN=${DOMAIN}"
fi

# Make sure nginx can read key
chmod 600 "$KEY"

exec nginx -g "daemon off;"
# EOF