#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_RUNTIME_MODE="${LOCAL_RUNTIME_MODE:-docker}"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  echo "缺少 .env，请先执行 make setup。"
  exit 1
fi

if [[ "$LOCAL_RUNTIME_MODE" != "docker" && "$LOCAL_RUNTIME_MODE" != "mixed" ]]; then
  echo "不支持的 LOCAL_RUNTIME_MODE=$LOCAL_RUNTIME_MODE，仅支持 docker 或 mixed。"
  exit 1
fi

echo "当前本地运行模式：$LOCAL_RUNTIME_MODE"

docker compose \
  -f "$ROOT_DIR/docker-compose.yml" \
  -f "$ROOT_DIR/docker-compose.dev.yml" \
  --env-file "$ROOT_DIR/.env" \
  up -d --build

if [[ "$LOCAL_RUNTIME_MODE" == "mixed" ]]; then
  cat <<'EOF'
已启动 Docker 侧服务。

当前模板支持混合开发模式，但不预设具体本地进程启动方式。
项目接入时应补充以下内容之一：

1. 在本脚本中加入本地进程启动命令
2. 增加独立的本地开发脚本并从这里调用
3. 在项目文档中明确说明开发人员还需要手动执行哪些命令
EOF
fi
