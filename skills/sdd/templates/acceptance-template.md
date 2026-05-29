# Acceptance Record: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期] | **Spec**: [spec.md](spec.md)

> 当任一 Feature Trait 命中时使用本模板。详见 [`../references/feature-traits.md`](../references/feature-traits.md)。
> 不命中任何 trait 的 feature 可省略本文件，直接在 closeout 中给出简短结论。

---

## Evidence Table

> 当 `user-visible-output` 或 `external-side-effects` 命中时必填。每条 P0/P1 requirement 必须有对应行。

| Requirement | Evidence | Test or File | Verdict |
|---|---|---|---|
| [FR-XXX 简述] | [具体证据：捕获的 payload 摘要 / 行为观察 / 文件内容片段] | [测试名 / 文件路径 / commit SHA / 日志位置] | PASS / PARTIAL / FAIL |

**Evidence 填写规范**:

- 必须能定位到具体测试名、文件路径、捕获的 payload 或 fixture
- 不得只写"已实现"、"测试通过"、"代码 review 通过"等抽象描述
- PARTIAL 的行必须说明缺什么证据才能升 PASS

---

## Verdict Summary *(三维 Verdict)*

> 当任一强化 trait 命中时必填。三维不一致时必须在最后说明。

| Dimension | Verdict | Notes |
|---|---|---|
| Component capability | PASS / PARTIAL / FAIL | [组件层面是否实现：函数、模块、接口存在且行为正确] |
| Workflow closure | PASS / PARTIAL / FAIL | [跨组件协同是否闭环：producer-consumer 链路完整] |
| User-visible outcome | PASS / PARTIAL / FAIL | [用户实际可见结果是否与 spec 对齐] |

**Overall**: PASS / CONDITIONAL PASS / FAIL

**三维不一致说明** *(任一维度非 PASS 时必填)*:

[说明为何允许在某维度未完全通过的情况下宣布收尾，或承认 feature 未真正完成。引用具体哪条 requirement / scenario 决定了该判断。]

---

## Workflow Replay *(if `multi-stage-workflow` AND `user-visible-output`)*

- **输入摘要**: [代表性输入]
- **最终 payload 摘要**: [捕获到的端到端结果]
- **用户可见结果断言**: [对照 spec 中 user-visible-output 的期望]
- **Replay 类型**: 真实 / fixture（fixture 时说明无法做真实 replay 的原因）
