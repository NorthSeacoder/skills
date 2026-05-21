# Feature Specification: Evolve personal-skills Repository And Harden SDD

**Workspace**: `evolve-personal-skills-and-sdd`  
**Created**: 2026-05-21  
**Status**: Draft  
**Input**: 用户描述: "为 `~/personal/personal-skills` 写一份 PRD。目标不是盲目套用多 skill 平台模板，而是在当前以 `sdd` 为主公开 skill、以 `skills.sh` 为分发方式的前提下，同时优化整个仓库骨架与 `sdd` 的产品化程度。要求明确：`sdd` 只管软件交付，不负责路由其他 skill；当前阶段不以拆分 `sdd` 为多个 skill 为目标；文档中不要提 `context-hub`，但应把必要的校验要求收敛清楚。"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 仓库骨架更清楚，公开与自用边界更稳定 (Priority: P1)

作为仓库维护者，我希望 `personal-skills` 的目录、文档和 skill 边界更清楚，以便后续继续演进时，不会把公开分发、个人自用和 `sdd` 的内部资产混在一起。

**Why this priority**: 当前仓库已经不止一个 skill，同时又以 `sdd` 为主公开 skill。若边界不清楚，后续新增或维护时容易发生文档承诺和实际可用性不一致。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** 新用户或未来维护者查看仓库根目录  
   **When** 阅读 README、AGENTS.md 和结构说明  
   **Then** 能清楚理解哪些是公开 skill、哪些是自用 skill、哪些目录服务于 `sdd` 内部工作流

2. **[US1-2]**
   **Given** 仓库继续通过 `skills.sh` 分发  
   **When** 新增或调整 skill  
   **Then** 目录与文档约定能支持长期维护，而不是依赖口头约定或个人记忆

**Edge Cases**:

- **[US1-3]** 某个 skill 保留在仓库中但不保证公开跨环境可用时，文档必须明确其维护级别
- **[US1-4]** 仓库内存在治理文档、流程文档和 skill 运行资产时，不应让用户误以为它们都属于公开安装接口

### User Story 2 - `sdd` 单入口更清楚、更稳、更易维护 (Priority: P1)

作为 `sdd` 的使用者，我希望继续只记住一个 `sdd` 入口，但它的阶段边界、依赖产物和下一步衔接更清楚，以便我能稳定地用它推进交付流程。

**Why this priority**: `sdd` 已经是当前仓库最重要的公开 skill。若入口虽统一但阶段边界模糊，用户仍会在实际使用中失去确定性。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** 用户只提到 `sdd`  
   **When** skill 判断当前所处阶段  
   **Then** 能明确说明当前进入哪个阶段、依据是什么、会产出什么、下一步建议是什么

2. **[US2-2]**
   **Given** `specs/<feature>/` 下已有部分产物  
   **When** 用户继续推进工作  
   **Then** `sdd` 能根据现有产物判断当前阶段，必要时回退上游，而不是盲目往前推进

3. **[US2-3]**
   **Given** `sdd` 只负责软件交付流程  
   **When** 仓库中同时存在 `debug`、`git-guard`、`knowledge-management`  
   **Then** `sdd` 不承担这些 skill 的统一路由职责，也不因为它们的存在而扩大自身边界

**Edge Cases**:

- **[US2-4]** 如果某阶段缺关键上游产物，`sdd` 必须返回上游阶段，而不是继续写下游文档
- **[US2-5]** 如果任务规模很小或明显不适合 SDD 流程，`sdd` 应保持克制，不强行套完整流程
- **[US2-6]** 当前阶段不以把 `sdd` 拆成多个 skill 为目标，除非后续出现明确维护痛点或复用证据

### User Story 3 - `sdd` 的产物与校验模型可预测 (Priority: P2)

作为维护者和使用者，我希望 `sdd` 的交付产物、完成标准和校验层次更明确，以便流程不是“写几份文档”，而是“能判断是否达标”。

**Why this priority**: 单入口 skill 要想长期稳定，不能只靠阶段名称，还必须有清楚的产物模型和校验规则。

**Acceptance Scenarios**:

1. **[US3-1]**
   **Given** `sdd` 工作区约定使用 `specs/<feature>/`  
   **When** 用户进入某阶段  
   **Then** 能清楚知道哪些文件是核心必备、哪些是可选扩展、当前会写或更新哪些文件

2. **[US3-2]**
   **Given** 某一阶段已完成  
   **When** 判断是否可以进入下一阶段  
   **Then** 存在明确的阶段内校验和产物校验，而不是只凭主观感觉判断

3. **[US3-3]**
   **Given** 仓库结构或 `sdd` 资产发生调整  
   **When** 维护者检查一致性  
   **Then** 能根据仓库结构校验规则发现模板、阶段说明、引用关系或公开边界的漂移

**Edge Cases**:

- **[US3-4]** `specs/.active` 若与实际正在推进的 feature 不一致，规则应说明如何更新和恢复
- **[US3-5]** 可选文档如 `data-model.md`、`acceptance.md` 不应被默认强制，但其使用条件必须清楚

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 仓库必须明确区分三类内容：公开分发 skill、自用 skill、以及服务于 skill 维护或工作流的仓库级文档/资产。
- **FR-002**: README 与相关说明文档必须清楚说明 `sdd` 是当前主公开交付 skill，以及其他 skill 的维护边界。
- **FR-003**: `sdd` 必须继续作为单入口软件交付 workflow skill 存在，不以本次演进为契机拆分为多个公开 skill。
- **FR-004**: `sdd` 的职责边界必须明确限定在软件交付流程内，不负责统一路由 `debug`、`git-guard`、`knowledge-management` 等其他 skill。
- **FR-005**: `sdd` 必须为其主要阶段定义清晰的进入条件、依赖产物、阶段产出、回退条件和下一步建议。
- **FR-006**: `sdd` 必须明确 `specs/<feature>/` 的核心产物模型，至少覆盖 `spec.md`、`plan.md`、`tasks.md` 的角色与依赖关系。
- **FR-007**: `sdd` 必须说明 `data-model.md`、`acceptance.md` 等扩展产物在什么条件下创建或更新。
- **FR-008**: `sdd` 必须定义 `specs/.active` 的语义、更新时机和失配时的处理方式。
- **FR-009**: 仓库必须定义三层校验模型：
  - 阶段内校验：判断单个阶段是否完成
  - 产物校验：判断 `spec/plan/tasks` 等交付文档是否满足最小质量要求
  - 仓库结构校验：判断阶段说明、模板、引用关系、公开边界和目录结构是否一致
- **FR-010**: 仓库结构必须支持 `sdd` 的长期维护，把入口、阶段说明、模板、规则与仓库治理文档分开，而不是继续把它们混成单层说明。
- **FR-011**: 仓库必须继续兼容 `skills.sh` 的安装与分发模型，并避免文档承诺超出实际可移植性。
- **FR-012**: 对自用 skill，不得因为与 `sdd` 同仓存在，就自动推导为公开分发承诺。

### Non-Functional Requirements *(if applicable)*

- **NFR-001**: 改造后仓库应优先提升可理解性和可维护性，而不是追求平台化复杂度。
- **NFR-002**: `sdd` 的单入口体验必须保留，新增规则不应让用户重新记住一组拆开的子 skill 名称。
- **NFR-003**: 新的目录和文档结构应支持未来继续增长，但不应为了假想的多 skill 平台演进提前引入重型基础设施。
- **NFR-004**: 校验要求应以“能防止明显漂移”为目标，而不是一次性建设大而全的自动化系统。

### Key Entities *(if applicable)*

- **`sdd` skill**: 当前主公开交付 workflow skill，负责从需求推进到规格、计划、任务、实现与审查的单入口流程。
- **阶段资产**: 位于 `skills/sdd/references/stages/` 的阶段说明文档，定义不同阶段的行为边界。
- **模板资产**: 位于 `skills/sdd/templates/` 的工作区写入模板，用于生成或更新 `specs/<feature>/` 下的文档。
- **工作区产物**: 位于 `specs/<feature>/` 的交付文件，如 `spec.md`、`plan.md`、`tasks.md`、`data-model.md`、`acceptance.md`。
- **仓库治理文档**: 面向仓库维护与分发边界的说明文档，如 README、AGENTS.md、架构说明和维护规范。
- **自用 skill**: 位于 `skills/` 下但不默认承诺公开跨环境可用性的 skill，如 `debug`、`git-guard`、`knowledge-management`。

---

## Business Metrics *(optional — 上线后度量)*

- **BM-001**: 新维护者能在阅读根级文档后快速判断仓库哪些内容属于 `sdd` 主流程，哪些属于自用或治理层。
- **BM-002**: 用户在只记住 `sdd` 的情况下，能更稳定地完成阶段判断和产物推进，而不是频繁依赖额外口头解释。
- **BM-003**: 仓库在新增阶段说明、模板或辅助文档时，更少出现引用漂移、边界混乱或公开承诺失真的问题。

---

## Out of Scope *(if applicable)*

明确不在本次功能范围内的内容：

- 将 `sdd` 拆分为多个公开 skill
- 把 `sdd` 扩展为整个仓库的统一路由器
- 为 `skills.sh` 平台增加新能力
- 把所有自用 skill 都重构为公开可移植 skill
- 一次性建设重型自动化 validator、生成器或平台式编排系统
- 以“未来可能需要”为理由预先引入 `gstack` 式重平台结构

---

## Unclear Questions *(if applicable)*

探索循环后仍可保留到计划阶段的问题：

- 三层校验中，哪些部分在第一轮以文档规则存在，哪些部分应直接落为脚本校验，可在后续 `plan` 阶段再精化
- `sdd` 是否需要新增独立的规则型资产目录，还是继续在现有 `references/` 与 `templates/` 结构内收敛，可在结构设计时再决定
