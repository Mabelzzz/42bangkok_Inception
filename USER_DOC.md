# USER DOCUMENTATION

This document is intended for **end users and administrators** who want to run and use the Inception project.

---

## Overview

This project deploys a **secure WordPress website** using Docker and Docker Compose.  
The stack includes:

- **Nginx** – HTTPS reverse proxy (TLS enabled)
- **WordPress (PHP-FPM)** – Application layer
- **MariaDB** – Database backend

All services are containerized and isolated in a Docker network.

---

## Services Provided

| Service   | Description |
|----------|-------------|
| Nginx    | Serves HTTPS traffic on port 443 |
| WordPress | Website & admin panel |
| MariaDB | Persistent database for WordPress |

---

## Start the Project

From the project root:

```bash
make up
```

This will:
- Build all Docker images
- Start containers in detached mode

---

## Stop the Project

```bash
make down
```

---

## Access the Website

Open a browser and go to:

```
https://pnamwayk.42.fr
```

If running locally, you may need:

```bash
curl -k --resolve pnamwayk.42.fr:443:127.0.0.1 https://pnamwayk.42.fr
```

---

## Access the WordPress Admin Panel

```
https://pnamwayk.42.fr/wp-admin
```

During first launch, WordPress will display the **installation wizard**.

---

## Credentials Management

Credentials are defined in the `.env` file:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppassword
MYSQL_ROOT_PASSWORD=rootpassword
```

⚠️ **Never commit real secrets in production environments.**

---

## Check Services Status

```bash
make ps
```

View logs:

```bash
make logs
```

---

## Data Persistence

- Database data persists via Docker volumes
- WordPress uploads are preserved across restarts

---

## Troubleshooting

- Browser warning about certificate → expected (self-signed TLS)
- 403 errors → verify Nginx configuration and WordPress volume

---

## Summary

This project provides a secure, reproducible WordPress environment suitable for learning Docker orchestration and service isolation.
