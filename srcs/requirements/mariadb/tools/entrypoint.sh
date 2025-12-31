#!/usr/bin/env bash
set -euo pipefail

# Required env vars from .env
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"

DATADIR="/var/lib/mysql"
INIT_MARKER="${DATADIR}/.inception_initialized"

# Ensure ownership (volume mount may reset)
chown -R mysql:mysql /run/mysqld "$DATADIR"

# Initialize DB only on first run
if [ ! -f "$INIT_MARKER" ]; then
  echo "[mariadb] Initializing database..."
  mariadb-install-db --user=mysql --datadir="$DATADIR" > /dev/null

  # Start temporary server on unix socket
  mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  # Wait for server
  for i in {1..30}; do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  echo "[mariadb] Creating database and user..."
  mariadb --socket=/run/mysqld/mysqld.sock <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

  # Stop temp server
  kill "$pid"
  wait "$pid" || true

  touch "$INIT_MARKER"
  chown mysql:mysql "$INIT_MARKER"
  echo "[mariadb] Initialization done."
fi

# Start server normally (listen on network)
exec mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0
# EOF
