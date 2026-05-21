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

`spec.md` 是后续 `clarify`、`plan`、`tasks` 的上游核心产物；没有它时，不应继续生成下游文档。

## 核心原则

- `spec` 只回答需求，不回答实现
- 先做范围级只读探索，再写规格
- 能确认的先确认，关键不确定项用 `[NEEDS CLARIFICATION]` 标记
- spec 必须足以支撑 `clarify / plan`

## 执行步骤

1. 生成简短英文 `kebab-case` feature 名称
2. 创建或确认 `specs/<feature>/`
3. 做范围级只读探索
4. 读取 `templates/spec-template.md` 生成 `spec.md`
5. 需要时配合 `templates/checklist-template.md` 做规格质量检查

## 回退条件

- 若探索后发现需求仍明显发散或用户目标不稳定，返回 `ideate`
- 若 feature 名称、工作区或 `specs/.active` 与当前目标不符，应先修正再继续写 spec

## 下一步

- 有关键歧义：进入 `clarify`
- 无关键歧义：进入 `plan`

## 阶段完成标准

- `spec.md` 已写入 `specs/<feature>/`
- `specs/.active` 已指向当前 feature
- spec 足以支撑 `clarify` 或 `plan`，而不是只有标题和空框架
