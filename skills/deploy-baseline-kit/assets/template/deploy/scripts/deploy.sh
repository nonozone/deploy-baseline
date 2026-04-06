#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
APP_SERVICE="${APP_SERVICE:-app}"

source "$ROOT_DIR/deploy/scripts/compose-prod.sh"
bash "$ROOT_DIR/deploy/scripts/preflight.sh"

set -a
# shellcheck disable=SC1090
source "$PROD_ENV_FILE"
set +a

DEPLOY_MODE="${DEPLOY_MODE:-source}"
TARGET_IMAGE="${DEPLOY_IMAGE:-${APP_IMAGE:-}}"

# 项目接入时可在这里追加前置动作，例如：
# 1. 数据库迁移
# 2. 静态资源上传
# 3. 缓存预热
# 4. 网关刷新
# 建议把这些动作拆成独立脚本，再由 deploy.sh 顺序调用。

if [[ "$DEPLOY_MODE" == "image" ]]; then
  export APP_IMAGE="$TARGET_IMAGE"
  echo "开始镜像部署：$TARGET_IMAGE"
  compose_prod pull "$APP_SERVICE"
else
  echo "开始源码部署：将基于当前代码执行 docker compose build"
  compose_prod build "$APP_SERVICE"
fi

compose_prod up -d "$APP_SERVICE"
wait_for_service_health "$APP_SERVICE" "${APP_HEALTHCHECK_TIMEOUT:-120}"
echo "发布完成判定通过。建议继续执行日志确认或业务验收。"
