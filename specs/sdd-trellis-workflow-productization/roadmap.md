# Roadmap: SDD Trellis Workflow Productization

**Umbrella**: `sdd-trellis-workflow-productization`
**Created**: 2026-06-07
**Status**: active
**Current Feature**: `sdd-break-loop-for-bugfix`
**Next Recommended Feature**: `roadmap-closeout`

> 本 roadmap 用于继续吸收 Trellis 的工作流产品化思想。边界固定：不引入 `.trellis/`、Trellis CLI、task.py、JSONL task 结构、hook 自动注入或默认外部副作用。

---

## Summary

本 roadmap 将 Trellis 中高价值的“续接路由、状态一致性、知识回流、失败闭环、生命周期出口”拆成可独立验收的 SDD feature。`sdd-continue-next-step`、`sdd-status-model-and-validator`、`sdd-knowledge-capture-closeout` 和 `sdd-break-loop-for-bugfix` 已完成；剩余 `sdd-optional-lifecycle-integrations` 只在用户明确需要外部同步时启动。

---

## Current State

| Field | Value |
|---|---|
| Current feature | `sdd-break-loop-for-bugfix` |
| specs/.active expected | `sdd-break-loop-for-bugfix` |
| Current stage | `closeout` |
| Next stage | `roadmap-closeout` |
| Current objective | `sdd-break-loop-for-bugfix` 已完成 closeout；若不启动外部同步，下一步建议 roadmap closeout |

---

## Feature Roadmap

| Feature | Goal | Status | Depends On | Start Condition | Recommended Stage | Notes |
|---|---|---|---|---|---|---|
| `sdd-continue-next-step` | 用户说“继续 / 下一步 / 接着做”时，SDD 自动根据 `.active` 和 feature 文件状态推荐正确阶段 | done | none | 用户已批准 Trellis 工作流产品化路线 | closeout | PASS，已提交 `c7db24d` |
| `sdd-status-model-and-validator` | 强化状态一致性规则和 validator，检查 `.active`、roadmap current、manifest、tasks、acceptance 是否匹配 | done | `sdd-continue-next-step` | 续接路由规则稳定后 | closeout | PASS，验收记录见 `specs/sdd-status-model-and-validator/acceptance.md` |
| `sdd-knowledge-capture-closeout` | closeout 时沉淀 decision / convention / pattern / anti-pattern / gotcha / common mistake | done | `sdd-status-model-and-validator` | 状态校验规则可提供可靠 closeout 输入 | closeout | PASS，验收记录见 `specs/sdd-knowledge-capture-closeout/acceptance.md` |
| `sdd-break-loop-for-bugfix` | 对复杂 bugfix 增加 root cause、失败尝试、预防机制、扩散检查、知识沉淀 | done | `sdd-knowledge-capture-closeout` | 知识回流结构已落地 | closeout | PASS，验收记录见 `specs/sdd-break-loop-for-bugfix/acceptance.md` |
| `sdd-optional-lifecycle-integrations` | 设计可选生命周期出口，如 closeout 后同步知识库或外部任务系统 | backlog | `sdd-knowledge-capture-closeout` | 用户明确需要外部同步 | ideate | 可选项，不默认启用；若无外部同步需求，建议 roadmap closeout |

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
| `sdd-status-model-and-validator` | 2026-06-07 | PASS | `specs/sdd-status-model-and-validator/acceptance.md` | 推荐启动 `sdd-knowledge-capture-closeout` |
| `sdd-knowledge-capture-closeout` | 2026-06-08 | PASS | `specs/sdd-knowledge-capture-closeout/acceptance.md` | 推荐启动 `sdd-break-loop-for-bugfix` |
| `sdd-break-loop-for-bugfix` | 2026-06-08 | PASS | `specs/sdd-break-loop-for-bugfix/acceptance.md` | 推荐 roadmap closeout；仅在用户明确需要外部同步时启动 `sdd-optional-lifecycle-integrations` |
| `sdd-optional-lifecycle-integrations` | pending | pending | pending | 第二批按需要启动 |

---

## Next Recommendation

`sdd-break-loop-for-bugfix` 已 PASS。下一步推荐做 roadmap closeout，因为本 roadmap 的默认能力项已完成；只有用户明确需要外部同步时，才启动 `sdd-optional-lifecycle-integrations`。

---

## Deferred / Explicitly Out Of Scope

- `.trellis/` 目录、Trellis CLI、task.py 或 JSONL task 文件结构：不吸收。
- hook 自动注入上下文：不吸收。
- 自动 commit / push：不吸收。
- 新增实现 subagent：暂不做，除非后续证明现有 explorer / docs / reviewer 不够用。
- 外部任务系统同步：仅在 `sdd-optional-lifecycle-integrations` 中作为显式可选出口评估。
