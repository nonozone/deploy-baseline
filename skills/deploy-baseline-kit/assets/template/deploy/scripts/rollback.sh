#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
SERVICE_NAME="${APP_SERVICE:-app}"

if [[ -z "${ROLLBACK_IMAGE:-}" ]]; then
  echo "未配置 ROLLBACK_IMAGE。"
  echo "项目接入时必须把真实回滚策略补充到 deploy/scripts/rollback.sh。"
  echo "建议至少支持按镜像标签回滚，并在部署文档中写清验证步骤。"
  echo "如果项目包含数据库迁移、副作用任务或静态资源发布，也必须写清回滚边界。"
  exit 1
fi

export APP_IMAGE="$ROLLBACK_IMAGE"

docker compose \
  -f "$ROOT_DIR/docker-compose.prod.yml" \
  --env-file "$PROD_ENV_FILE" \
  up -d "$SERVICE_NAME"

echo "已执行回滚命令。项目接入时请补充回滚后健康检查与版本确认步骤。"
