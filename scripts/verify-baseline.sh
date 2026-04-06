#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/template"
SKILL_DIR="$ROOT_DIR/skills/deploy-baseline-kit"

errors=0
warnings=0

pass()  { printf '  \033[32m✓\033[0m %s\n' "$1"; }
fail()  { printf '  \033[31m✗\033[0m %s\n' "$1" >&2; ((errors++)) || true; }
warn()  { printf '  \033[33m~\033[0m %s\n' "$1"; ((warnings++)) || true; }
header(){ printf '\n\033[1m=== %s ===\033[0m\n' "$1"; }

# ── 1. 模板脚本语法检查 ────────────────────────────────────────────
header "bash -n：模板脚本语法检查"
while IFS= read -r -d '' script; do
  rel="${script#"$TEMPLATE_DIR/"}"
  if bash -n "$script" 2>/dev/null; then
    pass "$rel"
  else
    fail "$rel：语法错误"
  fi
done < <(find "$TEMPLATE_DIR/scripts" "$TEMPLATE_DIR/deploy/scripts" -name "*.sh" -print0 2>/dev/null)

# ── 2. 模板文件完整性 ────────────────────────────────────────────────
header "模板文件完整性检查"
required_template_files=(
  ".env.example"
  "Makefile"
  "Dockerfile"
  "docker-compose.yml"
  "docker-compose.dev.yml"
  "docker-compose.prod.yml"
  "scripts/setup.sh"
  "scripts/dev.sh"
  "scripts/build.sh"
  "scripts/test.sh"
  "scripts/env-sync-local.sh"
  "scripts/pg-check.sh"
  "deploy/env/app.prod.env.example"
  "deploy/scripts/preflight.sh"
  "deploy/scripts/deploy.sh"
  "deploy/scripts/compose-prod.sh"
  "deploy/scripts/status.sh"
  "deploy/scripts/health.sh"
  "deploy/scripts/version.sh"
  "deploy/scripts/pg-check.sh"
  "deploy/scripts/rollback.sh"
  "deploy/scripts/env-sync.sh"
  "deploy/README.md"
  ".github/workflows/ci.yml"
  ".github/workflows/deploy.yml"
)
for f in "${required_template_files[@]}"; do
  if [[ -f "$TEMPLATE_DIR/$f" ]]; then
    pass "$f"
  else
    fail "缺少模板文件：$f"
  fi
done

# ── 3. .env.example 关键 key 完整性 ─────────────────────────────────
header ".env.example 关键变量检查"
required_env_keys=(
  COMPOSE_PROJECT_NAME
  LOCAL_RUNTIME_MODE
  APP_PORT
  APP_INTERNAL_PORT
  APP_IMAGE
  DB_USER
  DB_PASSWORD
  DB_NAME
)
for key in "${required_env_keys[@]}"; do
  if grep -Eq "^${key}=" "$TEMPLATE_DIR/.env.example"; then
    pass "$key"
  else
    fail ".env.example 缺少变量：$key"
  fi
done

# ── 4. Makefile 命令面检查 ───────────────────────────────────────────
header "模板 Makefile 命令面检查"
required_targets=(
  help setup init dev build test deploy rollback logs
  local-env-sync prod-env-sync deploy-check
  up down prod-down prod-logs prod-status prod-health prod-version pg-check prod-pg-check db-up db-down db-shell
)
for target in "${required_targets[@]}"; do
  if grep -Eq "^${target}:" "$TEMPLATE_DIR/Makefile"; then
    pass "make $target"
  else
    fail "缺少 Makefile target：make $target"
  fi
done

# ── 5. dev 启动行为检查 ─────────────────────────────────────────────
header "dev 启动行为检查"
if grep -Fq "up --build" "$TEMPLATE_DIR/scripts/dev.sh"; then
  pass "template/scripts/dev.sh 前台启动 compose"
else
  fail "template/scripts/dev.sh 应使用前台启动（缺少 up --build）"
fi

if grep -Fq "up -d --build" "$TEMPLATE_DIR/scripts/dev.sh"; then
  fail "template/scripts/dev.sh 不应使用后台启动（检测到 up -d --build）"
else
  pass "template/scripts/dev.sh 未使用后台启动"
fi

if grep -Fq "本地访问入口：" "$TEMPLATE_DIR/scripts/dev.sh"; then
  pass "template/scripts/dev.sh 统一输出本地访问入口"
else
  fail "template/scripts/dev.sh 应统一输出本地访问入口"
fi

if grep -Fq "应用首页：" "$TEMPLATE_DIR/scripts/dev.sh" \
  && grep -Fq "健康检查：" "$TEMPLATE_DIR/scripts/dev.sh" \
  && grep -Fq "PostgreSQL：" "$TEMPLATE_DIR/scripts/dev.sh"; then
  pass "template/scripts/dev.sh 输出应用与数据库访问地址"
else
  fail "template/scripts/dev.sh 应输出应用首页、健康检查和 PostgreSQL 入口"
fi

if cmp -s "$TEMPLATE_DIR/scripts/dev.sh" "$SKILL_DIR/assets/template/scripts/dev.sh"; then
  pass "template/scripts/dev.sh 与 skill 资产保持同步"
else
  fail "template/scripts/dev.sh 与 skill 资产不一致"
fi

if cmp -s "$TEMPLATE_DIR/scripts/pg-check.sh" "$SKILL_DIR/assets/template/scripts/pg-check.sh"; then
  pass "template/scripts/pg-check.sh 与 skill 资产保持同步"
else
  fail "template/scripts/pg-check.sh 与 skill 资产不一致"
fi

header "PostgreSQL 18 持久化路径检查"
if grep -Fq 'PGDATA: /var/lib/postgresql/18/docker' "$TEMPLATE_DIR/docker-compose.yml"; then
  pass "docker-compose.yml 使用 PostgreSQL 18 推荐 PGDATA"
else
  fail "docker-compose.yml 应使用 PGDATA=/var/lib/postgresql/18/docker"
fi

if grep -Fq -- '- pgdata:/var/lib/postgresql' "$TEMPLATE_DIR/docker-compose.yml"; then
  pass "docker-compose.yml 挂载 PostgreSQL 18 推荐上层目录"
else
  fail "docker-compose.yml 应挂载 /var/lib/postgresql"
fi

if grep -Fq '/var/lib/postgresql/data' "$TEMPLATE_DIR/docker-compose.yml"; then
  fail "docker-compose.yml 不应继续使用 PostgreSQL 18 旧挂载路径 /var/lib/postgresql/data"
else
  pass "docker-compose.yml 未使用 PostgreSQL 18 旧挂载路径"
fi

if grep -Fq 'PGDATA: /var/lib/postgresql/18/docker' "$TEMPLATE_DIR/docker-compose.prod.yml"; then
  pass "docker-compose.prod.yml 使用 PostgreSQL 18 推荐 PGDATA"
else
  fail "docker-compose.prod.yml 应使用 PGDATA=/var/lib/postgresql/18/docker"
fi

if grep -Fq -- '- pgdata_prod:/var/lib/postgresql' "$TEMPLATE_DIR/docker-compose.prod.yml"; then
  pass "docker-compose.prod.yml 挂载 PostgreSQL 18 推荐上层目录"
else
  fail "docker-compose.prod.yml 应挂载 /var/lib/postgresql"
fi

if grep -Fq '/var/lib/postgresql/data' "$TEMPLATE_DIR/docker-compose.prod.yml"; then
  fail "docker-compose.prod.yml 不应继续使用 PostgreSQL 18 旧挂载路径 /var/lib/postgresql/data"
else
  pass "docker-compose.prod.yml 未使用 PostgreSQL 18 旧挂载路径"
fi

# ── 6. 镜像发布部署契约检查 ─────────────────────────────────────────
header "镜像发布部署契约检查"
if grep -Eq '^[[:space:]]+image:' "$TEMPLATE_DIR/docker-compose.prod.yml"; then
  pass "docker-compose.prod.yml 包含 image 声明"
else
  fail "docker-compose.prod.yml 应包含 image 声明"
fi

if grep -Eq '^[[:space:]]+build:' "$TEMPLATE_DIR/docker-compose.prod.yml"; then
  fail "docker-compose.prod.yml 不应包含生产构建逻辑（检测到 build:）"
else
  pass "docker-compose.prod.yml 未包含生产构建逻辑"
fi

if grep -Fq 'pull "$APP_SERVICE"' "$TEMPLATE_DIR/deploy/scripts/deploy.sh"; then
  pass "deploy.sh 在发布前拉取目标镜像"
else
  fail "deploy.sh 应在发布前拉取目标镜像"
fi

if grep -Fq -- "--build" "$TEMPLATE_DIR/deploy/scripts/deploy.sh"; then
  fail "deploy.sh 不应执行服务器本地构建（检测到 --build）"
else
  pass "deploy.sh 未执行服务器本地构建"
fi

if grep -Fq 'pull "$SERVICE_NAME"' "$TEMPLATE_DIR/deploy/scripts/rollback.sh"; then
  pass "rollback.sh 在回滚前拉取目标镜像"
else
  fail "rollback.sh 应在回滚前拉取目标镜像"
fi

if grep -Fq 'wait_for_service_health "$SERVICE_NAME"' "$TEMPLATE_DIR/deploy/scripts/rollback.sh"; then
  pass "rollback.sh 包含回滚后的健康检查"
else
  fail "rollback.sh 应包含回滚后的健康检查"
fi

if grep -Fq "registry: ghcr.io" "$TEMPLATE_DIR/.github/workflows/deploy.yml"; then
  pass "deploy workflow 默认登录 GHCR"
else
  fail "deploy workflow 应默认登录 GHCR"
fi

if grep -Fq "docker/build-push-action" "$TEMPLATE_DIR/.github/workflows/deploy.yml"; then
  pass "deploy workflow 构建并推送镜像"
else
  fail "deploy workflow 应构建并推送镜像"
fi

if grep -Fq "make prod-health" "$TEMPLATE_DIR/.github/workflows/deploy.yml"; then
  pass "deploy workflow 在远端执行部署后健康检查"
else
  fail "deploy workflow 应在远端执行部署后健康检查"
fi

for rel_path in \
  "docker-compose.prod.yml" \
  "deploy/scripts/compose-prod.sh" \
  "deploy/scripts/preflight.sh" \
  "deploy/scripts/deploy.sh" \
  "deploy/scripts/status.sh" \
  "deploy/scripts/health.sh" \
  "deploy/scripts/version.sh" \
  "deploy/scripts/pg-check.sh" \
  "deploy/scripts/rollback.sh" \
  ".github/workflows/deploy.yml" \
  "deploy/env/app.prod.env.example" \
  "deploy/env/app.env.example"
do
  if cmp -s "$TEMPLATE_DIR/$rel_path" "$SKILL_DIR/assets/template/$rel_path"; then
    pass "$rel_path 与 skill 资产保持同步"
  else
    fail "$rel_path 与 skill 资产不一致"
  fi
done

# ── 7. skill 资产检查 ───────────────────────────────────────────────
header "skill 资产检查"
if [[ -d "$SKILL_DIR" ]]; then
  pass "skills/deploy-baseline-kit 目录存在"
  for skill_file in SKILL.md references assets; do
    if [[ -e "$SKILL_DIR/$skill_file" ]]; then
      pass "$skill_file"
    else
      warn "skills/deploy-baseline-kit/$skill_file 不存在"
    fi
  done
else
  warn "skills/deploy-baseline-kit 目录不存在（skill 资产未同步）"
fi

# ── 8. 本仓库根级脚本语法检查 ────────────────────────────────────────
header "本仓库脚本语法检查"
while IFS= read -r -d '' script; do
  rel="${script#"$ROOT_DIR/"}"
  if bash -n "$script" 2>/dev/null; then
    pass "$rel"
  else
    fail "$rel：语法错误"
  fi
done < <(find "$ROOT_DIR/scripts" -name "*.sh" -print0 2>/dev/null)

# ── 结果汇总 ────────────────────────────────────────────────────────
printf '\n'
if (( errors > 0 )); then
  printf '\033[31m基线验证失败：%d 个错误，%d 个警告。\033[0m\n' "$errors" "$warnings" >&2
  exit 1
else
  printf '\033[32m基线验证通过（%d 个警告）。\033[0m\n' "$warnings"
fi
