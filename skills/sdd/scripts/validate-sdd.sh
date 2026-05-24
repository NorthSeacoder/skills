#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
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

echo "validate-sdd: checking required stage assets..."
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

echo "validate-sdd: checking top-level routing semantics..."
require_grep 'Clarify / Domain Alignment' "skills/sdd/SKILL.md"
require_grep 'references/stages/verify\.md' "skills/sdd/SKILL.md"
require_grep 'references/stages/closeout\.md' "skills/sdd/SKILL.md"
require_grep '`code-review` 不再是主链终点' "skills/sdd/SKILL.md"
require_grep '没有 fresh evidence，不应宣布 feature 已完成' "skills/sdd/SKILL.md"

echo "validate-sdd: checking stage intent..."
require_grep '^# Clarify / Domain Alignment Stage$' "skills/sdd/references/stages/clarify.md"
require_grep 'checkpoint' "skills/sdd/references/stages/execute-plan.md"
require_grep '进入 `verify`' "skills/sdd/references/stages/implement.md"
require_grep '^# Verify Stage$' "skills/sdd/references/stages/verify.md"
require_grep '^# Closeout Stage$' "skills/sdd/references/stages/closeout.md"
require_grep 'Closeout Checklist' "skills/sdd/references/stages/closeout.md"
require_grep '^# Code Review Check$' "skills/sdd/references/stages/code-review.md"
require_grep '作为 `Verify` 阶段内的一个检查动作' "skills/sdd/references/stages/code-review.md"

echo "validate-sdd: checking template and workspace references..."
require_grep 'specs/\.active' "skills/sdd/SKILL.md"
require_grep 'specs/<feature>/acceptance\.md' "skills/sdd/SKILL.md"
require_grep '验证路径' "skills/sdd/references/stages/plan.md"

echo "validate-sdd: OK"
