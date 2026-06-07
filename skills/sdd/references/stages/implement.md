---
source: skills/implement/SKILL.md
---

# Implement Stage

依据 `spec.md`、`plan.md`、`tasks.md` 执行当前范围内的代码或文档改动，聚焦最小任务包、增量实现、状态更新和局部验证。

## 何时进入

- `spec.md`、`plan.md`、`tasks.md` 已存在
- 当前执行范围已明确

## 目标

- 在明确任务范围内完成改动
- 更新任务状态
- 做局部验证
- 为后续 `Verify` 准备 fresh evidence

## 核心原则

- 只在明确任务范围内工作
- 不重写 `spec`、`plan`、`tasks`
- 若存在 `context-manifest.md`，先读取 Implement Context；命中 trait 但 manifest 缺失时，应回退到 `tasks` 或 `plan` 补齐
- 优先复用现有模式，不顺手扩大范围
- 每个可验证单元完成后再更新任务状态
- 尽量让每轮实现对应一个最小任务包，而不是扩散成整批隐式改动
- context manifest 不替代源文件检查；待修改源文件仍由实现阶段按需读取

## 回退条件

- 若缺少 `spec.md`、`plan.md` 或 `tasks.md`，返回对应上游阶段
- 若实现中发现任务粒度、边界或方案明显不足，返回 `tasks` 或 `plan`
- 若当前 active feature 与正在修改的范围不一致，应先说明并修正上下文
- 若实现中发现 checkpoint 已漂移，应返回 `execute-plan` 重新编排
- 若 `context-manifest.md` 中 Required 文件不存在、缺少 reason，或 Implement Context 无法支撑当前实现，返回 `tasks` 或 `plan` 更新 manifest

## 执行步骤

1. 确定 feature 与执行范围
2. 若存在 `context-manifest.md`，读取 Implement Context；若命中 trait 但 manifest 缺失，先回退补齐或记录跳过原因
3. 校验 manifest 条目：每条必须有 reason；Required 本地文件必须存在
4. 读取最小必要上下文和按需检查源文件
5. 按可验证单元渐进实现
6. 更新 `tasks.md` 状态
7. 做局部验证
8. 记录进入 `Verify` 所需的证据线索，包括 manifest 是否被读取

## 下一步

- 还有未完成任务：继续 `implement` 或回到 `execute-plan`
- 本轮计划范围完成：进入 `verify`

## 阶段完成标准

- 当前执行范围内的任务已完成并更新状态
- 已完成至少一轮局部验证
- 若存在 `context-manifest.md`，已读取 Implement Context 并说明缺失项处理结果；若跳过，已记录原因
- 已能明确说明是继续实现、回到编排，还是进入 `verify`
