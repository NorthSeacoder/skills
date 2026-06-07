# Implementation Plan: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/sdd-status-model-and-validator/spec.md`

**Note**: 跳过候选架构讨论。当前约束已经排除复杂 Markdown AST、外部 runtime、hook、Trellis CLI 和新依赖；唯一合理方向是在现有 SDD Markdown 规则旁增加一份状态模型 reference，并扩展现有 shell validator 做本地结构一致性检查。

---

## Summary

为 SDD 增加可维护的状态模型和本地 validator：把 `.active`、roadmap current、context manifest、tasks、verify evidence、acceptance 的关系固定成轻量规则，并让 `validate-sdd.sh` 能发现状态漂移。推荐方案是新增 `skills/sdd/references/status-model.md` 作为规则来源，再用 `skills/sdd/scripts/validate-sdd.sh` 进行机器可检查的结构校验。

---

## Architecture Overview

本 feature 不引入新的 runtime。状态模型仍由现有 workspace artifacts 表达，validator 只读取本仓库文件并输出短失败原因。

```text
specs/.active
  -> active feature directory
  -> specs/<feature>/{spec,plan,tasks,context-manifest,verify-evidence,acceptance}.md
  -> specs/<umbrella>/roadmap.md
  -> skills/sdd/references/status-model.md
  -> skills/sdd/scripts/validate-sdd.sh
  -> user-visible PASS / FAIL output
```

模块边界：

- `skills/sdd/references/status-model.md`: 状态关系、阶段门槛、失配处理和 validator 边界的文档来源。
- `skills/sdd/SKILL.md` 与 `references/continuation-routing.md`: 引用状态模型，不复制完整校验逻辑。
- `skills/sdd/scripts/validate-sdd.sh`: 保持单入口 shell validator，新增小函数检查 active、roadmap、manifest、closeout readiness 和 acceptance 完整性。
- `specs/<feature>/data-model.md`: 记录概念实体、状态推断和校验严重级别，供 tasks / verify 对齐。

不新增 `.trellis/`、Trellis CLI、task.py、JSONL task、hook、外部同步或自动提交能力。

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| `specs/.active` | active feature 名称 | `validate-sdd.sh`、continuation preflight | validator 检查文件存在、非空、目录存在；continuation routing 使用它恢复默认 feature |
| `specs/<feature>/spec.md` | feature traits 与需求边界 | `plan.md`、`tasks.md`、validator 阶段门槛 | validator 仅在 trait / 阶段条件满足时强制 manifest、evidence、acceptance |
| `specs/<umbrella>/roadmap.md` | Current Feature、status、Current State、Completion Log | `validate-sdd.sh`、closeout、continuation routing | active feature 属于 active roadmap 时，validator 检查 `Current Feature` 与 `.active` 一致 |
| `context-manifest.md` | Implement / Check / Research Context | implement、verify、validator | validator 检查 reason、Required 本地文件存在、Check Context 覆盖 spec/plan/tasks |
| `tasks.md` | 执行任务完成状态 | execute-plan、implement、closeout readiness | closeout readiness 检查 `- [ ]` 未完成任务 |
| `verify-evidence.md` | fresh verification evidence | verify、closeout readiness、acceptance | closeout readiness 要求可定位证据文件存在 |
| `acceptance.md` | Evidence Table、三维 Verdict、Closeout Checklist、Completion Record | closeout、roadmap closeout、后续知识回流 feature | validator 检查关键章节和 `Overall` / completion 字段存在 |
| `status-model.md` | 状态模型规则 | `SKILL.md`、`continuation-routing.md`、validator、tasks | 入口和 continuation reference 引用，validator 检查 reference 存在和关键词 |

**孤儿 artifact 处理**: 无孤儿 artifact。`status-model.md` 的消费者是入口路由、continuation reference、validator 和本 feature 后续 tasks。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可审计性 | 每个失败包含文件路径和原因 | validator 输出使用 `FAIL: <file>: <reason>` 风格 | fixture 或手工构造失配场景 |
| 可维护性 | shell 仍可读，规则集中 | 使用小函数，状态说明放 reference，不写复杂 parser | `validate-sdd.sh` 代码审查 |
| 低副作用 | 只读本地文件，不写工作区、不提交 | validator 禁止修改文件，测试用临时副本或手工 diff | `git diff` 与脚本审查 |
| 阶段感知 | 不把合法中间阶段误判为失败 | closeout 检查只在显式 closeout mode 或阶段条件满足时执行 | plan/tasks/implement 中覆盖 plan 阶段、tasks 阶段和 closeout 阶段 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: 状态规则位置 | 状态关系不能散落在入口和脚本里 | A: 只写进脚本；B: 新增 `status-model.md`；C: 放进 `SKILL.md` | 选 B，脚本实现可检查子集，reference 保留完整语义 | 多一个 reference 文件，需要 validator 检查引用 | Local: `skills/sdd/references/continuation-routing.md`, `spec.md` |
| ADR-002: validator 入口 | 现有 repo 已用 `validate-sdd.sh` 做结构校验 | A: 扩展现有脚本；B: 新增独立脚本；C: 引入 Markdown parser | 选 A，保持单入口和零依赖 | 脚本会变长，需函数分组 | Local: `skills/sdd/scripts/validate-sdd.sh` |
| ADR-003: 多 roadmap 命中 active feature | 多 umbrella 候选会污染续接路由 | A: warning；B: fail；C: 静默选择第一个 | 选 B，多个 active roadmap 候选必须失败 | 旧 workspace 若重复引用 active 需要清理 | Local: `continuation-routing.md` |
| ADR-004: completed roadmap 与 `Current Feature: none` | 完成的 roadmap 不应阻塞新的 active feature | A: 全局强制匹配；B: completed/none 豁免；C: 删除 completed roadmap | 选 B，只对 active/current roadmap 强制匹配 | validator 需要识别 completed/none | `spec.md` FR-003 |
| ADR-005: closeout readiness | 默认 validator 不能在 plan/implement 中误伤未完成 feature | A: 默认强制 tasks/evidence/acceptance；B: 阶段感知；C: 不检查 closeout | 选 B，默认做基础状态，closeout readiness 做阶段条件或显式 mode | 需要清楚定义触发条件 | `spec.md` US3-4 |

---

## Key Design Decisions

### Decision 1: 以结构校验为边界

- **背景**: spec 明确要求 validator 不替代 LM 的语义判断。
- **选项**:
  - A: 只检查文件、章节、表格行和关键字段。
  - B: 尝试理解 acceptance 结论、证据质量和任务语义。
- **结论**: 选 A。validator 只判断“是否存在、是否一致、是否可定位”，不判断证据是否真的充分。
- **影响**: 误报少，脚本可维护；复杂质量判断仍由 verify / reviewer 完成。
- **来源**: `spec.md` NFR-002。

### Decision 2: roadmap 匹配只约束 active/current 关系

- **背景**: 历史 roadmap 会保留完成记录，不能因为旧记录包含同名 feature 就失败。
- **选项**:
  - A: 任意 roadmap 出现 active feature 都必须 current。
  - B: 只对 active roadmap 或 current 行强制；completed + `Current Feature: none` 豁免。
- **结论**: 选 B。多个 active/current 候选 fail，completed/none 不参与 current 匹配。
- **影响**: 支持保留历史 completion log，同时防止续接选错 umbrella。
- **来源**: `spec.md` FR-002 / FR-003 / US1-5 / US1-6。

### Decision 3: context manifest 按阶段和 trait 执行

- **背景**: 轻量 feature 可跳过 manifest，但 trait 命中 feature 在 implement / verify 前需要上下文清单。
- **选项**:
  - A: 所有 feature 都强制 manifest。
  - B: manifest 存在就检查结构；进入 tasks 后且 trait 命中时要求 active/skipped 有明确依据。
- **结论**: 选 B。plan 阶段不因缺 manifest 失败；tasks/implement/verify/closeout 阶段必须有 manifest 或 skip reason。
- **影响**: 不阻塞当前 plan 阶段，但为后续执行建立门槛。
- **来源**: `feature-traits.md`, `context-manifest-template.md`, `spec.md` US2-4。

---

## Module Design

### Module: `skills/sdd/references/status-model.md`

**职责**: 定义 SDD workspace 的状态源、推断顺序、错误级别和阶段门槛。

**改动概述**:

- 新增 reference。
- 记录 active feature、roadmap、manifest、tasks、verify evidence、acceptance 的关系。
- 明确哪些状态是 FAIL，哪些状态在当前阶段允许存在。

**关键接口 / 行为**:

```text
active feature = explicit feature OR specs/.active
roadmap candidate = active roadmap whose Current Feature == active feature
completed roadmap with Current Feature none = ignored for current matching
manifest required = trait hit AND stage >= tasks, unless Status skipped + Skip Reason
closeout ready = tasks complete AND verify-evidence exists AND acceptance has required sections
```

### Module: `skills/sdd/scripts/validate-sdd.sh`

**职责**: 单入口本地 validator，读取仓库文件并报告结构失配。

**改动概述**:

- 保留现有 stage asset / keyword checks。
- 新增函数分组：
  - `check_active_feature`
  - `check_roadmap_consistency`
  - `check_context_manifest`
  - `check_closeout_readiness`
  - `check_acceptance_record`
- 可选支持 `--closeout-ready` mode，用于强制执行 tasks/evidence/acceptance 检查；默认 mode 不应因当前 feature 仍在 plan/tasks 阶段而失败。

**关键接口 / 行为**:

```text
bash skills/sdd/scripts/validate-sdd.sh
  -> repo structure + active + roadmap + manifest syntax if present

bash skills/sdd/scripts/validate-sdd.sh --closeout-ready
  -> default checks
  -> tasks must have no "- [ ]"
  -> verify-evidence.md must exist
  -> acceptance.md must contain required sections and Overall / Completion Record
```

### Module: SDD entry and stage references

**职责**: 让 LM 路由规则和机器 validator 共享同一状态词表。

**改动概述**:

- `SKILL.md` 增加 `references/status-model.md` 作为 workspace status reference。
- `continuation-routing.md` 指向 `status-model.md`，说明完整机器化校验由 validator 执行。
- `verify.md` / `closeout.md` 可在相关步骤中建议运行 validator default 或 `--closeout-ready`。

### Module: Validation fixtures / evidence

**职责**: 在不污染真实 workspace 的前提下证明失败场景可被发现。

**改动概述**:

- 优先用临时副本或人工 fixture 记录验证证据。
- 覆盖 missing active、missing active directory、roadmap mismatch、manifest empty reason、required file missing、tasks incomplete、missing evidence、acceptance missing fields。

---

## Data Model

详见 [data-model.md](data-model.md)。本 feature 不新增数据库或存储 schema，但新增一套概念状态模型，因此需要独立 data model 记录实体、状态推断和严重级别。

---

## Project Structure

```text
skills/sdd/
  SKILL.md
  references/
    status-model.md              # new
    continuation-routing.md      # update reference link
    stages/
      verify.md                  # optional validator guidance
      closeout.md                # optional closeout-ready guidance
  scripts/
    validate-sdd.sh              # extend

specs/sdd-status-model-and-validator/
  spec.md
  plan.md                        # this file
  data-model.md                  # conceptual status model
  tasks.md                       # next stage
  context-manifest.md            # next stage if trait rules apply
  verify-evidence.md             # verify stage
  acceptance.md                  # closeout stage
```

---

## Risks and Tradeoffs

- **阶段误伤**: 如果 default validator 强制 closeout 条件，会让进行中的 feature 无法通过基础校验。缓解：closeout readiness 使用显式 mode 或阶段条件。
- **脚本复杂度上升**: shell 解析 Markdown 表格容易变脆。缓解：只检查稳定章节名、关键行和简单 pipe table 字段，不做 AST。
- **roadmap 历史记录误判**: Completion Log 会保留旧 feature。缓解：只匹配 active/current roadmap，不把 completed/none 当作当前冲突。
- **语义判断越界**: acceptance 证据充分性无法可靠 grep。缓解：validator 只检查字段存在，verify / reviewer 检查内容质量。

---

## Evolution Path

- **MVP**: 单一 `validate-sdd.sh`，新增 `status-model.md`，覆盖 P1/P2 结构失配。
- **成长期**: 如果 status checks 继续增加，再把 shell 函数拆到 `scripts/lib/`；仍保持零外部依赖。
- **成熟期**: 若 Markdown 表格检查大量增长，再评估轻量 parser；除非用户确认，不引入通用 task runtime 或 Trellis 文件结构。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。保留 shell 单入口，不引入新 runtime。
- 是否引用了外部模式但没有适配检查：否。本 plan 只使用本仓库既有 SDD 模式。
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：否。新增概念状态已记录在 `data-model.md`，无缓存、队列或外部依赖。

---

## Verification Strategy

实施完成后至少验证：

1. `bash skills/sdd/scripts/validate-sdd.sh` 在当前合法 active feature 上通过。
2. `bash skills/sdd/scripts/validate-sdd.sh --closeout-ready` 在未完成任务或缺 evidence 的 fixture 中失败，并输出具体文件和原因。
3. fixture 覆盖：
   - `.active` 缺失或为空。
   - `.active` 指向不存在 feature 目录。
   - active roadmap `Current Feature` mismatch。
   - 多个 active/current roadmap 候选。
   - completed roadmap + `Current Feature: none` 不触发 current mismatch。
   - manifest 缺 reason。
   - `Required = yes` 的本地文件不存在。
   - Check Context 缺 spec / plan / tasks。
   - `tasks.md` 仍有 `- [ ]`。
   - 缺 `verify-evidence.md`。
   - `acceptance.md` 缺 Evidence Table、Verdict Summary、Closeout Checklist、Completion Record 或 Overall。
4. `rg -n "status-model|closeout-ready|Current Feature|context-manifest" skills/sdd` 能显示入口、reference 和 validator 对齐。
5. 边界扫描确认未引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入或默认外部副作用。

---

## Stage Readiness

- 是否需要 `data-model.md`：需要。该 feature 的核心是状态源、状态推断、阶段门槛和校验严重级别，单靠 plan 难以稳定表达。
- 下一步建议：`tasks`
- 阻塞项：无。实现前需要在 tasks 阶段把 validator 函数、reference 更新和 fixture 验证拆成可执行任务。

---

## Design Artifacts

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 已生成 | 主实现计划 |
| data-model.md | 已生成 | 概念状态模型 |
| tasks.md | 后续阶段生成 | 拆分 reference、script、stage guidance 和验证任务 |
| context-manifest.md | 后续阶段生成 | 本 feature 命中强化 trait，tasks 阶段应生成 |
| acceptance.md | 后续阶段生成 | closeout 阶段必须生成持久验收记录 |

---

## Sources

| 决策 | 来源 | 备注 |
|------|------|------|
| ADR-001 / ADR-002 | `skills/sdd/scripts/validate-sdd.sh`, `skills/sdd/references/continuation-routing.md` | 本仓库既有结构 |
| ADR-003 / ADR-004 | `specs/sdd-status-model-and-validator/spec.md` | US1 / FR-002 / FR-003 |
| ADR-005 | `skills/sdd/references/feature-traits.md`, `skills/sdd/templates/context-manifest-template.md` | trait 和 manifest 规则 |
