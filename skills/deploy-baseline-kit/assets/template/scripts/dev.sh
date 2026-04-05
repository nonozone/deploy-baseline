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
APP_URL="http://127.0.0.1:$APP_PORT"

cat <<EOF
当前本地运行模式：$LOCAL_RUNTIME_MODE
开发服务将以前台方式启动，日志会持续输出。
访问地址：$APP_URL
停止方式：按 Ctrl+C
EOF

if [[ "$LOCAL_RUNTIME_MODE" == "mixed" ]]; then
  cat <<'EOF'

提示：当前模板支持 mixed 模式，但不预设具体本地进程启动方式。
项目接入时可在此脚本中补充本地进程启动命令，或在文档中说明还需手动执行哪些命令。
EOF
fi

exec docker compose \
  -f "$ROOT_DIR/docker-compose.yml" \
  -f "$ROOT_DIR/docker-compose.dev.yml" \
  --env-file "$ROOT_DIR/.env" \
  up --build
