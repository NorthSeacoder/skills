# Feature Specification: SDD Break Loop For Bugfix

**Workspace**: `sdd-break-loop-for-bugfix`  
**Created**: 2026-06-08  
**Status**: Draft  
**Input**: 用户描述: "`$sdd specify sdd-break-loop-for-bugfix`；继续 `sdd-trellis-workflow-productization` roadmap 中的复杂 bugfix 失败闭环能力"

> 写入本文件后，应同步更新 `specs/.active` 指向当前 workspace。

---

## Feature Traits *(LM 自动检测，用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 本 feature 会影响 bugfix 从 specify / clarify 到 plan / tasks / implement / verify / closeout 的整条链路 |
| `external-side-effects` | ❌ | 默认只写入 SDD 本地文档、验证证据和 acceptance；不自动发布、提交、同步或调用外部系统 |
| `artifact-handoff` | ✅ | bug 报告、复现证据、失败尝试、root cause hypothesis 和 regression guard 会在阶段间传递 |
| `user-visible-output` | ✅ | 用户会在 spec、plan、tasks、verify evidence 和 acceptance 中看到失败闭环、预防机制和扩散检查结论 |
| `prior-closure-failure` | ✅ | 现有 SDD 没有 bugfix 专用的 root cause、失败尝试和预防检查，复杂修复容易重复试错或只修当前症状 |
| `bugfix-loop-breaker` | ✅ | 本 feature 明确定义复杂 bugfix 的 root cause、failed attempt ledger、before/after evidence、regression guard、diffusion check 和 prevention mechanism |

**结论**: 本 feature 必须启用强化规则：plan 需定义 bugfix loop-breaker 的阶段边界和必填证据；tasks 需覆盖复现、失败尝试记录、修复、回归防护、扩散检查和 closeout 知识沉淀；verify / closeout 需证明修复打断了问题循环，而不只是声明测试通过。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Capture Bugfix Context Before Fixing (Priority: P1)

作为 `sdd` 使用者，我希望复杂 bugfix 在进入实现前记录症状、期望行为、复现状态、失败尝试和 root cause 假设，以便后续修复不再靠重复猜测推进。

**Why this priority**: 失败闭环的核心是先固定问题和证据。如果没有 bugfix context，后续 plan、tasks 和 verify 会退化成普通改代码流程，无法判断是否真的打断循环。

**Acceptance Scenarios**:

1. **[US1-1] bugfix context is required**
   **Given** 用户请求修复 regression、复杂 bug、重复失败的问题或明确提到 failed attempts / root cause / loop  
   **When** SDD 进入 specify / clarify / plan  
   **Then** 当前 feature 文档必须要求记录 observed behavior、expected behavior、scope、reproduction status、known failed attempts 和 current hypothesis

2. **[US1-2] unknowns are explicit**
   **Given** root cause、复现路径或失败尝试仍不完整  
   **When** SDD 继续下游阶段  
   **Then** 文档必须把未知项标记为待调查问题，而不是编造 root cause 或直接进入“已修复”叙述

### User Story 2 - Prevent Repeating Failed Fix Attempts (Priority: P1)

作为修复者，我希望每次失败尝试都能更新假设和证据，以便不会用同一个思路反复修改同一处代码。

**Why this priority**: 这是 break-loop 的行为差异。普通 bugfix 只要求完成修复；本 feature 需要让 SDD 在失败后强制重建判断依据。

**Acceptance Scenarios**:

1. **[US2-1] failed attempt ledger changes next action**
   **Given** 一次修复尝试没有通过复现、测试或用户验收  
   **When** SDD 继续 implement / verify  
   **Then** tasks 或 verify evidence 必须记录失败尝试、失败原因、被排除的假设和下一步调查方向

2. **[US2-2] no blind retry**
   **Given** 同一个失败条件连续出现  
   **When** SDD 准备再次修改  
   **Then** workflow 必须要求新增 fresh evidence、调整 root cause hypothesis 或回退到 clarify / plan，而不是无证据地重复同类改动

### User Story 3 - Prove The Bugfix Breaks The Loop (Priority: P1)

作为维护者，我希望 verify 证明修复覆盖了原始问题、回归防护和相邻影响面，以便 closeout 能判断 bugfix 是否真的完成。

**Why this priority**: bugfix 的完成证据必须绑定原始 bug，而不是只绑定“有测试通过”。复杂修复还需要检查同类问题是否扩散。

**Acceptance Scenarios**:

1. **[US3-1] before and after evidence**
   **Given** bug 可以被测试、脚本、fixture、日志或人工步骤复现  
   **When** verify 执行  
   **Then** evidence 必须说明修复前如何失败、修复后如何通过；若无法复现，必须记录原因和替代证据

2. **[US3-2] regression guard and diffusion check**
   **Given** 修复改变了共享逻辑、模板、阶段规则、validator 或用户可见输出  
   **When** verify / closeout 执行  
   **Then** 必须检查是否需要 regression guard、相邻路径扫描、同类问题扩散检查或 follow-up

### User Story 4 - Preserve Lessons In Closeout (Priority: P2)

作为后续会话的执行者，我希望 closeout 记录 root cause、修复机制、预防方式和可复用教训，以便同类 bug 不再从零排查。

**Why this priority**: 前一项 `sdd-knowledge-capture-closeout` 已提供知识沉淀结构，本 feature 需要把 bugfix 专用知识接入该收尾能力。

**Acceptance Scenarios**:

1. **[US4-1] bugfix knowledge is captured**
   **Given** bugfix 产生了可复用经验、反模式、失败尝试或预防机制  
   **When** closeout 写入 acceptance  
   **Then** Knowledge Capture 必须包含 bugfix 相关条目，证据来源可追溯到 spec、tasks、verify evidence 或 diff 摘要

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SDD 必须定义复杂 bugfix / loop-breaker 触发信号，至少覆盖 regression、重复失败、root cause 未明、用户明确要求 bugfix、同类问题扩散风险和修复后仍失败的场景。
- **FR-002**: SDD 必须提供 bugfix context 要求，记录 observed behavior、expected behavior、impact scope、environment / constraints、reproduction status、known failed attempts 和 current hypothesis。
- **FR-003**: 当 root cause 未确认时，SDD 必须允许显式 `unknown`，但必须要求下一步调查计划或证据获取路径。
- **FR-004**: plan 阶段必须要求 root cause hypothesis、验证策略、修复边界、回归防护策略和扩散检查策略；不得把 bugfix plan 写成只有“修改代码并测试”。
- **FR-005**: tasks 阶段必须把复杂 bugfix 拆成可执行任务，覆盖复现/证据、失败尝试 ledger、修复、regression guard、相关路径检查、verify evidence 和 closeout capture。
- **FR-006**: implement / execute 过程中，若修复尝试失败，SDD 必须要求更新失败尝试、排除假设和下一步证据，而不是继续重复同类修改。
- **FR-007**: verify 阶段必须把原始 bug 绑定到 fresh evidence；可复现时记录 before-fails / after-passes，无法复现时记录替代证据和剩余风险。
- **FR-008**: verify 必须要求 regression guard 与 diffusion check 的判断结果；若跳过，必须给出原因。
- **FR-009**: closeout / acceptance 必须记录 bugfix root cause、fix mechanism、prevention mechanism、failed attempts summary、remaining risk 和 Knowledge Capture 条目或明确 `none + reason`。
- **FR-010**: validator 或状态模型的新增检查必须保持结构性边界，只检查必要段落、关键词或文件关系，不尝试判断 root cause 是否“真实正确”。
- **FR-011**: 轻量、单点、低风险 bugfix 必须允许记录跳过原因后走简化路径，避免把所有小修复都强制升级为完整 loop-breaker。
- **FR-012**: 本 feature 不得引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入、自动提交、自动 push、外部 issue tracker 同步或默认外部副作用。

### Non-Functional Requirements

- **NFR-001**: bugfix loop-breaker 格式必须短、稳定、可审阅，不应制造比修复本身更重的流程负担。
- **NFR-002**: 所有 root cause、失败尝试和预防结论必须基于 fresh evidence 或明确标记为假设。
- **NFR-003**: 规则应复用现有 Markdown 阶段文件、模板和 shell validator，不引入新运行时依赖。
- **NFR-004**: 新规则必须与 Knowledge Capture Gate、status model 和 continuation routing 保持一致。

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可追溯性 | 每个复杂 bugfix 都能追溯到症状、复现、失败尝试、root cause 和修复证据 | 避免 closeout 只写“已修复” | verify evidence 和 acceptance 示例 | 是 |
| 低噪音 | 简单 bugfix 可显式跳过完整 loop-breaker | 避免 SDD 对小修复过度流程化 | plan 中定义触发和跳过条件 | 是 |
| 防回归 | 复杂 bugfix 必须判断 regression guard 和扩散检查 | 避免修当前症状但留下同类问题 | tasks / verify 覆盖相关检查 | 是 |
| 可维护性 | 规则分布在阶段说明、模板、status model 和 validator 中但词表一致 | 降低后续维护成本 | plan 中定义单一词表或引用关系 | 是 |

### Key Entities

- **Bugfix Loop Breaker**: 复杂 bugfix 的强化流程，用于记录证据、失败尝试、root cause、修复机制、回归防护和知识沉淀。
- **Bugfix Context**: bugfix 上游输入，包括 observed behavior、expected behavior、scope、environment、reproduction status、failed attempts 和 hypothesis。
- **Failed Attempt Ledger**: 记录失败修复尝试、失败证据、排除假设和下一步调查方向的结构。
- **Root Cause Hypothesis**: 当前解释 bug 的可验证假设；可以是 `unknown`，但不能伪装成已确认事实。
- **Regression Guard**: 防止原 bug 或同类 bug 回归的测试、fixture、脚本、validator 检查或人工验证步骤。
- **Diffusion Check**: 针对相邻模块、共享规则、模板、状态机或同类调用点的扩散风险检查。
- **Prevention Mechanism**: closeout 中记录的预防措施，可以是测试、防护规则、文档约定、validator、代码边界或 follow-up。

---

## Out of Scope

- 不实现通用 debug skill、日志采集器、自动诊断工具或运行时调试代理。
- 不把 `sdd` 改造成统一路由 `debug`、`git-guard`、`knowledge-management` 等其他 skill 的入口。
- 不默认同步外部 issue tracker、任务系统、飞书、Nowledge Mem 或其他知识库；外部同步仍属于 `sdd-optional-lifecycle-integrations`。
- 不新增自动 commit、自动 push、自动 rollback、deploy 或发布动作。
- 不替代 verify 阶段的 code review；bugfix loop-breaker 只定义 evidence 和 workflow 要求。
- 不强制历史 bugfix 规格或 acceptance 迁移到新格式。

---

## Stage Readiness

- 下一步建议：`plan`
- 阻塞项：无。
