#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_SKILL_DIR="$ROOT_DIR/skills/deploy-baseline-kit"
SOURCE_TEMPLATE_DIR="$ROOT_DIR/src/template"
SOURCE_DOCS_DIR="$ROOT_DIR/src/docs"
SOURCE_RULES_DIR="$ROOT_DIR/src/rules"
DIST_DIR="$ROOT_DIR/dist/deploy-baseline-kit"

bash "$ROOT_DIR/scripts/sync-template-compat.sh"
bash "$ROOT_DIR/scripts/sync-rule-compat.sh"

if [[ ! -d "$SOURCE_SKILL_DIR" ]]; then
  echo "缺少 skill 源目录：$SOURCE_SKILL_DIR"
  exit 1
fi

if [[ ! -d "$SOURCE_TEMPLATE_DIR" ]]; then
  echo "缺少模板真源目录：$SOURCE_TEMPLATE_DIR"
  exit 1
fi

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR/assets"

cp "$SOURCE_SKILL_DIR/SKILL.md" "$DIST_DIR/SKILL.md"
cp "$SOURCE_SKILL_DIR/product.md" "$DIST_DIR/product.md"

if [[ -d "$SOURCE_SKILL_DIR/agents" ]]; then
  cp -R "$SOURCE_SKILL_DIR/agents" "$DIST_DIR/agents"
fi

if [[ -d "$SOURCE_SKILL_DIR/scripts" ]]; then
  cp -R "$SOURCE_SKILL_DIR/scripts" "$DIST_DIR/scripts"
fi

if [[ -d "$SOURCE_RULES_DIR/references" ]]; then
  cp -R "$SOURCE_RULES_DIR/references" "$DIST_DIR/references"
fi

cp -R "$SOURCE_TEMPLATE_DIR" "$DIST_DIR/assets/template"
cp -R "$SOURCE_DOCS_DIR" "$DIST_DIR/docs"
cp -R "$SOURCE_RULES_DIR" "$DIST_DIR/rules"

echo "已生成自包含 skill 包：$DIST_DIR"
