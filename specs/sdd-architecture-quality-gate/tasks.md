# Tasks: SDD Architecture Quality Gate

**Workspace**: `sdd-architecture-quality-gate` | **Date**: 2026-05-25 | **Plan**: [plan.md](plan.md)

---

## Task List

### Phase 1 - Reference Asset

- [x] **T1** Add `skills/sdd/references/architecture-quality-gate.md`
  - Covers architecture questions, quality attributes, reference pattern policy, lightweight ADR, anti-pattern checks.
  - Verification: file links to external sources and does not copy long external content.

### Phase 2 - Stage Rules

- [x] **T2** Update `clarify.md`
  - Add architecture pre-plan questions and skip conditions for small changes.
  - Verification: clarify remains focused on blocking ambiguity, not broad consulting.

- [x] **T3** Update `plan.md`
  - Add reference pattern lookup, adaptation check, maturity-stage check and source citation requirements.
  - Verification: plan still requires code reality and spec alignment before design.

- [x] **T4** Update `tasks.md`
  - Require tasks to map to user stories, architecture decisions or quality attributes when relevant.
  - Verification: no task schema bloat for small changes.

- [x] **T5** Update `verify.md`
  - Add architecture drift checks and fresh evidence requirements for quality attributes.
  - Verification: verify can return to plan when implementation violates ADR.

- [x] **T6** Update `closeout.md`
  - Add ADR retention, architecture debt and evolution trigger checks.
  - Verification: closeout remains a final gate, not a new planning phase.

### Phase 3 - Templates

- [x] **T7** Update `spec-template.md`
  - Add quality attribute table under Non-Functional Requirements.
  - Verification: functional requirements and user scenarios remain primary.

- [x] **T8** Update `plan-template.md`
  - Add architecture reference, capacity notes, lightweight ADR, evolution path and anti-pattern check.
  - Verification: all external references have URL/source fields.

- [x] **T9** Update `tasks-template.md`
  - Add optional mapping to architecture decision / quality attribute.
  - Verification: template remains executable and concise.

### Phase 4 - Validation

- [x] **T10** Run repository validation
  - Commands: `bash ./scripts/check-installed-skill.sh sdd` and any existing structural validator.
  - Verification: `skills/sdd/scripts/validate-sdd.sh` passed; `check-installed-skill.sh sdd` reported installed runtime copies are stale, which is separate from repo correctness.

---

## Execution Notes

- Do not edit generated subagent files under `skills/sdd/agents/claude-code/` or `skills/sdd/agents/codex/`.
- Do not overwrite unrelated existing user changes in `skills/sdd/SKILL.md`.
- Keep external architecture content as cited references, not vendored tutorial text.
