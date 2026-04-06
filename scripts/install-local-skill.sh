#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist/deploy-baseline-kit"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
TARGET_DIR="$CODEX_HOME_DIR/skills/deploy-baseline-kit"

if [[ ! -d "$DIST_DIR" ]]; then
  bash "$ROOT_DIR/scripts/build-skill.sh"
fi

mkdir -p "$(dirname "$TARGET_DIR")"
rm -rf "$TARGET_DIR"
cp -R "$DIST_DIR" "$TARGET_DIR"

echo "已安装本地 skill：$TARGET_DIR"
