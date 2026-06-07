# Feature Specification: Trellis Style Context Manifests

**Workspace**: `trellis-style-context-manifests`
**Created**: 2026-06-07
**Status**: Draft
**Input**: 用户描述: "commit-boundary-and-diff-automation 已完成，继续最后一个 roadmap feature；吸收 Trellis `implement.jsonl` / `check.jsonl` / `research.jsonl` 思路，为 SDD 建立上下文清单"

> 本 feature 只吸收 Trellis 的"上下文清单化"设计：为 SDD feature 明确记录 implement / verify / research 阶段应读取的 spec、plan、tasks、研究或验证文件。不要引入 `.trellis/` 目录、Trellis CLI、hook、平台初始化或自动 subagent 注入系统。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 该能力跨 plan / tasks / implement / verify / closeout 多阶段，核心是让不同阶段消费不同 context manifest |
| `external-side-effects` | ❌ | 本 feature 只定义本地 SDD 文档和 manifest 规则，不发布、不提交、不调用外部 API |
| `artifact-handoff` | ✅ | plan/tasks 生成 context manifest，implement/verify 消费 manifest，closeout 记录是否更新 |
| `user-visible-output` | ✅ | 用户可见产物是 manifest 文件、阶段输出中的上下文选择说明和缺失上下文警告 |
| `prior-closure-failure` | ✅ | 过往 SDD feature 中经常依赖聊天上下文或人工记忆，容易在压缩/恢复后丢失执行依据 |

**结论**: 本 feature 必须启用 Producer-Consumer Matrix、Evidence Gate、Workflow Replay 和三维 Verdict。由于不涉及 git 或外部服务副作用，不启用 commit 自动化作为本期完成条件。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 为实现阶段提供 context manifest (Priority: P1)

作为 SDD 使用者，我希望在进入 implement 前，有一个明确的 manifest 记录实现阶段必须读取哪些规格、计划、任务、研究材料和局部约束，以便实现不依赖聊天记忆。

**Why this priority**: 这是 Trellis `implement.jsonl` 最值得吸收的点。没有实现上下文清单，subagent 或主线程在长会话、压缩或恢复后容易漏读关键规则。

**Acceptance Scenarios**:

1. **US1-1：生成 implement manifest**
   **Given** `plan.md` 和 `tasks.md` 已存在
   **When** SDD 准备进入 implement
   **Then** 系统必须生成或更新 `specs/<feature>/implement-context.md` 或等价 manifest，列出实现阶段应读取的文件和原因。

2. **US1-2：不列待修改源文件作为 context**
   **Given** 某个源文件即将被修改
   **When** 写 implement manifest
   **Then** manifest 应优先列 spec、plan、tasks、research、reference，而不是把待修改源文件当成固定 context；源文件仍由实现阶段按需检查。

3. **US1-3：manifest 条目必须有 reason**
   **Given** manifest 包含任一文件
   **When** 用户查看该 manifest
   **Then** 每个条目必须说明为什么需要读取，不能只列路径。

**Edge Cases**:

- **US1-4** 如果 feature 很小且不需要 manifest，必须记录跳过原因。
- **US1-5** 如果 manifest 中的文件不存在，implement 阶段必须先提示缺失，而不是静默继续。

### User Story 2 - 为验证阶段提供 check manifest (Priority: P1)

作为 SDD 使用者，我希望 verify 阶段有单独的 check manifest，列出验收时必须读取的 spec、acceptance、risk、quality gate 和测试证据，以便验证不混同于实现上下文。

**Why this priority**: Trellis 把 implement 和 check context 分开。SDD 也需要避免"实现者看过的材料"自动等于"审查者应检查的材料"。

**Acceptance Scenarios**:

1. **US2-1：生成 check manifest**
   **Given** 当前 feature 进入 verify
   **When** verify 开始前
   **Then** 系统必须读取或生成 `specs/<feature>/check-context.md` 或等价 manifest，列出验证阶段必须读取的文件和原因。

2. **US2-2：check manifest 包含验收和风险材料**
   **Given** feature 命中 Feature Traits 或存在 architecture / roadmap / commit 风险
   **When** 写 check manifest
   **Then** manifest 必须包含 spec、plan、tasks、acceptance template、roadmap 或风险记录中相关文件。

3. **US2-3：验证发现 context 缺失时回退**
   **Given** check manifest 缺少 P0/P1 requirement 的来源文件
   **When** verify 阶段执行
   **Then** 必须回退到 plan/tasks 更新 manifest，不得直接 PASS。

**Edge Cases**:

- **US2-4** 如果用户明确要求轻量验证，仍需说明跳过 check manifest 的原因。
- **US2-5** 如果 implement manifest 和 check manifest 完全相同，必须解释为什么没有验证专属上下文。

### User Story 3 - 记录研究上下文和外部参考 (Priority: P2)

作为 SDD 使用者，我希望 research manifest 能记录外部文档、参考仓库分析和本地研究文件，以便后续阶段知道哪些结论来自哪里。

**Why this priority**: 当前 SDD 已有 docs researcher 和 explorer，但研究结果常停留在对话中。Trellis 的 `research.jsonl` 思路可以帮助 SDD 把研究输入落盘。

**Acceptance Scenarios**:

1. **US3-1：研究文件落盘并被 manifest 引用**
   **Given** feature 使用了外部文档、参考仓库或本地探索结论
   **When** plan/tasks 结束
   **Then** `research-context.md` 必须引用这些研究文件或 source URL，并说明用途。

2. **US3-2：外部来源要可追溯**
   **Given** manifest 引用了外部 docs 或 repo
   **When** 用户查看 manifest
   **Then** 必须能看到 URL、读取日期或使用阶段，不得只写"参考 Trellis"。

3. **US3-3：不把大段研究内容塞进 manifest**
   **Given** 研究材料很长
   **When** 写 manifest
   **Then** manifest 只列路径、来源、用途和摘要，不复制长文。

**Edge Cases**:

- **US3-4** 如果外部文档不可访问，manifest 必须标记 source 为 UNVERIFIED 或记录本地替代证据。

### User Story 4 - 保持 SDD 轻量，不复制 Trellis 平台 (Priority: P2)

作为 SDD 维护者，我希望吸收上下文清单机制，但不复制 Trellis 的 `.trellis/`、hook、CLI、task.py、多平台初始化等平台结构。

**Why this priority**: 个人 SDD skill 是轻量工作流，不是平台。复制 Trellis 会引入维护成本和职责混乱。

**Acceptance Scenarios**:

1. **US4-1：manifest 使用 SDD specs 目录**
   **Given** SDD feature 已在 `specs/<feature>/`
   **When** 写 context manifest
   **Then** manifest 必须放在该 feature 目录下，不新增 `.trellis/`。

2. **US4-2：manifest 使用 Markdown 或 JSONL 的最小可读格式**
   **Given** 用户需要人工审查 manifest
   **When** 选择格式
   **Then** 必须优先人类可读；若使用 JSONL，也要有模板说明。

3. **US4-3：不强制 subagent 自动注入**
   **Given** 当前运行环境可能不支持 hook 注入
   **When** 实现 manifest 机制
   **Then** SDD 只要求阶段读取 manifest，不要求实现自动注入。

**Edge Cases**:

- **US4-4** 如果后续要做自动注入，应作为新 feature，而不是本期范围扩大。

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SDD 必须定义 implement context manifest，用于记录实现阶段应读取的文件、原因和使用阶段。
- **FR-002**: SDD 必须定义 check context manifest，用于记录验证阶段应读取的文件、原因和验证重点。
- **FR-003**: SDD 必须定义 research context manifest，用于记录外部文档、本地研究文件、source URL 和用途。
- **FR-004**: context manifest 必须位于 `specs/<feature>/` 内，不引入 `.trellis/` 目录。
- **FR-005**: manifest 每个条目必须至少包含 `file/source`、`reason`、`phase`；缺少 reason 的条目不得通过验证。
- **FR-006**: implement 阶段必须先读取 implement manifest；manifest 缺失或引用不存在文件时，必须提示并回退到 tasks/plan 更新。
- **FR-007**: verify 阶段必须先读取 check manifest；若 check manifest 无法覆盖 P0/P1 requirement 或风险点，不得给 PASS。
- **FR-008**: manifest 不应列待修改源文件作为固定上下文；源文件应由 implement/verify 按需检查。
- **FR-009**: manifest 机制必须支持轻量跳过路径，但必须记录跳过原因。
- **FR-010**: 本期不得引入 Trellis CLI、hook、task.py、多平台初始化或自动 context injection。

### Non-Functional Requirements

- **NFR-001**: manifest 必须人类可读，优先 Markdown；如采用 JSONL，必须提供模板和示例。
- **NFR-002**: manifest 应短小，只列高信号上下文，不复制长文档。
- **NFR-003**: manifest 规则不得让小改动强制变重。
- **NFR-004**: manifest 必须可被主线程和 subagent 共同使用，但不依赖 subagent。

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可续接性 | 压缩/恢复后仍能知道该读什么 | SDD 长任务经常跨 session | dry run 从 manifest 恢复 implement/check 入口 | 是 |
| 可审查性 | 用户能审查上下文选择是否合理 | manifest 决定 agent 会看什么 | 每条 manifest 都有 reason | 是 |
| 低耦合 | 不依赖 Trellis runtime 或 hooks | personal SDD 只做轻量 workflow | plan 明确不引入 `.trellis/` | 是 |
| 成本 | 小 feature 可跳过 | 避免 SDD 变重 | 跳过规则可验证 | 否 |

### Key Entities

- **Implement Context Manifest**: 实现阶段读取清单，记录 spec、plan、tasks、research 等高信号上下文。
- **Check Context Manifest**: 验证阶段读取清单，记录 spec、acceptance、risk、quality gate 和 evidence 相关上下文。
- **Research Context Manifest**: 研究阶段或外部来源清单，记录 source URL、本地研究文件和用途。
- **Manifest Entry**: 单条上下文记录，至少包含 file/source、reason、phase。

---

## Out of Scope *(if applicable)*

- 不引入 `.trellis/` 目录。
- 不引入 Trellis CLI、task.py、hook、插件或多平台配置。
- 不实现自动 context injection。
- 不替代现有 subagent 安装和调用机制。
- 不把所有小改动强制纳入 manifest 流程。

---

## Unclear Questions *(if applicable)*

- **UQ-001**: manifest 格式采用 Markdown 表格，还是 JSONL？留给 plan 阶段决策。
- **UQ-002**: 三类 manifest 是否分三个文件，还是一个 `context-manifest.md` 中分区？留给 plan 阶段决策。
- **UQ-003**: implement/verify 阶段是否必须强制读取 manifest，还是先以"存在则读取，命中特征则强制"落地？留给 plan 阶段决策。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。边界已明确：只吸收上下文清单机制，不复制 Trellis 平台。
