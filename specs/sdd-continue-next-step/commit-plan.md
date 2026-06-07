# Commit Plan: SDD Continue Next Step

**Workspace**: `sdd-continue-next-step`
**Date**: 2026-06-07
**Status**: Awaiting User Confirmation

> Commit plan 是提交前的用户确认 gate。未获得用户明确确认前，不得执行 `git add` 或 `git commit`。

---

## Summary

当前 feature 有相关 diff，建议作为一个批次提交。当前计划只包含 `sdd-continue-next-step` 及其 umbrella roadmap 相关文件，不自动提交。

---

## Included Files

| File | Reason | Evidence |
|---|---|---|
| `skills/sdd/SKILL.md` | 接入 continuation preflight 和输出要求 | `tasks.md` T004-T005 |
| `skills/sdd/references/continuation-routing.md` | 新增续接状态映射单一来源 | `tasks.md` T001-T003 |
| `skills/sdd/references/stages/ideate.md` | 续接请求短路，不进入 ideate 发散 | `tasks.md` T006 |
| `skills/sdd/scripts/validate-sdd.sh` | 增加 continuation reference 最小结构校验 | `tasks.md` T008-T009 |
| `specs/.active` | 当前 active feature 指向 `sdd-continue-next-step` | `spec.md` 与 roadmap |
| `specs/sdd-trellis-workflow-productization/roadmap.md` | 新 umbrella roadmap 和当前 feature closeout 回写 | roadmap |
| `specs/sdd-continue-next-step/spec.md` | 当前 feature spec | spec |
| `specs/sdd-continue-next-step/plan.md` | 当前 feature plan | plan |
| `specs/sdd-continue-next-step/tasks.md` | 当前 feature task execution record | tasks |
| `specs/sdd-continue-next-step/context-manifest.md` | implement / check context handoff | tasks |
| `specs/sdd-continue-next-step/verify-evidence.md` | verify fresh evidence | verify |
| `specs/sdd-continue-next-step/acceptance.md` | closeout completion record | acceptance |
| `specs/sdd-continue-next-step/commit-plan.md` | commit planning gate | closeout |

---

## Excluded Files

| File | Reason |
|---|---|
| 无 | 当前 `git status --short` 中未见与本 feature 无关的 dirty files。 |

---

## Needs User Decision

| File | Why Uncertain | Question |
|---|---|---|
| 无 | 当前提交边界清晰 | 无 |

---

## Risks

| Risk | Impact | Handling |
|---|---|---|
| SDD skill 行为变更 | 影响后续 `sdd` 续接判断 | 已通过 `validate-sdd.sh` 和 verify evidence 覆盖 |
| roadmap 后续 feature 尚未启动 | closeout 后仍需用户确认下一项 | completion record 只推荐，不自动切换到下一个 feature |
| 提交未确认 | 本地 diff 保持未提交 | 等待用户确认提交计划 |

---

## Commit Batches

| Batch | Files | Commit Message | Rationale |
|---|---|---|---|
| 1 | Included Files 全部 | `feat(sdd): add continuation routing` | 同一 feature 的 skill 规则、规格、验证和 closeout 记录 |

---

## Execution Rules

- 未获得用户明确确认前，不得执行 `git add` 或 `git commit`。
- 只允许 add `Included Files` 中属于已确认 batch 的文件。
- 不得使用 `git add -A`、`git add .` 或等价宽泛命令。
- 每个 batch 单独提交；任一 batch 失败时停止后续 batch。
- 不自动执行 `git push`。push 必须由用户另行明确要求。

---

## User Confirmation

等待用户确认：

- `确认提交`: 按上述 batch 执行本地提交。
- `修改计划`: 根据用户要求调整 included/excluded/batches。
- `暂不提交`: closeout 记录 not_submitted 和剩余 dirty files。
