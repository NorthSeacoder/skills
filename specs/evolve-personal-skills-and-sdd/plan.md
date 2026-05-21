# Implementation Plan: Evolve personal-skills Repository And Harden SDD

**Workspace**: `evolve-personal-skills-and-sdd` | **Date**: 2026-05-21 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/evolve-personal-skills-and-sdd/spec.md`

---

## Summary

本次演进以“仓库骨架收敛 + `sdd` 产品化增强”为主线，在不把 `sdd` 拆成多 skill、也不把它扩成统一路由器的前提下，补齐仓库边界说明、`sdd` 的产物与阶段约定，以及一层足够轻量但能防漂移的校验入口。

推荐方案是保留当前 `skills.sh` 分发模型与 `sdd` 单入口结构，在 `skills/sdd/` 内补强规则型资产，在仓库根文档层明确公开/自用边界，并把结构校验收敛为可执行脚本或最小 CI 入口，而不是引入平台式基础设施。

---

## Architecture Overview

本次改动涉及三层：

1. 仓库叙事层：`README.md`、`AGENTS.md`、`docs/*`
   - 负责解释哪些 skill 对外公开、哪些仅自用、`sdd` 的定位是什么，以及维护与安装边界。
2. `sdd` 产品层：`skills/sdd/SKILL.md`、`references/stages/`、`templates/`
   - 保持单入口不变，细化阶段进入条件、回退条件、产物职责、`.active` 语义与校验模型。
3. 结构校验层：`scripts/verify-skills.sh` 与现有 `.github/workflows/verify.yml`
   - 负责校验公开 skill 入口、模板与阶段引用、文档边界、以及 `sdd` 关键资产是否齐备。

核心数据流不是运行时 API，而是“仓库约定 -> `sdd` 路由说明 -> `specs/<feature>/` 产物 -> 结构校验”。也就是说，本次重点是把文档驱动的 workflow 变得可预测、可恢复、可维护。

---

## Key Design Decisions

### Decision 1: 保持 `sdd` 单入口，增强内部约定而不是横向拆分

- **背景**: `sdd` 已是当前主公开 skill。当前问题不在入口过少，而在阶段边界、产物职责和恢复逻辑不够清楚。
- **选项**:
  - A: 把 `sdd` 再拆成多个 installable 子 skill — 能细分职责，但会破坏“只记一个入口”的产品体验，也会扩大公开面。
  - B: 保留 `sdd` 单入口，在 `references/stages/` 与模板层补足规则 — 能保持用户心智稳定，同时降低维护成本。
- **结论**: 选 B。
- **影响**: 文档与阶段资产会变得更明确，但对外入口和安装方式保持不变。
- **来源**: UNVERIFIED

### Decision 2: 公开边界通过仓库叙事显式声明，而不是从目录位置反推

- **背景**: 当前所有 skill 都位于 `skills/` 下，但是否公开不能由路径自动推导，否则自用 skill 会被误解为公开承诺。
- **选项**:
  - A: 用目录层级区分公开与私有 — 结构清晰，但会引入迁移成本，并不符合当前仓库现状。
  - B: 保持统一目录，靠 README、AGENTS、维护文档和校验规则显式声明公开边界 — 更贴近当前仓库，也更适合 `skills.sh` 分发。
- **结论**: 选 B。
- **影响**: 需要补强文档一致性和校验规则，避免 README 叙事与真实资产漂移。
- **来源**: UNVERIFIED

### Decision 3: 三层校验优先落为轻量规则和脚本，不提前建设重型平台

- **背景**: spec 要求阶段内校验、产物校验、仓库结构校验，但仓库当前只有一个 CI 入口，且引用的 `scripts/verify-skills.sh` 似乎缺失。
- **选项**:
  - A: 直接引入复杂 validator/生成器体系 — 完整但过重，超出当前仓库规模。
  - B: 定义清晰规则，并优先实现结构层脚本校验；阶段内与产物校验先体现在 `sdd` 文档与模板中 — 更符合当前目标。
- **结论**: 选 B。
- **影响**: 第一轮先把“能防明显漂移”的机制落地，后续如有复用证据再增强自动化。
- **来源**: UNVERIFIED

---

## Module Design

### Module: 仓库治理文档层

**职责**: 统一说明仓库定位、公开边界、分发方式和维护约定。

**改动概述**: 更新根级和 `docs/` 文档，使其对以下问题给出一致答案：哪些 skill 公开、哪些是自用、`sdd` 是什么、`skills.sh` 如何安装、仓库级校验范围是什么。

**关键接口 / 行为**:

```text
README:
  - 声明主公开 skill = sdd
  - 列出自用 skill 但不赋予公开承诺
  - 说明安装路径与使用方式

docs/*:
  - 解释源码层 / 分发层 / sdd 内部资产层
  - 记录维护规范与公开边界

AGENTS.md:
  - 约束仓库贡献时对结构和文档一致性的要求
```

**注意事项**:

- 不新增“多 skill 平台”叙事
- 不让 telemetry、目录位置、是否可安装，混同为“是否公开承诺”

### Module: `sdd` 单入口与阶段资产层

**职责**: 提供从需求到交付的单入口路由，并明确阶段边界、产物模型和回退逻辑。

**改动概述**: 精化 `skills/sdd/SKILL.md` 及 `references/stages/*.md`，补上 `.active` 语义、核心/可选产物、进入条件、阶段完成标准、回退规则和下一步建议。

**关键接口 / 行为**:

```text
用户提到 sdd
  -> 判断当前 feature 与 specs/.active
  -> 根据已有产物选择 ideate/specify/clarify/plan/tasks/execute-plan/implement/code-review
  -> 输出当前阶段、依据、要更新的产物、下一步建议

工作区约定
  specs/<feature>/spec.md     必备
  specs/<feature>/plan.md     plan 阶段产出
  specs/<feature>/tasks.md    tasks 阶段产出
  specs/<feature>/data-model.md / acceptance.md 按需
```

**注意事项**:

- `sdd` 只处理软件交付流程，不负责路由 `debug`、`git-guard`、`knowledge-management`
- 小改动场景仍应允许克制退出，而不是强推完整流程

### Module: 结构校验与 CI 层

**职责**: 防止公开边界、引用关系、关键资产和验证入口发生明显漂移。

**改动概述**: 补齐或修正 `verify.yml` 所依赖的仓库脚本入口，并定义结构校验的最小集合。

**关键接口 / 行为**:

```text
verify script:
  - 检查每个 public skill 是否包含 SKILL.md
  - 检查 sdd 的 stages/templates 关键文件是否齐全
  - 检查 README 中声明的公开 skill 与仓库现实是否一致
  - 检查引用路径不悬空
  - 可选检查 specs/.active 约定说明是否仍在 sdd 中可找到
```

**注意事项**:

- 当前 `.github/workflows/verify.yml` 依赖 `scripts/verify-skills.sh`，但仓库里尚未看到该文件；实现时需要先修复这一断点
- 校验应保持可读、可维护，不依赖复杂外部基础设施

---

## Data Model

本次没有业务数据存储变更，但有一组需要被明确建模的“仓库工作区实体”：

- `SkillVisibility`
  - `public`: 出现在 README 安装与公开说明中，承诺基本可移植
  - `private-adopted`: 保留在仓库中，可本地安装，但不默认承诺跨环境可用
- `SddArtifact`
  - `spec.md`: 需求与验收语义
  - `plan.md`: 技术方案与验证路径
  - `tasks.md`: 可执行任务拆解
  - `data-model.md`: 按需扩展
  - `acceptance.md`: 交付验收结论
- `ActiveFeaturePointer`
  - `specs/.active` 指向当前默认续接的 feature 名称
  - 当用户显式指定其他 feature，或发现指针失配时，应允许更新或回退判断

这些实体足以在文档和校验脚本中表达，不需要单独拆出 `data-model.md`。

---

## Project Structure

```text
README.md
docs/
  architecture.md
  maintenance.md
  adoption-policy.md
.github/workflows/verify.yml
skills/
  sdd/
    SKILL.md
    references/stages/
    templates/
  debug/
  git-guard/
  knowledge-management/
scripts/
  verify-skills.sh   # 实现阶段补齐或修正校验入口
specs/
  .active
  evolve-personal-skills-and-sdd/
    spec.md
    plan.md
    tasks.md         # 后续阶段产出
```

---

## Risks and Tradeoffs

- 文档层与 skill 资产层容易各写一套说法，若不加结构校验，很快再次漂移。
- `sdd` 若补规则过多，可能重新变成巨型入口文档；需要把规则尽量留在 `references/stages/` 和模板层。
- 结构校验如果只验文件存在、不验叙事一致性，仍会留下 README 承诺失真风险。
- 当前 CI 已暴露潜在断链：`verify.yml` 指向缺失脚本。若先不修，这次演进的“校验模型”会停留在纸面。

---

## Verification Strategy

后续实现完成后，按三层验证：

1. 阶段内校验
   - 检查 `sdd` 在每个阶段文档中是否明确写出进入条件、依赖产物、阶段产出、回退条件、下一步建议。
2. 产物校验
   - 检查 `spec-template.md`、`plan-template.md`、`tasks-template.md` 与 `sdd` 叙事是否一致。
   - 通过一个真实 feature 工作区验证 `spec -> plan -> tasks` 是否能顺畅续接。
3. 仓库结构校验
   - 运行 `bash ./scripts/verify-skills.sh`
   - 运行仓库现有 CI 等价入口，确认 workflow 不再引用缺失路径

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 不需要 | 本次仅是仓库与 workflow 规则建模，已在 plan 内覆盖 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Notes

- 当前 feature 已有 `spec.md`，说明本轮最合适的路由是 `plan`，而不是重新 `ideate` 或直接 `implement`。
- 本计划默认先解决结构和规则清晰度，再决定是否补脚本自动化；但由于 CI 已有断链，结构校验脚本大概率应进入首轮实现范围。

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| 保持 `sdd` 单入口 | UNVERIFIED | 依据当前仓库现状与 spec 约束 |
| 公开边界显式声明 | UNVERIFIED | 依据 README/docs/architecture 现状 |
| 轻量结构校验 | UNVERIFIED | 依据当前 CI 入口与仓库规模 |
