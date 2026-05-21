---
source: skills/execute-plan/SKILL.md
---

# Execute Plan Stage

读取 `tasks.md`，决定从哪里开始执行、一次执行哪些任务，以及适合直接推进还是按阶段分块推进。

## 何时进入

- 已经有 `spec.md`、`plan.md`、`tasks.md`
- 用户说“开始做”“继续做”“从某一步开始做”
- 任务较多，需要控制节奏和上下文

## 目标

- 恢复当前执行状态
- 决定本轮执行范围
- 判断模式：`direct` 或 `delegated`
- 决定下一步是进入 `implement`、继续当前计划、还是回退到上游

## 核心原则

- 优先消费现有 `tasks.md`
- 编排目标是控制节奏、范围和上下文
- 若 `tasks.md` 质量不足以执行，应返回 `tasks`

## 回退条件

- 若 `tasks.md` 不存在，返回 `tasks`
- 若本轮用户目标与 `specs/.active` 指向的 feature 不一致，应先说明失配并重新确认执行范围
- 若发现待执行任务实际依赖未完成的上游产物，应回退到对应阶段

## 下一步

- 范围小且集中：进入 `implement`
- 任务多且跨阶段：按执行块继续 `execute-plan`

## 阶段完成标准

- 已明确当前要执行的 feature、任务范围和节奏
- 已判断本轮应直接进入 `implement`，还是继续按块编排
- 若未进入实现，已明确说明阻塞点和应回退的阶段
