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
