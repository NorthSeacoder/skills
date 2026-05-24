# Implementation Plan: SDD Workflow Hardening

**Workspace**: `sdd-workflow-hardening` | **Date**: 2026-05-24 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-workflow-hardening/spec.md`

---

## Summary

本次改造的目标不是迁移外部 skill，而是吸收它们在主链骨架、执行治理、验证收尾、路由和校验上的优点，重组为更完整的 `sdd` 工作流。推荐方案是在保留现有 `specs/<feature>/` 工作区约定和 subagent 基础设施的前提下，重构 `skills/sdd/` 的阶段模型，新增 `Verify / Closeout` 语义与资产，并补一层只服务 `sdd` 的内建 validator。

---

## Architecture Overview

本次改造涉及四层：

1. **主入口层** `skills/sdd/SKILL.md`
   - 重写阶段描述、路由顺序、阶段职责和委派模板
   - 把现有 `clarify` 重定义为 `Clarify / Domain Alignment`
   - 把 `Verify` 提升为独立阶段，`code-review` 退为其中一个检查动作

2. **阶段资产层** `skills/sdd/references/stages/*.md`
   - 更新 `clarify.md`、`plan.md`、`implement.md`、`execute-plan.md`
   - 新增 `verify.md`、`closeout.md`
   - 视情况弱化或重写 `code-review.md`，使其从“独立终点阶段”转为 `Verify` 的组成检查

3. **校验与结构稳定层** `skills/sdd/scripts/`
   - 新增只服务 `sdd` 的最小 validator
   - 校验路由声明、阶段文件存在性、关键命名和引用一致性
   - 让 `Verify / Closeout` 不只是文档存在，而是真正进入主链契约

4. **工作区产物层** `specs/<feature>/`
   - 保持现有 `spec / plan / tasks / acceptance` 约定
   - 为 `Closeout` 增加可执行 checklist 设计，必要时决定其落在 `acceptance.md` 还是独立模板/引用资产

整体数据流：

```text
user request
  -> sdd/SKILL.md route selection
  -> clarify/spec/plan/tasks/execute/verify/closeout stage docs
  -> implementation / review / evidence / closeout checklist
  -> acceptance or final completion record

maintainer change
  -> sdd stage docs / route table / templates
  -> sdd validator
  -> detect drift before workflow semantics silently break
```

---

## Key Design Decisions

### Decision 1: 重定义现有 `clarify`，而不是新增前置阶段名

- **背景**: spec 已确认要补“领域对齐”能力，但不想把主链继续拆得更碎
- **选项**:
  - A: 新增独立的 `domain-alignment` 或同类阶段名 — 语义更直白，但会增加路由复杂度
  - B: 直接重定义现有 `clarify` 为 `Clarify / Domain Alignment` — 改动面更集中，保留现有入口习惯
- **结论**: 选 B
- **影响**: `clarify.md` 和 `SKILL.md` 的定义会明显变重，但整体主链更稳定，不需要新增一个新的顶层阶段名
- **来源**: `spec.md`

### Decision 2: `Verify` 升为独立阶段，`code-review` 降为检查动作

- **背景**: 现状中“实现完成 -> code-review”不足以承载 evidence gate、runtime/browser 检查和完成判定
- **选项**:
  - A: 保留 `code-review` 作为独立阶段，只在前后补说明 — 兼容现状，但主链语义仍不够清晰
  - B: 新增独立 `Verify` 阶段，把 `code-review`、测试、runtime/browser QA、evidence gate 收编进去 — 职责最明确
- **结论**: 选 B
- **影响**: 需要新增 `verify.md`，并重写 `code-review.md` 的定位；主入口路由也要从“实现后交付前检查”改为“实现后进入验证”
- **来源**: `spec.md`

### Decision 3: `Closeout` 本次直接落为可执行 checklist

- **背景**: 如果 `Closeout` 只有口头语义，很容易再次退化成“结束前提醒一下”
- **选项**:
  - A: 本次只定义阶段语义 — 实现快，但收尾仍容易漂
  - B: 本次同时定义 checklist — 成本略高，但能形成真实 gate
- **结论**: 选 B
- **影响**: 需要决定 checklist 放在阶段文档、模板还是 `acceptance` 资产中，并让 `Verify -> Closeout` 的交接可执行
- **来源**: `spec.md`

### Decision 4: validator 是 `sdd` 内建能力，但第一版只覆盖 `skills/sdd/`

- **背景**: 路由和 references 继续增多后，纯靠人工维护很容易漂移
- **选项**:
  - A: 一开始抽成仓库级通用 validator — 复用潜力更大，但本 feature 范围容易失控
  - B: 先做只服务 `sdd` 的最小校验器 — 范围清晰，也符合当前主目标
- **结论**: 选 B
- **影响**: 新脚本或 verify 入口会先聚焦 `skills/sdd/`；未来如果成熟，再抽象给其他 skill 复用
- **来源**: `spec.md`

### Decision 5: 吸收优点，不迁移结构

- **背景**: `../skills` 的分析已经明确不同参考源各自强项，但它们很多都带有自己的目录结构、术语和重量
- **选项**:
  - A: 沿用“迁移/借壳”思路，把外部结构尽量映射进来 — 容易过重，也不符合仓库现状
  - B: 只吸收骨架、治理、纪律、入口、验证、沉淀这些优点，并在当前 `sdd` 上重组 — 更契合本仓
- **结论**: 选 B
- **影响**: `plan` 和后续 `tasks` 必须按“现有 `sdd` 强化”组织，而不是按外部仓库模块分块
- **来源**: [../skills/analysis/topics/sdd.md](../skills/analysis/topics/sdd.md), [../skills/analysis/topics/workflow.md](../skills/analysis/topics/workflow.md), [../skills/analysis/topics/routing.md](../skills/analysis/topics/routing.md), [../skills/analysis/topics/validation.md](../skills/analysis/topics/validation.md)

---

## Module Design

### Module: 主入口路由 (`skills/sdd/SKILL.md`)

**职责**: 定义 `sdd` 主链、阶段入口、回退逻辑和 subagent 使用边界

**改动概述**: 重写阶段路由，从当前的 `ideate -> specify -> clarify -> plan -> tasks -> execute-plan -> implement -> code-review`，收敛为强调主链语义的 `clarify -> spec -> plan -> execute -> verify -> closeout` 视图；同时保留必要的任务拆解与节奏控制资产，但不让它们与顶层阶段语义竞争。

**关键接口 / 行为**:

```text
route(user_input, workspace_state):
  if request too small:
    exit full sdd flow

  if no spec and need idea shaping:
    ideate or specify

  if spec exists but terminology/boundary/history unresolved:
    clarify (redefined as Clarify / Domain Alignment)

  if spec stable and no technical plan:
    plan

  if plan stable and work needs breakdown:
    tasks

  if implementation work is active:
    execute-plan decides pacing
    implement carries coding guidance

  if implementation claims done:
    verify

  if verify passes:
    closeout
```

**注意事项**:

- `tasks` 和 `execute-plan` 继续存在，但属于执行支撑层，不再与主链终态竞争
- `code-review` 需要降级成 `Verify` 的检查动作或子文档，不宜继续作为最终顶层终点

### Module: 阶段文档重组 (`skills/sdd/references/stages/`)

**职责**: 为每个阶段提供明确、可执行、低歧义的工作说明

**改动概述**:

- 重写 `clarify.md`，突出术语对齐、边界压实、既有决策核对
- 更新 `plan.md`，纳入 execution governance、验证路径和风险闭环
- 更新 `execute-plan.md` / `implement.md`，明确 checkpoint、drift、最小任务包
- 新增 `verify.md`，承载测试、review、runtime/browser QA、evidence gate
- 新增 `closeout.md`，承载 checklist、退役检查、发布跟进、文档/知识同步
- 处理 `code-review.md`：
  - 要么重写成 `Verify` 的一个检查子资产
  - 要么保留文件但明确它不再是独立最终阶段

**关键接口 / 行为**:

```text
clarify.md:
  identify only blockers to accurate spec/plan
  resolve terminology, boundaries, historical decisions

plan.md:
  define architecture, execution boundaries, verification path
  do not devolve into tasks list

verify.md:
  gather fresh evidence
  run code review / tests / runtime checks
  decide PASS / CONDITIONAL PASS / FAIL

closeout.md:
  run closeout checklist
  confirm retirement, follow-through, docs sync
```

**注意事项**:

- 当前阶段文件已经有 subagent 派发约定，重组时不要把这些约定丢掉
- `Verify` 要吸收 `gstack` 的轻量闭环意识，但不能引入重平台术语

### Module: 内建 validator (`skills/sdd/scripts/`)

**职责**: 防止 `sdd` 路由、阶段资产和关键约束在演进过程中静默漂移

**改动概述**: 新增一个最小 validator 脚本，并接入现有仓库的 verify 入口。它不校验业务代码，只校验 `sdd` 自身结构契约。

**关键接口 / 行为**:

```text
validate-sdd:
  check stage files referenced by SKILL.md all exist
  check top-level route names match stage docs
  check required stages include clarify/plan/verify/closeout
  check key templates/references paths are valid
  check code-review is not still described as final top-level endpoint
  exit non-zero on drift
```

**注意事项**:

- 第一版只覆盖 `skills/sdd/`
- 尽量使用简单 shell 校验，避免引入重依赖
- 需要和仓库已有验证入口衔接，避免校验脚本存在但没人运行

### Module: Verify / Closeout 资产设计

**职责**: 把“完成”从口头状态变成有证据、有收尾的 workflow gate

**改动概述**: 为 `Verify` 和 `Closeout` 明确产物、检查动作和交接关系；必要时补模板或 acceptance 约定。

**关键接口 / 行为**:

```text
verify:
  inputs = implementation result + tests + review findings + runtime evidence
  output = verdict + remaining issues + ready-for-closeout decision

closeout:
  inputs = verify verdict + closeout checklist
  output = retirement checked + docs sync checked + completion record
```

**注意事项**:

- 如果 `acceptance.md` 更适合做最终记录，应明确它与 `closeout.md` 的边界
- checklist 不应过重，但必须覆盖旧逻辑退役、发布跟进、文档更新、必要知识同步

---

## Data Model

本次不涉及业务实体或持久化模型变化，不需要 `data-model.md`。  
涉及的是 workflow 元素与结构契约：

- 阶段定义
- 路由契约
- 校验面
- 验证证据
- closeout checklist

这些更适合在 `plan.md` 和后续 `tasks.md` 中表达。

---

## Project Structure

```text
skills/sdd/
  SKILL.md
  references/stages/
    clarify.md
    plan.md
    execute-plan.md
    implement.md
    code-review.md
    verify.md                 # new
    closeout.md               # new
  scripts/
    install-sdd-subagents.sh
    check-installed-sdd-subagents.sh
    generate-agents.sh
    validate-sdd.sh          # new
  templates/
    spec-template.md
    plan-template.md
    tasks-template.md
    checklist-template.md
    acceptance-template?     # optional, only if closeout needs one

specs/sdd-workflow-hardening/
  spec.md
  plan.md
  tasks.md                   # next stage
```

---

## Risks and Tradeoffs

- 主链重构会牵动 `SKILL.md` 与多个阶段文档，如果阶段边界写得不够清晰，可能只是把旧重叠换成新重叠
- `Verify` 与 `code-review` 的关系如果处理不好，后续使用者仍会把它们当两个并列终态
- `Closeout` checklist 若过重，会让 `sdd` 失去轻量优势；若过轻，又无法形成真实 gate
- validator 若只存在脚本而未接入实际验证入口，防漂移价值会明显下降
- 继续保留 `tasks`、`execute-plan`、`implement` 的同时强化主链，需要谨慎处理“主阶段”和“执行支撑资产”的层次关系

---

## Verification Strategy

后续实现完成后，至少从四个层面验证：

1. **结构验证**
   - `skills/sdd/SKILL.md` 的阶段路由和 `references/stages/*.md` 一致
   - 新增 `verify.md`、`closeout.md` 存在且被入口引用
   - validator 能发现缺文件、错命名、旧路由残留

2. **语义验证**
   - `clarify.md` 是否真的体现 `Domain Alignment`
   - `plan.md` 是否包含 execution governance 与验证路径
   - `verify.md` 是否明确 evidence gate 与 review/runtime checks
   - `closeout.md` 是否包含可执行 checklist

3. **回归验证**
   - 旧的 `specify -> clarify -> plan -> tasks -> implement -> code-review` 资产不会因重构而断链
   - subagent 前置检查与阶段派发说明仍可用

4. **流程验证**
   - 以一个代表性 feature 场景走读主链，验证可以自然落到 `Clarify -> Spec -> Plan -> Execute -> Verify -> Closeout`
   - 确认“没有 fresh evidence 不算完成”在文档层已变为明确 gate

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要；本次没有实体/状态/存储模型变化
- 下一步建议：`tasks`
- 阻塞项（如有）：无

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 不需要 | 本次不涉及实体、状态、关系或存储变化 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 可作为 verify/closeout 后的最终记录 |

---

## Notes

- `sdd-subagent-enhancement` 已经提供了 subagent 基础设施，本次不要重复投入在安装、派生和版本控制机制上
- `Verify` 和 `Closeout` 是这次最关键的新能力，优先级应高于语义润色类改动
- 如果 `code-review.md` 最终保留，必须在文案上明确它属于 `Verify`，否则主链仍会歪回旧结构

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| 吸收优点而非迁移结构 | [../skills/analysis/topics/sdd.md](../skills/analysis/topics/sdd.md) | 分层吸收骨架、治理、纪律、入口、验证、沉淀 |
| 生命周期骨架 + 治理脊柱组合 | [../skills/analysis/topics/workflow.md](../skills/analysis/topics/workflow.md) | 强调阶段映射与 Aegis 式治理增强 |
| 显式路由优先于重平台 | [../skills/analysis/topics/routing.md](../skills/analysis/topics/routing.md) | 适合当前仓库 |
| 最小 validator 范围 | [../skills/analysis/topics/validation.md](../skills/analysis/topics/validation.md) | 先覆盖主干 skill 结构漂移 |
| Clarify / Verify / Closeout 关键边界 | [spec.md](spec.md) | 已经完成本轮澄清 |
