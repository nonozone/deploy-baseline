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

for fixture in "${expected_fixtures[@]}"; do
  file="$FIXTURES_DIR/$fixture/fixture.md"
  if [[ ! -f "$file" ]]; then
    echo "missing fixture metadata: $file" >&2
    exit 1
  fi

  mapfile -t actual_keys < <(
    { rg -o '^- [^:]+:' "$file" || true; } | sed 's/^- \(.*\):$/\1/'
  )

  if [[ ${#actual_keys[@]} -ne ${#required_fields[@]} ]]; then
    echo "fixture metadata key count mismatch in $file: expected ${#required_fields[@]}, got ${#actual_keys[@]}" >&2
    exit 1
  fi

  for idx in "${!required_fields[@]}"; do
    if [[ "${actual_keys[idx]}" != "${required_fields[idx]}" ]]; then
      echo "fixture metadata order mismatch in $file: expected '${required_fields[idx]}' at line $((idx + 1)), got '${actual_keys[idx]}'" >&2
      exit 1
    fi
  done
done

echo "static fixture metadata verification passed"
