#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: check-installed-sdd-subagents.sh [codex|claude-code|all] [--scope user|project] [--project-dir DIR]

Checks installed subagent versions against source definitions.
Uses .sdd-agents-manifest when available; falls back to file header parsing.

Exit codes:
  0 — all agents up-to-date
  1 — one or more agents stale, missing, or manifest absent

Defaults:
  target: all
  scope: user
EOF
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

TARGET="all"
SCOPE="user"
PROJECT_DIR="$(pwd)"

if [[ $# -gt 0 && "$1" != --* ]]; then
  TARGET="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)        SCOPE="${2:-}"; shift 2 ;;
    --project-dir)  PROJECT_DIR="${2:-}"; shift 2 ;;
    -h|--help)      usage; exit 0 ;;
    *)              fail "unknown argument: $1" ;;
  esac
done

extract_version() {
  local file="$1"
  awk '
    /^version: / { gsub(/"/, "", $2); print $2; exit }
    /^# version: / { print $3; exit }
  ' "$file"
}

check_platform() {
  local platform="$1"
  local src_subdir extension dst_dir
  case "$platform" in
    claude-code)
      src_subdir="claude-code"
      extension="md"
      if [[ "$SCOPE" == "project" ]]; then
        dst_dir="$PROJECT_DIR/.claude/agents"
      else
        dst_dir="$HOME/.claude/agents"
      fi
      ;;
    codex)
      src_subdir="codex"
      extension="toml"
      if [[ "$SCOPE" == "project" ]]; then
        dst_dir="$PROJECT_DIR/.codex/agents"
      else
        dst_dir="$HOME/.codex/agents"
      fi
      ;;
    *)
      fail "unknown platform: $platform"
      ;;
  esac

  local src_dir="$SKILL_DIR/agents/$src_subdir"
  [[ -d "$src_dir" ]] || fail "missing source directory: $src_dir"

  local manifest="$dst_dir/.sdd-agents-manifest"
  local failed=0

  if [[ ! -d "$dst_dir" ]]; then
    echo "MISSING: $dst_dir does not exist" >&2
    return 1
  fi

  for src in "$src_dir"/*."$extension"; do
    [[ -f "$src" ]] || continue
    local agent_name filename src_ver installed_ver
    filename="$(basename "$src")"
    agent_name="$(basename "$src" ".$extension")"
    src_ver="$(extract_version "$src")"

    if [[ -f "$manifest" ]]; then
      installed_ver="$(grep -o "\"$agent_name\": \"[^\"]*\"" "$manifest" | cut -d'"' -f4 || true)"
    else
      local dst="$dst_dir/$filename"
      if [[ -f "$dst" ]]; then
        installed_ver="$(extract_version "$dst")"
      else
        installed_ver=""
      fi
    fi

    if [[ -z "$installed_ver" ]]; then
      echo "MISSING: $agent_name not installed in $dst_dir" >&2
      failed=1
    elif [[ "$installed_ver" == "$src_ver" ]]; then
      echo "OK: $agent_name ($installed_ver)"
    elif [[ "$installed_ver" > "$src_ver" ]]; then
      echo "OK: $agent_name ($installed_ver, ahead of source $src_ver)"
    else
      echo "STALE: $agent_name installed=$installed_ver source=$src_ver" >&2
      failed=1
    fi
  done

  if [[ ! -f "$manifest" ]]; then
    echo "WARN: manifest not found at $manifest (using file headers)" >&2
  fi

  return $failed
}

overall=0

case "$TARGET" in
  all)
    check_platform codex || overall=1
    check_platform claude-code || overall=1
    ;;
  codex)       check_platform codex || overall=1 ;;
  claude-code) check_platform claude-code || overall=1 ;;
  *)           fail "unknown target: $TARGET" ;;
esac

if [[ "$overall" -eq 0 ]]; then
  echo "check-installed-sdd-subagents.sh: OK"
else
  echo "check-installed-sdd-subagents.sh: ISSUES FOUND" >&2
  exit 1
fi
