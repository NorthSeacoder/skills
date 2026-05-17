---
source: skills/clarify/SKILL.md
---

# Clarify Stage

识别 `spec.md` 中真正会阻塞后续设计或实现的关键歧义，并用最少的问题补齐。

## 何时进入

- `spec.md` 已存在
- 文档中有 `[NEEDS CLARIFICATION]`
- 虽然没标记，但仍有关键空洞会影响方案或验收

## 目标

- 只清掉会阻塞 `plan / tasks / implement` 的歧义
- 澄清后必须回写 `spec.md`

## 执行原则

- 只问高价值问题
- 能从代码、文档或上下文推断的，不问
- 优先澄清范围、数据、接口、权限、验收相关问题
- 一次只推进少量关键问题

## 执行步骤

1. 读取 `specs/<feature>/spec.md`
2. 识别关键不确定点并排序
3. 提出最小问题集
4. 用户回答后回写 `spec.md`
5. 判断是否可以进入 `plan`

## 下一步

- 关键歧义已清：进入 `plan`
- 仍有阻塞项：继续 `clarify`
