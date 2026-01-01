FROM debian:stable-slim

# 1. Install PHP dependencies and utilities
# - php-fpm: The PHP FastCGI Process Manager to handle PHP requests
# - php-mysql: Allows PHP to communicate with MariaDB
# - mariadb-client: Useful for WP-CLI database operations
# - curl: Used to download WP-CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    php-intl \
    mariadb-client \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Install WP-CLI (Command-line interface for WordPress)
# This tool allows us to install and configure WordPress via script easily
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# 3. Copy our custom PHP-FPM configuration
# Note: Debian stable currently uses PHP 8.2. Adjust path if version changes.
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# 4. Create the directory for PHP socket (Required for PHP-FPM to start)
RUN mkdir -p /run/php

# 5. Copy the entrypoint script and make it executable
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 6. Set working directory to where WordPress files will live
WORKDIR /var/www/html

# 7. Expose port 9000 so Nginx can send requests to this container
EXPOSE 9000

# 8. Define the command to run when the container starts
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]