#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${1:-sdd}"
shift || true

if [[ $# -gt 0 ]]; then
  SEARCH_ROOTS=("$@")
else
  SEARCH_ROOTS=(
    "$HOME/.agents/skills"
    "$HOME/.claude/skills"
    "$HOME/.codex/skills"
  )
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

compare_dir() {
  local installed_dir="$1"
  local repo_dir="$2"

  if [[ ! -d "$installed_dir" ]]; then
    fail "installed skill directory not found: $installed_dir"
  fi

  if diff -rq "$repo_dir" "$installed_dir" >/dev/null; then
    echo "OK: $installed_dir matches $repo_dir"
    return 0
  fi

  echo "DIFF: $installed_dir does not match $repo_dir" >&2
  diff -rq "$repo_dir" "$installed_dir" >&2 || true
  return 1
}

REPO_SKILL_DIR="$ROOT_DIR/skills/$SKILL_NAME"
[[ -d "$REPO_SKILL_DIR" ]] || fail "repo skill not found: $REPO_SKILL_DIR"

found_any=0
failed_any=0

for root in "${SEARCH_ROOTS[@]}"; do
  installed_dir="$root/$SKILL_NAME"
  if [[ -e "$installed_dir" ]]; then
    found_any=1
    if ! compare_dir "$installed_dir" "$REPO_SKILL_DIR"; then
      failed_any=1
    fi
  fi
done

if [[ "$found_any" -eq 0 ]]; then
  fail "no installed copy found for $SKILL_NAME in: ${SEARCH_ROOTS[*]}"
fi

if [[ "$failed_any" -ne 0 ]]; then
  exit 1
fi

echo "check-installed-skill.sh: OK"
