FROM dpage/pgadmin4:9.15

# The entrypoint starts as root, sets up directories and permissions,
# then drops privileges to the 'pgadmin' user (UID 5050).
# Do NOT set USER in this Dockerfile — the entrypoint handles it.
# See: https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html

# Copy custom config files to import.
# The init-pgadmin will still need to massage them...
# pgpass is generated from environment variables by the init-pgpass service.
COPY ./servers.json /pgadmin4/servers.json

USER pgadmin
