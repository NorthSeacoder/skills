# Feature Specification: [功能名称]

**Workspace**: `[工作区名称]`  
**Created**: [日期]  
**Status**: Draft  
**Input**: 用户描述: "[原始需求]"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - [标题] (Priority: P1)

[用户故事描述：作为 [角色]，我希望 [功能]，以便 [价值]]

**Why this priority**: [优先级理由]

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** [初始状态/前置条件]  
   **When** [用户操作]  
   **Then** [期望结果]

2. **[US1-2]**
   **Given** [初始状态/前置条件]  
   **When** [用户操作]  
   **Then** [期望结果]

**Edge Cases**:

- **[US1-3]** [描述边界场景及期望行为]
- **[US1-4]** [描述错误场景及期望行为]
- **[US1-5]** [描述并发场景及期望行为，如适用]

### User Story 2 - [标题] (Priority: P2)

[如有更多用户故事，按优先级排列。每个 User Story 包含同样的 Acceptance Scenarios、Edge Cases 结构]

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系统必须 [具体能力]
- **FR-002**: 用户必须能够 [关键交互]
- **FR-003**: [更多功能需求...]

### Non-Functional Requirements *(if applicable)*

- **NFR-001**: [性能/安全/可用性等非功能需求]

### Quality Attributes *(if architecture-relevant)*

> 当功能涉及新系统、跨模块边界、状态、存储、异步、缓存、安全、规模或长期演进时填写。小改动可省略。

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 性能 | [目标] | [原因] | [如何验证] | [是/否] |
| 可用性 | [目标] | [原因] | [如何验证] | [是/否] |
| 一致性 | [目标] | [原因] | [如何验证] | [是/否] |
| 成本 | [目标] | [原因] | [如何验证] | [是/否] |
| 可演进性 | [目标] | [原因] | [如何验证] | [是/否] |

### Key Entities *(if applicable)*

- **[实体1]**: [描述和关键属性]
- **[实体2]**: [描述和关键属性]

---

## Business Metrics *(optional — 上线后度量)*

> **说明**: 此章节定义上线后才能验证的业务度量指标。开发阶段的需求验证由各 User Story 的 Acceptance Scenarios 覆盖，无需在此重复。如果所有验收标准都已在 User Story 中定义清楚，本章节可省略。

- **BM-001**: [上线后可衡量的业务指标]
- **BM-002**: [上线后可衡量的业务指标]

---

## Out of Scope *(if applicable)*

明确不在本次功能范围内的内容：

- [排除项1]
- [排除项2]

---

## Unclear Questions *(if applicable)*

探索循环中未能解答、且可能影响后续阶段的遗留问题：

- [问题1]
- [问题2]

---

## Stage Readiness

- 下一步建议：`clarify` / `plan`
- 阻塞项（如有）：[哪些问题会阻塞下游阶段]
