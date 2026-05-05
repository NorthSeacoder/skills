# Implementation Plan: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期] | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/[工作区名称]/spec.md`

**Note**: 此模板由 `plan` 命令填充。章节按需使用，不需要的章节可以省略。

---

## Summary

[1-2 句话描述需求目标和推荐方案]

---

## Architecture Overview

<!-- 按需：适用于涉及多个模块、层次或服务的需求 -->

[描述系统中本次改动涉及的主要组件、关系和数据流]

---

## Key Design Decisions

<!-- 按需：只记录真正影响后续实现的关键决策 -->

### Decision 1: [决策标题]

- **背景**: [为什么要做这个决策]
- **选项**:
  - A: [选项A] — [优劣]
  - B: [选项B] — [优劣]
- **结论**: [最终选择及原因]
- **影响**: [对实现和维护的影响]

---

## Module Design

<!-- 按需：描述本次改动涉及的主要模块或边界 -->

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

<!-- 按需：如果需要单独补 data-model.md，可在这里说明其作用 -->

[如涉及实体、状态、关系变化，可概述核心变化；详细内容可落到 data-model.md]

---

## Project Structure

<!-- 必填：说明这次改动主要会触达哪些目录、文件或模块 -->

```text
[根据实际改动填写，示例：]
src/
├── [修改] app/orders/page.tsx
├── [新增] lib/orders/export.ts
└── [修改] api/orders/route.ts

tests/
└── [修改] orders/export.test.ts
```

---

## Risks and Tradeoffs

- [风险 1]
- [风险 2]
- [权衡说明]

---

## Verification Strategy

[说明后续如何验证实现是否达成目标，例如测试、typecheck、lint、局部手动验证、浏览器验收等]

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 按需 | 涉及实体、状态或存储变化时生成 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Notes

[其他备注、约束、已知问题、待观察点]
