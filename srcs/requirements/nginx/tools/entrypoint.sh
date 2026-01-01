#!/usr/bin/env bash
set -euo pipefail

# Define the domain name (fallback to pnamwayk.42.fr if not set)
DOMAIN="${DOMAIN:-pnamwayk.42.fr}"

# Paths for the SSL certificate and private key
CERT="/etc/ssl/certs/inception.crt"
KEY="/etc/ssl/private/inception.key"

# Ensure the directory for the private key exists
mkdir -p /etc/ssl/private

# ----------------------------------------------------------------------------
# Self-Signed Certificate Generation
# ----------------------------------------------------------------------------
if [ ! -f "$CERT" ] || [ ! -f "$KEY" ]; then
    echo "[nginx] Generating self-signed TLS cert for ${DOMAIN}..."
    
    # openssl req: Certificate Request
    # -x509: Output a self-signed certificate instead of a request
    # -nodes: "No DES", meaning do not encrypt the private key (no password prompt)
    # -days 365: Validity period
    # -newkey rsa:2048: Generate a new 2048-bit RSA key
    # -keyout: Where to save the key
    # -out: Where to save the certificate
    # -subj: Fills in the certificate info automatically (Country, State, Locality, Org, Unit, CommonName)
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY" \
        -out "$CERT" \
        -subj "/C=TH/ST=Bangkok/L=Bangkok/O=42/OU=Inception/CN=${DOMAIN}"
        
    echo "[nginx] Certificate generated."
fi

# ----------------------------------------------------------------------------
# Start Nginx
# ----------------------------------------------------------------------------
echo "[nginx] Starting Nginx..."

# 'daemon off;' forces Nginx to run in the foreground.
# This is required for Docker containers; otherwise, the container exits immediately.
exec nginx -g "daemon off;"