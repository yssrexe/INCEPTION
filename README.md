*This project has been created as part of the 42 curriculum by yael-yas.*

# Inception

## Description
Inception is a Docker-based infrastructure project that deploys a WordPress site served by Nginx over TLS and backed by MariaDB. The stack is orchestrated with Docker Compose and built from custom Debian-based images so each service is isolated, reproducible, and easy to rebuild.

Sources included in this project:
- Docker Compose definition that wires the services together.
- Custom Dockerfiles for Nginx, MariaDB, and WordPress (PHP-FPM).
- Nginx and MariaDB configuration files.
- Container entrypoint scripts for database and WordPress bootstrap.
- An environment file used to provide runtime configuration.

Main design choices:
- A dedicated bridge network for container-to-container communication by service name.
- TLS termination in Nginx using a self-signed certificate.
- WordPress installed and configured at runtime via WP-CLI.
- Persistent data stored on the host through bind-mounted directories.
- Configuration provided through a .env file for simplicity in a learning context.

Comparisons:
- Virtual Machines vs Docker: VMs run a full guest OS (heavier, stronger isolation), while Docker uses OS-level isolation (lighter, faster startup). This project uses Docker for quicker builds and consistent dev environments.
- Secrets vs Environment Variables: Environment variables are easy to use but stored in plain text in a .env file; Docker secrets keep sensitive data encrypted and mounted only at runtime. For production, secrets are preferable.
- Docker Network vs Host Network: A bridge network isolates containers and provides built-in DNS; host networking shares the host stack and reduces isolation. This project uses a bridge network to keep services isolated and predictable.
- Docker Volumes vs Bind Mounts: Volumes are managed by Docker and are portable; bind mounts map specific host paths and are easy to inspect. This project uses bind mounts (via the local driver) to persist WordPress and MariaDB data in a chosen host directory.

## Instructions
Prerequisites:
- Docker Engine and the Docker Compose plugin.
- A user allowed to run Docker commands (or use sudo).

Configuration:
1) Update the environment file at srcs/.env with your own values.
2) Ensure DATA_DIR points to a valid host path for persistence (e.g., /home/USER/data).
3) Keep DOMAIN_NAME and WP_HTTPS_URL aligned if you want HTTPS to resolve locally.
4) If you want the default domain to resolve locally, add it to /etc/hosts:

```text
127.0.0.1 yael-yas.42.fr
```

Build and run:
```bash
make
```

Useful commands:
```bash
make build     # build images
make up        # start containers in background
make down      # stop containers
make logs      # follow logs
make clean     # remove containers and volumes
make fclean    # clean + docker system prune
make fcleanall # clean + remove host data directories (see note)
make re        # full rebuild
```

Notes:
- The makefile creates /home/yael-yas/data/wordpress and /home/yael-yas/data/mariadb. If you change DATA_DIR, update the makefile or create the directories manually.
- The Nginx container listens on port 443 and proxies PHP requests to the WordPress container on port 9000.

## Resources
- Docker Engine documentation: https://docs.docker.com/engine/
- Docker Compose documentation: https://docs.docker.com/compose/
- Nginx documentation: https://nginx.org/en/docs/
- OpenSSL command reference: https://www.openssl.org/docs/manmaster/man1/openssl-req.html
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress documentation: https://wordpress.org/documentation/
- WP-CLI documentation: https://developer.wordpress.org/cli/commands/
- AI usage: GitHub Copilot was used to draft and structure this README based on the existing project files (no code or configuration was generated).
