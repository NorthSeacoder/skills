# Implementation Plan: SDD Roadmap Feature Orchestration

**Workspace**: `sdd-roadmap-feature-orchestration` | **Date**: 2026-06-06 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/sdd-roadmap-feature-orchestration/spec.md`

---

## Summary

在现有 SDD `specs/` 工作区约定内新增 umbrella roadmap 机制：当用户需求适合拆成多个 feature 时，先建立 `roadmap.md`，再把首个 feature 切入标准 `spec.md -> plan.md -> tasks.md -> verify -> closeout` 流程。完成一个 feature 后，closeout 必须回写 roadmap 并推荐下一个 feature。

方案讨论说明：本期是 SDD 文档、模板和阶段规则增强，不涉及外部运行时或多种技术架构选择；只有一个合理方向，即在现有 `specs/` 体系中补 roadmap，而不是引入 `.trellis/` 或重平台结构。

---

## Architecture Overview

```text
用户大需求
   │
   ▼
SDD 入口 / ideate / specify
   │  判断是否 multi-feature
   ▼
specs/<umbrella>/roadmap.md
   │
   ├── current_feature ───────────────┐
   │                                  ▼
   │                         specs/.active
   │                                  │
   │                                  ▼
   │                         specs/<feature>/spec.md
   │                                  │
   │                                  ▼
   │                         plan/tasks/verify/closeout
   │                                  │
   └──────── completion feedback ◄────┘
              │
              ▼
       next recommended feature
```

核心边界：

- `roadmap.md` 只管理大需求拆分、状态、依赖、推荐顺序和完成回写。
- `specs/.active` 仍只保存当前 feature 名称，不扩展成复杂状态文件。
- 单个 feature 的正式交付产物仍是现有 `spec.md`、`plan.md`、`tasks.md`、`acceptance.md`。
- Trellis 的启发只吸收文件驱动状态和完成后回写，不复制 `.trellis/tasks/` 或 JSONL context manifest。

---

## Architecture Reference

| 参考模式 / 模板 | 来源 URL | 适配点 | 不适配点 | 当前阶段 |
|-----------------|----------|--------|----------|----------|
| Trellis 文件驱动任务状态 | https://github.com/mindfold-ai/Trellis | specs、tasks、memory 写入仓库文件，跨 session 可恢复 | Trellis 的 `.trellis/`、多平台 hook、task.py、JSONL context manifest 对本期过重 | MVP |
| Trellis How It Works | https://docs.trytrellis.app/start/how-it-works | Plan/Execute/Finish 后把状态、归档和 journal 写回文件 | SDD 已有自己的阶段链，不引入 Trellis CLI 或 finish-work 命令 | MVP |

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| ideate / specify 拆分评估 | 候选 feature 列表 | roadmap.md | roadmap.md 中出现 Feature Roadmap 表，包含每个候选 feature |
| roadmap.md | `current_feature` | specs/.active 检查逻辑 | `.active` 与 roadmap current 一致；不一致时阶段输出要求先修正 |
| roadmap.md | Roadmap Feature Item | specify 阶段 | 首个 feature 生成 `specs/<feature>/spec.md`，后续 feature 保留轻量状态 |
| feature closeout | Completion Feedback | roadmap.md | roadmap 中当前 feature 状态更新为 done / conditional / blocked，并记录证据摘要 |
| roadmap.md | `next_recommended_feature` | 最终用户输出 / 下一轮 SDD | closeout 输出包含下一 feature、推荐依据和建议阶段 |
| roadmap.md | Future Feature Backlog | 后续 feature 的 specify / plan | 用户继续时可根据 roadmap 启动下一个 feature，而不需要重新解释大需求 |

**孤儿 artifact 处理**: 无未消费 artifact。`roadmap.md` 的每个字段要么服务当前 feature 对齐，要么服务 closeout 回写，要么服务后续 feature 启动。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可续接性 | 后续 session 可从 `roadmap.md` + `.active` 恢复状态 | roadmap 必须写在 `specs/<umbrella>/roadmap.md`，并含 current / next 字段 | 用本 feature 的 roadmap 做自测，确认能解释当前和下一步 |
| 低耦合 | 不重写现有阶段链 | 只在入口、specify、closeout 增加 roadmap 责任 | 检查 `SKILL.md` 和阶段文件的新增规则是否保持局部 |
| 可演进性 | 后续 feature 可直接接入 roadmap | 状态枚举包含 backlog / current / done / conditional / blocked / cancelled | roadmap 表能容纳 F2/F3/F4 |
| 可审查性 | 用户能看懂下一 feature 推荐依据 | closeout 必须输出推荐理由和启动条件 | verify 检查 closeout.md 中有下一 feature 推荐规则 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: roadmap 位置 | spec 中 UQ-001 需要确定默认位置 | A: `specs/<umbrella>/roadmap.md` / B: 首个 feature 目录内 `roadmap.md` / C: 根 `specs/roadmap.md` | A：用 umbrella 目录承载总路线，本 feature 的 umbrella 即 `sdd-roadmap-feature-orchestration` | 首个 feature 与 umbrella 同名时目录语义略重，但可读性最好 | 本次 plan |
| ADR-002: roadmap 模板 | spec 中 UQ-002 需要确定是否新增模板 | A: 只在阶段说明中写格式 / B: 新增 `templates/roadmap-template.md` | B：新增模板，保证用户和 LM 都能复用固定结构 | 多一个模板文件需要维护 | 本次 plan |
| ADR-003: `.active` 语义 | roadmap 需要 current feature，但 `.active` 已存在 | A: 扩展 `.active` 为结构化文件 / B: 保持 `.active` 单值，roadmap 另存状态 | B：`.active` 继续只存当前 feature 名称 | 需要增加失配检查规则 | 现有 SDD 工作区约定 |
| ADR-004: Trellis 吸收边界 | 用户要求分析 Trellis 并吸收设计 | A: 引入 `.trellis/` 结构 / B: 只吸收文件驱动状态和 finish 回写 / C: 本期直接做 JSONL context manifest | B：本期只吸收状态文件和完成回写；JSONL manifest 后置 F4 | 暂不解决 subagent 上下文清单化 | Trellis README / How It Works |
| ADR-005: roadmap closeout | spec 中 UQ-003 需要明确本期处理 | A: 本期新增 roadmap closeout 文件 / B: 当前 feature acceptance 记录完成，roadmap 记录摘要 | B：本期不新增独立 roadmap closeout，等所有 feature 完成时再设计 | 总路线最终收尾仍是后续增强点 | 本次 plan |

---

## Key Design Decisions

### Decision 1: `roadmap.md` 的默认结构

`roadmap.md` 使用 Markdown，避免 JSON/YAML 对人工编辑不友好。固定章节如下：

```text
# Roadmap: <umbrella title>

## Summary
## Current State
## Feature Roadmap
## Completion Log
## Next Recommendation
## Deferred Features
```

`Feature Roadmap` 表字段：

```text
| Feature | Goal | Status | Depends On | Start Condition | Recommended Stage | Notes |
```

状态枚举：

- `backlog`
- `current`
- `done`
- `conditional`
- `blocked`
- `cancelled`

### Decision 2: 阶段责任分配

| 阶段 | 新增责任 | 不新增的责任 |
|------|----------|--------------|
| `SKILL.md` 入口 | 在阶段路由前识别 multi-feature 需求，提示拆分评估 | 不直接实现复杂规划算法 |
| `ideate.md` | 需求发散时先输出候选 feature 和推荐首项 | 不写正式 spec |
| `specify.md` | 如果确认拆分，创建或更新 `roadmap.md`，并写首个 feature spec | 不提前为所有后续 feature 写完整 spec |
| `plan.md` | 当前 feature 若来自 roadmap，说明其与 roadmap 的关系和后续影响 | 不要求每个 plan 都生成 roadmap |
| `closeout.md` | closeout 通过后回写 roadmap，并推荐 next feature | 不负责自动 commit |
| `templates/roadmap-template.md` | 提供统一 roadmap 格式 | 不替代 `spec-template.md` |

### Decision 3: 当前 feature 对齐规则

进入任何下游阶段时，如果当前 feature 有 roadmap，应检查：

```text
roadmap.md Current State.current_feature == specs/.active
```

若不一致：

1. 明确说明失配。
2. 判断是用户显式切换 feature，还是 `.active` 陈旧。
3. 先更新 `.active` 或 roadmap 后再继续。

### Decision 4: 下一 feature 推荐规则

closeout 后按以下顺序推荐：

1. `status = backlog` 且 `depends_on` 全部 `done` 的 feature。
2. 如果有多个，优先 `Recommended Stage = specify` 且启动条件最明确的项。
3. 如果当前 feature 暴露新风险，则允许插入新的前置 feature，并在 Completion Log 说明来源。
4. 如果没有可推荐项，输出 roadmap closeout 建议。

---

## Module Design

### Module: `templates/roadmap-template.md`

**职责**: 提供 umbrella roadmap 的稳定 Markdown 格式。

**改动概述**: 新增模板文件，供 `specify` 和 `closeout` 阶段引用。

**关键接口 / 行为**:

```text
Roadmap fields:
- umbrella
- created
- status
- current_feature
- next_recommended_feature
- feature table
- completion log
- deferred features
```

**注意事项**:

- 模板必须中文说明，字段名可用英文以保持简洁。
- 后续 feature 只做轻量占位，不需要完整 spec。

### Module: `SKILL.md`

**职责**: 在统一入口层声明 multi-feature 拆分和 roadmap 语义。

**改动概述**:

- 在工作区约定中增加 `specs/<umbrella>/roadmap.md`。
- 在路由原则中增加"先判断是否需要拆成多个 feature"。
- 在输出要求中增加 roadmap 场景下的 current/next 说明。

**关键接口 / 行为**:

```text
if user_request_is_multi_feature:
  enter ideate/specify preflight
  list candidate features
  choose first feature
  create/update roadmap.md
  update specs/.active
```

### Module: `references/stages/ideate.md`

**职责**: 承接需求发散和多 feature 拆分评估。

**改动概述**:

- 增加多 feature 信号。
- 要求先输出候选 feature、依赖、推荐首项。
- 若用户只要求评估，不写文件。

### Module: `references/stages/specify.md`

**职责**: 在正式 spec 写入时创建或更新 roadmap。

**改动概述**:

- 若已确认 multi-feature，读取 roadmap template。
- 写入 `specs/<umbrella>/roadmap.md`。
- 将首个 feature 标记为 `current`，后续项标记为 `backlog`。
- 更新 `specs/.active`。

### Module: `references/stages/closeout.md`

**职责**: 在 feature 收尾后把 completion feedback 写回 roadmap。

**改动概述**:

- 检查当前 feature 是否属于某个 roadmap。
- PASS 时标记 `done`；CONDITIONAL PASS 标记 `conditional`；有阻塞则标记 `blocked`。
- 更新 Completion Log。
- 重新计算并输出 next recommended feature。

---

## Data Model

本期涉及轻量状态实体，但不涉及数据库或外部存储；不需要单独 `data-model.md`。

核心状态模型落在 Markdown 模板中：

```text
UmbrellaRoadmap
  - umbrella: string
  - status: active | complete | blocked
  - current_feature: string
  - next_recommended_feature: string
  - features: RoadmapFeatureItem[]
  - completion_log: CompletionFeedback[]

RoadmapFeatureItem
  - name: string
  - goal: string
  - status: backlog | current | done | conditional | blocked | cancelled
  - depends_on: string
  - start_condition: string
  - recommended_stage: ideate | specify | clarify | plan | tasks | implement | verify | closeout
  - notes: string
```

---

## Project Structure

```text
skills/sdd/
├── SKILL.md
├── templates/
│   └── roadmap-template.md        # new
└── references/stages/
    ├── ideate.md                  # patch
    ├── specify.md                 # patch
    └── closeout.md                # patch

specs/sdd-roadmap-feature-orchestration/
├── spec.md
├── plan.md
└── roadmap.md                     # generated during this feature as dogfooding
```

> 注意：当前 `skills/sdd` 在主仓里是 symlink 到 `../.agents/skills/sdd`。实现阶段必须在不回滚用户已有 symlink 改动的前提下修改其目标内容。

---

## Risks and Tradeoffs

- **风险 1**: Roadmap 机制可能把小改动流程变重。缓解：只在明显 multi-feature 时触发，单点小改动不生成 roadmap。
- **风险 2**: `.active` 与 roadmap current 可能失配。缓解：阶段规则明确要求检查并先修正。
- **风险 3**: 后续 feature 的轻量占位可能过于粗略。缓解：roadmap 只承担启动线索，正式需求仍由后续 feature 的 `spec.md` 固化。
- **风险 4**: Trellis JSONL manifest 很有价值，但本期不做会留下上下文清单缺口。缓解：作为 F4 独立 feature 记录在 roadmap 中。

---

## Evolution Path

- **MVP**: Markdown roadmap + 阶段规则 + closeout 回写 + 下一 feature 推荐。
- **成长期**: 引入中文 acceptance 强化和自动 commit boundary，使 closeout 更完整。
- **成熟期**: 引入 Trellis 风格 context manifest，为 implement / verify / subagent 提供精确上下文清单。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。本期不引入 `.trellis/`、CLI、hook 或 JSONL manifest。
- 是否引用了外部模式但没有适配检查：否。Trellis 只作为文件驱动状态和 finish 回写参考。
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：否。新增状态仅在 Markdown roadmap 模板中定义。

---

## Verification Strategy

1. **文档结构验证**: 检查 `roadmap-template.md` 是否包含 FR-003 要求字段。
2. **阶段规则验证**: 检查 `SKILL.md`、`ideate.md`、`specify.md`、`closeout.md` 是否都明确自己的 roadmap 责任。
3. **Dogfooding 验证**: 为本 feature 生成 `roadmap.md`，记录 F1/F2/F3/F4，并确认 `current_feature = sdd-roadmap-feature-orchestration` 与 `specs/.active` 一致。
4. **Closeout 模拟验证**: 在 verify 阶段模拟当前 feature PASS 后，确认 closeout 规则会把 F1 标记 done 并推荐 F2。
5. **小改动对照验证**: 检查入口规则明确小改动不触发 roadmap。

---

## Execution Governance

- **Checkpoint**: 每修改一个阶段文件后，对照本 plan 的阶段责任表，确认没有把后续 F2/F3/F4 塞入本期完成条件。
- **Drift 检测**: 若实现时发现需要自动提交或 JSONL manifest 才能完成本期，回到 plan 更新 ADR，不直接扩大实现范围。
- **验证收口**: 以本 feature 的 roadmap 作为用户可见输出证据，证明拆分、current、next recommendation 都能落地。

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要。状态模型是轻量 Markdown 文件，不涉及数据库、外部存储或复杂关系。
- 下一步建议：`tasks`
- 阻塞项：无。roadmap 位置、模板、`.active` 语义和后续 feature 边界都已决策。

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 已生成 | 主实现计划 |
| roadmap.md | 需要 | 本 feature dogfooding 产物，记录 F1-F4 |
| data-model.md | 不需要 | Markdown 状态模型已在 plan 中定义 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| Trellis 文件驱动 specs/tasks/memory | https://github.com/mindfold-ai/Trellis | README 中描述 specs、tasks、memory 写入 repo |
| Trellis task flow 和 finish 回写 | https://docs.trytrellis.app/start/how-it-works | 官方文档描述 task files、finish update 和 archive |
| Trellis 日常命令与 tasks/specs | https://docs.trytrellis.app/start/everyday-use | 官方文档描述 skill-first、finish-work、spec update |
