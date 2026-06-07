# Feature Specification: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator`  
**Created**: 2026-06-07  
**Status**: Draft  
**Input**: 用户描述: "继续 Trellis workflow productization roadmap，启动 `sdd-status-model-and-validator`，强化 `.active`、roadmap current、manifest、tasks、acceptance 的一致性规则和 validator"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 本 feature 校验 spec / plan / tasks / implement / verify / closeout 的状态交接 |
| `external-side-effects` | ❌ | 只增强 SDD 文档和本地 validator，不触发外部系统、提交或 hook |
| `artifact-handoff` | ✅ | 核心目标是检查 `.active`、roadmap、context manifest、tasks、verify evidence、acceptance 之间的交接一致性 |
| `user-visible-output` | ✅ | 用户运行 validator 或通过 SDD 续接时会看到更明确的状态失配说明 |
| `prior-closure-failure` | ✅ | 过往出现过 `.active` 指向已 closeout feature、roadmap current 和 active 不一致、manifest/acceptance 覆盖不足等风险 |

**结论**: 本 feature 必须启用强化验证：plan 需定义状态模型和校验边界；tasks 需覆盖 active、roadmap、manifest、tasks、verify evidence、acceptance 的一致性检查；closeout 必须写 acceptance。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validate Active And Roadmap State (Priority: P1)

作为 `sdd` 使用者，我希望 validator 能检查 `specs/.active` 与 roadmap current 是否一致，以便续接流程不会恢复到错误 feature。

**Why this priority**: `sdd-continue-next-step` 已建立 continuation routing；如果状态源本身漂移，续接路由会被错误输入污染。

**Acceptance Scenarios**:

1. **[US1-1] valid active feature**
   **Given** `specs/.active` 指向存在的 `specs/<feature>/`  
   **When** 运行 `bash skills/sdd/scripts/validate-sdd.sh`  
   **Then** validator 不应因 active feature 基础状态失败

2. **[US1-2] missing active directory**
   **Given** `specs/.active` 指向不存在目录  
   **When** validator 执行相关检查  
   **Then** validator 必须失败并指出 missing active feature directory

3. **[US1-3] roadmap current mismatch**
   **Given** active feature 属于某个 roadmap，但 roadmap `Current Feature` 与 `.active` 不一致  
   **When** validator 执行相关检查  
   **Then** validator 必须失败并指出 roadmap current mismatch

**Edge Cases**:

- **[US1-4]** `.active` 缺失或为空时，validator 必须失败。
- **[US1-5]** roadmap 已完成且 `Current Feature: none` 时，validator 不应强制 `.active` 匹配该 roadmap。
- **[US1-6]** 多个 roadmap 引用同一 active feature 时，validator 可先 warning 或 fail；plan 阶段需明确取舍。

### User Story 2 - Validate Context Manifest Coverage (Priority: P1)

作为维护者，我希望 validator 能发现 `context-manifest.md` 缺 reason、Required 文件不存在、或 Check Context 缺少关键产物，以便 implement / verify 不漏读上游上下文。

**Why this priority**: Trellis context manifest 已被 SDD 吸收；缺少结构校验会让 manifest 变成形式文档。

**Acceptance Scenarios**:

1. **[US2-1] manifest required files exist**
   **Given** active feature 有 `context-manifest.md`  
   **When** validator 检查 manifest  
   **Then** 所有 `Required = yes` 的本地文件必须存在

2. **[US2-2] manifest reason is missing**
   **Given** manifest 中存在空 `Reason` 条目  
   **When** validator 检查 manifest  
   **Then** validator 必须失败并指出缺少 reason

3. **[US2-3] check context misses core artifacts**
   **Given** manifest 存在但 Check Context 缺少 spec、plan 或 tasks  
   **When** validator 检查 manifest  
   **Then** validator 必须失败或给出明确阻塞提示

**Edge Cases**:

- **[US2-4]** 没有命中 feature traits 的轻量 feature 可以没有 manifest，但必须有跳过原因或由阶段规则允许。
- **[US2-5]** URL 或外部 source 不能按本地文件存在性检查，但必须有 reason 和 verified 状态。

### User Story 3 - Validate Tasks, Evidence And Acceptance Closure (Priority: P2)

作为 `sdd` 使用者，我希望 validator 能在 closeout 前发现 tasks 未完成、verify evidence 缺失或 acceptance 不完整，以便不会把局部 PASS 当作 feature 完成。

**Why this priority**: 这直接支撑后续 `sdd-knowledge-capture-closeout`，否则知识回流会基于不完整的完成状态。

**Acceptance Scenarios**:

1. **[US3-1] tasks contain unchecked items**
   **Given** `tasks.md` 仍有 `- [ ]` 任务  
   **When** validator 执行 closeout readiness 检查  
   **Then** validator 必须指出 tasks incomplete

2. **[US3-2] missing verify evidence**
   **Given** tasks 已完成但没有 `verify-evidence.md` 或 equivalent fresh evidence  
   **When** validator 执行 closeout readiness 检查  
   **Then** validator 必须指出 missing fresh evidence

3. **[US3-3] acceptance missing required verdict**
   **Given** feature 已 closeout 但 `acceptance.md` 缺 Overall 或 Completion Record  
   **When** validator 执行 acceptance 检查  
   **Then** validator 必须失败

**Edge Cases**:

- **[US3-4]** 当前 feature 仍处于 specify / plan / tasks 阶段时，不应强制要求 verify evidence 或 acceptance。
- **[US3-5]** validator 的输出必须短、明确、可定位到文件。

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: validator 必须检查 `specs/.active` 存在、非空、且指向存在的 feature directory。
- **FR-002**: validator 必须能检查 active feature 与所属 roadmap `Current Feature` 的一致性。
- **FR-003**: validator 必须明确处理 completed roadmap 或 `Current Feature: none` 的情况。
- **FR-004**: validator 必须检查 `context-manifest.md` 中每条 entry 有 reason。
- **FR-005**: validator 必须检查 `Required = yes` 的本地文件存在。
- **FR-006**: validator 必须检查 Check Context 至少覆盖 spec、plan、tasks，除非 manifest 明确 skipped 且有 skip reason。
- **FR-007**: validator 必须能检查 `tasks.md` 是否仍有未完成任务。
- **FR-008**: validator 必须能检查 verify evidence 是否存在，且可被 closeout 消费。
- **FR-009**: validator 必须能检查 `acceptance.md` 是否包含 Evidence Table、三维 Verdict、Closeout Checklist 和 Completion Record 的关键字段。
- **FR-010**: validator 输出必须可定位到具体文件和失败原因。
- **FR-011**: 本 feature 不得引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入或默认外部副作用。

### Non-Functional Requirements

- **NFR-001**: validator 应保持 shell 脚本可读，不引入复杂运行时依赖。
- **NFR-002**: validator 应优先做结构和一致性检查，不尝试替代 LM 的语义判断。

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可审计性 | 每个失败都有文件和原因 | 用户需要快速修复状态漂移 | validator 输出示例 | 是 |
| 可维护性 | 规则集中、脚本清晰 | SDD skill 是 Markdown + shell 资产 | plan 中明确模块边界 | 是 |
| 低副作用 | 不触发外部系统或提交 | 保持 `sdd` 轻量边界 | boundary scan | 是 |

---

## Out of Scope

- 不实现 closeout 知识回流；该能力属于 `sdd-knowledge-capture-closeout`。
- 不实现 bugfix break-loop trait。
- 不实现 lifecycle hooks 或外部系统同步。
- 不把 validator 扩展成 Trellis task runtime。
- 不解析复杂 Markdown AST；优先使用 shell 中可维护的结构检查。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。
