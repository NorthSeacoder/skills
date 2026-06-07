# Feature Specification: Commit Boundary And Diff Automation

**Workspace**: `commit-boundary-and-diff-automation`
**Created**: 2026-06-06
**Status**: Draft
**Input**: 用户描述: "chinese-acceptance-and-closeout-record 已完成，继续后续 feature；roadmap 推荐 `commit-boundary-and-diff-automation`"

> 本 feature 只定义 SDD 在 closeout 后如何识别当前 feature 相关 diff、排除无关 dirty files、生成 commit plan，并在用户确认后提交。本期不自动 push，不处理远程发布，不引入 Trellis context manifest。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 该能力跨 verify / closeout / git commit 边界，需要从验收证据进入提交计划 |
| `external-side-effects` | ✅ | `git add` / `git commit` 会改变本地仓库历史和索引，属于可见副作用；必须用户确认 |
| `artifact-handoff` | ✅ | verify/acceptance 的完成证据、任务文件、git diff 会交给 commit plan 消费 |
| `user-visible-output` | ✅ | 用户会看到 commit plan、被包含/排除文件、提交消息和最终提交结果 |
| `prior-closure-failure` | ✅ | 当前主仓曾存在无关 dirty files、symlink 迁移状态和被忽略 runtime 文件，说明 diff 归属容易误判 |

**结论**: 本 feature 必须启用 Producer-Consumer Matrix、Evidence Gate、Workflow Replay、三维 Verdict 和中文 completion record。由于命中 `external-side-effects`，任何提交动作都必须先展示 commit plan 并获得用户明确确认。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 识别当前 feature 相关 diff (Priority: P1)

作为 SDD 使用者，我希望 closeout 后系统能列出当前 feature 相关改动和无关 dirty files，以便提交时不会混入用户正在做的其他工作。

**Why this priority**: 自动提交只有在 diff 边界清楚时才安全。当前仓库经常存在既有迁移状态、symlink、未跟踪文件或用户改动，若边界不清会造成错误提交。

**Acceptance Scenarios**:

1. **US1-1：列出包含文件**
   **Given** 当前 feature 已通过 verify
   **When** 进入 commit planning
   **Then** 系统必须列出建议纳入提交的文件，并说明每个文件为什么属于当前 feature。

2. **US1-2：列出排除文件**
   **Given** 工作树中存在 unrelated dirty files
   **When** 生成 commit plan
   **Then** 系统必须列出排除文件和排除理由，不得静默忽略。

3. **US1-3：无法判断归属时停止**
   **Given** 某个文件可能属于当前 feature，也可能是用户其他改动
   **When** 系统无法从 spec/tasks/acceptance/diff 判断归属
   **Then** 必须标记为 needs user decision，不得自动加入提交。

**Edge Cases**:

- **US1-4** 被 `.gitignore` 忽略的运行时文件如果是功能实现的一部分，必须在 commit plan 中标注为不可提交或需上游源仓同步。
- **US1-5** symlink 替换普通目录时，必须提示这是结构性变更，不能按普通文件 patch 处理。

### User Story 2 - 生成可审查 commit plan (Priority: P1)

作为 SDD 使用者，我希望系统在提交前输出清晰的 commit plan，包括提交批次、文件列表、commit message 和风险说明，以便我一次性确认或要求调整。

**Why this priority**: 用户原始需求是"自动提交相关 diff"，但安全边界是"先 plan，后确认，再提交"。这也是 Trellis finish 阶段值得吸收的设计。

**Acceptance Scenarios**:

1. **US2-1：commit plan 必须先展示**
   **Given** 系统准备执行 git commit
   **When** 存在任何待提交 diff
   **Then** 必须先展示 commit plan，包含 batch、files、message、excluded files、risks。

2. **US2-2：用户确认后才执行**
   **Given** commit plan 已展示
   **When** 用户没有明确确认
   **Then** 系统不得执行 `git add` 或 `git commit`。

3. **US2-3：支持多批次提交**
   **Given** 当前 feature 同时修改 skill runtime、specs 文档、验证产物
   **When** 生成 commit plan
   **Then** 系统可以按逻辑边界分批，例如 implementation docs、feature specs、verification records，但必须说明拆分依据。

**Edge Cases**:

- **US2-4** 如果仓库没有可提交相关 diff，系统应说明无提交动作，而不是生成空 commit。
- **US2-5** 如果 commit 失败，系统必须报告失败原因和已执行到哪一步，不能继续后续批次。

### User Story 3 - 自动提交但不自动 push (Priority: P1)

作为 SDD 使用者，我希望确认 commit plan 后，系统能自动执行相关 `git add` 和 `git commit`，但不自动 push，以便本地历史形成清晰提交，同时避免远程副作用。

**Why this priority**: 本 feature 的价值是减少 closeout 后手工整理 diff 的摩擦；但 push 影响远程状态，必须留给用户显式请求。

**Acceptance Scenarios**:

1. **US3-1：只 add plan 中批准的文件**
   **Given** 用户确认了 commit plan
   **When** 系统执行 `git add`
   **Then** 只能 add plan 中列出的 included files，不得使用宽泛 `git add -A` 覆盖无关改动。

2. **US3-2：按批次 commit**
   **Given** commit plan 包含多个 batch
   **When** 系统执行提交
   **Then** 每个 batch 单独 `git commit`，并在失败时停止。

3. **US3-3：不自动 push**
   **Given** 提交成功
   **When** closeout 输出最终结果
   **Then** 系统只报告 commit hash，不执行 `git push`，除非用户另行明确要求。

**Edge Cases**:

- **US3-4** 如果用户已有 staged changes，系统必须先检查 staged 区域，并说明是否属于当前 feature；不应覆盖用户 staged 状态。
- **US3-5** 如果提交中包含文件删除、symlink 或子模块指针，commit plan 必须把这类结构性变化单独列为风险。

### User Story 4 - 与 roadmap closeout 衔接 (Priority: P2)

作为 SDD 使用者，我希望提交动作完成后，roadmap closeout 能记录 commit hash 和下一个推荐 feature，以便后续 feature 可以可靠续接。

**Why this priority**: F1 已建立 roadmap；F2 已强化中文验收。本 feature 应把 commit 结果接入 closeout 记录，而不是成为另一个孤立动作。

**Acceptance Scenarios**:

1. **US4-1：completion record 记录 commit**
   **Given** commit 成功
   **When** 更新 acceptance 或 closeout record
   **Then** 必须记录 commit hash、message 和包含文件摘要。

2. **US4-2：roadmap 记录提交状态**
   **Given** 当前 feature 属于 roadmap
   **When** closeout 完成
   **Then** roadmap Completion Log 可以记录 commit hash 或"未提交/无需提交"状态。

3. **US4-3：仍推荐下一个 feature**
   **Given** 当前 feature 完成且提交状态已记录
   **When** roadmap 仍有 backlog
   **Then** 系统继续推荐下一个 feature，不因 commit 自动化打断 roadmap 流程。

**Edge Cases**:

- **US4-4** 如果用户选择不提交，closeout 可以 PASS，但必须记录"用户选择暂不提交"和剩余 dirty files。

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SDD 必须在 closeout 或 finish 类流程中生成 commit plan，而不是直接执行 `git add` / `git commit`。
- **FR-002**: commit plan 必须列出 included files、excluded files、needs user decision files、commit batch、commit message 和 risks。
- **FR-003**: 系统必须从 `spec.md`、`tasks.md`、`acceptance.md`、roadmap、git diff 和用户说明中推断文件归属。
- **FR-004**: 对无法判断归属的文件，系统必须要求用户决策，不得自动纳入提交。
- **FR-005**: 执行提交前必须获得用户明确确认；未确认时不得运行 `git add` 或 `git commit`。
- **FR-006**: 执行 `git add` 时只能添加 commit plan 中批准的文件，不得使用宽泛 `git add -A` 或等价操作包含未知文件。
- **FR-007**: 支持按逻辑边界分多批 commit，并在每个 batch 失败时停止后续批次。
- **FR-008**: 系统不得自动 push；push 必须是用户另行明确请求。
- **FR-009**: 如果工作树包含 staged changes、ignored runtime files、symlink、submodule 或删除，commit plan 必须显式标注风险。
- **FR-010**: 成功提交后，closeout / acceptance / roadmap 应记录 commit hash、message 和文件摘要；用户选择不提交时记录原因和剩余状态。

### Non-Functional Requirements

- **NFR-001**: commit plan 必须使用简体中文，commit message 可按仓库历史风格使用英文 conventional commit。
- **NFR-002**: 该能力必须保留 fast path：无相关 diff 时只报告无需提交。
- **NFR-003**: 该能力不得依赖远程服务或网络。
- **NFR-004**: 安全优先于自动化；任何不确定归属都应阻止自动提交。

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 安全性 | 不提交无关用户改动 | 工作树经常存在并行变更 | dry run 覆盖 unrelated dirty files 和 needs decision | 是 |
| 可审查性 | 用户能一眼看懂将提交什么 | commit 是外部副作用 | commit plan 示例覆盖 included/excluded/risks | 是 |
| 可恢复性 | 失败时知道执行到哪一步 | git add/commit 可能部分成功 | plan 需定义失败停止和报告格式 | 是 |
| 低耦合 | 不重写 SDD 阶段链 | 只增强 closeout/finish 责任 | plan 需说明落在哪个阶段和模板 | 否 |

### Key Entities

- **Commit Plan**: 提交前展示给用户的计划，包含批次、文件、消息、排除项、待决策项和风险。
- **Included File**: 判定属于当前 feature、可在用户确认后纳入提交的文件。
- **Excluded File**: 判定不属于当前 feature 或不应提交的文件。
- **Needs Decision File**: 归属不确定，需要用户显式决定的文件。
- **Commit Batch**: 一组逻辑相关文件及其 commit message。
- **Commit Result**: 提交执行后的 hash、message、文件摘要、失败状态或用户选择不提交的记录。

---

## Out of Scope *(if applicable)*

- 不自动 push。
- 不自动解决 merge conflict、rebase、stash 或跨分支同步。
- 不设计 Trellis 风格 `implement.jsonl` / `check.jsonl` 上下文清单。
- 不要求所有 feature 都必须提交；无相关 diff 或用户选择不提交时允许记录原因后收尾。
- 不绕过用户确认执行任何 git 副作用。

---

## Unclear Questions *(if applicable)*

- **UQ-001**: commit plan 作为独立模板 `commit-plan-template.md`，还是写入 acceptance/closeout 模板中？留给 plan 阶段决策。
- **UQ-002**: SDD 是否需要新增"finish"语义，还是只增强 closeout？留给 plan 阶段决策。
- **UQ-003**: 对 ignored runtime files 的处理，是只在 commit plan 中提示，还是要求 roadmap/acceptance 记录分发源仓同步状态？留给 plan 阶段决策。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。副作用边界、确认机制、排除规则和不自动 push 原则已明确。
