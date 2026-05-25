# Feature Specification: SDD Architecture Quality Gate

**Workspace**: `sdd-architecture-quality-gate`  
**Created**: 2026-05-25  
**Status**: Draft  
**Input**: 用户描述: "参考 awesome-architecture 和 architecture-copilot，把架构思考、成熟架构模式和 ADR 纪律优化进我的 sdd skill，用于 vibe coding 时避免跳过架构。"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 在写方案前补齐架构问题 (Priority: P1)

作为 `sdd` 使用者，我希望在进入 `plan` 前先识别业务范围、约束、规模、质量属性和关键风险，以便 vibe coding 不会直接从需求跳到实现。

**Why this priority**: 现有 `sdd` 已有 `clarify` 与 `plan`，但架构质量属性、约束和关键取舍还没有成为稳定 gate。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** 用户提出一个中大型功能或系统设计需求  
   **When** `sdd` 判断进入 `clarify` 或 `plan`  
   **Then** 必须识别架构相关问题，包括业务范围、规模、读写特征、一致性、失败代价、硬约束和质量属性

2. **[US1-2]**
   **Given** 需求很小或不涉及架构变化  
   **When** `sdd` 进行阶段判断  
   **Then** 不应强行套完整架构提问，只需说明不进入架构质量门的原因

**Edge Cases**:

- **[US1-3]** 如果架构问题能从现有代码、文档或 spec 推断，不应重复询问用户
- **[US1-4]** 如果关键质量属性缺失且会影响方案，不应直接进入任务拆解

### User Story 2 - 把成熟架构模式作为参考，而不是模板套用 (Priority: P1)

作为 `sdd` 使用者，我希望能引用成熟架构模式和类系统模板作为设计参考，以便方案有可比较的候选项，但不会把成熟期架构硬套到 MVP。

**Why this priority**: `awesome-architecture` 中的核心模式和系统模板适合作为候选参考，但 SDD 必须保持项目现实优先。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** 用户正在设计一个系统或复杂功能  
   **When** `plan` 生成关键设计决策  
   **Then** 可以引用成熟架构模式作为候选项，并记录适配理由、放弃理由和来源 URL

2. **[US2-2]**
   **Given** 某个参考模板属于成熟期系统  
   **When** 当前项目只是 MVP 或个人工具  
   **Then** `plan` 必须显式降级为当前阶段合适的方案，而不是直接复制成熟期设计

**Edge Cases**:

- **[US2-3]** 外部模式只能作为参考证据，不得替代本仓库代码探索和用户需求
- **[US2-4]** 如果没有找到匹配模式，`plan` 应记录 `UNVERIFIED` 或“不适用”，而不是编造来源

### User Story 3 - 用 ADR 留住架构决策的为什么 (Priority: P2)

作为维护者，我希望 `plan` 中关键架构取舍能形成轻量 ADR，以便后续实现、验证和收尾都能检查是否漂移。

**Why this priority**: 架构最容易丢失的是当初为什么这么选。SDD 的 `verify` 和 `closeout` 需要能回查这些决策。

**Acceptance Scenarios**:

1. **[US3-1]**
   **Given** `plan` 中存在关键模块边界、数据流、存储、异步、缓存、扩展性或一致性决策  
   **When** 生成 `plan.md`  
   **Then** 每个关键决策应记录背景、候选、结论、影响、代价和来源

2. **[US3-2]**
   **Given** 实现完成准备进入 `verify`  
   **When** 检查交付证据  
   **Then** 必须检查实现是否违背 plan 中的架构边界或 ADR

**Edge Cases**:

- **[US3-3]** ADR 不应变成重文档流程；只记录影响实现或维护的关键决策
- **[US3-4]** 新实现中出现未记录的新依赖、新状态或新失败模式时，应回退到 `plan` 或补充 ADR

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `sdd` 必须在 `clarify` 阶段加入架构澄清检查，覆盖业务范围、规模、读写特征、一致性、增长、失败代价、硬约束和质量属性。
- **FR-002**: `sdd` 必须在 `spec-template.md` 中强化质量属性表达，使关键非功能需求能支撑后续方案设计。
- **FR-003**: `sdd` 必须在 `plan` 阶段加入架构参考机制，允许引用成熟架构模式、类系统模板和外部来源。
- **FR-004**: 外部成熟架构模式只能作为候选参考，不得覆盖代码现实、用户目标和当前产品阶段。
- **FR-005**: `plan-template.md` 必须支持轻量 ADR：背景、候选、结论、影响、代价、来源。
- **FR-006**: `plan` 必须支持记录架构图、数据流、关键状态、容量/规模估算、模式适配和演进路线。
- **FR-007**: `tasks` 必须能把关键任务映射到用户故事、架构决策或质量属性。
- **FR-008**: `verify` 必须检查实现是否出现架构漂移、未记录依赖、未记录状态或违反关键质量属性。
- **FR-009**: `closeout` 必须检查是否需要沉淀 ADR、演进触发信号和后续架构债。
- **FR-010**: 引用外部仓库时必须保留 URL，并明确来源是参考而非官方项目约束。

### Non-Functional Requirements *(if applicable)*

- **NFR-001**: 架构质量门应保持轻量，不得让所有小改动都背负完整系统设计流程。
- **NFR-002**: `sdd` 仍保持单入口，不新增用户必须记忆的新公开 skill。
- **NFR-003**: 模式参考必须优先服务于取舍判断，而不是制造术语堆叠。
- **NFR-004**: 第一版不新增 `sdd_architect` subagent，除非后续使用证明主线程负担过重。

### Key Entities *(if applicable)*

- **Architecture Quality Gate**: 嵌入 `clarify / plan / tasks / verify / closeout` 的架构质量检查机制。
- **Architecture Pattern Reference**: 来自外部架构模式或类系统模板的参考来源，只用于候选方案和取舍比较。
- **Lightweight ADR**: `plan.md` 内的关键架构决策记录，不单独引入重流程。
- **Quality Attribute**: 性能、可用性、持久性、可扩展性、一致性、安全性、成本、可维护性、可观测性、可演进性等。

---

## Out of Scope *(if applicable)*

- 复制 `awesome-architecture` 的完整教程或模板内容到本仓库
- 把 `architecture-copilot` 作为另一个并列入口并入 `sdd`
- 第一版新增新的架构 subagent
- 为所有 feature 强制生成独立 ADR 文件
- 把成熟期系统架构默认套用到 MVP

---

## Unclear Questions *(if applicable)*

- 是否要在后续版本中提供本地缓存的模式索引，还是第一版只保留外部 URL 和引用规则
- 是否需要为架构模式参考新增独立模板文件，还是先合并进 `plan-template.md`

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项（如有）：无；成熟架构模式可以作为参考引用，但必须带适配检查和来源 URL。
