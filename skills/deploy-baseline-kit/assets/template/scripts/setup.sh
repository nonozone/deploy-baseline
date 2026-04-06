#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_FILE="$ROOT_DIR/deploy/env/app.env.example"
DEV_ENV_FILE="$ROOT_DIR/deploy/env/app.dev.env"
LEGACY_ENV_FILE="$ROOT_DIR/.env"

mkdir -p "$(dirname "$DEV_ENV_FILE")"

if [[ ! -f "$DEV_ENV_FILE" ]]; then
  if [[ -f "$LEGACY_ENV_FILE" ]]; then
    cp "$LEGACY_ENV_FILE" "$DEV_ENV_FILE"
    echo "检测到旧 .env，已复制生成 deploy/env/app.dev.env，请确认后继续使用新的开发环境变量路径。"
  else
    cp "$EXAMPLE_FILE" "$DEV_ENV_FILE"
    echo "已根据 deploy/env/app.env.example 生成 deploy/env/app.dev.env，请按项目实际情况修改。"
  fi
else
  echo "deploy/env/app.dev.env 已存在，跳过生成。"
fi

echo "请在 scripts/setup.sh 中补充项目实际初始化逻辑。"
echo "如需 make 命令补全，可执行：source scripts/make-completion.sh"
