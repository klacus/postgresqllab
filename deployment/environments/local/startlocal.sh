#!/bin/bash
set -euo pipefail

env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
compose_file="$env_dir/docker-compose.yml"
env_file="$env_dir/.env"

if [[ ! -f "$env_file" ]]; then
  echo "Missing $env_file" >&2
  exit 1
fi

if [[ "${1:-}" == "--init" ]]; then
  echo "==> Init mode: removing containers and volumes..."
  docker compose --env-file "$env_file" -f "$compose_file" down -v
else
  echo "==> Restarting containers (preserving volumes)..."
  docker compose --env-file "$env_file" -f "$compose_file" down
fi

# docker compose --progress plain --env-file "$env_file" -f "$compose_file" up -d --build
docker compose --env-file "$env_file" -f "$compose_file" up -d --build
