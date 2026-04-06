#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_FILE="$ROOT_DIR/deploy/env/app.env.example"
TARGET_FILE="$ROOT_DIR/.env"

if [[ ! -f "$EXAMPLE_FILE" ]]; then
  echo "缺少示例文件：$EXAMPLE_FILE"
  exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
  cp "$EXAMPLE_FILE" "$TARGET_FILE"
  echo "已生成 $TARGET_FILE"
  exit 0
fi

tmp_file="$(mktemp)"
state_dir="$(mktemp -d)"
inserted_any=false
declare -A example_group_files=()
declare -A existing_keys=()
declare -A seen_groups=()
missing_keys=()
example_groups=()

cleanup() {
  rm -f "$tmp_file"
  rm -rf "$state_dir"
}

trap cleanup EXIT

is_group_header() {
  [[ "$1" =~ ^#[[:space:]][^=]+$ ]]
}

register_group() {
  local group="$1"
  if [[ -n "${example_group_files[$group]:-}" ]]; then
    return
  fi
  local file="$state_dir/group_${#example_groups[@]}.txt"
  : > "$file"
  example_groups+=("$group")
  example_group_files["$group"]="$file"
}

ensure_group_separator() {
  if [[ ! -s "$tmp_file" ]]; then
    return 0
  fi
  if [[ -n "$(tail -n 1 "$tmp_file")" ]]; then
    printf '\n' >> "$tmp_file"
  fi
  return 0
}

insert_missing_for_group() {
  local group="$1"
  local group_file="${example_group_files[$group]:-}"
  local added_in_group=false

  [[ -n "$group_file" ]] || return

  while IFS= read -r example_line || [[ -n "$example_line" ]]; do
    [[ -z "$example_line" ]] && continue
    local key="${example_line%%=*}"
    if [[ -n "${existing_keys[$key]:-}" ]]; then
      continue
    fi

    printf '%s\n' "$example_line" >> "$tmp_file"
    existing_keys["$key"]=1
    missing_keys+=("$key")
    inserted_any=true
    added_in_group=true
  done < "$group_file"

  if [[ "$added_in_group" == true ]]; then
    printf '\n' >> "$tmp_file"
  fi
}

current_group=""
while IFS= read -r line || [[ -n "$line" ]]; do
  if is_group_header "$line"; then
    current_group="$line"
    register_group "$current_group"
    continue
  fi

  if [[ "$line" =~ ^[A-Z0-9_]+= ]]; then
    if [[ -z "$current_group" ]]; then
      current_group="# added by env-sync-local from deploy/env/app.env.example"
      register_group "$current_group"
    fi
    printf '%s\n' "$line" >> "${example_group_files[$current_group]}"
    continue
  fi
done < "$EXAMPLE_FILE"

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^[A-Z0-9_]+= ]]; then
    existing_keys["${line%%=*}"]=1
  fi
done < "$TARGET_FILE"

current_group=""
group_buffer="$state_dir/current-group.txt"
: > "$group_buffer"

flush_current_group() {
  local group="$1"
  if [[ -z "$group" ]]; then
    return 0
  fi
  cat "$group_buffer" >> "$tmp_file"
  insert_missing_for_group "$group"
  : > "$group_buffer"
  return 0
}

while IFS= read -r line || [[ -n "$line" ]]; do
  if is_group_header "$line" && [[ -n "${example_group_files[$line]:-}" ]]; then
    flush_current_group "$current_group"
    current_group="$line"
    seen_groups["$line"]=1
    printf '%s\n' "$line" >> "$group_buffer"
    continue
  fi

  if [[ -n "$current_group" ]]; then
    printf '%s\n' "$line" >> "$group_buffer"
  else
    printf '%s\n' "$line" >> "$tmp_file"
  fi
done < "$TARGET_FILE"

flush_current_group "$current_group"

for example_group in "${example_groups[@]}"; do
  if [[ -n "${seen_groups[$example_group]:-}" ]]; then
    continue
  fi
  group_file="${example_group_files[$example_group]}"
  has_missing=false
  while IFS= read -r example_line || [[ -n "$example_line" ]]; do
    [[ -z "$example_line" ]] && continue
    key="${example_line%%=*}"
    if [[ -z "${existing_keys[$key]:-}" ]]; then
      has_missing=true
      break
    fi
  done < "$group_file"
  if [[ "$has_missing" == true ]]; then
    ensure_group_separator
    printf '%s\n' "$example_group" >> "$tmp_file"
    insert_missing_for_group "$example_group"
  fi
done

if [[ "$inserted_any" == false ]]; then
  echo ".env 已与 deploy/env/app.env.example 对齐，无需追加。"
  exit 0
fi

mv "$tmp_file" "$TARGET_FILE"
printf '已根据 deploy/env/app.env.example 向 .env 按分组补齐缺失变量：%s\n' "$(IFS=,; echo "${missing_keys[*]}")"
