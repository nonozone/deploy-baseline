#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_RULE_REFERENCES_DIR="$ROOT_DIR/src/rules/references"
SKILL_REFERENCES_DIR="$ROOT_DIR/skills/deploy-baseline-kit/references"

if [[ ! -d "$SOURCE_RULE_REFERENCES_DIR" ]]; then
  echo "缺少规则真源目录：$SOURCE_RULE_REFERENCES_DIR"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "缺少 rsync，无法安全刷新 skill references。"
  exit 1
fi

mkdir -p "$SKILL_REFERENCES_DIR"
rsync -a --delete "$SOURCE_RULE_REFERENCES_DIR"/ "$SKILL_REFERENCES_DIR"/

echo "已根据 src/rules/references 刷新 skill references/"
