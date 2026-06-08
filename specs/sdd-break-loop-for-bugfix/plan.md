# Implementation Plan: SDD Break Loop For Bugfix

**Workspace**: `sdd-break-loop-for-bugfix` | **Date**: 2026-06-08 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-break-loop-for-bugfix/spec.md`

---

## Summary

Add a structured bugfix loop-breaker path to SDD for complex bugfixes. The path requires bug context, root-cause hypothesis, failed-attempt tracking, before/after evidence, regression guard, diffusion check, and closeout knowledge capture while preserving a lightweight skip path for small one-off fixes.

Candidate architecture discussion skipped: this is a Markdown + shell workflow enhancement with one reasonable direction. The implementation should extend existing SDD references, templates, stage rules, and validator checks instead of adding a separate debug runtime, external tracker integration, or new command surface.

---

## Architecture Overview

This feature adds a small shared reference for bugfix loop-breaking vocabulary and threads that reference through the existing SDD stages.

```text
user bugfix request
  -> specify detects bugfix-loop-breaker trait when complex/repeated/regression signals exist
  -> clarify captures unknowns without inventing root cause
  -> plan records hypothesis, fix boundary, guard strategy, diffusion strategy
  -> tasks creates reproduce / ledger / fix / guard / verify / closeout tasks
  -> implement updates failed-attempt ledger after failed fixes
  -> verify proves before-fails / after-passes or records substitute evidence
  -> closeout writes root cause, fix mechanism, prevention, remaining risk and Knowledge Capture
```

The design deliberately keeps bugfix data inside normal SDD artifacts. There is no new persistent state file, issue tracker sync, debug agent router, hook, or automatic external side effect.

---

## Architecture Reference

| Reference | Fit | Limits | Source |
|---|---|---|---|
| Incident postmortem style root-cause record | Useful for root cause, contributing factors, prevention and follow-up | Too heavy for small bugfixes; use only for complex loop-breaker cases | UNVERIFIED general engineering practice |
| Regression testing workflow | Useful for before/after proof and guard selection | Not every bug can be reproduced in a deterministic test; allow substitute evidence | UNVERIFIED general engineering practice |
| Existing SDD Knowledge Capture Gate | Directly reusable for closeout learning and sync status | Does not define bugfix-specific fields today | `skills/sdd/references/stages/closeout.md` |

No external framework behavior needs official documentation lookup for this plan.

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| `spec.md` | `bugfix-loop-breaker` trait, user stories and FR-001..FR-012 | `plan.md`, `tasks.md`, `verify` | Plan maps requirements to module changes and validation paths |
| `skills/sdd/references/bugfix-loop-breaker.md` | Trigger signals, skip rules, context schema, failed-attempt ledger, evidence vocabulary | stage rules, templates, validator, future SDD sessions | Every updated stage links to or names the shared reference |
| `templates/spec-template.md` | Bugfix trait row | future `spec.md` files | Future complex bugfix specs can mark the trait explicitly |
| `references/stages/plan.md` and `templates/plan-template.md` | Bugfix strategy section | future bugfix plans | Plans include root-cause hypothesis, fix boundary, guard and diffusion strategy |
| `references/stages/tasks.md` and `templates/tasks-template.md` | Bugfix task coverage requirements | future `tasks.md` files | Tasks cover reproduce, ledger, fix, guard, diffusion, verify and closeout |
| `references/stages/implement.md` | Failed fix retry rule | implement sessions | Failed attempts update ledger or trigger clarify/plan instead of blind retry |
| `references/stages/verify.md` | Before/after proof, regression guard and diffusion check requirements | `verify-evidence.md`, closeout | Evidence table can map original bug to fresh proof |
| `references/stages/closeout.md` and `acceptance-template.md` | Bugfix closeout fields | `acceptance.md`, Knowledge Capture | Acceptance records root cause, fix mechanism, prevention, remaining risk |
| `validate-sdd.sh --closeout-ready` | Structural bugfix readiness checks when active spec marks bugfix loop-breaker | verify / closeout | Missing bugfix evidence fields fail with file-specific output |

**Orphan artifact handling**: do not create a standalone `bugfix.md` or ledger file by default. The ledger is a section in `tasks.md` or `verify-evidence.md`; closeout learns from the same evidence path.

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可追溯性 | 从症状到 root cause、失败尝试、修复和预防都有路径 | 统一 bugfix vocabulary 和 evidence fields | fixture workspace + closeout-ready validator |
| 低噪音 | 简单单点 bugfix 可显式跳过完整 loop-breaker | trigger signals 和 skip conditions 必须并列定义 | spec/template 文案检查 |
| 防回归 | 复杂 bugfix 必须判断 regression guard 和 diffusion check | tasks / verify / acceptance 都有对应字段 | fixture + `rg` boundary scan |
| 可维护性 | 规则集中在一个 reference，阶段文件只引用和补充阶段职责 | 新增 `bugfix-loop-breaker.md`，避免多处自由发挥 | validate-sdd default mode 检查引用存在 |
| 低副作用 | 默认只写本地 SDD artifacts | 不新增外部同步、hook、自动提交或任务系统 | boundary scan |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: Add `bugfix-loop-breaker` trait | 当前 trait 不能准确表达复杂 bugfix 失败闭环 | A: 复用 `prior-closure-failure`; B: 新增 trait; C: 只靠自然语言 | 选择 B | 需要更新 spec template 和 trait reference；历史 specs 不强制迁移 | `spec.md` FR-001, FR-011 |
| ADR-002: Use one shared bugfix reference | 多阶段规则需要一致词表 | A: 每个 stage 独立写规则; B: 新增 reference 并由 stage 引用; C: 新增运行时命令 | 选择 B | 多一个文档资产，但避免复制规则 | `spec.md` FR-002..FR-009 |
| ADR-003: Keep ledger in existing artifacts | Failed-attempt ledger 是过程证据，不是独立数据模型 | A: 新建 `bugfix.md`; B: 写入 tasks / verify evidence / acceptance; C: 只写对话 | 选择 B | 长 bugfix 的 tasks/evidence 会稍长 | `spec.md` NFR-001, NFR-004 |
| ADR-004: Validator stays structural | Root cause 正确性需要人工和 fresh evidence 判断 | A: validator 判断语义; B: 只检查必需 section/fields; C: 不校验 | 选择 B | 不能证明 root cause 真实，只能防漏记录 | `status-model.md` boundaries |
| ADR-005: No default external integration | 外部同步已延后到 optional lifecycle integrations | A: 自动同步 issue/memory; B: 只写本地 artifacts; C: 写 hook | 选择 B | 外部任务追踪需要后续 feature | roadmap boundary |

---

## Key Design Decisions

### Decision 1: New Trait Is Explicit And Narrow

- **背景**: `prior-closure-failure` 表达“曾经闭环断裂”，不能稳定触发 bugfix 专用字段。
- **结论**: 新增 `bugfix-loop-breaker` trait，只有复杂 bugfix 命中：regression、重复失败、root cause 未明、修复后仍失败、同类问题扩散风险、用户明确要求 root cause / failed attempts / break loop。
- **影响**: `feature-traits.md` 和 `spec-template.md` 需要新增 trait 行。极小单点 bugfix 仍可跳过，并记录原因。
- **来源**: `spec.md` FR-001, FR-011。

### Decision 2: Bugfix Reference Owns The Vocabulary

- **背景**: root cause、failed attempt、regression guard、diffusion check 等词如果散落在阶段文件中，后续会漂移。
- **结论**: 新增 `skills/sdd/references/bugfix-loop-breaker.md`，定义 trigger signals、skip conditions、Bugfix Context、Failed Attempt Ledger、Regression Guard、Diffusion Check、Prevention Mechanism 和 closeout fields。
- **影响**: stage files 只写“何时应用”和“本阶段必须产出什么”，字段定义回到 reference。
- **来源**: `spec.md` Key Entities。

### Decision 3: Failed Attempts Change Control Flow

- **背景**: break-loop 的关键不是记录失败，而是失败后不能无证据地重复同类修改。
- **结论**: `implement.md` 和 `verify.md` 增加规则：若同一失败条件再次出现，必须更新 failed-attempt ledger、排除假设并获取 fresh evidence；否则回退到 clarify / plan。
- **影响**: 复杂 bugfix 的 execute loop 会更严格，但小 bugfix 可按 skip path 走。
- **来源**: `spec.md` US2, FR-006。

### Decision 4: Closeout Records Prevention, Not Only Fix

- **背景**: bugfix closeout 若只写“已修复”，无法防止同类问题复发。
- **结论**: `acceptance.md` 在命中 bugfix trait 时记录 root cause、fix mechanism、prevention mechanism、failed attempts summary、remaining risk 和 Knowledge Capture。
- **影响**: closeout-ready validator 可以检查字段存在，但不判断内容充分性。
- **来源**: `spec.md` US4, FR-009, FR-010。

---

## Module Design

### Module: `skills/sdd/references/bugfix-loop-breaker.md`

**职责**: 作为 bugfix loop-breaker 的单一词表和规则来源。

**改动概述**: 新增 reference，包含触发信号、跳过条件、Bugfix Context 字段、Failed Attempt Ledger 字段、Evidence 要求、Regression Guard、Diffusion Check、Prevention Mechanism 和 closeout capture rules。

**关键行为**:

```text
if complex bugfix signal:
  mark bugfix-loop-breaker trait
  require Bugfix Context
else if one-off low-risk bugfix:
  allow skip with reason

if fix attempt fails:
  record attempt + evidence + excluded hypothesis
  require new evidence or revised hypothesis before retry
```

### Module: `skills/sdd/references/feature-traits.md`

**职责**: 定义 trait 和强化规则触发。

**改动概述**: 新增 `bugfix-loop-breaker` trait；说明它触发 Bugfix Loop Breaker rules，生效于 clarify / plan / tasks / implement / verify / closeout。

**关键行为**:

```text
bugfix-loop-breaker => Bugfix Context + Failed Attempt Ledger + Before/After Evidence + Regression Guard + Diffusion Check
```

### Module: `skills/sdd/templates/spec-template.md`

**职责**: 让未来 specs 能显式标记 bugfix trait。

**改动概述**: 在 Feature Traits 表新增 `bugfix-loop-breaker` 行，并提示极小 bugfix 可记录跳过原因。

### Module: `skills/sdd/references/stages/clarify.md`

**职责**: 处理 bugfix 上游未知项。

**改动概述**: 命中 bugfix trait 且 root cause / repro / failed attempts 缺失时，clarify 必须把未知项显式列为 `unknown` 和调查问题，不得编造 root cause。

### Module: `skills/sdd/references/stages/plan.md` and `skills/sdd/templates/plan-template.md`

**职责**: 定义 bugfix 修复策略，而不是任务列表。

**改动概述**: 命中 bugfix trait 时，plan 必须包含 Root Cause Hypothesis、Fix Boundary、Regression Guard Strategy、Diffusion Check Strategy、Failed Attempt Handling 和 Verification Path。

### Module: `skills/sdd/references/stages/tasks.md` and `skills/sdd/templates/tasks-template.md`

**职责**: 把 bugfix strategy 拆成可执行任务。

**改动概述**: 命中 bugfix trait 时，tasks 必须覆盖 reproduce/evidence、failed-attempt ledger、fix、guard、diffusion check、verify evidence、acceptance closeout 和 Knowledge Capture。

### Module: `skills/sdd/references/stages/implement.md`

**职责**: 管控失败修复尝试。

**改动概述**: 若实现或局部验证失败，implement 必须记录失败尝试、失败证据、排除假设和下一步调查；若没有新证据，不得重复同类修改。

### Module: `skills/sdd/references/stages/verify.md`

**职责**: 证明 bugfix 打断循环。

**改动概述**: 命中 bugfix trait 时，verify evidence 必须包含 before/after proof，或者说明无法复现并给出替代证据；同时记录 regression guard 和 diffusion check 的结果。

### Module: `skills/sdd/references/stages/closeout.md` and `skills/sdd/templates/acceptance-template.md`

**职责**: 把 bugfix 完成结论沉淀为 completion record。

**改动概述**: 命中 bugfix trait 时，acceptance 必须记录 Root Cause、Fix Mechanism、Prevention Mechanism、Failed Attempts Summary、Remaining Risk，并通过 Knowledge Capture 记录可复用经验。

### Module: `skills/sdd/references/status-model.md`

**职责**: 描述 closeout-ready 的 bugfix 结构要求和 validator 边界。

**改动概述**: 增加 bugfix trait 的 closeout-ready 说明：只检查必要字段存在和可定位，不判断 root cause 语义正确性。

### Module: `skills/sdd/scripts/validate-sdd.sh`

**职责**: 提供默认结构校验和 closeout-ready 校验。

**改动概述**: default mode 检查新增 reference 和 stage/template 引用；closeout-ready mode 在 active spec 命中 `bugfix-loop-breaker` 时，检查 `verify-evidence.md` 或 `acceptance.md` 中存在 bugfix evidence 字段。

**关键行为**:

```text
if active spec contains bugfix-loop-breaker marked hit:
  require verify evidence contains Root Cause or Root Cause Hypothesis
  require verify evidence contains Regression Guard
  require verify evidence contains Diffusion Check
  require acceptance contains Prevention Mechanism
```

---

## Data Model

不创建 `data-model.md`。

本 feature 不新增数据库、存储文件、状态机或外部系统实体。Bugfix Context、Failed Attempt Ledger、Regression Guard、Diffusion Check 和 Prevention Mechanism 是 Markdown artifact 中的结构化段落，不需要单独持久数据模型。

---

## Project Structure

Planned additions:

```text
skills/sdd/references/bugfix-loop-breaker.md
specs/sdd-break-loop-for-bugfix/plan.md
```

Planned updates:

```text
skills/sdd/references/feature-traits.md
skills/sdd/references/status-model.md
skills/sdd/references/stages/clarify.md
skills/sdd/references/stages/plan.md
skills/sdd/references/stages/tasks.md
skills/sdd/references/stages/implement.md
skills/sdd/references/stages/verify.md
skills/sdd/references/stages/closeout.md
skills/sdd/templates/spec-template.md
skills/sdd/templates/plan-template.md
skills/sdd/templates/tasks-template.md
skills/sdd/templates/acceptance-template.md
skills/sdd/scripts/validate-sdd.sh
specs/sdd-break-loop-for-bugfix/spec.md
specs/sdd-trellis-workflow-productization/roadmap.md
```

`spec.md` update is expected because ADR-001 introduces a first-class `bugfix-loop-breaker` trait after specify.

---

## Risks and Tradeoffs

| Risk | Impact | Mitigation |
|---|---|---|
| Process gets too heavy for small fixes | Users may avoid SDD for normal bugfixes | Keep explicit skip condition for one-off low-risk bugfixes |
| Root cause fields invite invented certainty | Wrong closeout knowledge could be saved | Allow `unknown`; require evidence and hypothesis wording |
| Validator becomes semantic reviewer | Shell checks may become brittle or misleading | Keep validator structural; semantic review stays in verify / reviewer |
| Too many stage files change at once | Maintenance surface increases | Centralize vocabulary in `bugfix-loop-breaker.md`; stage files reference it |
| Existing specs lack new trait | Historical docs look inconsistent | Do not migrate history; update current feature spec and future template only |

---

## Evolution Path

1. **MVP**: Add reference, trait, templates, stage rules, structural validator checks, and dogfood this feature.
2. **Later if needed**: Add richer fixtures or sample workspaces for bugfix cases.
3. **Explicitly deferred**: External issue tracker sync, memory sync, hooks, debug skill routing and lifecycle integrations.

---

## Anti-Pattern Check

| Anti-pattern | Decision |
|---|---|
| Treat every typo fix as a full incident | Avoided by skip conditions for low-risk one-off bugfixes |
| Claim root cause without evidence | Avoided by `unknown` and hypothesis wording |
| Repeat failed patch attempts | Avoided by failed-attempt ledger and fresh-evidence requirement |
| Store separate artifacts nobody reads | Avoided by keeping ledger/evidence in tasks, verify evidence and acceptance |
| Add external side effects by default | Avoided by local-only SDD artifact design |

---

## Verification Strategy

1. Run `bash skills/sdd/scripts/validate-sdd.sh` after implementation.
2. Run `bash skills/sdd/scripts/validate-sdd.sh --closeout-ready` after tasks, verify evidence and acceptance exist.
3. Use this feature as the dogfood case: current spec should mark `bugfix-loop-breaker`, tasks should include loop-breaker coverage, and acceptance should record bugfix-prevention Knowledge Capture.
4. Create temporary fixture workspaces during verify:
   - positive: active spec with `bugfix-loop-breaker` plus verify/acceptance fields passes closeout-ready
   - negative: missing Regression Guard or Prevention Mechanism fails with a file-specific reason
   - skip path: low-risk bugfix records skip reason and is not forced through full bugfix evidence checks
5. Run boundary scan for prohibited defaults:
   - `.trellis`
   - `Trellis CLI`
   - `task.py`
   - `JSONL`
   - `hook 自动`
   - `自动提交`
   - `git push`
   - `外部 API`
   - `issue tracker`

---

## Stage Readiness

- 下一步建议：`tasks`
- 阻塞项：无。
- Context manifest: tasks 阶段应创建 `context-manifest.md`，因为本 feature 命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output`、`prior-closure-failure` 和新增 `bugfix-loop-breaker`，且会修改多个阶段文件。
- Data model: 不需要。

---

## Design Artifacts

- [spec.md](spec.md)
- [roadmap.md](../sdd-trellis-workflow-productization/roadmap.md)
- Planned: `skills/sdd/references/bugfix-loop-breaker.md`

---

## Notes

- 本 plan 不启动 `sdd-optional-lifecycle-integrations`。外部同步仍是后续可选 feature。
- 本 plan 不改变 subagent 安装或 agent role 定义。
- 本 plan 不提交当前 diff；提交仍由 closeout commit plan 和用户确认控制。

---

## Sources

- `specs/sdd-break-loop-for-bugfix/spec.md`
- `specs/sdd-trellis-workflow-productization/roadmap.md`
- `skills/sdd/references/feature-traits.md`
- `skills/sdd/references/status-model.md`
- `skills/sdd/references/stages/plan.md`
- `skills/sdd/references/stages/tasks.md`
- `skills/sdd/references/stages/implement.md`
- `skills/sdd/references/stages/verify.md`
- `skills/sdd/references/stages/closeout.md`
- `skills/sdd/templates/spec-template.md`
- `skills/sdd/templates/plan-template.md`
- `skills/sdd/scripts/validate-sdd.sh`
