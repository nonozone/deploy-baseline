#!/usr/bin/env bash
set -euo pipefail

start_dir="${1:-$PWD}"
if [[ ! -d "$start_dir" ]]; then
  echo "detect-root: not a directory: $start_dir" >&2
  exit 1
fi

score_dir() {
  local dir="$1"
  local score=0

  [[ -d "$dir/.git" ]] && score=$((score + 5))
  [[ -f "$dir/package.json" ]] && score=$((score + 4))
  [[ -f "$dir/pyproject.toml" ]] && score=$((score + 4))
  [[ -f "$dir/go.mod" ]] && score=$((score + 4))
  [[ -f "$dir/Cargo.toml" ]] && score=$((score + 4))
  [[ -f "$dir/Dockerfile" ]] && score=$((score + 3))
  [[ -f "$dir/Makefile" ]] && score=$((score + 3))
  [[ -f "$dir/README.md" ]] && score=$((score + 2))
  [[ -f "$dir/docker-compose.yml" ]] && score=$((score + 4))
  [[ -d "$dir/deploy" ]] && score=$((score + 2))
  [[ -d "$dir/scripts" ]] && score=$((score + 1))

  printf '%s\n' "$score"
}

best_dir=""
best_score=-1
current="$(cd "$start_dir" && pwd)"

while :; do
  score="$(score_dir "$current")"
  if (( score > best_score )); then
    best_score="$score"
    best_dir="$current"
  fi

  if [[ "$current" == "/" ]]; then
    break
  fi
  current="$(dirname "$current")"
done

if (( best_score <= 0 )); then
  echo "$(cd "$start_dir" && pwd)"
  exit 0
fi

echo "$best_dir"
