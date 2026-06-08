# Commit Plan: SDD Break Loop For Bugfix

**Workspace**: `sdd-break-loop-for-bugfix`
**Date**: 2026-06-08
**Status**: Awaiting User Confirmation

> Commit plan 是提交前的用户确认 gate。未获得用户明确确认前，不得执行 `git add` 或 `git commit`。

---

## Summary

当前工作树的相关 diff 都属于 `sdd-break-loop-for-bugfix`：新增 bugfix loop-breaker reference，更新 SDD 阶段规则、模板、validator、status model，并新增本 feature 的 spec/plan/tasks/context-manifest/verify-evidence/acceptance/commit-plan。未发现需要排除或待用户决策的 dirty tracked files。

---

## Included Files

| File | Reason | Evidence |
|---|---|---|
| `skills/sdd/references/bugfix-loop-breaker.md` | 新增 bugfix loop-breaker 共享词表和规则来源 | `tasks.md` T001; `plan.md` ADR-002 |
| `skills/sdd/references/feature-traits.md` | 新增 `bugfix-loop-breaker` trait 和触发规则 | `tasks.md` T002; `acceptance.md` Evidence Table |
| `skills/sdd/templates/spec-template.md` | 让 future specs 可标注 bugfix trait | `tasks.md` T003 |
| `skills/sdd/references/stages/clarify.md` | 增加 unknown root cause 处理规则 | `tasks.md` T005 |
| `skills/sdd/references/stages/plan.md` | 增加 bugfix strategy 要求 | `tasks.md` T006 |
| `skills/sdd/templates/plan-template.md` | 增加 Bugfix Strategy 模板段 | `tasks.md` T007 |
| `skills/sdd/references/stages/tasks.md` | 增加 bugfix task coverage 规则 | `tasks.md` T008 |
| `skills/sdd/templates/tasks-template.md` | 增加 Bugfix Loop Breaker Tasks 模板段 | `tasks.md` T009 |
| `skills/sdd/references/stages/implement.md` | 增加 failed attempt retry 控制规则 | `tasks.md` T010 |
| `skills/sdd/references/stages/verify.md` | 增加 bugfix proof evidence 要求 | `tasks.md` T011 |
| `skills/sdd/references/stages/closeout.md` | 增加 Bugfix Closure closeout 要求 | `tasks.md` T012 |
| `skills/sdd/templates/acceptance-template.md` | 增加 Bugfix Closure 持久验收段 | `tasks.md` T013 |
| `skills/sdd/references/status-model.md` | 增加 bugfix closeout-ready 结构边界 | `tasks.md` T014 |
| `skills/sdd/scripts/validate-sdd.sh` | 增加 default 资产引用和 closeout-ready bugfix 字段检查 | `tasks.md` T015-T017; `verify-evidence.md` fixture results |
| `specs/.active` | 当前 active feature 指向 `sdd-break-loop-for-bugfix` | SDD workspace convention |
| `specs/sdd-break-loop-for-bugfix/spec.md` | Feature specification | SDD specify artifact |
| `specs/sdd-break-loop-for-bugfix/plan.md` | Implementation plan and ADRs | SDD plan artifact |
| `specs/sdd-break-loop-for-bugfix/tasks.md` | Executed task list | T001-T027 completion |
| `specs/sdd-break-loop-for-bugfix/context-manifest.md` | Implement / check context manifest | Trait-heavy workflow requirement |
| `specs/sdd-break-loop-for-bugfix/verify-evidence.md` | Fresh verification evidence | Verify PASS |
| `specs/sdd-break-loop-for-bugfix/acceptance.md` | Final acceptance, Bugfix Closure and Knowledge Capture | Closeout PASS |
| `specs/sdd-break-loop-for-bugfix/commit-plan.md` | Commit confirmation gate | Closeout commit planning rules |
| `specs/sdd-trellis-workflow-productization/roadmap.md` | Roadmap current status and completion log | T026; acceptance completion record |

---

## Excluded Files

| File | Reason |
|---|---|
| none | No unrelated tracked dirty files detected. |

---

## Needs User Decision

| File | Why Uncertain | Question |
|---|---|---|
| none | No uncertain file ownership detected. | 无 |

---

## Risks

| Risk | Impact | Handling |
|---|---|---|
| staged changes | None observed in current status output | If user confirms commit, check status before add |
| ignored runtime files | Empty temporary fixture directories may exist locally but are untracked and not in `git status --short` | Do not include them; no commit impact |
| symlink / submodule / deletion | No deletion, symlink or submodule change observed in current feature diff | Single normal patch batch is sufficient |
| validator structural limit | Validator cannot prove root cause semantic truth | Recorded in acceptance Remaining Risk and Knowledge Capture |

---

## Commit Batches

| Batch | Files | Commit Message | Rationale |
|---|---|---|---|
| 1 | Included Files 全部 | `feat(sdd): add bugfix loop breaker` | Single cohesive SDD workflow feature with matching specs and acceptance evidence |

---

## Execution Rules

- 未获得用户明确确认前，不得执行 `git add` 或 `git commit`。
- 只允许 add `Included Files` 中属于已确认 batch 的文件。
- 不得使用 `git add -A`、`git add .` 或等价宽泛命令。
- 每个 batch 单独提交；任一 batch 失败时停止后续 batch。
- 不自动执行 `git push`。push 必须由用户另行明确要求。
- 如果没有相关 diff，记录 `no related diff`，不得生成空 commit。

---

## User Confirmation

等待用户确认：

- `确认提交`: 按上述 batch 执行本地提交。
- `修改计划`: 根据用户要求调整 included/excluded/batches。
- `暂不提交`: closeout 记录 not_submitted 和剩余 dirty files。
