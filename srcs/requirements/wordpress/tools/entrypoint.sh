#!/usr/bin/env bash
set -euo pipefail

# =====================================================================
# WordPress Entrypoint Script
# - Waits for MariaDB
# - Installs WordPress automatically (first run only)
# - Starts PHP-FPM in foreground
# =====================================================================

WP_PATH="/var/www/html"

# ---------------------------------------------------------------------
# 1. Validate required environment variables
# ---------------------------------------------------------------------
: "${WP_DB_NAME:?WP_DB_NAME is required}"
: "${WP_DB_USER:?WP_DB_USER is required}"
: "${WP_DB_PASSWORD:?WP_DB_PASSWORD is required}"
: "${WP_DB_HOST:?WP_DB_HOST is required}"
: "${WP_URL:?WP_URL is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"

# ---------------------------------------------------------------------
# 2. Wait for MariaDB to be ready
# ---------------------------------------------------------------------
echo "[wordpress] Waiting for MariaDB at ${WP_DB_HOST}..."

for i in {1..30}; do
    if php -r "
        mysqli_report(MYSQLI_REPORT_OFF);
        \$m = @new mysqli('${WP_DB_HOST}', '${WP_DB_USER}', '${WP_DB_PASSWORD}', '${WP_DB_NAME}');
        exit(\$m->connect_errno ? 1 : 0);
    " >/dev/null 2>&1; then
        echo "[wordpress] MariaDB is connected!"
        break
    fi
    echo "[wordpress] Retrying connection..."
    sleep 2
done

# ---------------------------------------------------------------------
# 3. Download WordPress core (only once)
# ---------------------------------------------------------------------
if [ ! -f "${WP_PATH}/wp-load.php" ]; then
    echo "[wordpress] Downloading WordPress core..."
    wp core download --path="${WP_PATH}" --allow-root
fi

# ---------------------------------------------------------------------
# 4. Create wp-config.php if missing
# ---------------------------------------------------------------------
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "[wordpress] Creating wp-config.php..."
    wp config create \
        --dbname="${WP_DB_NAME}" \
        --dbuser="${WP_DB_USER}" \
        --dbpass="${WP_DB_PASSWORD}" \
        --dbhost="${WP_DB_HOST}" \
        --path="${WP_PATH}" \
        --allow-root
fi

# ---------------------------------------------------------------------
# 5. Install WordPress if not installed yet
# This prevents showing /wp-admin/install.php
# ---------------------------------------------------------------------
if ! wp core is-installed --path="${WP_PATH}" --allow-root >/dev/null 2>&1; then
    echo "[wordpress] Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --path="${WP_PATH}" \
        --allow-root
else
    echo "[wordpress] WordPress already installed."
fi

# ---------------------------------------------------------------------
# 6. Fix permissions (required for uploads & plugins)
# ---------------------------------------------------------------------
echo "[wordpress] Enforcing permissions..."
chown -R www-data:www-data "${WP_PATH}"

# ---------------------------------------------------------------------
# 7. Start PHP-FPM (foreground, PID 1)
# Supports PHP 8.4 / 8.3 / generic php-fpm
# ---------------------------------------------------------------------
PHP_FPM_BIN="$(command -v php-fpm8.4 || command -v php-fpm8.3 || command -v php-fpm || true)"

if [ -z "${PHP_FPM_BIN}" ]; then
    echo "[wordpress] ERROR: php-fpm binary not found"
    exit 1
fi

echo "[wordpress] Starting PHP-FPM using ${PHP_FPM_BIN}"
mkdir -p /run/php
exec "${PHP_FPM_BIN}" -F
