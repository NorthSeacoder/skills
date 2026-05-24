#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$SKILL_DIR/agents/source"
CLAUDE_DIR="$SKILL_DIR/agents/claude-code"
CODEX_DIR="$SKILL_DIR/agents/codex"

CHECK_MODE=false
if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=true
fi

command -v yq >/dev/null 2>&1 || {
  echo "ERROR: yq is required but not installed. Install with: brew install yq" >&2
  exit 1
}

map_model_to_codex() {
  local model="$1"
  case "$model" in
    haiku)  echo "gpt-5.4-mini" ;;
    sonnet) echo "gpt-5.5" ;;
    opus)   echo "gpt-5.5" ;;
    *)      echo "$model" ;;
  esac
}

map_model_to_effort() {
  local model="$1"
  case "$model" in
    haiku)  echo "medium" ;;
    sonnet) echo "high" ;;
    opus)   echo "high" ;;
    *)      echo "medium" ;;
  esac
}

map_permission_to_sandbox() {
  local perm="$1"
  case "$perm" in
    plan)      echo "read-only" ;;
    bypassAll) echo "full" ;;
    *)         echo "read-only" ;;
  esac
}

generate_claude_code() {
  local src="$1"
  local name version description model tools perm prompt
  name="$(yq '.name' "$src")"
  version="$(yq '.version' "$src")"
  description="$(yq '.description' "$src")"
  model="$(yq '.model' "$src")"
  tools="$(yq '.tools.claude-code | join(", ")' "$src")"
  perm="$(yq '.permission_mode' "$src")"
  prompt="$(yq '.prompt' "$src")"

  local outfile="$CLAUDE_DIR/${name}.md"
  local content
  content="$(cat <<EOF
---
name: ${name}
description: ${description}
tools: ${tools}
model: ${model}
permissionMode: ${perm}
version: "${version}"
generated: true
---

<!-- AUTO-GENERATED from source/${name}.yaml — DO NOT EDIT -->

${prompt}
EOF
)"

  if [[ "$CHECK_MODE" == true ]]; then
    if [[ -f "$outfile" ]] && diff -q <(echo "$content") "$outfile" >/dev/null 2>&1; then
      return 0
    else
      echo "DRIFT: $outfile differs from source" >&2
      return 1
    fi
  fi

  echo "$content" > "$outfile"
}

generate_codex() {
  local src="$1"
  local name version description model perm prompt
  name="$(yq '.name' "$src")"
  version="$(yq '.version' "$src")"
  description="$(yq '.description' "$src")"
  model="$(yq '.model' "$src")"
  perm="$(yq '.permission_mode' "$src")"
  prompt="$(yq '.prompt' "$src")"

  local codex_name="${name//-/_}"
  local codex_model
  codex_model="$(map_model_to_codex "$model")"
  local effort
  effort="$(map_model_to_effort "$model")"
  local sandbox
  sandbox="$(map_permission_to_sandbox "$perm")"

  local outfile="$CODEX_DIR/${name}.toml"
  local content
  content="$(cat <<EOF
# AUTO-GENERATED from source/${name}.yaml — DO NOT EDIT
# version: ${version}
name = "${codex_name}"
description = "${description}"
model = "${codex_model}"
model_reasoning_effort = "${effort}"
sandbox_mode = "${sandbox}"

developer_instructions = """
${prompt}"""
EOF
)"

  if [[ "$CHECK_MODE" == true ]]; then
    if [[ -f "$outfile" ]] && diff -q <(echo "$content") "$outfile" >/dev/null 2>&1; then
      return 0
    else
      echo "DRIFT: $outfile differs from source" >&2
      return 1
    fi
  fi

  echo "$content" > "$outfile"
}

mkdir -p "$CLAUDE_DIR" "$CODEX_DIR"

failed=0
for src in "$SOURCE_DIR"/*.yaml; do
  [[ -f "$src" ]] || continue
  generate_claude_code "$src" || failed=1
  generate_codex "$src" || failed=1
done

if [[ "$CHECK_MODE" == true ]]; then
  if [[ "$failed" -eq 0 ]]; then
    echo "generate-agents: all derived files match source"
  else
    echo "generate-agents: drift detected (run without --check to regenerate)" >&2
    exit 1
  fi
else
  echo "generate-agents: done"
fi
