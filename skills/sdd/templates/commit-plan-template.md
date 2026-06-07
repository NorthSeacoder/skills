# Commit Plan: [Feature Name]

**Workspace**: `[feature-workspace]`
**Date**: [date]
**Status**: Draft / Awaiting User Confirmation / Confirmed / Not Submitted

> Commit plan 是提交前的用户确认 gate。未获得用户明确确认前，不得执行 `git add` 或 `git commit`。

---

## Summary

[说明当前 feature 是否有相关 diff、建议提交批次、是否存在无关 dirty files 或待用户决策文件。]

---

## Included Files

| File | Reason | Evidence |
|---|---|---|
| [path] | [为什么属于当前 feature] | [spec/tasks/acceptance/roadmap/git diff 依据] |

---

## Excluded Files

| File | Reason |
|---|---|
| [path] | [为什么不属于当前 feature，或为什么不应提交] |

---

## Needs User Decision

| File | Why Uncertain | Question |
|---|---|---|
| [path] | [为什么无法判断归属] | [需要用户确认的问题] |

> 只要存在 Needs User Decision 项，就不得执行提交。

---

## Risks

| Risk | Impact | Handling |
|---|---|---|
| staged changes | 可能覆盖用户已 staged 工作 | 先列出并确认归属 |
| ignored runtime files | 可能是本机运行时改动，无法进入主仓 diff | 标注为不可提交或需源仓同步 |
| symlink / submodule / deletion | 结构性变更，风险高于普通 patch | 单独列出并要求用户确认 |

---

## Commit Batches

| Batch | Files | Commit Message | Rationale |
|---|---|---|---|
| 1 | [paths] | [message] | [为什么这些文件同属一批] |

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

- `确认提交`: 按上述 batches 执行本地提交。
- `修改计划`: 根据用户要求调整 included/excluded/batches。
- `暂不提交`: closeout 记录 not submitted 和剩余 dirty files。
