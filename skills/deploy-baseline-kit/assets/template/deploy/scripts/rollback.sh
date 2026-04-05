#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
SERVICE_NAME="${APP_SERVICE:-app}"

source "$ROOT_DIR/deploy/scripts/compose-prod.sh"

if [[ -z "${ROLLBACK_IMAGE:-}" ]]; then
  echo "未配置 ROLLBACK_IMAGE。"
  echo "项目接入时必须把真实回滚策略补充到 deploy/scripts/rollback.sh。"
  echo "建议至少支持按镜像标签回滚，并在部署文档中写清验证步骤。"
  echo "建议使用 Git Commit SHA 或语义化版本号作为镜像 tag，不建议使用 latest。"
  echo "如果项目包含数据库迁移、副作用任务或静态资源发布，也必须写清回滚边界。"
  exit 1
fi

if [[ "$ROLLBACK_IMAGE" =~ :latest$ ]]; then
  echo "ROLLBACK_IMAGE 不能是 latest。请显式指定可回溯的镜像版本。"
  exit 1
fi

export APP_IMAGE="$ROLLBACK_IMAGE"

echo "开始回滚镜像：$ROLLBACK_IMAGE"
compose_prod pull "$SERVICE_NAME"
compose_prod up -d "$SERVICE_NAME"
wait_for_service_health "$SERVICE_NAME" "${APP_HEALTHCHECK_TIMEOUT:-120}"

echo "已执行回滚命令：$ROLLBACK_IMAGE"
echo "回滚后的健康检查已通过，请继续确认业务版本是否符合预期。"
