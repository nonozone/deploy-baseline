#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"

require_env() {
  local key="$1"
  if ! grep -Eq "^${key}=" "$PROD_ENV_FILE"; then
    echo "缺少必需变量：$key"
    exit 1
  fi
}

reject_placeholder() {
  local pattern="$1"
  local message="$2"
  if grep -Eq "$pattern" "$PROD_ENV_FILE"; then
    echo "$message"
    exit 1
  fi
}

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

require_env "APP_IMAGE"
require_env "APP_PUBLISH_PORT"
require_env "APP_INTERNAL_PORT"
require_env "DB_PASSWORD"

reject_placeholder '^APP_IMAGE=sampleapp:(latest|replace-with-git-sha)$' "APP_IMAGE 仍是模板默认值，请替换为项目实际镜像版本。建议使用 Git Commit SHA 或语义化版本号。"
reject_placeholder '^DB_PASSWORD=change-me(-in-production)?$' "DB_PASSWORD 仍是模板占位值，请替换为真实配置。"

if ! grep -Eq 'healthcheck:' "$ROOT_DIR/docker-compose.prod.yml"; then
  echo "生产 Compose 缺少 healthcheck 配置。"
  exit 1
fi

if ! grep -Eq '请替换为项目实际(生产启动命令|镜像构建逻辑)' "$ROOT_DIR/Dockerfile" "$ROOT_DIR/docker-compose.prod.yml"; then
  :
else
  echo "模板中的生产启动或镜像构建占位逻辑尚未替换。"
  exit 1
fi

echo "部署前检查通过。"
