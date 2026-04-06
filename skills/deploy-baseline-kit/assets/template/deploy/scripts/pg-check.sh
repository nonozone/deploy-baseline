#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"
DB_SERVICE="${DB_SERVICE:-db}"

source "$ROOT_DIR/deploy/scripts/compose-prod.sh"

if [[ ! -f "$PROD_ENV_FILE" ]]; then
  echo "缺少生产环境变量文件：$PROD_ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$PROD_ENV_FILE"
set +a

container_id="$(compose_prod ps -q "$DB_SERVICE")"
if [[ -z "$container_id" ]]; then
  echo "未找到生产数据库容器：$DB_SERVICE"
  echo "请先执行 make prod-status 或确认数据库服务已启动。"
  exit 1
fi

runtime_image="$(docker inspect --format '{{.Config.Image}}' "$container_id" 2>/dev/null || true)"
pgdata_env="$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$container_id" 2>/dev/null | awk -F= '$1=="PGDATA"{print $2; exit}')"
mounts="$(docker inspect --format '{{range .Mounts}}{{println .Destination " <= " .Name}}{{end}}' "$container_id" 2>/dev/null || true)"
data_directory="$(docker exec "$container_id" sh -lc 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atc "SELECT current_setting('\''data_directory'\'');"' 2>/dev/null || true)"

echo "生产 PostgreSQL 检查："
echo "- 容器：$container_id"
echo "- 镜像：${runtime_image:-unknown}"
echo "- PGDATA：${pgdata_env:-unknown}"
echo "- 当前挂载："
if [[ -n "$mounts" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && echo "  - $line"
  done <<< "$mounts"
else
  echo "  - 未解析到挂载信息"
fi

if [[ -n "$data_directory" ]]; then
  echo "- PostgreSQL data_directory：$data_directory"
else
  echo "- PostgreSQL data_directory：未解析（容器未就绪或 psql 不可用）"
fi

if [[ "$runtime_image" == postgres:18* ]]; then
  if grep -Fq '/var/lib/postgresql <= ' <<< "$mounts" && [[ "${pgdata_env:-}" == "/var/lib/postgresql/18/docker" ]]; then
    echo "结论：PostgreSQL 18 持久化路径配置正常。"
    exit 0
  fi
  echo "结论：检测到 PostgreSQL 18，但挂载或 PGDATA 不是推荐组合。"
  echo "建议：命名卷挂到 /var/lib/postgresql，并使用 PGDATA=/var/lib/postgresql/18/docker。"
  exit 1
fi

if grep -Fq '/var/lib/postgresql/data <= ' <<< "$mounts"; then
  echo "结论：当前更像 PostgreSQL 17 及以下的传统挂载方式。"
else
  echo "结论：未检测到标准旧路径挂载，请按项目实际情况确认。"
fi
