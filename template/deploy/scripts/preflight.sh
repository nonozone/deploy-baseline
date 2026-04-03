#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROD_ENV_FILE="$ROOT_DIR/deploy/env/app.prod.env"

require_env() {
  local key="$1"
  if ! grep -Eq "^${key}=" "$PROD_ENV_FILE"; then
    echo "缺少必需变量：$key"
    exit 1
  fi
}

reject_placeholder() {
  local pattern="$1"
  local message="$2"
  if grep -Eq "$pattern" "$PROD_ENV_FILE"; then
    echo "$message"
    exit 1
  fi
}

if ! command -v docker >/dev/null 2>&1; then
  echo "未检测到 docker，请先安装 Docker。"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "未检测到 docker compose，请先安装 Compose 插件。"
  exit 1
fi

for file in \
  "$ROOT_DIR/docker-compose.prod.yml" \
  "$ROOT_DIR/deploy/scripts/deploy.sh" \
  "$ROOT_DIR/deploy/scripts/rollback.sh"
do
  if [[ ! -f "$file" ]]; then
    echo "缺少必需文件：$file"
    exit 1
  fi
done

if [[ ! -f "$PROD_ENV_FILE" ]]; then
  echo "缺少生产环境文件：$PROD_ENV_FILE"
  echo "可先复制 deploy/env/app.prod.env.example 为 deploy/env/app.prod.env 再继续。"
  exit 1
fi

missing_example_keys=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  key="${line%%=*}"
  if ! grep -Eq "^${key}=" "$PROD_ENV_FILE"; then
    missing_example_keys+=("$key")
  fi
done < <(grep -E '^[A-Z0-9_]+=' "$ROOT_DIR/deploy/env/app.prod.env.example" || true)

if [[ ${#missing_example_keys[@]} -gt 0 ]]; then
  printf 'app.prod.env 缺少示例中的变量：%s\n' "$(IFS=,; echo "${missing_example_keys[*]}")"
  echo "请先执行 make prod-env-sync，再确认新增变量是否需要按真实环境填写。"
  exit 1
fi

# 本地 .env 与 .env.example 同步检查（警告级，不阻断部署）
LOCAL_ENV_FILE="$ROOT_DIR/.env"
LOCAL_ENV_EXAMPLE="$ROOT_DIR/.env.example"
if [[ -f "$LOCAL_ENV_EXAMPLE" ]]; then
  missing_local_keys=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    key="${line%%=*}"
    if [[ -f "$LOCAL_ENV_FILE" ]]; then
      if ! grep -Eq "^${key}=" "$LOCAL_ENV_FILE"; then
        missing_local_keys+=("$key")
      fi
    fi
  done < <(grep -E '^[A-Z0-9_]+=' "$LOCAL_ENV_EXAMPLE" || true)
  if [[ ${#missing_local_keys[@]} -gt 0 ]]; then
    printf '[warning] .env 缺少 .env.example 中的变量（建议执行 make local-env-sync）：%s\n' \
      "$(IFS=,; echo "${missing_local_keys[*]}")"
  elif [[ ! -f "$LOCAL_ENV_FILE" ]]; then
    echo "[warning] 未找到 .env 文件，建议先执行 make setup。"
  fi
fi

require_env "APP_IMAGE"
require_env "APP_PUBLISH_PORT"
require_env "APP_INTERNAL_PORT"
require_env "DB_PASSWORD"

reject_placeholder '^APP_IMAGE=sampleapp:(latest|replace-with-git-sha)$' "APP_IMAGE 仍是模板默认值，请替换为项目实际镜像版本。建议使用 Git Commit SHA 或语义化版本号。"
reject_placeholder '^DB_PASSWORD=(replace-me|change-me(-in-production)?)$' "DB_PASSWORD 仍是模板占位值，请替换为真实配置。"

if ! grep -Eq 'healthcheck:' "$ROOT_DIR/docker-compose.prod.yml"; then
  echo "生产 Compose 缺少 healthcheck 配置。"
  exit 1
fi

if ! grep -Eq '请替换为项目实际(生产启动命令|镜像构建逻辑)' "$ROOT_DIR/Dockerfile" "$ROOT_DIR/docker-compose.prod.yml"; then
  :
else
  echo "模板中的生产启动或镜像构建占位逻辑尚未替换。"
  exit 1
fi

echo "部署前检查通过。"
