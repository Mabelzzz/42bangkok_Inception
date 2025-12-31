# cat > ~/inception/srcs/requirements/wordpress/Dockerfile <<'EOF'
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm php-mysql php-curl php-gd php-xml php-mbstring php-zip php-intl \
    curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Prepare php-fpm to listen on 9000
RUN sed -i 's|^listen = .*|listen = 9000|g' /etc/php/*/fpm/pool.d/www.conf \
 && sed -i 's|^;clear_env = no|clear_env = no|g' /etc/php/*/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# EOF
