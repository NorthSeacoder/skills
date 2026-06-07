# Roadmap: [Umbrella Title]

**Umbrella**: `[umbrella-workspace]`
**Created**: [date]
**Status**: active
**Current Feature**: `[current-feature]`
**Next Recommended Feature**: `[next-feature-or-none]`

> 本文件只在一个用户需求适合拆成多个 feature 时创建。单点小改动或单 feature 需求不需要 roadmap。

---

## Summary

[用 2-4 句话说明 umbrella 目标、为什么需要拆成多个 feature、当前先做哪一个 feature。]

---

## Current State

| Field | Value |
|---|---|
| Current feature | `[current-feature]` |
| specs/.active expected | `[current-feature]` |
| Current stage | `[ideate/specify/clarify/plan/tasks/implement/verify/closeout]` |
| Next stage | `[next-stage]` |
| Current objective | [当前 feature 的目标] |

---

## Feature Roadmap

| Feature | Goal | Status | Depends On | Start Condition | Recommended Stage | Notes |
|---|---|---|---|---|---|---|
| `[feature-1]` | [目标] | current | none | [启动条件] | specify | [备注] |
| `[feature-2]` | [目标] | backlog | `[feature-1]` | [启动条件] | specify | [备注] |

状态枚举：

- `backlog`: 已识别但尚未启动
- `current`: 当前正在推进
- `done`: 已完成 closeout
- `conditional`: 有条件通过，仍有明确缺口
- `blocked`: 被阻塞，不能推荐为下一项
- `cancelled`: 用户或维护者明确取消

---

## Completion Log

| Feature | Date | Verdict | Evidence | Impact On Roadmap |
|---|---|---|---|---|
| `[feature]` | [date 或 pending] | PASS / CONDITIONAL PASS / FAIL / pending | [验收证据或 pending] | [对后续 feature 的影响] |

---

## Next Recommendation

[说明完成当前 feature 后推荐哪一个 feature、为什么、启动条件是什么、建议进入哪个 SDD 阶段。若没有可推荐 feature，说明应做 roadmap closeout。]

---

## Deferred Features

- `[feature]`: [为什么后置、何时重新评估]
