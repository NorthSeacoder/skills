---
source: skills/clarify/SKILL.md
---

# Clarify / Domain Alignment Stage

在正式进入技术方案前，识别并清理会影响后续设计或验收的术语歧义、边界冲突、历史决策失配和关键前提空洞。

## 何时进入

- `spec.md` 已存在
- 文档中有 `[NEEDS CLARIFICATION]`
- 虽然没标记，但术语、边界、上下文或既有决策仍未对齐
- 用户输入与当前 `spec.md` 的含义存在偏差，继续写 plan 会放大误解

## 目标

- 只清掉会阻塞 `plan / tasks / implement / verify` 的高价值歧义
- 在进入 plan 前完成必要的领域对齐
- 澄清后必须回写 `spec.md`

## 执行原则

- 只问高价值问题
- 能从代码、文档或上下文推断的，不问
- 优先澄清术语、范围、接口、权限、历史决策和验收相关问题
- 一次只推进少量关键问题
- 不把 `clarify` 退化成“格式化 spec 的补完器”

## 执行步骤

1. 读取 `specs/<feature>/spec.md`
2. 识别关键不确定点并排序
3. 识别术语、边界、上下文冲突和历史决策失配
4. 提出最小问题集
4. 用户回答后回写 `spec.md`
5. 判断是否可以进入 `plan`

## 回退条件

- 若 `spec.md` 不存在，返回 `specify`
- 若澄清过程中发现问题根源是需求本身未收敛，而不是局部歧义，返回 `ideate` 或 `specify`

## 下一步

- 关键歧义已清：进入 `plan`
- 仍有阻塞项：继续 `clarify`

## 阶段完成标准

- 阻塞 `plan / tasks / implement / verify` 的关键歧义已被清理或显式界定
- 术语、边界和关键历史前提已经对齐
- 相关结论已回写 `spec.md`
- 已能解释为什么可以进入 `plan`，或为什么必须继续 `clarify`
