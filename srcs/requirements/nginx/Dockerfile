FROM debian:buster-slim

# Update package lists
RUN apt-get update && apt-get install -y openssl libssl-dev

# Install NGINX with TLSv1.2 support
RUN apt-get install -y nginx

# Configure Nginx for TLSv1.2/1.3 (adjust as needed)
RUN echo "ssl_protocols TLSv1.2 TLSv1.3;" >> /srcs/requirements/nginx/conf/nginx.conf

# Replace default config with your own (optional)
COPY /srcs/requirements/nginx/conf/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 443
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
