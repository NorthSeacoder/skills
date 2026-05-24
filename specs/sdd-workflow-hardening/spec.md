# Feature Specification: SDD Workflow Hardening

**Workspace**: `sdd-workflow-hardening`  
**Created**: 2026-05-24  
**Status**: Draft  
**Input**: 用户描述: "优化现有 sdd skill 的阶段设计、执行治理与验证收尾；注意参考 ../skills 下的分析，但目标不是迁移外部 skill，而是吸收它们的优点"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 在写 spec 之前先完成关键澄清与领域对齐 (Priority: P1)

作为 `sdd` 使用者，我希望在正式写 `spec.md` 前先经过 `Clarify / Domain Alignment`，以便术语、边界、既有决策和历史上下文先被压实，而不是把误解直接写进正式规格。

**Why this priority**: 当前 `sdd` 虽然已经具备 `specify / clarify / plan` 路由，但整体主链仍偏“从写 spec 开始”，对前期需求拷打、术语统一、上下文冲突识别的强调不够。本次明确采用“重定义现有 `clarify` 阶段”的方式承载这层能力，而不是新增一个更上游的新阶段名。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** 用户带着模糊或半结构化需求进入 `sdd`  
   **When** 主线程判断需求尚未完成术语、边界或历史决策对齐  
   **Then** 流程先进入 `Clarify / Domain Alignment`，而不是直接生成正式 `spec.md`

2. **[US1-2]**
   **Given** 需求中存在已有决策、术语歧义或上下文冲突  
   **When** `sdd` 执行前期澄清  
   **Then** 输出只聚焦高价值澄清问题，并在后续正式 spec 中反映这些结论

3. **[US1-3]**
   **Given** 前期澄清已经完成  
   **When** 用户进入 `specify`  
   **Then** `spec.md` 只承担需求固化，不再承担前期探索和术语压实的主要职责

**Edge Cases**:

- **[US1-4]** 对非常小的改动或低风险单点修复，`sdd` 应明确退出完整主链，而不是强行引入前期澄清
- **[US1-5]** 如果用户输入本身已经是高质量规格草案，`sdd` 可跳过额外澄清，直接进入 `specify`

### User Story 2 - 计划、执行、验证和收尾形成连续主链 (Priority: P1)

作为 `sdd` 使用者，我希望 `sdd` 不只覆盖前段文档产出，还能明确 `Plan -> Execute -> Verify -> Closeout` 的职责、门禁和交接，以便“计划写完”不再等于“工作完成”。

**Why this priority**: 当前 `sdd` 已有 `plan / tasks / implement / code-review` 等阶段，但主链上的治理强度仍偏弱，尤其是 checkpoint、drift、evidence、retirement closure 这些执行后半段要素还没有形成统一闭环。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** `spec.md` 已稳定  
   **When** 用户进入 `plan`  
   **Then** 方案文档明确模块边界、验证路径和主要风险，而不是退化为任务列表或需求复述

2. **[US2-2]**
   **Given** `plan.md` 已完成并进入执行  
   **When** 用户推进实现  
   **Then** `sdd` 能明确执行节奏、checkpoint、偏移控制和最小任务包，而不是把整段上下文无约束地下发

3. **[US2-3]**
   **Given** 用户声称“已经做完”  
   **When** 流程进入验证和收尾  
   **Then** `sdd` 要求 fresh evidence、review 结论和旧逻辑退役检查，未满足时不能直接视为完成

**Edge Cases**:

- **[US2-4]** 对纯文档型或只读研究型 feature，执行阶段可弱化，但验证与收尾语义仍应存在
- **[US2-5]** 如果实现中发现当前 plan 与仓库现实明显偏离，流程应允许回退到 `clarify` 或 `plan`，而不是硬推进

### User Story 3 - 外部参考以“吸收优点”方式进入现有 sdd (Priority: P1)

作为 `sdd` 维护者，我希望参考 `../skills` 中外部 skill 分析时，目标是吸收各家的优点并重组到现有 `sdd` 体系，而不是迁移、复刻或照搬它们的结构。

**Why this priority**: 当前研究已经识别出不同参考源各自擅长的层面，但若用“迁移”思路推进，容易把外部仓库的结构、术语和重量一并引入，超出 `personal-skills` 需要。

**Acceptance Scenarios**:

1. **[US3-1]**
   **Given** `sdd` 需要强化主链  
   **When** 参考 `agent-skills`、`Aegis`、`skills`、`Waza`、`gstack`、`khazix-skills`  
   **Then** 新 spec 只描述各参考源分别提供哪些可吸收优点，而不要求复制其目录、artifact schema 或平台基础设施

2. **[US3-2]**
   **Given** 某些外部参考源本身非常重  
   **When** `sdd` 吸收它们的优点  
   **Then** 只引入必要的阶段语义、治理门禁或验证意识，不引入整套平台编排

3. **[US3-3]**
   **Given** 参考源之间存在重叠  
   **When** `sdd` 整理新主链  
   **Then** spec 明确每类优点在现有 `sdd` 中落到哪一层，而不是并列堆砌来源

**Edge Cases**:

- **[US3-4]** 某个优点若已经由现有 `sdd` 或上一个 feature 实现，不应重复定义为本次核心改造目标
- **[US3-5]** 某个参考源的优点如果依赖重平台或高维护成本，应明确降级为“可选增强”，不进入主干

### User Story 4 - 路由和校验变成 sdd 主链的基础设施 (Priority: P2)

作为 `sdd` 维护者，我希望 `sdd` 的阶段路由和基础校验不再完全依赖隐式约定，以便路由表、references、阶段命名和触发条件更稳定，不容易在后续演化中悄悄漂移。

**Why this priority**: 研究表明对 `personal-skills` 更合适的是显式路由表和最小 validator，而不是重平台式编排；这部分是 `sdd` 继续扩展前需要补的结构稳定层。

**Acceptance Scenarios**:

1. **[US4-1]**
   **Given** `sdd` 存在多个阶段与 references 文件  
   **When** 维护者调整阶段结构或文档引用  
   **Then** 存在最小可行的校验范围，用于发现路由、命名、引用路径和触发条件失配

2. **[US4-2]**
   **Given** 用户从入口触发 `sdd`  
   **When** skill 判断当前阶段  
   **Then** 阶段映射与推荐路径是显式的，用户能理解为什么进入该阶段以及下一步是什么

**Edge Cases**:

- **[US4-3]** 校验范围应优先覆盖主干 skill，不要求一开始统一治理整个仓库的所有实验性 skill

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `sdd` 必须把主链显式强化为 `Clarify / Domain Alignment -> Spec -> Plan -> Execute -> Verify -> Closeout`
- **FR-002**: `sdd` 必须通过重定义现有 `clarify` 阶段来承载 `Clarify / Domain Alignment`，并明确其与正式 spec 编写的边界，避免把两者继续混在同一职责里
- **FR-003**: `sdd` 必须定义 `Plan`、`Execute`、`Verify`、`Closeout` 的阶段职责、进入条件、回退条件与完成标准，其中 `Verify` 为独立新阶段，`code-review` 降为其中一个检查动作
- **FR-004**: `sdd` 必须在执行后半段引入轻量治理语义，至少覆盖 checkpoint、drift、evidence、retirement closure
- **FR-005**: `sdd` 必须把“没有 fresh evidence 不算完成”提升为 `Verify` 阶段中的显式 gate，而不是礼貌性提醒
- **FR-005A**: `sdd` 必须为 `Closeout` 定义一份可执行 checklist，而不是只停留在阶段语义描述
- **FR-006**: `sdd` 必须把外部参考源的作用表述为“可吸收优点 / 参考来源”，而不是迁移目标或复刻对象
- **FR-007**: `sdd` 必须明确各参考来源分别贡献哪类优点：骨架、治理、纪律、入口、重验证补强、收尾沉淀
- **FR-008**: `sdd` 必须明确哪些能力属于主 skill、哪些属于阶段 references、哪些属于已有 subagent 或后续增强点
- **FR-009**: `sdd` 必须补充显式阶段路由语义，使用户能够理解当前为何进入某阶段以及接下来应走哪一步，并能看出 `code-review`、evidence、runtime/browser 检查在 `Verify` 中的相对位置
- **FR-010**: `sdd` 必须建立最小可行校验范围，至少覆盖阶段命名、references 路径、路由结构和关键约束的一致性；该校验能力是 `sdd` 主链的内建组成部分，默认服务所有走 `sdd` 的流程，但第一版实现范围只落在 `skills/sdd/`
- **FR-011**: 本次 feature 必须把 `sdd-subagent-enhancement` 视为已完成的上游成果，不重复把 subagent 基础设施重做为核心目标

### Non-Functional Requirements *(if applicable)*

- **NFR-001**: 强化后的 `sdd` 必须保持轻量，不引入 `gstack` 式重平台编排或 `Aegis` 式整套 workspace 复制
- **NFR-002**: 新阶段和新约束必须能被当前仓库维护者理解和手工维护，不依赖额外复杂运行时
- **NFR-003**: 路由与校验设计应优先服务 `skills/sdd/` 主干实现，并允许实验性 skill 暂不纳入同等强度治理
- **NFR-004**: 参考来源描述必须可追溯到 `../skills` 分析结论，但最终表述以本仓现有 `sdd` 的强化目标为中心

### Key Entities *(if applicable)*

- **Clarify / Domain Alignment**: 由现有 `clarify` 阶段重定义得到的 `sdd` 主链前段阶段，负责术语、边界、上下文冲突和既有决策对齐
- **Spec Authoring**: 将澄清后的需求固化为 `spec.md` 的阶段，不负责实现方案
- **Execution Governance**: 执行阶段的轻量治理集合，包含 checkpoint、drift、evidence、最小任务包等语义
- **Verification Evidence**: 用于判断 feature 是否真的完成的最新证据，如测试结果、runtime 检查、review 结论
- **Verify Stage**: 独立于 `Execute` 的主链阶段，负责聚合测试、review、runtime/browser QA 与 completion evidence gate
- **Closeout**: 交付尾段，负责旧逻辑退役、发布跟进、文档或知识同步
- **Closeout Checklist**: `Closeout` 阶段使用的可执行检查清单，至少覆盖旧逻辑退役、发布跟进、文档更新和必要的知识同步
- **Reference Advantages**: 从外部 skill 分析中吸收的优点分类，而非待迁移的对象
- **Routing Contract**: `sdd` 入口对阶段映射、进入条件、回退条件和下一步建议的显式约束
- **Validation Surface**: `sdd` 内建的最小防漂移校验面，默认保护所有走 `sdd` 的流程，第一版实现聚焦 `skills/sdd/`，覆盖路由、references、命名与关键约束

---

## Business Metrics *(optional — 上线后度量)*

- **BM-001**: 使用 `sdd` 推进的 feature 中，进入 `plan` 前先经过明确澄清或显式跳过澄清的比例提升
- **BM-002**: 使用 `sdd` 完成的 feature 中，带有显式验证证据与 closeout 结论的比例提升

---

## Out of Scope *(if applicable)*

明确不在本次功能范围内的内容：

- 迁移或复刻 `agent-skills`、`Aegis`、`Waza`、`gstack` 等外部仓库的结构
- 直接引入 `gstack` 式平台级编排、生成层或重 QA 基础设施
- 重做已经在 `sdd-subagent-enhancement` 中落地的 subagent 安装、派生和版本控制机制
- 一次性统一改造整个 `personal-skills` 仓的所有 skill 路由与校验体系
- 完整建设 memory / knowledge 系统，只定义 closeout 后需要预留的同步意识

---

## Unclear Questions *(if applicable)*

探索循环中未能解答、且可能影响后续阶段的遗留问题：

- 无

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项（如有）：无
