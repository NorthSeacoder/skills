# Feature Specification: SDD Continue Next Step

**Workspace**: `sdd-continue-next-step`  
**Created**: 2026-06-07  
**Status**: Draft  
**Input**: 用户描述: "按 Trellis 吸收建议推进，先做 sdd 的 continue / 下一步续接能力"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 本 feature 改变 `sdd` 在 spec / plan / tasks / implement / verify / closeout 之间的续接路由 |
| `external-side-effects` | ❌ | 只修改 SDD skill 文档、reference 和 validator；不触发外部系统、提交或 hook |
| `artifact-handoff` | ✅ | 依赖 `specs/.active`、roadmap、spec、plan、tasks、acceptance 等文件之间的交接 |
| `user-visible-output` | ✅ | 用户说“继续 / 下一步”时会看到不同阶段判断和下一步建议 |
| `prior-closure-failure` | ✅ | 过往已出现旧 active feature closeout 后仍可能被恢复的状态漂移风险 |

**结论**: 下游阶段必须启用强化验证：plan 需明确状态映射表，tasks 需覆盖各文件状态分支，verify 需证明续接输出不会静默推进错误 feature。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Resume Active Feature (Priority: P1)

作为 `sdd` 使用者，我希望说“继续 / 下一步 / 接着做”时，系统自动读取当前 active feature 和已有产物，以便不用手动判断该进入 plan、tasks、implement、verify 还是 closeout。

**Why this priority**: 这是 Trellis `continue` 思想对 SDD 的核心价值；如果续接仍靠人工记忆，后续状态模型和 validator 的收益会打折。

**Acceptance Scenarios**:

1. **[US1-1] spec exists but plan is missing**
   **Given** `specs/.active` 指向一个存在的 feature，且该 feature 只有 `spec.md`  
   **When** 用户请求“继续”  
   **Then** `sdd` 必须推荐进入 `plan`，并说明依据是 `plan.md` 缺失

2. **[US1-2] plan exists but tasks are missing**
   **Given** active feature 已有 `spec.md` 和 `plan.md`，但没有 `tasks.md`  
   **When** 用户请求“下一步”  
   **Then** `sdd` 必须推荐进入 `tasks`

3. **[US1-3] tasks are incomplete**
   **Given** active feature 已有 `tasks.md`，且仍存在未完成任务  
   **When** 用户请求“接着做”  
   **Then** `sdd` 必须推荐 `execute-plan / implement`，而不是跳到 verify

**Edge Cases**:

- **[US1-4]** `tasks.md` 全部完成但缺少 fresh verification evidence 时，必须推荐 `verify`。
- **[US1-5]** verify 已通过但缺少 `acceptance.md` 或 closeout record 时，必须推荐 `closeout`。
- **[US1-6]** 若 feature 已 closeout 且 roadmap 无下一项，必须说明已完成，而不是重复推进旧 feature。

### User Story 2 - Detect Broken Active State (Priority: P1)

作为维护者，我希望 `.active` 指向不存在目录、roadmap current 不一致、或产物互相矛盾时，`sdd` 能先报告状态失配，以便避免在错误 feature 上继续。

**Why this priority**: 当前仓库已有旧 `.active` 指向已 closeout feature 的实际风险；续接能力必须先保证不会放大状态漂移。

**Acceptance Scenarios**:

1. **[US2-1] missing active directory**
   **Given** `specs/.active` 指向不存在的 `specs/<feature>/`  
   **When** 用户请求“继续”  
   **Then** `sdd` 必须回退到重新确认 feature 或 `specify`，不得猜测推进

2. **[US2-2] roadmap mismatch**
   **Given** active feature 属于某个 roadmap，但 roadmap 的 `Current Feature` 与 `.active` 不一致  
   **When** 用户请求“下一步”  
   **Then** `sdd` 必须先说明失配并建议修正 `.active` 或 roadmap

**Edge Cases**:

- **[US2-3]** 若用户显式指定了 feature，应以用户指定 feature 为准，并说明是否需要更新 `.active`。
- **[US2-4]** 若有多个 roadmap 都引用同一 feature，应要求人工确认归属，不静默选择。

### User Story 3 - Keep Lightweight Boundary (Priority: P2)

作为 `sdd` 维护者，我希望续接规则只使用现有 SDD 文件和 reference，不引入 Trellis hook 或 CLI，以便保持 skill 可移植、可审计、低副作用。

**Why this priority**: 本 roadmap 的目标是吸收 Trellis 设计，不复制 Trellis 平台。

**Acceptance Scenarios**:

1. **[US3-1] no Trellis runtime dependency**
   **Given** 实现完成  
   **When** 维护者检查 `skills/sdd`  
   **Then** 不应出现 `.trellis/`、Trellis CLI、task.py、JSONL task 或 hook 自动注入依赖

2. **[US3-2] explicit next-step output**
   **Given** 用户请求续接  
   **When** `sdd` 输出阶段判断  
   **Then** 输出必须包含当前阶段、依据、将读取或更新的产物、下一步建议

---

## Requirements *(mandatory)*

- **FR-001**: `sdd` 必须识别续接意图，包括“继续”、“下一步”、“接着做”、“resume”、“continue”等表达。
- **FR-002**: 续接请求必须优先读取或推断 `specs/.active`，除非用户显式指定 feature。
- **FR-003**: 若 `.active` 缺失、为空或指向不存在目录，必须回退到 feature 确认或 `specify`，不得静默创建下游产物。
- **FR-004**: 若 active feature 只有 `spec.md`，必须推荐 `plan`。
- **FR-005**: 若 active feature 有 `spec.md` 和 `plan.md` 但没有 `tasks.md`，必须推荐 `tasks`。
- **FR-006**: 若 `tasks.md` 存在且有未完成任务，必须推荐 `execute-plan / implement`。
- **FR-007**: 若 tasks 已完成但缺少 fresh verification evidence，必须推荐 `verify`。
- **FR-008**: 若 verify 通过但缺少 `acceptance.md` 或 closeout completion record，必须推荐 `closeout`。
- **FR-009**: 若当前 feature 属于 roadmap，续接时必须检查 roadmap `Current Feature` 与 `specs/.active` 是否一致。
- **FR-010**: 续接输出必须说明阶段判断依据，不能只给出阶段名。
- **FR-011**: 本 feature 不得引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入或默认外部副作用。

---

## Non-Goals

- 不实现 `sdd-status-model-and-validator` 的完整 validator 增强。
- 不实现 closeout 知识回流。
- 不实现 bugfix break-loop trait。
- 不实现生命周期 hook 或外部系统同步。
- 不新增实现 subagent。

---

## Success Criteria

- 用户说“继续 / 下一步 / 接着做”时，`sdd` 能基于文件状态给出稳定阶段建议。
- 状态失配时，`sdd` 先报告并回退，不静默推进下游阶段。
- 续接能力只依赖现有 SDD workspace 文件和 reference。
- `validate-sdd.sh` 能覆盖新增 reference 或入口规则的基本结构检查。

---

## Next Step

进入 `plan` 阶段，设计续接路由规则落在哪些文件中，以及 validator 应如何做最小结构校验。
