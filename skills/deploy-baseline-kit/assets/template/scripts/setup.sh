#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$ROOT_DIR/.env" ]]; then
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "已生成 .env，请按项目实际情况修改。"
else
  echo ".env 已存在，跳过生成。"
fi

echo "请在 scripts/setup.sh 中补充项目实际初始化逻辑。"
