---
source: skills/implement/SKILL.md
---

# Implement Stage

依据 `spec.md`、`plan.md`、`tasks.md` 执行当前范围内的代码或文档改动，聚焦实现、状态更新和局部验证。

## 何时进入

- `spec.md`、`plan.md`、`tasks.md` 已存在
- 当前执行范围已明确

## 目标

- 在明确任务范围内完成改动
- 更新任务状态
- 做局部验证

## 核心原则

- 只在明确任务范围内工作
- 不重写 `spec`、`plan`、`tasks`
- 优先复用现有模式，不顺手扩大范围
- 每个可验证单元完成后再更新任务状态

## 回退条件

- 若缺少 `spec.md`、`plan.md` 或 `tasks.md`，返回对应上游阶段
- 若实现中发现任务粒度、边界或方案明显不足，返回 `tasks` 或 `plan`
- 若当前 active feature 与正在修改的范围不一致，应先说明并修正上下文

## 执行步骤

1. 确定 feature 与执行范围
2. 读取最小必要上下文
3. 按可验证单元渐进实现
4. 更新 `tasks.md` 状态
5. 做局部验证

## 下一步

- 还有未完成任务：继续 `implement` 或回到 `execute-plan`
- 本轮计划范围完成：进入 `code-review`

## 阶段完成标准

- 当前执行范围内的任务已完成并更新状态
- 已完成至少一轮局部验证
- 已能明确说明是继续实现、回到编排，还是进入 `code-review`
