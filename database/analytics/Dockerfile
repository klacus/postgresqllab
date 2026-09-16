FROM timescale/timescaledb:2.26.4-pg17

# TimescaleDB image is a drop-in replacement for the official postgres image.
# It includes all standard PostgreSQL functionality plus the TimescaleDB extension.
# Connection parameters are provided at runtime via docker-compose environment settings.
# No credentials are hardcoded in this image.

# Copy any initialisation SQL scripts into the entrypoint directory.
# Files are executed in alphabetical order on first container start.
# COPY init/*.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
