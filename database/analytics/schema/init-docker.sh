#!/bin/sh
# Executed by the timescaledb entrypoint on first container start only.
set -eu

SCHEMA_DIR="/opt/olap-analytics"

echo "==> Loading analytics 'sampledw' schema from ${SCHEMA_DIR}"

for sql_file in "${SCHEMA_DIR}"/*.sql; do
  [ -e "$sql_file" ] || continue
  echo "--> Applying $(basename "$sql_file")"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$sql_file"
done

echo "==> Analytics 'sampledw' schema loaded"
