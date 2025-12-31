*This project has been created as part of the 42 curriculum by <pnamwayk>.*

# Inception

## Description

Inception is a system administration and DevOps project from the 42 curriculum.  
The objective is to build a complete WordPress infrastructure using **Docker** and **Docker Compose**, following strict rules about isolation, security, and reproducibility.

All services are deployed inside **Docker containers**, running on a **virtual machine**.  
Each service is built from a **custom Dockerfile** — no pre-built images such as `wordpress` or `mariadb` are used.

The final infrastructure includes:
- NGINX (HTTPS only)
- WordPress with PHP-FPM
- MariaDB
- Docker volumes for persistence
- A dedicated Docker network

---

## Project Architecture

```
Client (Browser)
        |
     HTTPS (443)
        |
     ┌────────┐
     │  NGINX │
     └────────┘
          |
      FastCGI
          |
     ┌───────────┐
     │ WordPress │ (PHP-FPM)
     └───────────┘
          |
       MySQL
          |
     ┌──────────┐
     │ MariaDB  │
     └──────────┘
```

Each service runs in its own container and communicates through a private Docker network.

---

## Services

### NGINX
- Acts as a reverse proxy
- Exposes **only port 443**
- Uses a self-signed TLS certificate
- Forwards PHP requests to WordPress (FastCGI)
- Does not contain PHP

### WordPress
- Runs PHP using PHP-FPM
- Automatically installs WordPress at first launch
- Connects to MariaDB via environment variables
- Stores files in persistent volumes

### MariaDB
- Provides database storage for WordPress
- Initialized using environment variables
- Data persists across container restarts

---

## Volumes & Persistence

The project uses Docker volumes with bind mounts to ensure persistence.

| Volume | Description |
|------|------------|
| mariadb_data | MariaDB database files |
| wordpress_data | WordPress core files |
| wordpress_uploads | Media uploads |

Volumes are stored on the host at:
```
/home/pnamwayk/data/
```

---

## Instructions

### Requirements
- Linux Virtual Machine
- Docker
- Docker Compose
- Make

### Installation

Clone the repository:
```bash
git clone git@vogsphere.42bangkok.com:vogsphere/intra-uuid-b55607e1-6144-418e-9aa5-a1021eb3a4e0-7096719-pnamwayk Inception
cd Inception
```

Create required directories on the VM:
```bash
mkdir -p /home/pnamwayk/data/mariadb
mkdir -p /home/pnamwayk/data/wordpress/uploads
```

### Run the project
```bash
make up
```

Useful commands:
```bash
make build
make up
make down
make re
make logs
make ps
make fclean
```

---

## Accessing WordPress

Add the domain inside the VM:
```bash
127.0.0.1 pnamwayk.42.fr
```

Open in browser:
```
https://pnamwayk.42.fr
```

---

## Security

- HTTPS only (port 443)
- No credentials hardcoded in images
- Environment variables for secrets
- Private Docker network

---

## Design Choices

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|-----------------|--------|
| Heavy | Lightweight |
| Slower startup | Fast startup |
| Full OS per service | Shared kernel |

Docker provides isolation with better performance.

---

### Secrets vs Environment Variables

Environment variables were chosen for simplicity and to match project constraints.

---

### Docker Network vs Host Network

A Docker bridge network is used for:
- Service name resolution
- Isolation
- Security

---

### Docker Volumes vs Bind Mounts

Bind-mounted volumes allow:
- Data persistence
- Easy inspection
- Clear separation from containers

---

## Resources

- https://docs.docker.com/
- https://nginx.org/en/docs/
- https://wordpress.org/documentation/
- https://mariadb.org/documentation/

### AI Usage

AI was used as a learning assistant for:
- Debugging Docker issues
- Understanding networking concepts
- Improving documentation clarity

All decisions were reviewed and implemented by pnamwayk.

---

## Conclusion

This project demonstrates:
- Containerized system design
- Secure service orchestration
- Persistent data management
- Clear and professional documentation
