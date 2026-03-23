#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"

bash "$ROOT_DIR/deploy/scripts/preflight.sh"

docker compose \
  -f "$ROOT_DIR/docker-compose.prod.yml" \
  --env-file "$PROD_ENV_FILE" \
  up -d --build
