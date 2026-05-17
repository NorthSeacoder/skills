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

## 核心原则

- 每个任务都必须能执行，而不是空标题
- 任务必须按依赖顺序组织
- 任务要能映射回需求、场景或验收点
- 覆盖实现任务、验证任务和必要收尾任务

## 执行步骤

1. 读取 `spec.md`、`plan.md`，按需读取 `data-model.md`
2. 提取用户场景、验收点、关键改动面与风险
3. 确认当前方案足以落成任务
4. 读取 `templates/tasks-template.md` 生成 `tasks.md`

## 下一步

- 任务较少且边界清晰：进入 `implement`
- 任务较多或需控节奏：先进入 `execute-plan`
