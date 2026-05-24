#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: install-sdd-subagents.sh [codex|claude-code|all] [--scope user|project] [--project-dir DIR] [--force]

Defaults:
  target: all
  scope: user

Behavior:
  - Reads version from each source file's header (`version: YYYY-MM-DD`).
  - Skips files when target version is newer than source (unless --force).
  - Writes/updates `.sdd-agents-manifest` in the runtime directory.

Examples:
  bash scripts/install-sdd-subagents.sh all
  bash scripts/install-sdd-subagents.sh claude-code --scope project --project-dir /path/to/repo
  bash scripts/install-sdd-subagents.sh all --force
EOF
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

TARGET="all"
SCOPE="user"
PROJECT_DIR="$(pwd)"
FORCE=false

if [[ $# -gt 0 && "$1" != --* ]]; then
  TARGET="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope)        SCOPE="${2:-}"; shift 2 ;;
    --project-dir)  PROJECT_DIR="${2:-}"; shift 2 ;;
    --force)        FORCE=true; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              fail "unknown argument: $1" ;;
  esac
done

extract_version() {
  local file="$1"
  # Matches `version: "YYYY-MM-DD"` (Claude .md frontmatter) or `# version: YYYY-MM-DD` (Codex .toml header)
  awk '
    /^version: / { gsub(/"/, "", $2); print $2; exit }
    /^# version: / { print $3; exit }
  ' "$file"
}

version_gt() {
  # ISO date string compare — newer date sorts later
  [[ "$1" > "$2" ]]
}

install_one() {
  local src="$1"
  local dst_dir="$2"
  local filename
  filename="$(basename "$src")"
  local dst="$dst_dir/$filename"

  local src_ver
  src_ver="$(extract_version "$src")"
  [[ -n "$src_ver" ]] || fail "missing version in $src"

  if [[ -f "$dst" ]]; then
    local dst_ver
    dst_ver="$(extract_version "$dst")"
    if [[ -n "$dst_ver" ]] && version_gt "$dst_ver" "$src_ver"; then
      if [[ "$FORCE" == true ]]; then
        echo "WARN: forcing downgrade $filename ($dst_ver -> $src_ver)" >&2
      else
        echo "SKIP: $filename — target newer ($dst_ver > $src_ver), use --force to override" >&2
        echo "$dst_ver"
        return 0
      fi
    fi
  fi

  cp "$src" "$dst"
  echo "OK:   $filename ($src_ver) -> $dst_dir/" >&2
  echo "$src_ver"
}

write_manifest() {
  local dst_dir="$1"
  shift
  local manifest="$dst_dir/.sdd-agents-manifest"

  local entries=()
  while [[ $# -gt 0 ]]; do
    entries+=("\"$1\": \"$2\"")
    shift 2
  done

  {
    echo "{"
    local i=0
    local total=${#entries[@]}
    for entry in "${entries[@]}"; do
      i=$((i + 1))
      if [[ $i -lt $total ]]; then
        echo "  $entry,"
      else
        echo "  $entry"
      fi
    done
    echo "}"
  } > "$manifest"

  echo "MANIFEST: $manifest updated"
}

install_target() {
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

  mkdir -p "$dst_dir"

  local manifest_args=()
  for src in "$src_dir"/*."$extension"; do
    [[ -f "$src" ]] || continue
    local agent_name
    agent_name="$(basename "$src" ".$extension")"
    local installed_ver
    installed_ver="$(install_one "$src" "$dst_dir" | tail -n 1)"
    manifest_args+=("$agent_name" "$installed_ver")
  done

  write_manifest "$dst_dir" "${manifest_args[@]}"
}

case "$TARGET" in
  all)         install_target codex; install_target claude-code ;;
  codex)       install_target codex ;;
  claude-code) install_target claude-code ;;
  *)           fail "unknown target: $TARGET" ;;
esac
