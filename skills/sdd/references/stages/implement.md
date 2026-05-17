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

## 执行步骤

1. 确定 feature 与执行范围
2. 读取最小必要上下文
3. 按可验证单元渐进实现
4. 更新 `tasks.md` 状态
5. 做局部验证

## 下一步

- 还有未完成任务：继续 `implement` 或回到 `execute-plan`
- 本轮计划范围完成：进入 `code-review`
