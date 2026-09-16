FROM postgres:18-alpine

# Standard PostgreSQL 17 image.
# Connection parameters are provided at runtime via environment variables.
# No credentials are hardcoded in this image.

# Copy any initialisation SQL scripts into the entrypoint directory.
# Files are executed in alphabetical order on first container start.
# COPY init/*.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
