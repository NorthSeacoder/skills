---
source: skills/plan/SKILL.md
template: ../../templates/plan-template.md
data_model_template: ../../templates/data-model-template.md
---

# Plan Stage

基于 `spec.md` 生成能指导实现的 `plan.md`。重点是模块边界、数据流、接口、风险和验证路径，而不是任务拆解。

## 何时进入

- `spec.md` 已存在
- 关键需求歧义已解决，或剩余歧义不阻塞方案设计

## 产物

- `specs/<feature>/plan.md`
- 按需：`specs/<feature>/data-model.md`

`plan.md` 是进入 `tasks` 的核心上游产物；`data-model.md` 只在实体、状态、关系或存储变化需要单独展开时创建。

## 核心原则

- 方案必须和代码现实对齐
- 先理解现状，再做设计决策
- `plan` 负责怎么做，不负责拆任务
- 框架特定决策必须标注来源

## 执行步骤

1. 读取 `spec.md`
2. 做方案级只读探索
3. 按需检测技术栈、查阅官方文档并标注来源
4. 读取 `templates/plan-template.md` 生成 `plan.md`
5. 涉及实体或状态变化时，读取 `templates/data-model-template.md` 生成 `data-model.md`

## 回退条件

- 若 `spec.md` 不存在，返回 `specify`
- 若 `spec.md` 仍存在关键阻塞歧义，返回 `clarify`
- 若只读探索后发现当前仓库现实与 spec 假设明显不符，应先更新 spec 或澄清，而不是硬写 plan

## 下一步

- 方案稳定：进入 `tasks`
- 仍存在关键歧义：返回 `clarify`

## 阶段完成标准

- `plan.md` 已说明主要模块边界、关键决策、风险和验证路径
- 已判断是否需要 `data-model.md`
- 方案已足够支撑任务拆解，而不是仍停留在需求复述
