#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------------
# 1. Validation & Configuration
# ----------------------------------------------------------------------------

# Check if essential environment variables are provided in .env
# If any are missing, the script will exit with an error.
: "${WP_DB_NAME:?WP_DB_NAME is required}"
: "${WP_DB_USER:?WP_DB_USER is required}"
: "${WP_DB_PASSWORD:?WP_DB_PASSWORD is required}"
: "${WP_DB_HOST:?WP_DB_HOST is required}"
: "${WP_URL:?WP_URL is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"

WP_PATH="/var/www/html"

# ----------------------------------------------------------------------------
# 2. Wait for Database Connection
# ----------------------------------------------------------------------------

echo "[wordpress] Waiting for MariaDB at $WP_DB_HOST..."

# Loop up to 30 times (approx 60 seconds) to check if MariaDB is ready
for i in {1..30}; do
    # Use a small PHP one-liner to test the database connection
    if php -r "mysqli_report(MYSQLI_REPORT_OFF); \$m=@new mysqli('${WP_DB_HOST}', '${WP_DB_USER}', '${WP_DB_PASSWORD}', '${WP_DB_NAME}'); if(\$m->connect_errno) exit(1); exit(0);" >/dev/null 2>&1; then
        echo "[wordpress] MariaDB is connected!"
        break
    fi
    echo "[wordpress] Retrying connection..."
    sleep 2
done

# ----------------------------------------------------------------------------
# 3. Install WordPress (Only if not already installed)
# ----------------------------------------------------------------------------

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "[wordpress] No installation found. Starting fresh setup..."

    # A. Download WordPress Core files
    echo "[wordpress] Downloading WordPress..."
    wp core download --path="$WP_PATH" --allow-root

    # B. Generate wp-config.php
    # Automatically links to the Database using env vars
    echo "[wordpress] Creating config..."
    wp config create \
        --dbname="$WP_DB_NAME" \
        --dbuser="$WP_DB_USER" \
        --dbpass="$WP_DB_PASSWORD" \
        --dbhost="$WP_DB_HOST" \
        --path="$WP_PATH" \
        --allow-root

    # C. Run the Installation
    # Creates the Admin account and sets the site title/URL
    echo "[wordpress] Installing site..."
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path="$WP_PATH" \
        --allow-root

    # (Optional) Create a secondary user (Editor/Author) if needed for evaluation
    # wp user create bob bob@example.com --role=author --user_pass=password123 --allow-root --path="$WP_PATH"

    echo "[wordpress] Setup finished successfully."
else
    echo "[wordpress] wp-config.php already exists. Skipping setup."
fi

# ----------------------------------------------------------------------------
# 4. Final Permission Check
# ----------------------------------------------------------------------------

# Ensure www-data owns the files so plugins/uploads work correctly
echo "[wordpress] Enforcing permissions..."
chown -R www-data:www-data "$WP_PATH"

# ----------------------------------------------------------------------------
# 5. Start PHP-FPM
# ----------------------------------------------------------------------------

echo "[wordpress] Starting PHP-FPM..."

# Ensure the PID directory exists
mkdir -p /run/php

# Start PHP-FPM in foreground mode (-F)
# Note: We use the full path to the binary (usually php-fpm8.2 in Debian Stable)
exec /usr/sbin/php-fpm8.2 -F