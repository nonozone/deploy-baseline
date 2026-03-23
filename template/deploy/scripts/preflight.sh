#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"

if ! command -v docker >/dev/null 2>&1; then
  echo "未检测到 docker，请先安装 Docker。"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "未检测到 docker compose，请先安装 Compose 插件。"
  exit 1
fi

for file in \
  "$ROOT_DIR/docker-compose.prod.yml" \
  "$ROOT_DIR/deploy/scripts/deploy.sh" \
  "$ROOT_DIR/deploy/scripts/rollback.sh"
do
  if [[ ! -f "$file" ]]; then
    echo "缺少必需文件：$file"
    exit 1
  fi
done

if [[ ! -f "$PROD_ENV_FILE" ]]; then
  echo "缺少生产环境文件：$PROD_ENV_FILE"
  echo "可先复制 deploy/env/app.prod.env.example 为 deploy/env/app.prod.env 再继续。"
  exit 1
fi

echo "部署前检查通过。"
