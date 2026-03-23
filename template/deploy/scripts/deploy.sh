#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"

bash "$ROOT_DIR/deploy/scripts/preflight.sh"

# 项目接入时可在这里追加前置动作，例如：
# 1. 数据库迁移
# 2. 静态资源上传
# 3. 缓存预热
# 4. 网关刷新
# 建议把这些动作拆成独立脚本，再由 deploy.sh 顺序调用。

docker compose \
  -f "$ROOT_DIR/docker-compose.prod.yml" \
  --env-file "$PROD_ENV_FILE" \
  up -d --build

echo "部署命令已执行。项目接入时请补充发布完成判定步骤，例如健康检查或日志确认。"
