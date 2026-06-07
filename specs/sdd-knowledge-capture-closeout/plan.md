# Implementation Plan: SDD Knowledge Capture Closeout

**Workspace**: `sdd-knowledge-capture-closeout` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-knowledge-capture-closeout/spec.md`

---

## Summary

Add a structured Knowledge Capture Gate to SDD closeout. The gate records durable decisions, conventions, patterns, anti-patterns, gotchas, common mistakes, follow-ups, or an explicit `none` result in local SDD artifacts without introducing default external sync.

---

## Architecture Overview

This is a Markdown + shell workflow change. The closeout stage will produce a Knowledge Capture section in `acceptance.md`; the acceptance template will define the table schema; the validator will check that closeout-ready features include the section or an explicit skip reason.

```text
spec.md traits
  -> plan/tasks define capture contract
  -> verify-evidence.md proves behavior
  -> closeout.md applies Knowledge Capture Gate
  -> acceptance-template.md stores Knowledge Capture section
  -> validate-sdd.sh --closeout-ready checks section exists
```

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| `spec.md` | Feature Traits and FR-001..FR-010 | `plan.md`, `tasks.md`, `verify` | Plan maps every P1/P2 scenario to implementation and verification |
| `closeout.md` | Knowledge Capture Gate rules | LM running closeout | Acceptance for this feature includes Knowledge Capture with evidence and sync status |
| `acceptance-template.md` | `## Knowledge Capture` section and table schema | Future feature `acceptance.md` files | Fixture acceptance generated from template passes validator |
| `validate-sdd.sh --closeout-ready` | Structural check for Knowledge Capture | Verify / closeout readiness | Negative fixture missing Knowledge Capture fails with a file-specific reason |
| `acceptance.md` | Durable Knowledge Capture records | Human reviewer, future SDD sessions, optional memory tools | Records Type, Title, Summary, Evidence, Scope, Sync Status, Follow-up |

**孤儿 artifact 处理**: 不新增单独 knowledge file。Knowledge Capture 只作为 `acceptance.md` 的一段，避免产生无人消费的并行记录。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可审计性 | 每条知识有证据来源和同步状态 | 表格字段固定，禁止空泛总结 | acceptance fixture + verify evidence |
| 低副作用 | 默认只写本地 SDD 产物 | 不调用 external memory / Feishu / API / hook | boundary scan |
| 可维护性 | Markdown 规则和 shell 检查保持简单 | validator 只查 header 和关键字段，不解析复杂 Markdown AST | `bash -n` + fixture |
| 低噪音 | 没有 durable knowledge 时允许 `none + reason` | closeout 不强制编造知识条目 | no-knowledge fixture |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: Store capture in `acceptance.md` | closeout 已把 acceptance 作为持久 completion record | A: 新建 `knowledge.md`; B: 写入 `acceptance.md`; C: 只写对话输出 | 选择 B | `acceptance.md` 稍变长，但消费路径最短 | `spec.md` FR-001..FR-006 |
| ADR-002: No default external sync | roadmap 将外部集成留给 optional lifecycle feature | A: 自动调用 memory; B: 只记录 sync status; C: 不记录同步状态 | 选择 B | 需要人工或环境级规则完成外部同步 | `spec.md` US2 |
| ADR-003: Validator remains structural | shell validator 不应替代 LM 判断知识是否有价值 | A: 复杂 Markdown parser; B: header + key field checks; C: 不校验 | 选择 B | 不能证明内容质量，只能防漏段 | `status-model.md` validator boundary |

---

## Key Design Decisions

### Decision 1: Knowledge Capture Gate Runs Inside Closeout

- **背景**: 当前 closeout checklist 只有“知识同步或经验沉淀”一行，容易写成不可审计结论。
- **结论**: 在 `closeout.md` 增加独立 Knowledge Capture Gate，要求 closeout 检查 durable knowledge、redaction、证据来源、同步状态和 skip reason。
- **影响**: closeout 输出和 `acceptance.md` 都必须能说明知识沉淀结果。
- **来源**: `spec.md` FR-001..FR-004。

### Decision 2: Capture Schema Is a Small Enum + Table

- **背景**: 知识库低质量总结的主要风险是分类自由发挥和缺证据。
- **结论**: 类型只允许 `decision`、`convention`、`pattern`、`anti-pattern`、`gotcha`、`common-mistake`、`follow-up`、`none`。
- **影响**: `acceptance-template.md` 提供固定表格字段：Type, Title, Summary, Evidence, Scope, Sync Status, Follow-up。
- **来源**: `spec.md` FR-002, FR-003。

### Decision 3: External Sync Is Status, Not Runtime Behavior

- **背景**: 本 feature 不负责 lifecycle integrations。
- **结论**: Sync Status 记录 `recorded-only`、`synced-by-session-memory`、`skipped`、`redacted` 或 `follow-up`；默认 `recorded-only`。
- **影响**: 不新增 API、CLI、hook 或后台任务；若环境级 memory 规则另行保存，只在 acceptance 中标注状态。
- **来源**: `spec.md` US2, FR-007, FR-008。

---

## Module Design

### Module: `skills/sdd/references/stages/closeout.md`

**职责**: 定义 closeout 阶段的最终 gate。

**改动概述**: 增加 Knowledge Capture Gate 规则、执行步骤和完成标准；把原 checklist 中的“知识同步或经验沉淀”改为可执行检查。

**关键行为**:

```text
if feature has durable knowledge:
  write Knowledge Capture rows with evidence and sync status
else:
  write Type=none with reason

if content includes secrets/privacy/non-public data:
  mark redacted or skipped

never call external sync by default
```

### Module: `skills/sdd/templates/acceptance-template.md`

**职责**: 提供持久 completion record 模板。

**改动概述**: 在 Closeout Checklist 后新增 `## Knowledge Capture` 段，包含写作规则、字段表、`none` 示例和 sync status 说明。

**关键行为**:

```text
| Type | Title | Summary | Evidence | Scope | Sync Status | Follow-up |
|---|---|---|---|---|---|---|
| none | No durable knowledge | [reason] | [file] | n/a | skipped | none |
```

### Module: `skills/sdd/scripts/validate-sdd.sh`

**职责**: 做结构、一致性和可定位失败检查。

**改动概述**: 在 `--closeout-ready` acceptance 检查中新增 Knowledge Capture header 和关键字段检查；保留 default mode 不强制 closeout 产物。

**关键行为**:

```text
require_grep '^## Knowledge Capture' "$acceptance"
require_grep 'Sync Status' "$acceptance"
require_grep 'decision\|convention\|pattern\|anti-pattern\|gotcha\|common-mistake\|follow-up\|none' "$acceptance"
```

### Module: `skills/sdd/references/status-model.md`

**职责**: 维护 closeout-ready 所需 acceptance 字段词表。

**改动概述**: 把 Knowledge Capture 加入 acceptance required sections，说明 validator 只检查结构，不判断知识质量。

### Module: `skills/sdd/SKILL.md`

**职责**: 单入口路由和阶段规则摘要。

**改动概述**: 将 closeout 的“必要知识同步”表述升级为“Knowledge Capture Gate”，同时保留外部同步不默认启用的边界。

---

## Data Model

不需要单独 `data-model.md`。本 feature 的数据形态是 `acceptance.md` 中的表格 schema，不新增存储、实体生命周期或跨文件状态机。

Knowledge Capture Item:

| Field | Meaning | Required |
|---|---|---|
| Type | `decision` / `convention` / `pattern` / `anti-pattern` / `gotcha` / `common-mistake` / `follow-up` / `none` | yes |
| Title | 短标题；`none` 时说明 no durable knowledge | yes |
| Summary | 1-3 句可复用内容或 skip reason | yes |
| Evidence | 文件、测试、verify evidence 或 acceptance 行为来源 | yes |
| Scope | 适用范围，例如 current feature / SDD closeout / future bugfix | yes |
| Sync Status | `recorded-only` / `synced-by-session-memory` / `skipped` / `redacted` / `follow-up` | yes |
| Follow-up | 无、外部同步建议或后续 feature | yes |

---

## Project Structure

```text
skills/sdd/SKILL.md                              # update closeout summary
skills/sdd/references/status-model.md           # update closeout-ready required sections
skills/sdd/references/stages/closeout.md        # add Knowledge Capture Gate
skills/sdd/templates/acceptance-template.md     # add Knowledge Capture section
skills/sdd/scripts/validate-sdd.sh              # add closeout-ready structure check
specs/sdd-knowledge-capture-closeout/plan.md    # this plan
specs/sdd-knowledge-capture-closeout/tasks.md   # next stage
specs/sdd-knowledge-capture-closeout/verify-evidence.md
specs/sdd-knowledge-capture-closeout/acceptance.md
```

---

## Risks and Tradeoffs

- **内容质量风险**: validator 只能确认 Knowledge Capture 存在，不能证明摘要有价值。缓解：closeout 规则要求 evidence 和 1-3 句限制。
- **噪音风险**: 每个 feature 都强制写知识会污染记录。缓解：允许 `none + reason`。
- **边界风险**: 环境级 memory 规则可能和 SDD 本地记录重叠。缓解：SDD 只记录 sync status，不拥有外部同步。
- **兼容风险**: 旧 acceptance 文件没有 Knowledge Capture 段。缓解：只在新的 `--closeout-ready` 或后续 closeout 中强制；default validator 不要求历史 feature 全部迁移。

---

## Evolution Path

- **MVP**: Markdown schema + closeout rule + shell structure check。
- **成长期**: 若多个 closeout 都产生高价值条目，再评估可选外部同步出口。
- **成熟期**: 在 `sdd-optional-lifecycle-integrations` 中设计明确 opt-in 的知识库同步或任务系统出口。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。没有引入外部知识库、hook、后台同步或新运行时。
- 是否引用了外部模式但没有适配检查：否。只吸收 Trellis 的 closeout knowledge loop 思想，不复制 Trellis task runtime。
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：否。新增的是 acceptance 表格字段和 validator 结构检查。

---

## Verification Strategy

- Run `bash skills/sdd/scripts/validate-sdd.sh` to ensure default structural checks still pass.
- Run `bash -n skills/sdd/scripts/validate-sdd.sh` after validator edits.
- Create fixture acceptance missing `## Knowledge Capture`; assert `--closeout-ready` fails with a file-specific reason.
- Create fixture acceptance with `Type=none` and skip reason; assert `--closeout-ready` passes structural checks.
- Verify this feature's own `acceptance.md` includes Knowledge Capture and records at least one `decision` or `pattern`.
- Run boundary scan for `.trellis`, Trellis CLI, `task.py`, JSONL task, hook automation, automatic push, and default external sync calls.

---

## Design Artifacts

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划，定义 schema、模块边界和验证路径 |
| data-model.md | 不需要 | 只有 Markdown 表格 schema，无新增存储实体 |
| tasks.md | 后续阶段生成 | 拆分 closeout/template/validator/verification 任务 |
| acceptance.md | 后续阶段生成 | 记录最终验收、Knowledge Capture 和 roadmap 回写 |

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要，原因是本 feature 不新增存储、状态机或实体关系。
- 下一步建议：`tasks`
- 阻塞项：无。

---

## Sources

- [spec.md](spec.md)
- [status-model.md](../../skills/sdd/references/status-model.md)
- [closeout.md](../../skills/sdd/references/stages/closeout.md)
- [acceptance-template.md](../../skills/sdd/templates/acceptance-template.md)
- [validate-sdd.sh](../../skills/sdd/scripts/validate-sdd.sh)
