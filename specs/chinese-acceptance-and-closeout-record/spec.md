# Feature Specification: 中文验收与收尾记录

**Workspace**: `chinese-acceptance-and-closeout-record`  
**Created**: 2026-06-06  
**Status**: Draft  
**Input**: 用户描述: "`$sdd specify chinese-acceptance-and-closeout-record`"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 需求作用于 `verify -> closeout -> acceptance record` 的连续阶段，且 closeout 依赖 verify verdict 与 evidence。 |
| `external-side-effects` | ❌ | 本 feature 只定义本地 SDD 文档与记录要求，不涉及发布、发送、部署或第三方写入。 |
| `artifact-handoff` | ✅ | `spec.md`、verify 结论和 closeout checklist 会共同决定是否生成或更新 `acceptance.md`。 |
| `user-visible-output` | ✅ | 最终产物是用户直接阅读的中文验收记录、收尾结论和 completion record。 |
| `prior-closure-failure` | ✅ | 现有参考分析明确指出 verify / closeout 太弱，存在没有 fresh evidence 就宣布完成、旧逻辑未退役仍留在主链的问题。 |

**结论**: 本 feature 需要启用 Producer-Consumer Matrix、Evidence Gate、Workflow Replay 和三维 Verdict 强化规则。后续 plan 必须说明 verify 证据如何交给 closeout，closeout 如何生成中文 completion record。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 生成中文验收记录 (Priority: P1)

作为使用 SDD 工作流交付功能的用户，我希望在验证通过后得到中文 `acceptance.md`，以便快速判断功能是否真的满足 spec、证据是否可追溯、是否还有未完成事项。

**Why this priority**: 验收记录是用户最终判断交付状态的主要可见产物；如果仍是空泛结论，Evidence Gate 就无法成立。

**Acceptance Scenarios**:

1. **US1-1：命中强化 trait 时生成中文 acceptance record**
   **Given** 当前 feature 的 `spec.md` 至少命中一个 Feature Trait，且 verify 阶段给出 PASS 或 CONDITIONAL PASS  
   **When** 用户进入 closeout 阶段  
   **Then** 系统必须生成或更新 `specs/<feature>/acceptance.md`，并使用中文记录 Evidence Table、三维 Verdict、Overall 结论和必要说明。

2. **US1-2：每条关键需求都有证据**
   **Given** `spec.md` 中存在 P0/P1 user story 或关键 functional requirement  
   **When** closeout 写入 Evidence Table  
   **Then** 每条关键需求必须至少对应一条可定位证据，证据可指向测试名、文件路径、行为观察、payload 摘要、日志位置或人工验证记录。

3. **US1-3：证据不足时不得写 PASS**
   **Given** 某条关键需求只有实现描述，没有测试、文件、行为观察或人工验证证据  
   **When** closeout 评估该需求  
   **Then** 对应 Verdict 必须为 PARTIAL 或 FAIL，并说明缺少什么证据才能升为 PASS。

**Edge Cases**:

- **US1-4** 如果 feature 没有命中任何 trait，closeout 可以不生成 `acceptance.md`，但必须用中文给出简短收尾结论和跳过原因。
- **US1-5** 如果 verify 没有 PASS，closeout 必须回退到 verify 或 implement，不得生成完成态 acceptance record。
- **US1-6** 如果三维 Verdict 不一致，acceptance record 必须用中文解释为什么 Overall 是 CONDITIONAL PASS 或 FAIL。

### User Story 2 - 强化中文 closeout completion record (Priority: P1)

作为维护 SDD skill 的用户，我希望 closeout 不只是礼貌性总结，而是用中文逐项记录旧逻辑退役、发布跟进、文档同步和知识沉淀状态，以便后续能追溯为什么可以宣布 feature 完成。

**Why this priority**: 当前参考分析指出 closeout 弱点集中在 fresh evidence、retirement closure 和 follow-through。中文 completion record 是把这些检查变成可审计结果的核心。

**Acceptance Scenarios**:

1. **US2-1：closeout checklist 必须有中文状态**
   **Given** 用户进入 closeout 阶段  
   **When** 系统完成 closeout 检查  
   **Then** completion record 必须逐项说明旧逻辑退役、发布/提交/CI/follow-through、文档更新、ADR/架构债、演进触发信号、知识同步的状态，并标注“已完成 / 延后 / 不适用 / 阻塞”。

2. **US2-2：旧逻辑退役不能被默认跳过**
   **Given** feature 涉及 bugfix、refactor、contract change、workflow change 或替换旧路径  
   **When** closeout 生成 completion record  
   **Then** 必须明确旧路径、fallback、临时兼容或旧文档是否需要退役；如果保留，必须写明保留原因和后续触发条件。

3. **US2-3：未完成事项阻止完成声明**
   **Given** closeout checklist 中存在阻塞项  
   **When** 系统生成最终结论  
   **Then** 不得宣布 feature 完成，必须指出回退到 `implement`、`verify` 或继续 `closeout` 的下一步。

**Edge Cases**:

- **US2-4** 如果某项 checklist 与当前 feature 无关，必须标注“不适用”并给出一句依据，而不是留空。
- **US2-5** 如果需要知识同步但目标知识库或工具不可用，completion record 必须标注为“延后”或“阻塞”，并说明恢复条件。

### User Story 3 - 保持 SDD 阶段边界清晰 (Priority: P2)

作为维护者，我希望这个 feature 只规定验收和收尾记录的需求语义，不提前绑定具体实现方式，以便后续 plan 能根据主仓实际结构选择最小改动路径。

**Why this priority**: 当前工作区是参考研究基座，不是个人主 skill 源仓；spec 需要提供迁移输入，而不是在参考仓里直接改造正式 skill。

**Acceptance Scenarios**:

1. **US3-1：spec 不写实现方案**
   **Given** 当前处于 specify 阶段  
   **When** 写入本文件  
   **Then** 文件只描述用户场景、需求、范围、验收语义和边界，不规定具体代码结构、函数名或文件改动。

2. **US3-2：产物可迁移到主仓**
   **Given** `~/personal/skills` 是参考工作区，`~/personal/personal-skills` 是主 skill 源仓  
   **When** 后续进入 plan 阶段  
   **Then** plan 必须明确哪些需求可迁移到主仓，以及哪些参考材料仅作为设计依据。

**Edge Cases**:

- **US3-3** 如果后续发现主仓已有相同能力，plan 必须转为差距分析和补强，而不是重复实现。

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SDD closeout 阶段必须在中文 completion record 中记录验收结论，而不是只输出“已完成”类泛化总结。
- **FR-002**: 当任一 Feature Trait 命中时，系统必须要求生成或更新 `specs/<feature>/acceptance.md`；只有用户显式选择轻量路径或无 trait 命中时，才能记录跳过原因。
- **FR-003**: `acceptance.md` 必须包含中文 Evidence Table，且每条 P0/P1 requirement 或关键验收场景必须有可定位证据。
- **FR-004**: `acceptance.md` 必须包含中文三维 Verdict：Component capability、Workflow closure、User-visible outcome，以及 Overall 结论。
- **FR-005**: 当 `multi-stage-workflow` 与 `user-visible-output` 同时命中时，系统必须要求记录 Workflow Replay，包括输入摘要、最终 payload 或产物摘要、用户可见结果断言和 replay 类型。
- **FR-006**: closeout 必须逐项检查旧逻辑退役、发布/提交/CI/follow-through、文档更新、ADR/架构债、演进触发信号和知识同步，并把最终 completion record 写入 `acceptance.md`。
- **FR-007**: 如果 verify 未通过、证据不足或 closeout checklist 存在阻塞项，系统必须阻止完成声明，并给出回退阶段。
- **FR-008**: 所有面向用户的 acceptance 和 closeout 记录必须使用简体中文，保留必要英文术语时必须服务于 SDD 阶段语义。
- **FR-009**: 需求必须兼容“无 trait 命中”的轻量路径：可跳过 `acceptance.md`，但必须记录中文跳过原因。
- **FR-010**: 规格必须保留从参考工作区迁移到主仓的边界说明，不把 `~/personal/skills` 当作正式实现仓。
- **FR-011**: 中文验收和收尾记录必须避免空泛、模板化的段末总结句；每个结论都应对应状态、证据或下一步。

### Non-Functional Requirements

- **NFR-001**: 记录格式必须足够短，避免把 closeout 变成重流程；每个 checklist 项应能用一句状态和证据定位表达。
- **NFR-002**: 记录必须可审计，不能只使用“已实现”“测试通过”“review 通过”等不可定位表述。
- **NFR-003**: 输出语言必须稳定为简体中文，避免中英混杂导致用户无法快速判断状态。
- **NFR-004**: 需求必须允许手工验证证据存在，因为部分 skill 行为无法完全自动化测试。
- **NFR-005**: 中文表达必须自然、短句优先，避免为了形式完整而堆叠结构化套话。

### Quality Attributes *(if architecture-relevant)*

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可追溯性 | 每条关键结论能定位到证据 | closeout 是最终 gate，不能依赖口头判断 | `acceptance.md` Evidence Table 有具体测试、文件、日志或人工验证记录 | 是 |
| 可维护性 | 中文模板和阶段规则职责清晰 | 避免后续 SDD 阶段继续漂移 | plan 明确模板、阶段规则和调用点边界 | 是 |
| 轻量性 | 小 feature 不被强制重流程 | SDD 需要保留 fast path | 无 trait 命中时能记录跳过原因并收尾 | 否 |

### Key Entities *(if applicable)*

- **Acceptance Record**: `specs/<feature>/acceptance.md`，记录 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist 和最终结论。
- **Completion Record**: closeout 阶段形成的最终中文完成记录；命中任一 trait 时统一写入 `acceptance.md`，closeout 对话输出只保留摘要和下一步。
- **Evidence Item**: 支撑某条 requirement 或场景的可定位证据，包括测试名、文件路径、日志位置、payload 摘要或人工验证记录。
- **Closeout Checklist Item**: 旧逻辑退役、follow-through、文档、ADR/架构债、演进触发信号、知识同步等收尾检查项。

---

## Out of Scope *(if applicable)*

- 不在参考工作区直接改造 `~/personal/personal-skills` 的正式 skill 实现。
- 不规定具体实现文件、函数名、CLI 参数或 subagent 内部协议。
- 不把所有小改动强制纳入完整 acceptance record。
- 不设计新的 SDD 阶段；本 feature 只强化现有 verify / closeout / acceptance 记录语义。

---

## Clarified Decisions

- **D1**: 命中任一 Feature Trait 时，`acceptance.md` 默认为落盘产物；无 trait 命中或用户显式选择轻量路径时，才允许跳过并记录原因。
- **D2**: 中文 completion record 统一写入 `acceptance.md`；closeout 阶段对话输出只给摘要、阻塞项和下一步。
- **D3**: 知识同步只要求记录“是否需要同步、同步到哪里、当前状态”，不绑定 `nmem`、飞书或主仓文档等具体工具。
- **D4**: 本 feature 是迁移输入，不直接在参考工作区改造正式 `sdd` skill；后续 plan 应面向主仓落地路径，同时保留参考材料来源。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项（如有）：无。产物边界、completion record 归属和知识同步边界已对齐。
