---
source: skills/tasks/SKILL.md
template: ../../templates/tasks-template.md
---

# Tasks Stage

基于 `spec.md` 和 `plan.md` 生成可执行的 `tasks.md`，确保任务有顺序、有边界、可直接落地。

## 何时进入

- `spec.md` 和 `plan.md` 已存在
- 技术方案已经基本稳定

## 产物

- `specs/<feature>/tasks.md`

`tasks.md` 是进入 `execute-plan` 或 `implement` 的核心上游产物；没有它时，不应直接把 plan 当任务执行。

## 核心原则

- 每个任务都必须能执行，而不是空标题
- 任务必须按依赖顺序组织
- 任务要能映射回需求、场景或验收点
- 当 plan 中存在架构决策或质量属性时，相关任务应能映射回对应决策、质量属性或验证点
- 覆盖实现任务、验证任务和必要收尾任务

## 执行步骤

1. 读取 `spec.md`、`plan.md`，按需读取 `data-model.md`
2. 提取用户场景、验收点、关键改动面与风险
3. 提取 plan 中的关键架构决策、质量属性目标和 architecture drift 风险
4. 确认当前方案足以落成任务
5. 读取 `templates/tasks-template.md` 生成 `tasks.md`

## 回退条件

- 若 `plan.md` 不存在，返回 `plan`
- 若 `spec.md` 不存在，返回 `specify`
- 若方案仍不足以拆成明确任务，返回 `plan` 补强，而不是写空任务标题

## 下一步

- 任务较少且边界清晰：进入 `implement`
- 任务较多或需控节奏：先进入 `execute-plan`

## 阶段完成标准

- `tasks.md` 中每个任务都具备边界和验证方式
- 已说明任务依赖顺序与关键路径
- 关键架构决策、质量属性或 drift 风险已有对应实现或验证任务
- 已能判断应直接 `implement` 还是先 `execute-plan`
