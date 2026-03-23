#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
APP_SERVICE="${APP_SERVICE:-app}"

bash "$ROOT_DIR/deploy/scripts/preflight.sh"

set -a
# shellcheck disable=SC1090
source "$PROD_ENV_FILE"
set +a

HEALTHCHECK_TIMEOUT="${APP_HEALTHCHECK_TIMEOUT:-120}"
HEALTHCHECK_INTERVAL=5

# 项目接入时可在这里追加前置动作，例如：
# 1. 数据库迁移
# 2. 静态资源上传
# 3. 缓存预热
# 4. 网关刷新
# 建议把这些动作拆成独立脚本，再由 deploy.sh 顺序调用。

docker compose \
  -f "$ROOT_DIR/docker-compose.prod.yml" \
  --env-file "$PROD_ENV_FILE" \
  up -d --build

container_id="$(docker compose -f "$ROOT_DIR/docker-compose.prod.yml" --env-file "$PROD_ENV_FILE" ps -q "$APP_SERVICE")"
if [[ -z "$container_id" ]]; then
  echo "未找到应用容器：$APP_SERVICE"
  exit 1
fi

deadline=$((SECONDS + HEALTHCHECK_TIMEOUT))
while (( SECONDS < deadline )); do
  health_status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container_id" 2>/dev/null || true)"
  if [[ "$health_status" == "healthy" ]]; then
    echo "应用服务已通过健康检查：$APP_SERVICE"
    echo "发布完成判定通过。建议继续执行日志确认或业务验收。"
    exit 0
  fi
  if [[ "$health_status" == "unhealthy" ]]; then
    echo "应用服务健康检查失败：$APP_SERVICE"
    docker compose -f "$ROOT_DIR/docker-compose.prod.yml" --env-file "$PROD_ENV_FILE" logs --tail=100 "$APP_SERVICE" || true
    exit 1
  fi
  sleep "$HEALTHCHECK_INTERVAL"
done

echo "等待应用服务健康检查超时：$APP_SERVICE"
docker compose -f "$ROOT_DIR/docker-compose.prod.yml" --env-file "$PROD_ENV_FILE" logs --tail=100 "$APP_SERVICE" || true
exit 1
