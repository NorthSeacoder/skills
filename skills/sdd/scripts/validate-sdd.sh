#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

MODE="default"

usage() {
  echo "usage: bash skills/sdd/scripts/validate-sdd.sh [--closeout-ready]" >&2
}

for arg in "$@"; do
  case "$arg" in
    --closeout-ready)
      MODE="closeout-ready"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage
      echo "FAIL: unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

strip_code_ticks() {
  local value
  value="$(trim "$1")"
  value="${value#\`}"
  value="${value%\`}"
  printf '%s' "$value"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_grep() {
  local pattern="$1"
  local path="$2"
  if ! grep -Eq -- "$pattern" "$path"; then
    fail "pattern not found in $path: $pattern"
  fi
}

metadata_value() {
  local label="$1"
  local path="$2"
  local line value
  line="$(grep -E "^\\*\\*$label\\*\\*:" "$path" | head -n 1 || true)"
  value="${line#**$label**:}"
  strip_code_ticks "$value"
}

section_has_text() {
  local path="$1"
  local section="$2"
  local text="$3"
  awk -v section="## $section" -v text="$text" '
    $0 == section { in_section = 1; next }
    in_section && /^## / { in_section = 0 }
    in_section && index($0, text) > 0 { found = 1 }
    END { exit found ? 0 : 1 }
  ' "$path"
}

section_has_non_placeholder_text() {
  local path="$1"
  local section="$2"
  awk -v section="## $section" '
    $0 == section { in_section = 1; next }
    in_section && /^## / { in_section = 0 }
    in_section {
      line = $0
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      if (line != "" && line !~ /^---$/ && line !~ /^\[/) {
        found = 1
      }
    }
    END { exit found ? 0 : 1 }
  ' "$path"
}

is_url() {
  [[ "$1" =~ ^https?:// ]]
}

is_local_context_source() {
  local source="$1"
  [[ -z "$source" ]] && return 1
  is_url "$source" && return 1
  [[ "$source" == *"["* ]] && return 1
  [[ "$source" == *"*"* ]] && return 1
  return 0
}

parse_active_feature() {
  require_file "specs/.active"
  ACTIVE_FEATURE="$(tr -d '\r' < "specs/.active" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | head -n 1)"
  [[ -n "$ACTIVE_FEATURE" ]] || fail "specs/.active: active feature is empty"
  ACTIVE_DIR="specs/$ACTIVE_FEATURE"
  [[ -d "$ACTIVE_DIR" ]] || fail "$ACTIVE_DIR: missing active feature directory"
}

check_roadmap_consistency() {
  local roadmap status current row_matches
  local -a current_matches=()

  shopt -s nullglob
  for roadmap in specs/*/roadmap.md; do
    status="$(metadata_value "Status" "$roadmap")"
    current="$(metadata_value "Current Feature" "$roadmap")"

    if [[ "$status" == "completed" && "$current" == "none" ]]; then
      continue
    fi

    row_matches=1
    if grep -Eq "^\\| \`$ACTIVE_FEATURE\` \\|" "$roadmap"; then
      row_matches=0
    fi

    if [[ "$current" == "$ACTIVE_FEATURE" ]]; then
      current_matches+=("$roadmap")
    elif [[ "$row_matches" -eq 0 && "$status" == "active" && -n "$current" && "$current" != "none" ]]; then
      fail "$roadmap: roadmap current mismatch: Current Feature is '$current', specs/.active is '$ACTIVE_FEATURE'"
    fi
  done
  shopt -u nullglob

  if (( ${#current_matches[@]} > 1 )); then
    fail "multiple roadmap candidates for active feature '$ACTIVE_FEATURE': ${current_matches[*]}"
  fi
}

check_context_manifest() {
  local manifest="$ACTIVE_DIR/context-manifest.md"
  local status line source reason phase required
  [[ -f "$manifest" ]] || return 0

  status="$(metadata_value "Status" "$manifest")"
  if [[ "$status" == "skipped" ]]; then
    section_has_non_placeholder_text "$manifest" "Skip Reason" || fail "$manifest: skipped manifest requires Skip Reason"
    return 0
  fi

  while IFS= read -r line; do
    [[ "$line" == \|* ]] || continue
    [[ "$line" == *"---"* ]] && continue
    [[ "$line" == *"File / Source"* ]] && continue

    IFS='|' read -r _ source reason phase required _ <<< "$line"
    source="$(strip_code_ticks "$source")"
    reason="$(trim "$reason")"
    phase="$(trim "$phase")"
    required="$(trim "$required")"

    [[ -n "$source" ]] || continue
    [[ -n "$reason" ]] || fail "$manifest: context entry missing reason for $source"
    [[ "$reason" != \[* ]] || fail "$manifest: context entry has placeholder reason for $source"

    if [[ "$required" == "yes" ]] && is_local_context_source "$source"; then
      [[ -e "$source" ]] || fail "$manifest: required context file missing: $source"
    fi
  done < "$manifest"

  section_has_text "$manifest" "Check Context" "$ACTIVE_DIR/spec.md" || fail "$manifest: Check Context missing spec.md"
  section_has_text "$manifest" "Check Context" "$ACTIVE_DIR/plan.md" || fail "$manifest: Check Context missing plan.md"
  section_has_text "$manifest" "Check Context" "$ACTIVE_DIR/tasks.md" || fail "$manifest: Check Context missing tasks.md"
}

check_closeout_ready() {
  local tasks="$ACTIVE_DIR/tasks.md"
  local evidence="$ACTIVE_DIR/verify-evidence.md"
  local acceptance="$ACTIVE_DIR/acceptance.md"

  require_file "$tasks"
  if grep -Eq '^- \[ \]' "$tasks"; then
    fail "$tasks: tasks incomplete"
  fi

  [[ -f "$evidence" ]] || fail "$evidence: missing fresh evidence"
  [[ -f "$acceptance" ]] || fail "$acceptance: missing acceptance record"

  require_grep '^## Evidence Table' "$acceptance"
  require_grep '^## Verdict Summary' "$acceptance"
  require_grep '^## Closeout Checklist' "$acceptance"
  require_grep '^## Completion Record' "$acceptance"
  require_grep 'Overall' "$acceptance"
}

echo "validate-sdd: checking required stage assets..."
for path in \
  skills/sdd/references/continuation-routing.md \
  skills/sdd/references/status-model.md \
  skills/sdd/references/stages/ideate.md \
  skills/sdd/references/stages/specify.md \
  skills/sdd/references/stages/clarify.md \
  skills/sdd/references/stages/plan.md \
  skills/sdd/references/stages/tasks.md \
  skills/sdd/references/stages/execute-plan.md \
  skills/sdd/references/stages/implement.md \
  skills/sdd/references/stages/code-review.md \
  skills/sdd/references/stages/verify.md \
  skills/sdd/references/stages/closeout.md
do
  require_file "$path"
done

echo "validate-sdd: checking top-level routing semantics..."
require_grep 'Clarify / Domain Alignment' "skills/sdd/SKILL.md"
require_grep 'references/stages/verify\.md' "skills/sdd/SKILL.md"
require_grep 'references/stages/closeout\.md' "skills/sdd/SKILL.md"
require_grep '`code-review` 不再是主链终点' "skills/sdd/SKILL.md"
require_grep '没有 fresh evidence，不应宣布 feature 已完成' "skills/sdd/SKILL.md"
require_grep 'references/continuation-routing\.md' "skills/sdd/SKILL.md"
require_grep 'references/status-model\.md' "skills/sdd/SKILL.md"
require_grep 'resume / continue' "skills/sdd/SKILL.md"

echo "validate-sdd: checking stage intent..."
require_grep '^# Clarify / Domain Alignment Stage$' "skills/sdd/references/stages/clarify.md"
require_grep 'continuation-routing\.md' "skills/sdd/references/stages/ideate.md"
require_grep 'checkpoint' "skills/sdd/references/stages/execute-plan.md"
require_grep '进入 `verify`' "skills/sdd/references/stages/implement.md"
require_grep '^# Verify Stage$' "skills/sdd/references/stages/verify.md"
require_grep 'validate-sdd\.sh' "skills/sdd/references/stages/verify.md"
require_grep '^# Closeout Stage$' "skills/sdd/references/stages/closeout.md"
require_grep 'Closeout Checklist' "skills/sdd/references/stages/closeout.md"
require_grep '--closeout-ready' "skills/sdd/references/stages/closeout.md"
require_grep '^# Code Review Check$' "skills/sdd/references/stages/code-review.md"
require_grep '作为 `Verify` 阶段内的一个检查动作' "skills/sdd/references/stages/code-review.md"

echo "validate-sdd: checking template and workspace references..."
require_grep 'specs/\.active' "skills/sdd/SKILL.md"
require_grep 'specs/<feature>/acceptance\.md' "skills/sdd/SKILL.md"
require_grep '验证路径' "skills/sdd/references/stages/plan.md"

echo "validate-sdd: checking continuation routing..."
require_grep 'specs/\.active' "skills/sdd/references/continuation-routing.md"
require_grep 'status-model\.md' "skills/sdd/references/continuation-routing.md"
require_grep 'roadmap mismatch' "skills/sdd/references/continuation-routing.md"
require_grep 'fresh evidence' "skills/sdd/references/continuation-routing.md"
require_grep 'acceptance\.md' "skills/sdd/references/continuation-routing.md"
require_grep 'closeout' "skills/sdd/references/continuation-routing.md"
require_grep 'resume' "skills/sdd/references/continuation-routing.md"
require_grep 'continue' "skills/sdd/references/continuation-routing.md"

echo "validate-sdd: checking status model..."
require_grep 'Validation Modes' "skills/sdd/references/status-model.md"
require_grep 'closeout-ready' "skills/sdd/references/status-model.md"
require_grep 'multiple roadmap candidates' "skills/sdd/references/status-model.md"
require_grep 'Current Feature: none' "skills/sdd/references/status-model.md"
require_grep 'context-manifest\.md' "skills/sdd/references/status-model.md"

echo "validate-sdd: checking workspace status..."
parse_active_feature
check_roadmap_consistency
check_context_manifest

if [[ "$MODE" == "closeout-ready" ]]; then
  echo "validate-sdd: checking closeout readiness..."
  check_closeout_ready
fi

echo "validate-sdd: OK"
