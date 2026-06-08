# Implementation Plan: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期] | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/[工作区名称]/spec.md`

**Note**: 此模板由 `plan` 命令填充。章节按需使用，不需要的章节可以省略。
**Artifact Rule**: `plan.md` 为核心产物；仅在实体、状态、关系或存储变化需要展开时，再补 `data-model.md`。

---

## Summary

[1-2 句话描述需求目标和推荐方案]

---

## Architecture Overview

[描述系统中本次改动涉及的主要组件、关系和数据流]

```text
[如适用，用 ASCII 描述 Context / Container / 数据流。小改动可省略。]
```

---

## Architecture Reference *(if applicable)*

> 只在中大型功能或架构相关改动中使用。成熟架构模式只能作为候选参考，不能替代当前代码现实和产品阶段。

| 参考模式 / 模板 | 来源 URL | 适配点 | 不适配点 | 当前阶段 |
|-----------------|----------|--------|----------|----------|
| [例如：单体 / 事件驱动 / BFF / RAG 知识库] | [URL] | [为什么可参考] | [为什么不能照搬] | [MVP/成长期/成熟期] |

---

## Producer-Consumer Matrix *(if `multi-stage-workflow` or `artifact-handoff`)*

> 当 spec.md 中对应 trait 命中时必填。详见 [`../references/feature-traits.md`](../references/feature-traits.md)。
> 列出每个跨阶段 artifact 的生产者、消费者和消费证据，用于在设计阶段识别"产物没有消费者"的闭环断点。

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| [生产模块/阶段] | [产物名称] | [消费模块/阶段] | [如何验证消费已发生] |

**孤儿 artifact 处理**: 若某 artifact 找不到 consumer，必须显式说明它是"预留中间能力"还是"待补消费方"，不得默认通过。

---

## Quality Attribute Targets *(if applicable)*

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| [性能/可用性/一致性/成本/安全/可演进性] | [目标] | [对架构的影响] | [如何验证] |

---

## Bugfix Strategy *(if `bugfix-loop-breaker`)*

> 当 spec.md 中 `bugfix-loop-breaker` 命中时填写。详见 [`../references/bugfix-loop-breaker.md`](../references/bugfix-loop-breaker.md)。

| Field | Value |
|---|---|
| Observed Behavior | [实际错误或退化] |
| Expected Behavior | [期望行为] |
| Reproduction Status | reproducible / intermittent / not-reproduced / unknown |
| Root Cause Hypothesis | [已验证假设，未知时写 unknown] |
| Fix Boundary | [本次修复范围和明确不改范围] |
| Failed Attempt Handling | [如何记录失败尝试、排除假设和下一步证据] |
| Regression Guard Strategy | [测试、fixture、validator 或人工验证] |
| Diffusion Check Strategy | [相邻路径、共享规则、模板、状态机或调用点检查] |
| Verification Path | [before/after proof 或替代证据] |

---

## Capacity / Scale Notes *(if applicable)*

- **规模假设**: [用户量 / 请求量 / 数据量 / 并发量]
- **读写特征**: [读多写少 / 写多读少 / 实时 / 批处理]
- **失败代价**: [慢 / 错 / 丢 / 重复 / 不可用的后果]

---

## Lightweight ADR *(if applicable)*

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| [ADR-001] | [为什么现在要决策] | [A / B / 不做] | [选择] | [放弃什么，引入什么风险] | [URL 或 UNVERIFIED] |

---

## Key Design Decisions

### Decision 1: [决策标题]

- **背景**: [为什么要做这个决策]
- **选项**:
  - A: [选项A] — [优劣]
  - B: [选项B] — [优劣]
- **结论**: [最终选择及原因]
- **影响**: [对实现和维护的影响]
- **来源**: [官方文档 URL，或 UNVERIFIED]

---

## Module Design

### Module: [模块名称]

**职责**: [一句话描述]

**改动概述**: [这次要新增或修改什么]

**关键接口 / 行为**:

```text
[用伪代码、步骤或接口说明描述，不写大量真实代码]
```

**注意事项**:

- [复用现有能力]
- [限制、兼容性或异常路径]

---

## Data Model

[如涉及实体、状态、关系变化，可概述核心变化；详细内容可落到 data-model.md]

---

## Project Structure

```text
[根据实际改动填写]
```

---

## Risks and Tradeoffs

- [风险 1]
- [风险 2]
- [权衡说明]

---

## Evolution Path *(if applicable)*

- **MVP**: [当前阶段保留的简单方案]
- **成长期**: [出现哪些信号后升级]
- **成熟期**: [长期可能需要的架构形态]

---

## Anti-Pattern Check *(if applicable)*

- 是否把成熟期架构套到了 MVP：[否 / 是，说明处理]
- 是否引用了外部模式但没有适配检查：[否 / 是，说明处理]
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：[否 / 是，说明处理]

---

## Verification Strategy

[说明后续如何验证实现是否达成目标]

---

## Stage Readiness

- 是否需要 `data-model.md`：[需要 / 不需要 + 原因]
- 下一步建议：`tasks` / `clarify`
- 阻塞项（如有）：[哪些问题仍阻塞任务拆解]

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 按需 | 涉及实体、状态、关系或存储变化时生成 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Notes

[其他备注、约束、已知问题、待观察点]

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| [Decision 1] | [URL] | |
| [Decision 2] | UNVERIFIED | 未找到官方文档 |
