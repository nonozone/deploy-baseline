#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist/deploy-baseline-kit"
SOURCE_TEMPLATE_DIR="$ROOT_DIR/src/template"

fail() {
  echo "$1" >&2
  exit 1
}

[[ -d "$DIST_DIR" ]] || fail "缺少打包目录：$DIST_DIR，请先执行 make build-skill。"

required_paths=(
  "SKILL.md"
  "product.md"
  "agents/openai.yaml"
  "references/root-detection.md"
  "scripts/detect-root.sh"
  "assets/template/Makefile"
  "docs/README.md"
  "rules/README.md"
)

for rel_path in "${required_paths[@]}"; do
  [[ -e "$DIST_DIR/$rel_path" ]] || fail "打包目录缺少必要文件：$rel_path"
done

if ! diff -qr "$SOURCE_TEMPLATE_DIR" "$DIST_DIR/assets/template" >/dev/null; then
  fail "打包内模板与 src/template 不一致，请重新执行 make build-skill。"
fi

if ! cmp -s "$ROOT_DIR/skills/deploy-baseline-kit/SKILL.md" "$DIST_DIR/SKILL.md"; then
  fail "打包内 SKILL.md 与源文件不一致。"
fi

if ! cmp -s "$ROOT_DIR/skills/deploy-baseline-kit/product.md" "$DIST_DIR/product.md"; then
  fail "打包内 product.md 与源文件不一致。"
fi

if ! diff -qr "$ROOT_DIR/src/rules/references" "$DIST_DIR/references" >/dev/null; then
  fail "打包内 references 与 src/rules/references 不一致。"
fi

echo "skill 打包验证通过。"
