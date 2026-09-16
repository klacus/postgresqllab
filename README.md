
# PostgreSQL Lab

A sample PostgreSQL solution for getting started with database development in a
local environment. It spins up a complete, disposable stack with Docker Compose:

> **Not for production use.** This is a throwaway learning and experimentation
> sandbox. It ships with well-known default passwords in a plaintext `.env`, runs
> every database as a superuser, exposes ports without TLS and stores nothing
> durably. Do not put real data in it and do not expose it outside your machine.
> It is provided with absolutely no warranty — see [LICENSE](LICENSE).

| Service | What it is | URL / Port |
| --- | --- | --- |
| `postgresqllab.oltp` | PostgreSQL 18 with a sample OLTP schema (`sample`) | `localhost:9432` |
| `postgresqllab.olap` | TimescaleDB with a sample analytics schema (`sampledw`) | `localhost:9433` |
| `postgresqllab.pgadmin` | pgAdmin 4 for managing both databases | http://localhost:9050 |
| `postgresqllab.grafana` | Grafana with pre-provisioned sample dashboards | http://localhost:9000 |

Both databases are created and populated with sample data automatically on first
start, so there is something to query and chart straight away.

# Prerequisites

A Linux host with Docker Engine, the Compose V2 plugin and Buildx. On a
Debian/Ubuntu system:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2 docker-buildx
```

If `docker-buildx` is not available in your distribution, use
`docker-buildx-plugin` instead.

Add yourself to the `docker` group so the scripts can run without `sudo`, then
log out and back in for it to take effect:

```bash
sudo usermod -aG docker "$USER"
```

Verify the installation:

```bash
docker --version
docker compose version   # must report v2.x
docker buildx version
```

| Requirement | Why it is needed |
| --- | --- |
| Docker Engine | Runs the PostgreSQL, TimescaleDB, pgAdmin and Grafana containers. |
| Docker Compose V2 | The stack is defined in a Compose file and the scripts call `docker compose` (the V1 `docker-compose` binary will not work). |
| Docker Buildx | Builds the customised images from the `Dockerfile`s in this repository. |

# Getting started

Everything for the local environment lives in `deployment/environments/local`.

```bash
cd deployment/environments/local
./startlocal.sh --init
```

Then open Grafana at http://localhost:9000 or pgAdmin at http://localhost:9050.

## Start and stop scripts

Both scripts resolve the compose file and `.env` next to them, so they can be run
from any directory.

| Command | Effect |
| --- | --- |
| `./startlocal.sh` | Recreates and starts the stack, **keeping** existing data volumes. |
| `./startlocal.sh --init` | Removes containers **and volumes** first, then rebuilds and starts. Use this to get a clean database — it is the only way to re-run the schema scripts. |
| `./stoplocal.sh` | Stops and removes the containers, **keeping** the data volumes. |
| `./stoplocal.sh --clean` | Stops and removes the containers **and the data volumes**. All data is lost. |

The schema and seed scripts only run when a database volume is empty. If you
change anything under `database/*/schema`, restart with `./startlocal.sh --init`
for it to take effect.

# Configuration

All credentials, database names and host ports are read from
`deployment/environments/local/.env`. Nothing is hardcoded in the compose file,
so this is the only file you need to touch.

| Variable | Purpose |
| --- | --- |
| `OLTP_DB`, `OLTP_USER`, `OLTP_PASSWORD` | Database, superuser and password created in the OLTP container. |
| `OLTP_PORT` | Host port mapped to the OLTP PostgreSQL instance. |
| `OLAP_DB`, `OLAP_USER`, `OLAP_PASSWORD` | Database, superuser and password created in the analytics (TimescaleDB) container. |
| `OLAP_PORT` | Host port mapped to the analytics instance. |
| `PGADMIN_EMAIL`, `PGADMIN_PASSWORD` | pgAdmin login. |
| `PGADMIN_PORT` | Host port for the pgAdmin web UI. |
| `GRAFANA_USER`, `GRAFANA_PASSWORD` | Grafana admin login. |
| `GRAFANA_PORT` | Host port for the Grafana web UI. |

Notes:

- A literal `$` in a value must be written as `$$`.
- Changing a password only has an effect on a database that has not been
  initialised yet. Run `./startlocal.sh --init` after changing `OLTP_PASSWORD` or
  `OLAP_PASSWORD`.
- The `.env` file holds real secrets. Consider ignoring it in Git and committing
  a placeholder copy instead if this ever leaves your machine.

## Database credentials in pgAdmin

The `pgpass` file is **not** stored in the repository and is not baked into the
pgAdmin image. Instead, the short-lived `init-pgpass` service generates it at
startup:

1. Compose passes the `OLTP_*` and `OLAP_*` values from `.env` to a busybox
   container as environment variables.
2. That container writes `/pgadmin4/pgpass` into the shared `pgadmin_config`
   volume, with one line per server, then sets owner `5050:root` and mode `600`
   as pgAdmin requires.
3. The pgAdmin service mounts the same volume and waits for `init-pgpass` to
   finish successfully, so the file is always present before it boots.
   `PGPASSFILE=./pgpass` resolves against pgAdmin's `/pgadmin4` working directory.

The passwords are expanded by the shell inside the container rather than by
Compose, so they do not appear in `docker compose config` output. Both servers
are pre-registered from `pgadmin/servers.json`, so no manual connection setup is
needed.

# Repository layout

```
database/oltp/schema        OLTP 'sample' schema + seed data, applied on first start
database/analytics/schema   TimescaleDB 'sampledw' schema, policies and seed data
grafana/provisioning        Grafana datasource and sample dashboards
pgadmin                     pgAdmin image and pre-registered servers
deployment/environments/local
                            .env, docker-compose.yml and the start/stop scripts
```

# License

MIT — see [LICENSE](LICENSE). The software is provided "as is", without warranty
of any kind.
