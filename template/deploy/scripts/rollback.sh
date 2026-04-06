#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
SERVICE_NAME="${APP_SERVICE:-app}"

source "$ROOT_DIR/deploy/scripts/compose-prod.sh"

if [[ -n "${ROLLBACK_IMAGE:-}" && -n "${ROLLBACK_REF:-}" ]]; then
  echo "请只选择一种回滚方式：ROLLBACK_REF（默认源码回滚）或 ROLLBACK_IMAGE（高级镜像回滚）。"
  exit 1
fi

if [[ -n "${ROLLBACK_REF:-}" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    echo "源码回滚需要 git，请先安装 Git。"
    exit 1
  fi

  if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "当前部署目录不是 Git 仓库，无法执行源码回滚。"
    exit 1
  fi

  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain --untracked-files=no)" ]]; then
    echo "当前工作树存在未提交修改，无法安全执行源码回滚。请先处理本地变更。"
    exit 1
  fi

  git -C "$ROOT_DIR" fetch --tags origin >/dev/null 2>&1 || true
  echo "开始源码回滚：$ROLLBACK_REF"
  git -C "$ROOT_DIR" checkout "$ROLLBACK_REF"
  DEPLOY_MODE=source bash "$ROOT_DIR/deploy/scripts/deploy.sh"
  echo "已切换到源码版本：$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
  echo "如需恢复主线，可执行 git switch main && git pull。"
  exit 0
fi

if [[ -z "${ROLLBACK_IMAGE:-}" ]]; then
  echo "未配置回滚目标。"
  echo "默认源码回滚：ROLLBACK_REF=<git-tag-or-commit> make rollback"
  echo "高级镜像回滚：ROLLBACK_IMAGE=<image:tag> make rollback"
  echo "如果项目包含数据库迁移、副作用任务或静态资源发布，也必须写清回滚边界。"
  exit 1
fi

if [[ "$ROLLBACK_IMAGE" =~ :latest$ ]]; then
  echo "ROLLBACK_IMAGE 不能是 latest。请显式指定可回溯的镜像版本。"
  exit 1
fi

export APP_IMAGE="$ROLLBACK_IMAGE"

echo "开始镜像回滚：$ROLLBACK_IMAGE"
compose_prod pull "$SERVICE_NAME"
compose_prod up -d "$SERVICE_NAME"
wait_for_service_health "$SERVICE_NAME" "${APP_HEALTHCHECK_TIMEOUT:-120}"

echo "已执行镜像回滚命令：$ROLLBACK_IMAGE"
echo "回滚后的健康检查已通过，请继续确认业务版本是否符合预期。"
