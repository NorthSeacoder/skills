---
source: skills/specify/SKILL.md
template: ../../templates/spec-template.md
checklist: ../../templates/checklist-template.md
---

# Specify Stage

把自然语言需求固化成可执行的 `spec.md`，明确目标、范围、场景、约束和非目标，而不是提前设计实现方案。

## 何时进入

- 一个中大型功能还没有正式规格
- 后续准备按 `specs/<feature>/` 流程推进
- 用户需求包含多个场景、边界或约束

## 产物

- `specs/<feature>/spec.md`
- `specs/.active`
- 按需：`specs/<umbrella>/roadmap.md`（当用户需求被确认拆成多个 feature 时）

`spec.md` 是后续 `clarify`、`plan`、`tasks` 的上游核心产物；没有它时，不应继续生成下游文档。

## 核心原则

- `spec` 只回答需求，不回答实现
- 先做范围级只读探索，再写规格
- 能确认的先确认，关键不确定项用 `[NEEDS CLARIFICATION]` 标记
- spec 必须足以支撑 `clarify / plan`
- 多 feature 需求只为当前推荐首项写完整 spec，后续 feature 只在 roadmap 中保留轻量占位

## 执行步骤

1. 生成简短英文 `kebab-case` feature 名称
2. 创建或确认 `specs/<feature>/`
3. 做范围级只读探索
4. 如果需求已确认拆成多个 feature，读取 `templates/roadmap-template.md`，创建或更新 `specs/<umbrella>/roadmap.md`：当前 feature 标记为 `current`，后续 feature 标记为 `backlog`，并记录依赖、启动条件和推荐阶段
5. 读取 `templates/spec-template.md` 生成当前 feature 的 `spec.md`
6. 检测 feature traits 并写入 spec.md 的 `Feature Traits` 段（参考 `../feature-traits.md`，逐 trait 给出命中标记和依据）
7. 同步更新 `specs/.active` 指向当前 feature；若当前 feature 属于 roadmap，确认 `.active` 与 roadmap 的 `Current Feature` 一致
8. 需要时配合 `templates/checklist-template.md` 做规格质量检查

## 回退条件

- 若探索后发现需求仍明显发散或用户目标不稳定，返回 `ideate`
- 若 feature 名称、工作区或 `specs/.active` 与当前目标不符，应先修正再继续写 spec
- 若 roadmap 的 `Current Feature` 与 `specs/.active` 不一致，应先说明失配并修正 roadmap 或 `.active`，不得静默继续

## 下一步

- 有关键歧义：进入 `clarify`
- 无关键歧义：进入 `plan`

## Subagent 派发

若前置检查确认 subagent 可用，在执行步骤第 3 步（范围级只读探索）时派发：

- `sdd-explorer`：输入为 feature 名称 + 用户需求摘要；期望输出为按主题分组的 findings 列表（`file:line — summary` 格式，≤30 行）+ Open questions

派发后等待返回，将压缩结论作为写 spec 的输入上下文。不可用时退回主线程手动探索。

## 阶段完成标准

- `spec.md` 已写入 `specs/<feature>/`
- `specs/.active` 已指向当前 feature
- 若当前需求被拆成多个 feature，`specs/<umbrella>/roadmap.md` 已创建或更新，且 roadmap 的 `Current Feature` 与 `specs/.active` 一致
- `Feature Traits` 段已写入 spec.md（即使全部为 ❌ 也需显式标记，并给出"按基础流程推进"的结论）
- spec 足以支撑 `clarify` 或 `plan`，而不是只有标题和空框架
