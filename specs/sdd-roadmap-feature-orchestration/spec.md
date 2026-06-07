# Feature Specification: SDD Roadmap Feature Orchestration

**Workspace**: `sdd-roadmap-feature-orchestration`
**Created**: 2026-06-06
**Status**: Draft
**Input**: 用户描述: "优化 sdd 这个 skill，如果发现用户描述的一个需求适合拆分成多个 feature 时，自动拆分，有 roadmap，完成一个 feature 后自动更新后序 feature，最终验收后自动推荐下一个 feature，自动提交相关 diff，验收文档中文；分析 https://github.com/mindfold-ai/Trellis，有哪些优秀的设计可以吸收进去；先评估一下这个需求，分析那个似乎可以单独列一个 feature 后续再做"

> 本 feature 只覆盖多 feature 拆分、roadmap 建立、feature 完成后的 roadmap 更新和下一 feature 推荐。中文验收强化、自动提交、Trellis 风格上下文 manifest 作为后续 feature 明确排期，不塞入本期实现。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 改动涉及 ideate / specify / plan / verify / closeout 多阶段协同，并需要在完成一个 feature 后更新后续 feature |
| `external-side-effects` | ❌ | 本期只修改 SDD skill 文档、模板或阶段说明，不执行发布、部署、发送或外部系统写入 |
| `artifact-handoff` | ✅ | roadmap / feature index / specs/.active / acceptance 之间存在明确交接关系 |
| `user-visible-output` | ✅ | 用户可见结果是 SDD 的阶段输出、roadmap 文档和下一 feature 推荐行为变化 |
| `prior-closure-failure` | ✅ | 过往 SDD 使用中已多次人工拆分大需求和复评 roadmap，本次要把该行为内建进 skill，降低遗漏风险 |

**结论**: 本 feature 适用 Producer-Consumer Matrix、Evidence Gate 和三维 Verdict。由于本期不涉及外部副作用，自动提交相关 diff 不在本期完成条件内。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 自动识别多 feature 需求并先做拆分 (Priority: P1)

作为 `sdd` 使用者，我希望当自然语言需求明显包含多个可独立交付的目标时，`sdd` 先进入拆分评估，而不是直接为整个大需求写一个过宽的 spec。

**Why this priority**: 这是本 feature 的入口。若入口仍把大需求当作单 feature，后续 roadmap、状态更新和下一 feature 推荐都无从发生。

**Acceptance Scenarios**:

1. **[US1-1] 大需求触发拆分评估**
   **Given** 用户描述中包含多个独立结果，例如"拆分 feature、有 roadmap、完成后更新后续、自动提交 diff、验收中文"
   **When** 用户触发 `sdd`
   **Then** `sdd` 必须先说明当前进入 `ideate` 或 `specify` 前的拆分评估，并列出候选 feature 边界

2. **[US1-2] 选择首个 feature 进入正式 spec**
   **Given** 拆分评估已识别多个候选 feature
   **When** 用户确认继续
   **Then** `sdd` 必须选定一个优先 feature 写入 `specs/<feature>/spec.md`，并把其他 feature 记录为 roadmap 后续项

3. **[US1-3] 单点小改动不强行拆分**
   **Given** 用户需求只有一个低风险单点修复或文案调整
   **When** 用户触发 `sdd`
   **Then** `sdd` 不应生成 roadmap，也不应把小改动拆成多个 feature

**Edge Cases**:

- **[US1-4]** 如果候选 feature 之间存在强依赖，roadmap 必须记录依赖顺序，而不是只列平行清单
- **[US1-5]** 如果用户明确要求"先只评估，不写文件"，`sdd` 只输出评估，不创建 spec 或 roadmap

### User Story 2 - 建立可续接的 roadmap 产物 (Priority: P1)

作为 `sdd` 使用者，我希望拆分后的 feature roadmap 以仓库文件形式保存，后续会话能恢复当前整体目标、已完成 feature、推荐中的下一个 feature 和延期项。

**Why this priority**: Trellis 的核心优点之一是把任务状态和记忆写入仓库文件，而不是依赖聊天上下文。SDD 需要吸收这个文件驱动状态思想，但保持现有 `specs/` 目录约定。

**Acceptance Scenarios**:

1. **[US2-1] roadmap 写入稳定位置**
   **Given** 当前需求被拆成多个 feature
   **When** `sdd` 写入首个 feature spec
   **Then** 必须同时创建或更新一个 roadmap 产物，记录 umbrella 目标、feature 列表、状态、依赖、推荐顺序和当前 active feature

2. **[US2-2] roadmap 与 specs/.active 对齐**
   **Given** roadmap 中标记某个 feature 为 current
   **When** 检查 `specs/.active`
   **Then** `specs/.active` 必须指向同一个 feature；若不一致，后续阶段必须提示失配并先修正

3. **[US2-3] 后续 feature 保持轻量占位**
   **Given** roadmap 中存在尚未启动的后续 feature
   **When** 首个 feature 正在推进
   **Then** 后续 feature 不强制提前生成完整 spec，只需保留名称、目标、依赖、状态和启动条件

**Edge Cases**:

- **[US2-4]** 如果已经存在相关 roadmap，`sdd` 必须更新现有 roadmap，而不是新建重复路线
- **[US2-5]** 如果后续 feature 被用户取消，roadmap 应标记为 cancelled 或 dropped，并记录理由

### User Story 3 - Feature 完成后自动更新后续顺序 (Priority: P1)

作为 `sdd` 使用者，我希望一个 feature 验证和收尾完成后，`sdd` 自动复评 roadmap，更新后续 feature 的状态、依赖和推荐顺序。

**Why this priority**: 当前 SDD closeout 能宣布单个 feature 完成，但没有一等机制把完成结论反馈到更大的 roadmap，容易导致后续 feature 顺序过期。

**Acceptance Scenarios**:

1. **[US3-1] closeout 后更新 roadmap**
   **Given** 当前 feature 的 verify 为 PASS 且 closeout 完成
   **When** `sdd` 执行收尾
   **Then** roadmap 必须把当前 feature 标记为 done，并记录完成日期、验收文档路径和关键证据摘要

2. **[US3-2] 复评未完成 feature**
   **Given** 当前 feature 完成后影响了后续依赖或风险
   **When** roadmap 更新
   **Then** `sdd` 必须重新评估后续 feature 的推荐顺序，必要时调整 `next recommended`

3. **[US3-3] 自动推荐下一个 feature**
   **Given** roadmap 中仍有未完成 feature
   **When** 当前 feature closeout 完成
   **Then** 最终输出必须推荐下一个 feature，并说明推荐依据、启动条件和建议进入的 SDD 阶段

**Edge Cases**:

- **[US3-4]** 如果当前 feature 只达到 CONDITIONAL PASS，不得把 roadmap 状态标记为 done，只能标记 blocked 或 conditional，并说明缺口
- **[US3-5]** 如果后续 feature 全部完成，`sdd` 应建议做 roadmap closeout，而不是推荐不存在的下一个 feature

### User Story 4 - 明确后续 feature 边界，不让本期过载 (Priority: P2)

作为 `sdd` 维护者，我希望本期只交付 roadmap 编排能力，同时把中文验收、自动提交和 Trellis 风格上下文 manifest 明确列为后续 feature，以免一次改动横跨过多阶段和文件契约。

**Why this priority**: 用户原始需求本身已经包含多个 feature。若本期继续把所有内容一起做，会复现本 feature 要解决的过宽需求问题。

**Acceptance Scenarios**:

1. **[US4-1] 后续 feature 被显式记录**
   **Given** 本期 spec 写入
   **When** 查看 roadmap 或 Out of Scope
   **Then** 必须能看到 `chinese-acceptance-and-closeout-record`、`commit-boundary-and-diff-automation`、`trellis-style-context-manifests` 三个后续 feature

2. **[US4-2] 本期不实现自动提交**
   **Given** 用户原始需求包含"自动提交相关 diff"
   **When** 验收本期 feature
   **Then** 不得要求本期已经能自动 git commit；只需 roadmap 中记录该能力作为后续 feature

3. **[US4-3] Trellis 设计吸收先落在 roadmap 编排**
   **Given** 已分析 Trellis
   **When** 本期进入 plan
   **Then** 只能吸收文件驱动状态、任务状态、finish 后归档/更新的设计思想；`implement.jsonl` / `check.jsonl` 类上下文 manifest 单独后置

**Edge Cases**:

- **[US4-4]** 如果 plan 阶段发现自动提交与 roadmap closeout 强耦合，仍应先记录为 ADR 风险，不应扩大本期完成条件

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `sdd` 必须在需求评估或 specify 前识别"一个用户需求是否适合拆成多个 feature"，并输出拆分依据
- **FR-002**: 当需求被拆成多个 feature 时，`sdd` 必须生成或更新一个 roadmap 产物，记录 umbrella 目标、feature 列表、状态、依赖、推荐顺序和当前 feature
- **FR-003**: roadmap 中每个 feature 至少包含 `name`、`goal`、`status`、`depends_on`、`start_condition`、`recommended_stage`、`notes`
- **FR-004**: `sdd` 必须把首个推荐 feature 写入标准 `specs/<feature>/spec.md`，并同步更新 `specs/.active`
- **FR-005**: `sdd` 必须在 closeout 完成后更新 roadmap，把当前 feature 标记为 done 或 conditional / blocked，并记录完成证据或缺口
- **FR-006**: `sdd` 必须在 feature 完成后自动推荐下一个 feature；若无下一个 feature，必须建议 roadmap closeout
- **FR-007**: 如果 `specs/.active` 与 roadmap 当前 feature 不一致，`sdd` 必须提示失配并先修正，不得静默继续
- **FR-008**: `sdd` 必须明确支持"只评估不写文件"的用户意图；只有用户同意推进正式流程时才创建 spec / roadmap
- **FR-009**: 本期必须把以下能力记录为后续 feature，而非当前完成条件：中文验收文档强化、自动提交相关 diff、Trellis 风格 implement/check context manifest

### Non-Functional Requirements

- **NFR-001**: 新增 roadmap 机制必须保持现有 `specs/` 工作区约定，不引入 `.trellis/` 目录或复制 Trellis 平台结构
- **NFR-002**: roadmap 必须是人类可读、可审查、可手工编辑的 Markdown 产物
- **NFR-003**: 本期不依赖新的运行时工具或外部服务，优先通过 `SKILL.md`、阶段 reference 和模板约定落地
- **NFR-004**: 规则必须允许小改动退出完整 SDD，不因 roadmap 机制增加无谓流程成本

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可续接性 | 后续会话能从文件恢复 roadmap 状态 | 大需求跨 feature 时聊天上下文容易丢失 | plan 需定义 roadmap 文件位置、字段和 `.active` 对齐规则 | 是 |
| 低耦合 | roadmap 编排不重写现有阶段链 | SDD 已有 specify/plan/tasks/verify/closeout，不能引入平行流程 | plan 需说明各阶段只增加哪些责任 | 是 |
| 可演进性 | 后续 feature 可在 roadmap 上增量接入 | 中文验收、自动提交、context manifest 都要后续扩展 | roadmap 必须容纳 future/backlog/blocked 状态 | 是 |
| 可审查性 | 用户能看懂为何推荐下一个 feature | 推荐顺序影响后续工作投入 | closeout 输出必须说明推荐依据 | 否 |

### Key Entities

- **Umbrella Roadmap**: 一个大需求拆分后的总体路线产物，记录总目标、feature 列表、状态、依赖、当前 feature 和下一步推荐
- **Roadmap Feature Item**: roadmap 中的单个 feature 条目，包含名称、目标、状态、依赖、启动条件、推荐阶段和备注
- **Current Feature**: 当前进入标准 `specs/<feature>/` 流程的 feature，必须与 `specs/.active` 对齐
- **Next Recommended Feature**: 当前 feature 完成或阻塞后，SDD 推荐用户下一步推进的 feature
- **Completion Feedback**: closeout 后写回 roadmap 的完成日期、证据摘要、验收文档路径和对后续 feature 的影响

---

## Business Metrics *(optional — 上线后度量)*

- **BM-001**: 使用 `sdd` 处理大需求时，能显式生成 feature 拆分和 roadmap 的比例提升
- **BM-002**: feature closeout 后，用户能收到下一 feature 推荐且 roadmap 被更新的比例提升

---

## Out of Scope *(if applicable)*

- **F2 `chinese-acceptance-and-closeout-record`**: 强制所有最终验收文档中文、统一 acceptance 中文模板、完善中文 Evidence Table 表达
- **F3 `commit-boundary-and-diff-automation`**: 自动识别本 feature 相关 diff、排除无关 dirty files、生成 commit plan，并经用户确认后自动提交
- **F4 `trellis-style-context-manifests`**: 吸收 Trellis `implement.jsonl` / `check.jsonl` / `research.jsonl` 思路，为 SDD feature 建立实现和验证上下文清单
- 引入 `.trellis/` 目录、Trellis CLI 或 Trellis 多平台初始化机制
- 一次性重写 SDD subagent 架构
- 对历史 specs 进行批量迁移或补写 roadmap

---

## Unclear Questions *(if applicable)*

- **UQ-001**: roadmap 的默认文件位置是 `specs/<umbrella>/roadmap.md`，还是在首个 feature 目录内放 `roadmap.md` 并由字段指向 umbrella？留给 plan 阶段决策
- **UQ-002**: roadmap 是否需要独立模板 `templates/roadmap-template.md`，还是先写入阶段说明中的固定格式？留给 plan 阶段决策
- **UQ-003**: roadmap closeout 是否需要单独文件，还是复用最后一个 feature 的 `acceptance.md` 汇总？留给后续 roadmap closeout 设计

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。本期边界已明确，三个后续 feature 已列入 Out of Scope，可进入技术方案设计。
