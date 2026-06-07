# Verify Evidence: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator` | **Date**: 2026-06-07
**Scope**: T001-T016

---

## Implementation Scope

| Area | Files | Evidence |
|---|---|---|
| Status model reference | `skills/sdd/references/status-model.md` | Defines state sources, inference order, roadmap consistency, manifest rules, default mode and closeout-ready mode |
| Routing alignment | `skills/sdd/SKILL.md`, `skills/sdd/references/continuation-routing.md` | Both reference `status-model.md` without duplicating full rules |
| Verify / closeout guidance | `skills/sdd/references/stages/verify.md`, `skills/sdd/references/stages/closeout.md` | Verify mentions default validator; closeout mentions `--closeout-ready` |
| Validator implementation | `skills/sdd/scripts/validate-sdd.sh` | Adds mode parsing, active feature checks, roadmap checks, manifest checks and strict closeout readiness checks |
| SDD workspace evidence | `specs/sdd-status-model-and-validator/*` | `spec.md`, `plan.md`, `data-model.md`, `tasks.md`, `context-manifest.md`, this evidence file |

---

## Command Evidence

| Check | Command | Result | Notes |
|---|---|---|---|
| Shell syntax | `bash -n skills/sdd/scripts/validate-sdd.sh` | PASS | No syntax errors |
| Default validator | `bash skills/sdd/scripts/validate-sdd.sh` | PASS | Current active feature and roadmap state are valid |
| Strict mode before closeout | `bash skills/sdd/scripts/validate-sdd.sh --closeout-ready` | EXPECTED FAIL | Failed on `tasks incomplete` before closeout tasks were completed |
| Strict mode after closeout | `bash skills/sdd/scripts/validate-sdd.sh --closeout-ready` | PASS | Tasks are complete, fresh evidence exists and acceptance has required sections |
| Status references | `rg -n "status-model|--closeout-ready|multiple roadmap candidates|Current Feature: none|context-manifest" ...` | PASS | Entry, continuation, status model, stage guidance and validator are linked |
| Boundary scan | `rg -n "\\.trellis|Trellis CLI|task\\.py|JSONL|hook 自动|git push|自动提交" skills/sdd specs/sdd-status-model-and-validator` | PASS | Matches are boundary statements or existing commit safety rules, not new runtime mechanisms |

---

## Fixture Evidence

临时副本路径由 `mktemp -d` 创建，测试结束后删除。真实 workspace 未被修改。

| Scenario | Expected | Result |
|---|---|---|
| default valid workspace | PASS | PASS |
| `.active` points to missing feature directory | FAIL with `missing active feature directory` | PASS |
| active roadmap `Current Feature` mismatch | FAIL with `roadmap current mismatch` | PASS |
| multiple active/current roadmap candidates | FAIL with `multiple roadmap candidates` | PASS |
| completed roadmap + `Current Feature: none` | PASS | PASS |
| context manifest entry missing reason | FAIL with `missing reason` | PASS |
| strict mode missing verify evidence | FAIL with `missing fresh evidence` | PASS |
| strict mode incomplete acceptance | FAIL with missing `Verdict Summary` | PASS |
| strict mode complete fixture | PASS | PASS |

Fixture output summary:

```text
PASS ok: default valid
PASS fail: missing active dir
PASS fail: roadmap mismatch
PASS fail: multiple roadmap
PASS ok: completed none ignored
PASS fail: manifest missing reason
PASS fail: missing evidence
PASS fail: acceptance incomplete
PASS ok: strict complete
```

---

## Requirement Coverage

| Requirement | Evidence | Verdict |
|---|---|---|
| FR-001 active exists / non-empty / directory exists | default validator + missing active fixture | PASS |
| FR-002 active roadmap current consistency | roadmap mismatch fixture | PASS |
| FR-003 completed roadmap / `Current Feature: none` handling | completed none fixture | PASS |
| FR-004 manifest reason required | missing reason fixture | PASS |
| FR-005 Required local file existence | manifest parser checks Required local files; current manifest passes | PASS |
| FR-006 Check Context covers spec / plan / tasks | default validator checks active manifest Check Context | PASS |
| FR-007 tasks incomplete detection | strict mode on current workspace failed with `tasks incomplete` | PASS |
| FR-008 verify evidence exists for closeout | missing evidence fixture | PASS |
| FR-009 acceptance key sections | incomplete acceptance fixture + strict complete fixture | PASS |
| FR-010 concise file + reason output | observed FAIL output includes file path and reason | PASS |
| FR-011 no Trellis runtime / external side effects | boundary scan | PASS |

---

## Context Manifest Coverage

Check Context read and used:

- `specs/sdd-status-model-and-validator/spec.md`
- `specs/sdd-status-model-and-validator/plan.md`
- `specs/sdd-status-model-and-validator/data-model.md`
- `specs/sdd-status-model-and-validator/tasks.md`

All Required context files exist. Each manifest entry has a reason.

---

## Architecture Drift Check

| Plan Boundary | Result |
|---|---|
| Use `status-model.md` as shared reference | PASS |
| Keep single shell validator entry | PASS |
| No complex Markdown AST parser | PASS |
| Default mode does not require evidence / acceptance for in-progress feature | PASS |
| Strict mode checks tasks, fresh evidence and acceptance | PASS |
| No `.trellis/`, CLI, hook or external sync | PASS |

---

## Verdict

**Verdict**: PASS

实现范围 T001-T016 已完成并有 fresh evidence。T017 acceptance 和 T018 roadmap closeout 属于后续 closeout 阶段。
