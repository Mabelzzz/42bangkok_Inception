FROM debian:stable-slim

# 1. Install MariaDB Server and Client
# --no-install-recommends: Installs only essential packages to keep image small
# rm -rf /var/lib/apt/lists/*: Cleans up apt cache to save space
RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Directories and Permissions
# /var/lib/mysql: Stores database data
# /run/mysqld: Stores the socket file (mysqld.sock)
# chown -R mysql:mysql: Ensures the 'mysql' user owns these directories
RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
    && chmod 777 /var/run/mysqld

# 3. Copy Configuration File
# We overwrite the default server config with our custom one
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# 4. Copy Entrypoint Script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 5. Expose Port (Optional but good practice)
EXPOSE 3306

# 6. Set Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]