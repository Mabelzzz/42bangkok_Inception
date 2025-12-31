# DEVELOPER DOCUMENTATION

This document is intended for **developers and evaluators**.

---

## Project Architecture

The stack follows a **three-tier architecture**:

```
Client → Nginx → WordPress (PHP-FPM) → MariaDB
```

Each service runs in its own container.

---

## Prerequisites

- Docker (ARM64 compatible)
- Docker Compose v2
- Make
- Linux VM (recommended for 42 evaluation)

---

## Environment Setup

Clone the repository and ensure this structure:

```
.
├── Makefile
├── srcs
│   ├── docker-compose.yml
│   ├── requirements
│   │   ├── nginx
│   │   ├── wordpress
│   │   └── mariadb
```

Create `.env` file in `srcs/`.

---

## Build and Launch

```bash
make build
make up
```

Rebuild everything:

```bash
make re
```

---

## Makefile Commands

| Command | Description |
|-------|-------------|
| make up | Build & start containers |
| make down | Stop containers |
| make logs | Follow logs |
| make ps | Container status |
| make clean | Remove containers |
| make fclean | Remove containers + volumes |

---

## Container Management

```bash
docker compose ps
docker compose logs -f nginx
docker exec -it srcs-wordpress-1 sh
```

---

## Data Persistence Strategy

| Component | Storage |
|---------|---------|
| MariaDB | Docker volume |
| WordPress files | Docker volume |
| Uploads | Docker volume |

Volumes ensure data survives container restarts.

---

## Design Choices

### Docker vs Virtual Machines
- Faster startup
- Lower resource usage
- Easier reproducibility

### Environment Variables vs Secrets
- `.env` used for simplicity
- Secrets recommended in production

### Docker Network vs Host Network
- Service isolation
- DNS-based service discovery

### Volumes vs Bind Mounts
- Volumes used for portability
- Avoids host filesystem dependency

---

## Security Considerations

- HTTPS enforced via TLS
- Services isolated via Docker network
- No database exposed to host

---

## Validation Checklist

- Containers start without error
- HTTPS reachable
- WordPress installer accessible
- Data persists after restart

---

## Notes for Evaluators

This project strictly follows the **42 Inception requirements**:
- One service per container
- No external images
- TLS enabled
- Persistent storage
- Makefile orchestration
