#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_TEMPLATE_DIR="$ROOT_DIR/src/template"
LEGACY_TEMPLATE_DIR="$ROOT_DIR/template"
SKILL_TEMPLATE_DIR="$ROOT_DIR/skills/deploy-baseline-kit/assets/template"

if [[ ! -d "$SOURCE_TEMPLATE_DIR" ]]; then
  echo "缺少模板真源目录：$SOURCE_TEMPLATE_DIR"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "缺少 rsync，无法安全刷新兼容模板目录。"
  exit 1
fi

sync_tree() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "$target_dir"
  rsync -a --delete "$source_dir"/ "$target_dir"/
}

sync_tree "$SOURCE_TEMPLATE_DIR" "$LEGACY_TEMPLATE_DIR"
sync_tree "$SOURCE_TEMPLATE_DIR" "$SKILL_TEMPLATE_DIR"

echo "已根据 src/template 刷新兼容模板目录："
echo "- template/"
echo "- skills/deploy-baseline-kit/assets/template/"
