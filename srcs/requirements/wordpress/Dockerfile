# =====================================================================
# WordPress Dockerfile
# Base: Debian (penultimate stable requirement compliant)
# =====================================================================

FROM debian:stable

# ---------------------------------------------------------------------
# Install system dependencies, PHP-FPM, WordPress tools
# ---------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    mariadb-client \
    curl \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------
# Install WP-CLI (official, not DockerHub image)
# ---------------------------------------------------------------------
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# ---------------------------------------------------------------------
# Configure PHP-FPM to listen on TCP 9000 (required for Nginx container)
# This is applied to ALL PHP versions installed
# ---------------------------------------------------------------------
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/*/fpm/pool.d/www.conf

# ---------------------------------------------------------------------
# Copy custom PHP-FPM pool configuration
# ---------------------------------------------------------------------
COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

# ---------------------------------------------------------------------
# Copy WordPress entrypoint script
# ---------------------------------------------------------------------
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ---------------------------------------------------------------------
# Expose PHP-FPM port
# ---------------------------------------------------------------------
EXPOSE 9000

# ---------------------------------------------------------------------
# Start WordPress container
# ---------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
