# Feature Specification: SDD Knowledge Capture Closeout

**Workspace**: `sdd-knowledge-capture-closeout`  
**Created**: 2026-06-07  
**Status**: Draft  
**Input**: 用户描述: "继续 Trellis workflow productization roadmap，启动 `sdd-knowledge-capture-closeout`，让 closeout 沉淀 decision / convention / pattern / anti-pattern / gotcha / common mistake"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 本 feature 改变 verify -> closeout -> acceptance / roadmap 的收尾链路 |
| `external-side-effects` | ❌ | 默认只写入 SDD 本地文档和 acceptance 记录；不自动调用外部知识库、hook、提交或同步 API |
| `artifact-handoff` | ✅ | closeout 需要消费 spec、plan、tasks、verify evidence、acceptance 和 roadmap，再产出结构化知识条目 |
| `user-visible-output` | ✅ | 用户会在 closeout 输出和 `acceptance.md` 中看到知识沉淀结论、跳过原因或后续同步建议 |
| `prior-closure-failure` | ✅ | 现有 closeout 只有"知识同步或经验沉淀"检查项，缺少结构化分类、证据和同步状态，容易流于形式 |

**结论**: 本 feature 必须启用强化验证：plan 需定义知识条目分类和 closeout 写入边界；tasks 需覆盖模板、阶段规则和 validator；verify 需证明 closeout 不再只给空泛"已同步"结论。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Capture Durable Closeout Knowledge (Priority: P1)

作为 `sdd` 使用者，我希望 closeout 在 feature 完成时主动识别可复用知识，以便后续会话能回收关键决策、约定、模式、反模式、坑点和常见错误。

**Why this priority**: 这是本 roadmap 第一批能力的闭环点；状态模型已经能判断 closeout readiness，下一步必须让收尾阶段产出可复用知识，而不是只声明"已完成"。

**Acceptance Scenarios**:

1. **[US1-1] knowledge items exist**
   **Given** 当前 feature 的 verify evidence 和 closeout checklist 中包含可复用决策、实现约定或反模式  
   **When** closeout 执行知识沉淀检查  
   **Then** `acceptance.md` 必须记录结构化 Knowledge Capture 条目，包含类型、标题、内容摘要、证据来源、适用范围和同步状态

2. **[US1-2] no durable knowledge**
   **Given** 当前 feature 是低风险小改动，且没有可复用知识  
   **When** closeout 执行知识沉淀检查  
   **Then** closeout 必须写明 `none` 和跳过原因，而不是留下空白段落或泛泛说"无需同步"

3. **[US1-3] memory-worthy decision**
   **Given** plan 或 closeout 中出现会影响后续 SDD 行为的设计取舍  
   **When** closeout 形成 Knowledge Capture  
   **Then** 条目必须标记为 `decision`，并引用对应文件或 evidence，方便后续同步到记忆系统或知识库

**Edge Cases**:

- **[US1-4]** 同一条知识同时像 pattern 和 convention 时，必须选择最主要类型，并在内容中说明次要属性。
- **[US1-5]** 涉及密钥、个人隐私、客户数据或不可公开上下文时，必须记录为 `redacted` 或跳过，并说明原因。
- **[US1-6]** 条目没有明确证据来源时，不得作为确定知识沉淀，只能列为 follow-up 或 open question。

### User Story 2 - Keep External Sync Optional (Priority: P1)

作为维护者，我希望知识沉淀默认停留在本地 acceptance / closeout 记录中，以便不把 `sdd` 变成外部知识库同步器，也不与后续 lifecycle integrations feature 重叠。

**Why this priority**: roadmap 明确 `sdd-optional-lifecycle-integrations` 才评估外部同步出口；本 feature 必须先建立结构化本地 capture，不引入默认外部副作用。

**Acceptance Scenarios**:

1. **[US2-1] no automatic external write**
   **Given** closeout 识别出知识条目  
   **When** 用户没有显式要求同步外部知识库，且运行环境没有独立 memory 指令  
   **Then** `sdd` 只能把条目写入 `acceptance.md`，不得默认调用外部 API、CLI、hook 或后台同步

2. **[US2-2] explicit sync status**
   **Given** closeout 记录了知识条目  
   **When** completion record 写入提交或同步状态  
   **Then** 每条知识必须有同步状态，例如 `recorded-only`、`synced-by-session-memory`、`skipped`、`redacted` 或 `follow-up`

3. **[US2-3] environment-level memory instruction**
   **Given** 当前 agent 环境另有明确的 memory 保存规则  
   **When** closeout 需要保存 durable decision  
   **Then** `sdd` 可以说明同步由环境级规则处理，但 acceptance 仍必须保留本地 Knowledge Capture 记录

**Edge Cases**:

- **[US2-4]** 用户要求"只写文件，不同步记忆"时，sync status 必须为 `recorded-only`。
- **[US2-5]** 外部同步失败不应自动把 feature verdict 从 PASS 改为 FAIL，除非该 feature 的 spec 明确把外部同步列为验收条件。

### User Story 3 - Make Capture Auditable And Low Noise (Priority: P2)

作为 `sdd` 使用者，我希望知识条目短、准、可审计，以便后续检索时读到的是可复用经验，而不是整段实现日志。

**Why this priority**: 知识库最容易被低质量总结污染；closeout 必须控制写入粒度和证据要求。

**Acceptance Scenarios**:

1. **[US3-1] controlled categories**
   **Given** closeout 进入知识沉淀步骤  
   **When** LM 分类知识条目  
   **Then** 类型只能使用 `decision`、`convention`、`pattern`、`anti-pattern`、`gotcha`、`common-mistake`、`follow-up`、`none`

2. **[US3-2] concise item format**
   **Given** 一条知识被记录  
   **When** 写入 `acceptance.md`  
   **Then** 单条内容应是 1-3 句摘要，并引用证据文件；不得粘贴长日志或完整 diff

3. **[US3-3] validator catches missing section**
   **Given** feature 命中任一 Feature Trait 且生成 `acceptance.md`  
   **When** 运行 closeout readiness validator  
   **Then** validator 必须能检查 `acceptance.md` 中存在 Knowledge Capture 或明确跳过原因

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `closeout.md` 必须把知识沉淀从普通 checklist 项升级为可执行 Knowledge Capture Gate。
- **FR-002**: Knowledge Capture Gate 必须识别并分类 `decision`、`convention`、`pattern`、`anti-pattern`、`gotcha`、`common-mistake`、`follow-up` 和 `none`。
- **FR-003**: 每条非 `none` 知识必须包含类型、标题、1-3 句内容摘要、证据来源、适用范围、同步状态和后续动作。
- **FR-004**: 当没有可沉淀知识时，closeout 必须记录 `none` 和一句跳过原因。
- **FR-005**: `acceptance-template.md` 必须提供 Knowledge Capture 段，供命中 trait 的 feature 形成持久 completion record。
- **FR-006**: `validate-sdd.sh --closeout-ready` 必须检查 acceptance 中存在 Knowledge Capture 段或明确跳过原因。
- **FR-007**: closeout 必须区分本地记录和外部同步；默认同步状态为 `recorded-only`，不得默认调用外部知识库。
- **FR-008**: 若当前环境级规则已经执行 memory 保存，closeout 可把同步状态记为 `synced-by-session-memory`，但仍需保留本地条目。
- **FR-009**: 知识沉淀不得保存密钥、隐私、客户数据或不可公开原文；必要时必须标记 `redacted` 或跳过。
- **FR-010**: 本 feature 不得引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入、自动提交、自动 push 或默认外部副作用。

### Non-Functional Requirements

- **NFR-001**: Knowledge Capture 格式必须短、稳定、便于人工审阅和未来机器校验。
- **NFR-002**: validator 增量应保持 shell 可读，不引入 Markdown AST 或新运行时依赖。
- **NFR-003**: 新规则不得让轻量小改动被迫写冗长知识总结；允许 `none + reason`。

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可审计性 | 每条知识都有证据来源和同步状态 | 避免无来源总结污染知识库 | verify evidence 检查 acceptance 示例 | 是 |
| 低副作用 | 默认只写本地 SDD 产物 | 避免和 lifecycle integrations 重叠 | boundary scan | 是 |
| 可维护性 | closeout 规则、模板、validator 使用同一字段词表 | 后续 feature 可复用同一 capture schema | plan 中定义 schema | 是 |

### Key Entities

- **Knowledge Capture Item**: closeout 产出的单条可复用知识，字段包括 Type、Title、Summary、Evidence、Scope、Sync Status、Follow-up。
- **Knowledge Capture Gate**: closeout 阶段的收尾门槛，负责判断是否有 durable knowledge、是否可记录、是否需要跳过或 redaction。
- **Sync Status**: 说明知识条目当前只在本地记录，还是已由环境级 memory 规则同步，或被跳过、脱敏、留作 follow-up。

---

## Out of Scope

- 不实现外部知识库、Feishu、Nowledge Mem 或任务系统的默认同步集成。
- 不新增 lifecycle hook、后台任务或自动 context injection。
- 不改变 `sdd` subagent 安装模型。
- 不实现 bugfix break-loop root-cause 模板；该能力属于 `sdd-break-loop-for-bugfix`。
- 不自动提交本 feature 相关 diff；提交仍由 closeout commit plan 和用户确认控制。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。
