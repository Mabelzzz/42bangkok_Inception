FROM debian:buster-slim

# Update package lists
RUN apt-get update && apt-get install -y php-fpm php-mysqli

# Install and configure WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -r wordpress /var/www/html && \
    rm -rf latest.tar.gz wordpress

# Expose port for php-fpm (default 9000)
EXPOSE 9000

# Set working directory for php-fpm
WORKDIR /var/www/html

CMD ["php-fpm7", "-F"]
