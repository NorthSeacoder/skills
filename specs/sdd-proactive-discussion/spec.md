# Feature Specification: SDD Proactive Discussion

**Workspace**: `sdd-proactive-discussion`  
**Created**: 2026-05-25  
**Status**: Draft  
**Input**: 用户描述: "clarify 阶段要主动挖掘隐藏问题、确保用户没有遗漏；plan 阶段要用 awesome-architecture 等成熟架构模式和用户真正讨论候选方案，而不是 LM 自己填表。"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Clarify 主动挖掘隐藏问题 (Priority: P1)

作为 `sdd` 使用者，我希望 clarify 阶段能主动发现我没考虑到的隐藏问题和盲点，而不是被动等我回答问题清单，以便进入 plan 前不会带着未识别的风险。

**Why this priority**: 当前 clarify 的行为是"列出问题清单让用户批量回答"，用户已经知道的问题不需要问，真正有价值的是用户没想到的。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** 用户提出一个功能需求并进入 clarify  
   **When** LM 读取 spec 和代码现状  
   **Then** LM 应主动指出用户可能没考虑到的隐藏风险、边界冲突、依赖影响或历史决策矛盾，而不是只列出"请回答以下问题"

2. **[US1-2]**
   **Given** LM 发现了隐藏问题  
   **When** 向用户呈现  
   **Then** 应说明"我发现了这个潜在问题，你的想法是什么"，而不是"请回答：X 是什么"

3. **[US1-3]**
   **Given** 用户的 spec 已经足够完整  
   **When** LM 没有发现隐藏问题  
   **Then** 应直接说明"没有发现遗漏，可以进入 plan"，不强行制造问题

**Edge Cases**:

- **[US1-4]** 如果隐藏问题能从代码或文档推断出答案，LM 应直接给出推断结论并请用户确认，而不是把推断过程变成提问
- **[US1-5]** 如果用户对某个隐藏问题说"不重要"或"先不管"，应尊重并记录为 known risk，不反复追问

### User Story 2 - Plan 阶段的架构方案讨论 (Priority: P1)

作为 `sdd` 使用者，我希望 plan 阶段能参考成熟架构模式和我讨论候选方案的优劣，让我做出知情决策，而不是 LM 自己选好方案后直接输出 plan.md。

**Why this priority**: 架构决策是讨论出来的，不是模板填出来的。当前 plan 阶段 LM 直接生成完整方案，用户只能事后审阅，错过了最有价值的方案对比和取舍讨论。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** 用户进入 plan 阶段，需求涉及架构选择  
   **When** LM 开始设计方案  
   **Then** 必须先提出 2-3 个候选架构方向（可参考 awesome-architecture 的核心模式和类系统模板），说明各自的适配点、不适配点和代价，让用户选择或讨论

2. **[US2-2]**
   **Given** LM 提出候选方案  
   **When** 用户选择或提出修改意见  
   **Then** LM 根据用户决策生成 plan.md，ADR 中记录讨论过程和放弃的方案

3. **[US2-3]**
   **Given** 需求简单，只有一个合理方案  
   **When** LM 判断不需要方案对比  
   **Then** 应说明"这个场景只有一个合理方向，原因是 X"，然后直接推进，不强行凑候选

**Edge Cases**:

- **[US2-4]** 如果用户对架构讨论不感兴趣（"你决定就好"），LM 应快速给出推荐方案和理由，不强制对话
- **[US2-5]** 参考 awesome-architecture 时，必须说明当前项目阶段（MVP/成长期/成熟期），不把成熟期方案套到 MVP
- **[US2-6]** 如果讨论中用户改变了需求范围，应返回 clarify 或 specify，而不是在 plan 里硬适配

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: clarify 阶段必须主动分析 spec + 代码现状，识别用户可能没考虑到的隐藏问题（依赖冲突、边界模糊、历史决策矛盾、规模假设、失败模式等）
- **FR-002**: clarify 的输出形式必须是"我发现了 X，你怎么看"而不是"请回答以下问题清单"
- **FR-003**: clarify 能从代码/文档推断的结论应直接给出并请用户确认，不转化为开放式提问
- **FR-004**: plan 阶段在涉及架构选择时，必须先和用户讨论候选方案再生成 plan.md
- **FR-005**: 候选方案讨论必须包含：方案名称、适配点、不适配点、代价、参考来源（可引用 awesome-architecture 核心模式或类系统模板）
- **FR-006**: 用户做出架构决策后，plan.md 的 ADR 必须记录讨论过程中被放弃的方案及原因
- **FR-007**: 当需求简单或只有一个合理方案时，不强制方案对比，但需说明原因
- **FR-008**: 当用户明确表示"你决定"时，LM 应给出推荐并说明理由，快速推进

### Non-Functional Requirements

- **NFR-001**: clarify 的主动分析不应让小改动变重；小改动仍可快速通过或跳过 clarify
- **NFR-002**: 架构讨论不应变成冗长的教学；重点是帮用户做决策，不是展示知识
- **NFR-003**: 整体交互节奏应保持紧凑，每轮讨论聚焦 1-2 个核心取舍

---

## Out of Scope

- 新增独立的 architecture-copilot skill 或 subagent
- 复制 awesome-architecture 的完整教程内容
- 改变 sdd 的阶段路由模型或工作区约定
- 修改 spec-template 或 tasks-template（本次只改 clarify 和 plan 的行为）

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项（如有）：无
