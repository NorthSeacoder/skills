# Commit Plan: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator`
**Date**: 2026-06-07
**Status**: Confirmed

> Commit plan 是提交前的用户确认 gate。未获得用户明确确认前，不得执行 `git add` 或 `git commit`。

---

## Summary

当前 dirty files 均属于 `sdd-status-model-and-validator` feature：一批 SDD skill 实现文件、一批 feature specs/evidence/acceptance 文件，以及 umbrella roadmap / `.active` 状态文件。建议单批提交。

---

## Included Files

| File | Reason | Evidence |
|---|---|---|
| `skills/sdd/SKILL.md` | 入口引用 status model reference | T002 |
| `skills/sdd/references/continuation-routing.md` | continuation routing 指向 status model | T002 |
| `skills/sdd/references/status-model.md` | 新增状态模型 reference | T001 |
| `skills/sdd/references/stages/verify.md` | verify 阶段引用 default validator | T003 |
| `skills/sdd/references/stages/closeout.md` | closeout 阶段引用 `--closeout-ready` | T003 |
| `skills/sdd/scripts/validate-sdd.sh` | 实现 default / closeout-ready validator 检查 | T004-T012 |
| `specs/.active` | 当前 feature active pointer | SDD workspace state |
| `specs/sdd-status-model-and-validator/spec.md` | feature spec | specify 阶段产物 |
| `specs/sdd-status-model-and-validator/plan.md` | implementation plan | plan 阶段产物 |
| `specs/sdd-status-model-and-validator/data-model.md` | status model data model | plan 阶段产物 |
| `specs/sdd-status-model-and-validator/tasks.md` | executable tasks and completion state | tasks / implement 阶段产物 |
| `specs/sdd-status-model-and-validator/context-manifest.md` | implement / check context manifest | tasks 阶段产物 |
| `specs/sdd-status-model-and-validator/verify-evidence.md` | fresh verification evidence | verify 阶段产物 |
| `specs/sdd-status-model-and-validator/acceptance.md` | closeout completion record | closeout 阶段产物 |
| `specs/sdd-status-model-and-validator/commit-plan.md` | commit confirmation gate | closeout 阶段产物 |
| `specs/sdd-trellis-workflow-productization/roadmap.md` | roadmap status, completion log and next recommendation | T018 |

---

## Excluded Files

| File | Reason |
|---|---|
| 无 | 当前未发现无关 dirty files |

---

## Needs User Decision

| File | Why Uncertain | Question |
|---|---|---|
| 无 | 当前 diff 归属清晰 | 无 |

---

## Risks

| Risk | Impact | Handling |
|---|---|---|
| staged changes | 当前未检查到 staged-only 风险 | 提交前再跑 `git status --short` |
| untracked specs directory | 需要明确纳入提交，否则 feature 记录缺失 | included files 已列出整个 feature workspace |
| validator shell 逻辑 | shell parsing 后续维护成本高于纯 Markdown | 已保持单脚本小函数并记录演进触发信号 |

---

## Commit Batches

| Batch | Files | Commit Message | Rationale |
|---|---|---|---|
| 1 | Included Files 全部 | `feat(sdd): add status model validator` | skill 实现与 SDD feature evidence 同属一个可验收功能 |

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
- `暂不提交`: closeout 记录 not submitted 和剩余 dirty files。
