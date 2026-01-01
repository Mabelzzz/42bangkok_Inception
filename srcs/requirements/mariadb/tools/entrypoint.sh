#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------------
# 1. Validation
# ----------------------------------------------------------------------------
# Check if necessary environment variables are set in .env
: "${WP_DB_NAME:?WP_DB_NAME is required}"
: "${WP_DB_USER:?WP_DB_USER is required}"
: "${WP_DB_PASSWORD:?WP_DB_PASSWORD is required}"
: "${WP_DB_ROOT_PASSWORD:?WP_DB_ROOT_PASSWORD is required}"

# ----------------------------------------------------------------------------
# 2. Permission Fix
# ----------------------------------------------------------------------------
# Ensure correct ownership. This is crucial because when using Docker Volumes,
# the mapped directory might belong to 'root' initially.
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# ----------------------------------------------------------------------------
# 3. Initialization Logic (Run only if DB is empty)
# ----------------------------------------------------------------------------
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[mariadb] Initializing database..."

    # Initialize the data directory with system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Start a temporary MariaDB server in the background
    # --skip-networking: Security measure (no remote connections during setup)
    echo "[mariadb] Starting temporary server..."
    mysqld --user=mysql --skip-networking &
    PID="$!"

    # Wait for the temporary server to be ready
    echo "[mariadb] Waiting for server to start..."
    for i in {1..30}; do
        if mysqladmin ping --silent; then
            break
        fi
        sleep 1
    done

    echo "[mariadb] Configuring Database and Users..."
    
    # Send SQL commands to the server via EOF (Here-Doc)
    # 1. FLUSH PRIVILEGES: Reload grant tables.
    # 2. CREATE DATABASE: Create the WordPress database.
    # 3. CREATE USER: Create the WP user allowed to connect from ANY host ('%').
    # 4. GRANT ALL: Give full permission on the WP DB to that user.
    # 5. ALTER USER root: Set the root password (for localhost access).
    mysql -u root <<-EOSQL
        FLUSH PRIVILEGES;
        CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\`;
        CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    # Stop the temporary server properly
    echo "[mariadb] Stopping temporary server..."
    mysqladmin -u root -p"${WP_DB_ROOT_PASSWORD}" shutdown
    wait "$PID"

    echo "[mariadb] Initialization finished."
else
    echo "[mariadb] Database already initialized. Skipping setup."
fi

# ----------------------------------------------------------------------------
# 4. Start Server
# ----------------------------------------------------------------------------
# Use 'exec' to replace the shell process with mysqld.
# This ensures MariaDB receives signals (like SIGTERM) correctly.
echo "[mariadb] Starting MariaDB Server..."
exec mysqld