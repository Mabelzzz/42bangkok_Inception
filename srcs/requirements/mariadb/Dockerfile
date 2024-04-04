FROM debian:buster-slim

# Update package lists
RUN apt-get update && apt-get install -y mariadb-server

# Expose port for MariaDB (default 3306)
EXPOSE 3306

# Allow remote connections (adjust as needed)
RUN echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf

# Set environment variables for database access (optional)
ENV MYSQL_DATABASE wordpress
ENV MYSQL_USER wordpress_user
ENV MYSQL_PASSWORD your_password
ENV MYSQL_ROOT_PASSWORD your_root_password

# Initialize database on startup
CMD ["mysqld_safe"]
