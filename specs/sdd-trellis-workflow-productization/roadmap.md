# Roadmap: SDD Trellis Workflow Productization

**Umbrella**: `sdd-trellis-workflow-productization`
**Created**: 2026-06-07
**Status**: active
**Current Feature**: `sdd-continue-next-step`
**Next Recommended Feature**: `sdd-status-model-and-validator`

> 本 roadmap 用于继续吸收 Trellis 的工作流产品化思想。边界固定：不引入 `.trellis/`、Trellis CLI、task.py、JSONL task 结构、hook 自动注入或默认外部副作用。

---

## Summary

本 roadmap 将 Trellis 中高价值的“续接路由、状态一致性、知识回流、失败闭环、生命周期出口”拆成可独立验收的 SDD feature。当前先做 `sdd-continue-next-step`，因为它直接改善用户说“继续 / 下一步”时的阶段判断，且能为后续 validator 和 closeout 知识回流提供明确状态入口。

---

## Current State

| Field | Value |
|---|---|
| Current feature | `sdd-continue-next-step` |
| specs/.active expected | `sdd-continue-next-step` |
| Current stage | `closeout` |
| Next stage | `specify` for `sdd-status-model-and-validator` |
| Current objective | 为 SDD 增加 Trellis `continue` 风格的续接意图识别和阶段路由规则 |

---

## Feature Roadmap

| Feature | Goal | Status | Depends On | Start Condition | Recommended Stage | Notes |
|---|---|---|---|---|---|---|
| `sdd-continue-next-step` | 用户说“继续 / 下一步 / 接着做”时，SDD 自动根据 `.active` 和 feature 文件状态推荐正确阶段 | done | none | 用户已批准 Trellis 工作流产品化路线 | closeout | PASS，已完成 acceptance；提交等待用户确认 |
| `sdd-status-model-and-validator` | 强化状态一致性规则和 validator，检查 `.active`、roadmap current、manifest、tasks、acceptance 是否匹配 | backlog | `sdd-continue-next-step` | 续接路由规则稳定后 | specify | 第一批 P1 |
| `sdd-knowledge-capture-closeout` | closeout 时沉淀 decision / convention / pattern / anti-pattern / gotcha / common mistake | backlog | `sdd-status-model-and-validator` | 状态校验规则可提供可靠 closeout 输入 | specify | 第一批 P1 |
| `sdd-break-loop-for-bugfix` | 对复杂 bugfix 增加 root cause、失败尝试、预防机制、扩散检查、知识沉淀 | backlog | `sdd-knowledge-capture-closeout` | 知识回流结构已落地 | specify | 第二批，按 bugfix trait 触发 |
| `sdd-optional-lifecycle-integrations` | 设计可选生命周期出口，如 closeout 后同步知识库或外部任务系统 | backlog | `sdd-knowledge-capture-closeout` | 用户明确需要外部同步 | ideate | 第二批，不默认启用 |

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
| `sdd-continue-next-step` | 2026-06-07 | PASS | `specs/sdd-continue-next-step/acceptance.md` | 推荐启动 `sdd-status-model-and-validator` |
| `sdd-status-model-and-validator` | pending | pending | pending | 完成后推荐启动 `sdd-knowledge-capture-closeout` |
| `sdd-knowledge-capture-closeout` | pending | pending | pending | 完成后第一批能力闭环 |
| `sdd-break-loop-for-bugfix` | pending | pending | pending | 第二批按需要启动 |
| `sdd-optional-lifecycle-integrations` | pending | pending | pending | 第二批按需要启动 |

---

## Next Recommendation

`sdd-continue-next-step` 已完成 closeout。下一步推荐启动 `sdd-status-model-and-validator`，从 `specify` 阶段开始；启动前再将 `specs/.active` 切换到新的 feature。

---

## Deferred / Explicitly Out Of Scope

- `.trellis/` 目录、Trellis CLI、task.py 或 JSONL task 文件结构：不吸收。
- hook 自动注入上下文：不吸收。
- 自动 commit / push：不吸收。
- 新增实现 subagent：暂不做，除非后续证明现有 explorer / docs / reviewer 不够用。
- 外部任务系统同步：仅在 `sdd-optional-lifecycle-integrations` 中作为显式可选出口评估。
