#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
APP_SERVICE="${APP_SERVICE:-app}"

source "$ROOT_DIR/deploy/scripts/compose-prod.sh"

if [[ ! -f "$PROD_ENV_FILE" ]]; then
  echo "缺少生产环境变量文件：$PROD_ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$PROD_ENV_FILE"
set +a

container_id="$(compose_prod ps -q "$APP_SERVICE")"
if [[ -z "$container_id" ]]; then
  echo "未找到应用容器：$APP_SERVICE"
  exit 1
fi

runtime_image="$(docker inspect --format '{{.Config.Image}}' "$container_id" 2>/dev/null || true)"
image_digest="$(docker inspect --format '{{join .RepoDigests "\n"}}' "$container_id" 2>/dev/null || true)"

if [[ -z "$runtime_image" ]]; then
  echo "无法解析应用当前镜像：$APP_SERVICE"
  exit 1
fi

echo "应用当前镜像：$runtime_image"

if [[ -n "$image_digest" && "$image_digest" != "<no value>" ]]; then
  echo "镜像摘要："
  printf '%s\n' "$image_digest"
fi
