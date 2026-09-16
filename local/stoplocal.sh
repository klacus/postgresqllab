#!/bin/bash
set -euo pipefail

env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
compose_file="$env_dir/docker-compose.yml"
env_file="$env_dir/.env"

if [[ "${1:-}" == "--clean" ]]; then
  echo "==> Clean up mode: removing containers and volumes..."
  docker compose --env-file "$env_file" -f "$compose_file" down -v
else
  echo "==> Stopping containers (preserving volumes)..."
  docker compose --env-file "$env_file" -f "$compose_file" down
fi
