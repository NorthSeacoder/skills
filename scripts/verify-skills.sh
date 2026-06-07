#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file: $path"
}

require_grep() {
  local pattern="$1"
  local path="$2"
  if ! grep -Eq "$pattern" "$path"; then
    fail "pattern not found in $path: $pattern"
  fi
}

echo "Verifying public skill entrypoints..."
require_file "README.md"
require_file "skills/sdd/SKILL.md"
require_grep '^## 当前公开 skill$' "README.md"
require_grep '^\- `sdd`：' "README.md"

echo "Verifying private skill declarations..."
require_file "skills/debug/SKILL.md"
require_file "skills/git-guard/SKILL.md"
require_file "skills/knowledge-management/SKILL.md"
require_grep '^## 当前自用 skill$' "README.md"
require_grep '^\- `knowledge-management`$' "README.md"
require_grep '^\- `debug`$' "README.md"
require_grep '^\- `git-guard`$' "README.md"
require_grep '^\- `content-orchestrator-agent`$' "README.md"
require_file "skills/content-orchestrator-agent/SKILL.md"
require_file "skills/content-orchestrator-agent/agents/openai.yaml"

echo "Verifying SDD stage assets..."
for path in \
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

echo "Verifying SDD templates..."
for path in \
  skills/sdd/templates/spec-template.md \
  skills/sdd/templates/plan-template.md \
  skills/sdd/templates/tasks-template.md \
  skills/sdd/templates/checklist-template.md \
  skills/sdd/templates/data-model-template.md
do
  require_file "$path"
done

echo "Verifying SDD subagent assets..."
for path in \
  skills/sdd/agents/source/sdd-explorer.yaml \
  skills/sdd/agents/source/sdd-reviewer.yaml \
  skills/sdd/agents/source/sdd-docs-researcher.yaml \
  skills/sdd/agents/codex/sdd-explorer.toml \
  skills/sdd/agents/codex/sdd-reviewer.toml \
  skills/sdd/agents/codex/sdd-docs-researcher.toml \
  skills/sdd/agents/claude-code/sdd-explorer.md \
  skills/sdd/agents/claude-code/sdd-reviewer.md \
  skills/sdd/agents/claude-code/sdd-docs-researcher.md \
  skills/sdd/scripts/validate-sdd.sh \
  skills/sdd/scripts/generate-agents.sh \
  skills/sdd/scripts/install-sdd-subagents.sh \
  skills/sdd/scripts/check-installed-sdd-subagents.sh
do
  require_file "$path"
done

echo "Verifying derived agents match source (drift check)..."
if command -v yq >/dev/null 2>&1; then
  bash skills/sdd/scripts/generate-agents.sh --check || fail "derived agents drift from source — run: bash skills/sdd/scripts/generate-agents.sh"
else
  echo "WARN: yq not installed, skipping generate-agents drift check" >&2
fi

echo "Verifying SDD routing and artifact rules..."
require_grep 'specs/\.active' "skills/sdd/SKILL.md"
require_grep '`sdd` 只负责软件交付流程' "skills/sdd/SKILL.md"
require_grep 'sdd_explorer' "skills/sdd/SKILL.md"
require_grep 'install-sdd-subagents\.sh' "skills/sdd/SKILL.md"
require_grep 'references/stages/verify\.md' "skills/sdd/SKILL.md"
require_grep 'references/stages/closeout\.md' "skills/sdd/SKILL.md"
require_grep 'Clarify / Domain Alignment' "skills/sdd/SKILL.md"
require_grep '## 回退条件' "skills/sdd/references/stages/plan.md"
require_grep '## 阶段完成标准' "skills/sdd/references/stages/tasks.md"
require_grep '## Stage Readiness' "skills/sdd/templates/spec-template.md"
require_grep 'Artifact Rule' "skills/sdd/templates/plan-template.md"
require_grep '^# Verify Stage$' "skills/sdd/references/stages/verify.md"
require_grep '^# Closeout Stage$' "skills/sdd/references/stages/closeout.md"

echo "Running SDD structural validator..."
bash skills/sdd/scripts/validate-sdd.sh

echo "Verifying workflow wiring..."
require_file ".github/workflows/verify.yml"
require_file "scripts/check-installed-skill.sh"
require_grep 'bash \./scripts/verify-skills\.sh' ".github/workflows/verify.yml"

echo "verify-skills.sh: OK"
