# Feature Specification: Migrate Repository To Skills.sh Distribution

**Workspace**: `migrate-to-skills-sh-distribution`  
**Created**: 2026-05-16  
**Status**: Draft  
**Input**: 用户描述: "基于前述讨论，评估并规格化如何把当前 personal-skills 仓库从手动发布到 `.agents/.claude` 的模式，迁移为面向 `skills.sh` 的可安装 skill 仓库。移除 registry，重构 SDD 结构，并判断 knowledge-management 是否继续独立对外。"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 以 skills.sh 方式分发仓库 (Priority: P1)

作为仓库维护者，我希望这个仓库可以被其他环境通过 `npx skills add` 直接安装，以便不再依赖本地软链接发布流程。

**Why this priority**: 这是本次仓库改造的核心目标，决定了目录结构、README、仓库边界和后续维护方式。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** 当前仓库仍以 `registry/skills.yaml` 和 `scripts/publish-links.sh` 为中心  
   **When** 本次改造完成  
   **Then** 仓库对外说明应以 `skills.sh` 安装方式为主，而不是本地运行时目录发布

2. **[US1-2]**
   **Given** 新用户在其他环境查看本仓库  
   **When** 阅读 README  
   **Then** 能明确看到仓库提供哪些可安装 skill、如何安装、以及相关前置条件

**Edge Cases**:

- **[US1-3]** 仓库中原有脚本或文档若继续存在，不应让用户误以为手动发布仍是主流程
- **[US1-4]** 迁移后若某个 skill 不能跨环境使用，README 必须明确说明限制，而不是隐含失败

### User Story 2 - 收敛可公开分发的 skill 边界 (Priority: P1)

作为维护者，我希望仓库只暴露真正可单独理解和安装的 skill，以便降低安装复杂度并反映真实使用方式。

**Why this priority**: 现有多个 SDD skill 强耦合，继续拆散发布会增加认知负担且与实际使用方式不符。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** 当前 SDD 流程由 `specify / clarify / plan / tasks / implement / code-review / execute-plan` 等多个 skill 组成  
   **When** 仓库架构完成调整  
   **Then** 对外应以单个 `sdd` skill 作为该流程的安装与使用入口

2. **[US2-2]**
   **Given** `knowledge-management` 依赖 `nmem` 且是否能稳定跨环境复用仍不确定  
   **When** 完成本次仓库架构调整  
   **Then** 该 skill 不应阻塞主迁移目标；必要时可以暂不作为对外公开安装单元

**Edge Cases**:

- **[US2-3]** 如果 `knowledge-management` 包含本地路径、私有仓库或仅个人环境可用的硬编码，可以选择不对外公开，而不是为兼容其现状扩大本次改造范围
- **[US2-4]** `sdd` 内部可以继续保留分阶段方法论，但这些阶段不应继续作为独立安装单元暴露
- **[US2-5]** `sdd` 收敛为单一 skill 后，用户仍应能通过直接调用 `sdd` 进入流程，并由 skill 内部提示或推进下一阶段，而不是要求用户记住多个子 skill 名称

### User Story 3 - 统一私有配置约定 (Priority: P2)

作为安装使用者，我希望每个对外 skill 的私有依赖都能通过清晰的环境变量约定配置，以便单独安装某个 skill 时也能独立完成设置。

**Why this priority**: skill 能否真正跨环境使用，取决于配置模型是否独立、可理解、无个人环境耦合。

**Acceptance Scenarios**:

1. **[US3-1]**
   **Given** 某个对外 skill 需要私有配置  
   **When** 用户只安装该 skill  
   **Then** 该 skill 的配置要求应能独立理解，不依赖仓库内其他 skill 的上下文

2. **[US3-2]**
   **Given** 仓库中可能存在多个对外 skill，但 `sdd` 是主入口  
   **When** 定义环境变量规范  
   **Then** 变量命名和说明应按 skill 维度隔离，避免单一仓库级配置混杂所有依赖

**Edge Cases**:

- **[US3-3]** 若 `skills.sh` 本身不提供按 skill 自动加载 `.env` 的机制，仓库文档必须明确这是一种配置约定，而不是平台保证

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 仓库必须从“本地发布到 `~/.agents/skills` / `~/.claude/skills`”的主模型，迁移为“面向 `skills.sh` 的可安装 skill 仓库”。
- **FR-002**: 仓库必须移除对 `registry/skills.yaml` 的核心依赖，不再以 registry 作为安装与发布的事实来源。
- **FR-003**: 仓库必须把现有强耦合的 SDD skill 收敛为单个对外 `sdd` skill。
- **FR-004**: `sdd` skill 必须覆盖当前 SDD 交付链路中用户实际需要的阶段能力，包括需求规格、澄清、计划、任务拆解、实现、审查和执行推进。
- **FR-005**: `sdd` skill 必须定义单一入口下的使用方式，使安装后的用户可以直接通过引用 `sdd` 启动流程，并由 skill 内部承接阶段切换与下一步提示。
- **FR-006**: README 必须说明仓库提供的对外 skill、`skills.sh` 安装方式、适用前置条件、隐私配置约定和致谢来源。
- **FR-007**: 仓库规范文档（如 `AGENTS.md`、架构说明、维护规范）必须更新为新架构，不再把 registry 或 publish-links 作为主流程。
- **FR-008**: 每个需要私有配置的对外 skill 必须有独立的配置说明，并使用带 skill 前缀的环境变量命名约定。
- **FR-009**: 对外 skill 不得依赖写死的个人本地路径、私有目录结构或未说明的私有工具前置条件。
- **FR-010**: `knowledge-management` 不得成为本次仓库迁移的必保留对外 skill；若其跨环境可用性不足，可以保留源码但不作为公开安装单元。

### Non-Functional Requirements *(if applicable)*

- **NFR-001**: 改造后的仓库结构应尽量简化，优先减少对外 skill 数量和理解成本。
- **NFR-002**: 文档必须让首次接触该仓库的使用者在短时间内判断“能否安装”和“安装后是否可用”。
- **NFR-003**: 私有配置约定必须可扩展，允许未来新增对外 skill 时保持一致模式。

### Key Entities *(if applicable)*

- **`sdd` skill**: 本仓库对外提供的主交付流程 skill，承载原本分散在多个 SDD 子 skill 中的能力。
- **`knowledge-management` skill**: 依赖 `nmem` 的候选独立 skill；是否对外公开取决于其跨环境可用性，不构成本次迁移完成条件。
- **对外 skill 配置约定**: 以 skill 为维度的环境变量说明、示例文件和前置依赖声明。

---

## Business Metrics *(optional — 上线后度量)*

- **BM-001**: 新用户无需阅读旧发布脚本即可理解如何安装本仓库的 skill。
- **BM-002**: 仓库对外暴露的 skill 数量明显少于当前拆散的 SDD skill 数量，且 `sdd` 成为清晰唯一的主入口。

---

## Out of Scope *(if applicable)*

明确不在本次功能范围内的内容：

- 保留对旧 `registry + publish-links` 模型的兼容支持
- 为 `skills.sh` 平台本身新增能力，例如自动按 skill 加载 `.env`
- 扩展与本次仓库架构调整无关的新 skill 功能
- 为所有历史 skill 保留独立安装形态
- 强制 `knowledge-management` 在本次改造中必须公开发布

---

## Unclear Questions *(if applicable)*

探索循环中未能解答、且可能影响后续阶段的遗留问题：

- 仓库是否最终只保留 `sdd` 一个对外 skill，或同时保留 `knowledge-management` 作为可选对外 skill，可以在实现前根据可移植性检查再决定；这不会阻塞进入 `plan`
