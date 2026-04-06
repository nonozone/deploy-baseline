#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_FILE="$ROOT_DIR/deploy/env/app.env.example"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  cp "$EXAMPLE_FILE" "$ROOT_DIR/.env"
  echo "已根据 deploy/env/app.env.example 生成 .env，请按项目实际情况修改。"
else
  echo ".env 已存在，跳过生成。"
fi

echo "请在 scripts/setup.sh 中补充项目实际初始化逻辑。"
echo "如需 make 命令补全，可执行：source scripts/make-completion.sh"
