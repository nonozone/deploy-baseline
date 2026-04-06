#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_ROOT="$ROOT_DIR/dist"
DIST_DIR="$DIST_ROOT/deploy-baseline-kit"
PACKAGE_DIR="$DIST_ROOT/packages"
PACKAGE_PATH="$PACKAGE_DIR/deploy-baseline-kit.tar.gz"

bash "$ROOT_DIR/scripts/build-skill.sh"

mkdir -p "$PACKAGE_DIR"
rm -f "$PACKAGE_PATH"
tar -czf "$PACKAGE_PATH" -C "$DIST_ROOT" deploy-baseline-kit

echo "已生成打包产物：$PACKAGE_PATH"
