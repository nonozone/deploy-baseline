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

health_status="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container_id" 2>/dev/null || true)"

if [[ "$health_status" == "healthy" ]]; then
  echo "应用服务健康检查通过：$APP_SERVICE"
  exit 0
fi

echo "应用服务当前不是 healthy：$APP_SERVICE（状态：${health_status:-unknown}）"
compose_prod logs --tail=100 "$APP_SERVICE" || true
exit 1
