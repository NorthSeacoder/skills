# Implementation Plan: Migrate Repository To Skills.sh Distribution

**Workspace**: `migrate-to-skills-sh-distribution` | **Date**: 2026-05-16 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `specs/migrate-to-skills-sh-distribution/spec.md`

---

## Summary

把仓库从“`registry + publish-links` 驱动的本地发布仓库”重构为“面向 `skills.sh` 的 skill 源仓库”。推荐方案是收敛对外能力为单一 `sdd` 主 skill，并将 `knowledge-management` 视作可选公开项，不让其阻塞主迁移。

---

## Architecture Overview

当前仓库有三层耦合：

- `skills/<name>/`：真实源码
- `registry/skills.yaml`：管理元数据与发布目标
- `scripts/*publish*`：把源码软链接发布到 `~/.agents/skills` / `~/.claude/skills`

目标架构应改为两层：

- `skills/`：仅保留实际维护的 skill 源目录
- 仓库文档层：README、AGENTS、`docs/*` 直接说明 `skills.sh` 安装与维护方式

`sdd` 将从多个强耦合子 skill 收敛为单一入口 skill。其内部继续保留阶段化方法论，但这些阶段改为 `references/` 或内部说明材料，不再作为独立安装单元暴露。用户安装后应只需要使用 `sdd`，由 skill 自身负责判断当前阶段并提示后续动作。

---

## Key Design Decisions

### Decision 1: 移除 registry 与 publish-links，转为文档驱动的 skills.sh 分发

- **背景**: 现有 registry 和脚本服务于本地软链接发布，与“跨环境直接安装”目标冲突。
- **选项**:
  - A: 保留 registry 作为维护元数据，同时新增 `skills.sh` 支持 — 迁移不彻底，文档和流程仍会双轨
  - B: 直接删除 registry 和发布脚本，仓库只保留 skill 源与文档 — 模型更简单，也更符合新目标
- **结论**: 选择 B。用户已明确不需要兼容旧模式。
- **影响**: `README.md`、`AGENTS.md`、`docs/architecture.md`、`docs/maintenance.md` 都需要重写；旧脚本要删除或至少不再成为仓库主路径。
- **来源**: https://www.skills.sh/docs

### Decision 2: 对外只保留 `sdd` 作为主 skill

- **背景**: `specify / clarify / plan / tasks / implement / code-review / execute-plan` 当前强耦合，基本没有独立安装价值。
- **选项**:
  - A: 保持拆分 skill — 安装与理解成本高，且不符合真实使用方式
  - B: 增加总控 skill，同时保留全部子 skill — 结构冗余，仍需维护多份对外入口
  - C: 直接收敛为单一 `sdd` skill，内部保留阶段说明 — 对外最清晰，维护成本最低
- **结论**: 选择 C。
- **影响**: 需要设计 `sdd/SKILL.md` 的入口行为，并迁移原 SDD skill 中仍有价值的内容到 `sdd/references/`。
- **来源**: UNVERIFIED — 这是基于当前仓库结构和用户使用方式的产品决策，不依赖平台特定 API

### Decision 3: `sdd` 采用“单入口 + 内部阶段引导”，而非多命令切换

- **背景**: 收敛为单一 skill 后，用户不能再依赖显式调用多个子 skill 名称推进流程。
- **选项**:
  - A: 让用户继续记忆旧阶段名，并在 `sdd` 中口头映射 — 对外模型和内部模型脱节
  - B: 让 `sdd` 接收不同场景输入，自行判断当前所处阶段并给出下一步 — 单入口一致性最好
- **结论**: 选择 B。
- **影响**: `sdd/SKILL.md` 需要把“触发条件、阶段判断、产物约定、下一步推荐”写成统一入口协议。
- **来源**: UNVERIFIED — 平台只要求 skill 可安装；具体交互协议属于仓库内设计

### Decision 4: `knowledge-management` 不阻塞主迁移，可作为后续可选公开 skill

- **背景**: 该 skill 依赖 `nmem`，且是否完全脱离个人环境仍未验证。
- **选项**:
  - A: 强制一起公开 — 可能拖慢主迁移并引入额外清理工作
  - B: 允许其暂时不公开，只保留源码并单独评估可移植性 — 降低主迁移风险
- **结论**: 选择 B。
- **影响**: 本轮实现优先围绕 `sdd` 和仓库分发模型；`knowledge-management` 只需避免被 README 误宣传为已可直接对外安装。
- **来源**: UNVERIFIED — 取决于仓库内该 skill 的实际依赖情况

### Decision 5: 安装说明优先使用仓库安装，单 skill 安装作为补充

- **背景**: `skills.sh` 文档明确给出仓库安装命令；技能页还展示了带 `--skill` 的安装方式。
- **选项**:
  - A: README 只写仓库安装 — 简洁，但不利于未来保留可选 skill
  - B: README 主推仓库安装，同时补充单 skill 安装示例 — 更完整
- **结论**: 选择 B。
- **影响**: README 需要区分“推荐安装方式”和“按 skill 安装方式”。
- **来源**: https://www.skills.sh/docs ; https://www.skills.sh/docs/cli ; https://skills.sh/vercel-labs/add-skill/find-skills

---

## Module Design

### Module: `skills/sdd/`

**职责**: 作为对外唯一主入口，承载完整的 SDD 工作流。

**改动概述**: 合并原 `specify`、`clarify`、`plan`、`tasks`、`implement`、`code-review`、`execute-plan` 的对外职责；把阶段细则下沉到 `references/`，把产物模板集中到 `templates/`，避免单一入口文件膨胀。

**关键接口 / 行为**:

```text
用户安装 skill
→ 用户在会话中提到 “sdd” 或直接按 SDD 方式发起需求
→ sdd 判断当前输入更接近哪一阶段
→ sdd 告知当前将产出什么文件/产物
→ sdd 在阶段结束时提示下一步
→ 后续仍由同一 skill 继续承接，而不是要求用户切换 skill 名称
```

**注意事项**:

- `SKILL.md` 入口必须短，避免把全部阶段细则堆在一个文件里
- 阶段说明与产物模板必须分层维护，不能混放
- 阶段模板、规范、反模式应尽量沉到 `references/`
- 原子目录名建议稳定为 `skills/sdd/`，不要继续使用子 skill 作为安装单元

**内部资产组织**:

```text
skills/sdd/
├── SKILL.md
├── references/
│   └── stages/
│       ├── ideate.md
│       ├── specify.md
│       ├── clarify.md
│       ├── plan.md
│       ├── tasks.md
│       ├── implement.md
│       ├── code-review.md
│       └── execute-plan.md
├── templates/
│   ├── spec-template.md
│   ├── plan-template.md
│   ├── tasks-template.md
│   └── acceptance-template.md
└── examples/                         # 按需
```

**维护规则**:

- 所有会写入工作区的模板统一维护在 `skills/sdd/templates/`
- 所有阶段方法论统一维护在 `skills/sdd/references/stages/`
- `SKILL.md` 只保留入口协议、阶段判断、产物与下一步衔接，不复制模板正文
- `ideate` 若保留，只作为 `sdd` 的可选前置阶段材料存在，不再作为独立安装单元

### Module: Repository Documentation

**职责**: 让新用户在不了解历史背景的情况下，明确知道这个仓库如何安装、如何使用、如何配置。

**改动概述**: 重写 `README.md`、`AGENTS.md`、`docs/architecture.md`、`docs/maintenance.md`，统一改为 `skills.sh` 模型。

**关键接口 / 行为**:

```text
README:
- badge
- 仓库用途
- 安装命令
- sdd 的使用方式
- 可选 skill 状态说明
- .env / 环境变量约定
- 致谢
```

**注意事项**:

- 不再把 `~/.agents/skills` 或 `~/.claude/skills` 作为主叙事
- 明确区分“可安装”和“仅源码保留”
- 不提 `context-hub`

### Module: Legacy Assets Cleanup

**职责**: 清理与新架构冲突的旧目录、脚本和文档表述。

**改动概述**: 删除 `registry/skills.yaml`，清理或删除 `publish-links.sh`、`unpublish-links.sh`、`list-conflicts.sh`，并处理旧 SDD skill 目录的去留。

**关键接口 / 行为**:

```text
识别旧资产
→ 判断是删除还是并入 sdd references
→ 更新所有指向旧模型的文档
→ 确保仓库树与 README 叙事一致
```

**注意事项**:

- 若保留旧目录作为迁移参考，不应继续被 README 或 AGENTS 描述为可安装 skill
- 删除旧目录前要先迁移其中仍有价值的模板和规范

---

## Project Structure

```text
README.md                              [修改]
AGENTS.md                              [修改]
docs/
├── architecture.md                    [修改]
└── maintenance.md                     [修改]
skills/
├── sdd/                               [新增]
│   ├── SKILL.md                       [新增]
│   ├── references/stages/             [新增]
│   │   ├── ideate.md                  [新增/迁移]
│   │   ├── specify.md                 [新增/迁移]
│   │   ├── clarify.md                 [新增/迁移]
│   │   ├── plan.md                    [新增/迁移]
│   │   ├── tasks.md                   [新增/迁移]
│   │   ├── implement.md               [新增/迁移]
│   │   ├── code-review.md             [新增/迁移]
│   │   └── execute-plan.md            [新增/迁移]
│   ├── templates/                     [新增]
│   │   ├── spec-template.md           [新增/迁移]
│   │   ├── plan-template.md           [新增/迁移]
│   │   ├── tasks-template.md          [新增/迁移]
│   │   └── acceptance-template.md     [新增/迁移/按需]
│   └── examples/                      [按需]
├── specify/                           [删除或下线]
├── clarify/                           [删除或下线]
├── plan/                              [删除或下线]
├── tasks/                             [删除或下线]
├── implement/                         [删除或下线]
├── code-review/                       [删除或下线]
└── execute-plan/                      [删除或下线]
registry/skills.yaml                   [删除]
scripts/publish-links.sh               [删除]
scripts/unpublish-links.sh             [删除]
scripts/list-conflicts.sh              [删除]
```

---

## Risks and Tradeoffs

- `sdd` 合并后入口文件过重，若不做内容下沉，会降低可维护性。
- 旧 SDD skill 中可能存在可复用模板、反模式说明或路径约定，迁移时容易漏掉。
- `knowledge-management` 若暂不公开，README 需要避免传达“仓库内所有 skill 都可直接安装”的错误预期。
- `skills.sh` 官方文档公开说明了仓库安装和 badge，但单 skill 安装方式更多来自技能页展示，README 里应避免对未验证的平台行为做过强承诺。

---

## Verification Strategy

- 结构验证：
  - 仓库顶层不再依赖 `registry/skills.yaml`
  - 对外文档中不再把 publish-links 作为主流程
- 内容验证：
  - `sdd/SKILL.md` 能独立解释入口、阶段切换和产物约定
  - README 能在不阅读历史文档的前提下说明安装与使用方式
- 一致性验证：
  - README、AGENTS、`docs/architecture.md`、`docs/maintenance.md` 的仓库模型一致
  - 仓库树与 README 中描述的 installable skill 一致
- 可发布性验证：
  - 使用 `skills.sh` 约定的安装命令示例校对 README 文案
  - 若后续允许联网实测，再补一次真实 `npx skills add ...` 安装验证

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 不需要 | 本次是仓库架构与文档迁移，不涉及复杂实体或存储模型 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Notes

- `knowledge-management` 的对外发布与否，不应阻塞 `sdd` 主迁移。
- 如果实现阶段发现某些旧 SDD 目录必须临时保留，应明确标注为内部迁移材料，而不是继续暴露为可安装 skill。
- README 中关于 `.env` 的表述应写成“仓库约定”或“skill 配置方式”，不要暗示 `skills.sh` 平台会自动按 skill 隔离加载环境变量。

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| skills.sh 仓库安装方式 | https://www.skills.sh/docs | 文档给出 `npx skills add owner/repo` 形式 |
| skills CLI 基本用法 | https://www.skills.sh/docs/cli | CLI 文档确认 `npx skills add <skill-name>` / `owner/repo` 安装 |
| README badge 写法 | https://www.skills.sh/docs | 文档给出 badge 模板 |
| 单 skill 安装示例 | https://skills.sh/vercel-labs/add-skill/find-skills | 技能页展示 `npx skills add https://github.com/... --skill find-skills` |
