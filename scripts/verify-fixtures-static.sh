#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURES_DIR="$ROOT_DIR/fixtures"

required_fields=(
  name
  scenario
  expected_root
  expected_classification
  expected_mode
  expected_database
  expected_project_commands
  expected_unit_commands
  expected_command_recommendation
  support_level
  expected_recommendation
  verification_level
  notes
)

expected_fixtures=(
  empty-project
  lightweight-existing
  heavy-existing-deploy
  frontend-backend-split
  monorepo-subproject
  mysql-compare
)

allowed_verification_levels=(
  static
)

actual_fixtures=()
while IFS= read -r -d '' dir; do
  fixture_name="$(basename "$dir")"
  if [[ "$fixture_name" == "runnable" ]]; then
    continue
  fi
  actual_fixtures+=("$fixture_name")
done < <(find "$FIXTURES_DIR" -maxdepth 1 -mindepth 1 -type d -print0)

if [[ ${#actual_fixtures[@]} -ne ${#expected_fixtures[@]} ]]; then
  echo "fixture directory count mismatch under $FIXTURES_DIR" >&2
  echo "expected ${#expected_fixtures[@]} fixtures but found ${#actual_fixtures[@]}" >&2
  exit 1
fi

expected_sorted="$(printf '%s\n' "${expected_fixtures[@]}" | sort)"
actual_sorted="$(printf '%s\n' "${actual_fixtures[@]}" | sort)"
if [[ "$expected_sorted" != "$actual_sorted" ]]; then
  echo "fixture directory mismatch under $FIXTURES_DIR" >&2
  echo "expected directories:" >&2
  printf '  %s\n' "${expected_fixtures[@]}" >&2
  echo "found directories:" >&2
  printf '  %s\n' "${actual_fixtures[@]}" >&2
  exit 1
fi

for fixture in "${expected_fixtures[@]}"; do
  file="$FIXTURES_DIR/$fixture/fixture.md"
  if [[ ! -f "$file" ]]; then
    echo "missing fixture metadata: $file" >&2
    exit 1
  fi

  raw_keys="$(rg -o '^- [^:]+:' "$file" 2>/dev/null || true)"
  actual_keys=()
  if [[ -n "$raw_keys" ]]; then
    while IFS= read -r line; do
      line="${line#- }"
      line="${line%:}"
      actual_keys+=("$line")
    done <<< "$raw_keys"
  fi

  if [[ ${#actual_keys[@]} -ne ${#required_fields[@]} ]]; then
    echo "fixture metadata key count mismatch in $file: expected ${#required_fields[@]}, got ${#actual_keys[@]}" >&2
    exit 1
  fi

  for idx in "${!required_fields[@]}"; do
    if [[ "${actual_keys[idx]}" != "${required_fields[idx]}" ]]; then
      echo "fixture metadata order mismatch in $file: expected '${required_fields[idx]}' at position $((idx + 1)), got '${actual_keys[idx]}'" >&2
      exit 1
    fi
  done

  layout_files=()
  case "$fixture" in
    lightweight-existing)
      layout_files=(".env.example" "app/main.sh")
      ;;
    heavy-existing-deploy)
      layout_files=("Makefile" "docker-compose.yml" "docker-compose.prod.yml" "deploy/README.md")
      ;;
    frontend-backend-split)
      layout_files=("backend/package.json" "frontend/package.json")
      ;;
    monorepo-subproject)
      layout_files=("package.json" "apps/api/package.json" "apps/web/package.json" "packages/shared/README.md")
      ;;
    mysql-compare)
      layout_files=("docker-compose.yml")
      ;;
  esac

  for rel_path in "${layout_files[@]:-}"; do
    if [[ ! -e "$FIXTURES_DIR/$fixture/$rel_path" ]]; then
      echo "missing layout file '$rel_path' in $fixture" >&2
      exit 1
    fi
  done

  case "$fixture" in
    heavy-existing-deploy)
      rg -q '^help:' "$FIXTURES_DIR/$fixture/Makefile" || {
        echo "expected help target in $fixture/Makefile" >&2
        exit 1
      }
      rg -q '^deploy:' "$FIXTURES_DIR/$fixture/Makefile" || {
        echo "expected deploy target in $fixture/Makefile" >&2
        exit 1
      }
      ;;
    frontend-backend-split)
      rg -q '"build"\s*:' "$FIXTURES_DIR/$fixture/backend/package.json" || {
        echo "expected backend build script in $fixture" >&2
        exit 1
      }
      rg -q '"test"\s*:' "$FIXTURES_DIR/$fixture/backend/package.json" || {
        echo "expected backend test script in $fixture" >&2
        exit 1
      }
      rg -q '"dev"\s*:' "$FIXTURES_DIR/$fixture/frontend/package.json" || {
        echo "expected frontend dev script in $fixture" >&2
        exit 1
      }
      ;;
    monorepo-subproject)
      rg -q '"workspaces"\s*:' "$FIXTURES_DIR/$fixture/package.json" || {
        echo "expected workspaces in $fixture/package.json" >&2
        exit 1
      }
      rg -q '"build"\s*:' "$FIXTURES_DIR/$fixture/package.json" || {
        echo "expected root build script in $fixture/package.json" >&2
        exit 1
      }
      rg -q '"test"\s*:' "$FIXTURES_DIR/$fixture/package.json" || {
        echo "expected root test script in $fixture/package.json" >&2
        exit 1
      }
      rg -q '"build"\s*:' "$FIXTURES_DIR/$fixture/apps/api/package.json" || {
        echo "expected api build script in $fixture" >&2
        exit 1
      }
      rg -q '"test"\s*:' "$FIXTURES_DIR/$fixture/apps/api/package.json" || {
        echo "expected api test script in $fixture" >&2
        exit 1
      }
      if rg -q '"dev"\s*:' "$FIXTURES_DIR/$fixture/apps/api/package.json"; then
        echo "api fixture should intentionally omit dev script in $fixture" >&2
        exit 1
      fi
      rg -q '"dev"\s*:' "$FIXTURES_DIR/$fixture/apps/web/package.json" || {
        echo "expected web dev script in $fixture" >&2
        exit 1
      }
      ;;
  esac

  verification_line="$(rg -m1 '^- verification_level: ' "$file" 2>/dev/null || true)"
  verification_value=""
  if [[ -n "$verification_line" ]]; then
    verification_value="${verification_line#- verification_level: }"
  fi
  if [[ -z "$verification_value" ]]; then
    echo "missing verification_level value in $file" >&2
    exit 1
  fi

  allowed=false
  for allowed_value in "${allowed_verification_levels[@]}"; do
    if [[ "$verification_value" == "$allowed_value" ]]; then
      allowed=true
      break
    fi
  done
  if [[ "$allowed" != true ]]; then
    echo "unexpected verification_level '$verification_value' in $file" >&2
    exit 1
  fi
done

echo "static fixture metadata verification passed"
