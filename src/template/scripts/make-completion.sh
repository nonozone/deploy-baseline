#!/usr/bin/env bash

_baseline_make_targets() {
  local makefile="${1:-Makefile}"
  [[ -f "$makefile" ]] || return 0
  awk 'BEGIN {FS=":.*## " } /^[a-zA-Z0-9_-]+:.*## / { print $1 }' "$makefile"
}

if [[ -n "${BASH_VERSION:-}" ]]; then
  _baseline_make_complete_bash() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local targets
    targets="$(_baseline_make_targets)"
    COMPREPLY=( $(compgen -W "$targets" -- "$cur") )
  }

  complete -o default -F _baseline_make_complete_bash make
fi

if [[ -n "${ZSH_VERSION:-}" ]]; then
  _baseline_make_complete_zsh() {
    local -a targets
    targets=("${(@f)$(_baseline_make_targets)}")
    _describe 'make target' targets
  }

  if command -v compdef >/dev/null 2>&1; then
    compdef _baseline_make_complete_zsh make
  fi
fi
