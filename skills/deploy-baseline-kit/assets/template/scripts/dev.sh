#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_RUNTIME_MODE="${LOCAL_RUNTIME_MODE:-docker}"

read_env_value() {
  local key="$1"

  awk -F= -v lookup_key="$key" '
    $0 ~ "^[[:space:]]*#" { next }
    $1 == lookup_key {
      sub(/^[^=]+=/, "", $0)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
      gsub(/^["'\''"]|["'\''"]$/, "", $0)
      print $0
      exit
    }
  ' "$ROOT_DIR/.env"
}

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "缺少 .env，请先执行 make setup。"
  exit 1
fi

if [[ "$LOCAL_RUNTIME_MODE" != "docker" && "$LOCAL_RUNTIME_MODE" != "mixed" ]]; then
  echo "不支持的 LOCAL_RUNTIME_MODE=$LOCAL_RUNTIME_MODE，仅支持 docker 或 mixed。"
  exit 1
fi

APP_PORT="${APP_PORT:-$(read_env_value APP_PORT)}"
APP_PORT="${APP_PORT:-8000}"
APP_HEALTHCHECK_PATH="${APP_HEALTHCHECK_PATH:-$(read_env_value APP_HEALTHCHECK_PATH)}"
APP_HEALTHCHECK_PATH="${APP_HEALTHCHECK_PATH:-/health}"
DB_PORT="${DB_PORT:-$(read_env_value DB_PORT)}"
DB_PORT="${DB_PORT:-5432}"
DB_USER="${DB_USER:-$(read_env_value DB_USER)}"
DB_USER="${DB_USER:-sampleapp}"
DB_NAME="${DB_NAME:-$(read_env_value DB_NAME)}"
DB_NAME="${DB_NAME:-sampleapp}"
APP_URL="http://127.0.0.1:$APP_PORT"
APP_HEALTH_URL="${APP_URL}${APP_HEALTHCHECK_PATH}"
DB_URL="postgresql://${DB_USER}@127.0.0.1:${DB_PORT}/${DB_NAME}"

cat <<EOF
当前本地运行模式：$LOCAL_RUNTIME_MODE
开发服务将以前台方式启动，日志会持续输出。
停止方式：按 Ctrl+C
EOF

if [[ "$LOCAL_RUNTIME_MODE" == "mixed" ]]; then
  cat <<'EOF'

提示：当前模板支持 mixed 模式，但不预设具体本地进程启动方式。
项目接入时可在此脚本中补充本地进程启动命令，或在文档中说明还需手动执行哪些命令。
EOF
fi

cat <<EOF

本地访问入口：
- 应用首页：$APP_URL
- 健康检查：$APP_HEALTH_URL
- PostgreSQL：$DB_URL
EOF

exec docker compose \
  -f "$ROOT_DIR/docker-compose.yml" \
  -f "$ROOT_DIR/docker-compose.dev.yml" \
  --env-file "$ROOT_DIR/.env" \
  up --build
