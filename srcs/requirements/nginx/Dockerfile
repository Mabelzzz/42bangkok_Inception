FROM debian:stable-slim

# 1. Install Dependencies
# - nginx: The web server
# - openssl: Tool to generate Self-Signed Certificates
# - ca-certificates: To handle SSL certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup Config
# Copy our custom nginx.conf to replace the default one
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 3. Setup Entrypoint
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 4. Prepare Directories
# Ensure the web root exists (though it will be mounted over)
RUN mkdir -p /var/www/html

# 5. Expose Ports
# Only 443 (HTTPS) is allowed by the subject
EXPOSE 443

# 6. Start the container
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]