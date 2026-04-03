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
  "deploy/env/app.prod.env.example"
  "deploy/scripts/preflight.sh"
  "deploy/scripts/deploy.sh"
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
  up down prod-down prod-logs db-up db-down db-shell
)
for target in "${required_targets[@]}"; do
  if grep -Eq "^${target}:" "$TEMPLATE_DIR/Makefile"; then
    pass "make $target"
  else
    fail "缺少 Makefile target：make $target"
  fi
done

# ── 5. skill 资产检查 ───────────────────────────────────────────────
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

# ── 6. 本仓库根级脚本语法检查 ────────────────────────────────────────
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
