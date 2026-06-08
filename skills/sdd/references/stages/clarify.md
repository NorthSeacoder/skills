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
- 对中大型功能补齐必要的架构前提：业务范围、规模、约束、质量属性和失败代价
- 澄清后必须回写 `spec.md`

## 执行原则

- LM 的角色是”风险发现者”，不是”提问者”——主动分析并呈现用户可能没考虑到的隐藏问题，而不是列问题清单等用户回答
- 能从代码、文档或上下文推断的，直接给出推断结论并请用户确认，不转化为开放式提问
- 输出形式是”我发现了 X，我的推断是 Y，你确认吗”，不是”请回答：X 是什么”
- 一次只呈现少量关键发现，不一次性倾倒所有分析结果
- 当需求涉及新系统、跨模块边界、状态、存储、异步、缓存、安全或关键质量属性时，参考 `../architecture-quality-gate.md`
- 若分析后没有发现隐藏问题，直接说明”没有发现遗漏”并建议进入 plan，不强行制造问题
- 不把 `clarify` 退化成”格式化 spec 的补完器”
- 不把小改动强行扩成完整架构咨询；跳过架构质量门时简短说明原因
- 用户对某个发现说”不重要”或”先不管”时，记录为 known risk 并继续，不反复追问
- 若 spec 命中 `bugfix-loop-breaker`，参考 `../bugfix-loop-breaker.md` 检查 Bugfix Context；root cause、复现状态或失败尝试未知时必须显式写 `unknown` 和下一步调查路径，不得编造 root cause

## 执行步骤

1. 读取 `specs/<feature>/spec.md` 和相关代码、文档
2. 主动分析：识别隐藏问题、盲点、依赖冲突、边界模糊、历史决策矛盾
3. 对能从代码或文档直接推断的项，形成推断结论备用
4. 如触发架构质量门，分析业务范围、规模、读写特征、一致性、增长路径、失败代价、硬约束和质量属性中的隐藏风险
5. 若 spec 命中 `bugfix-loop-breaker`，检查 Observed Behavior、Expected Behavior、Impact Scope、Reproduction Status、Known Failed Attempts、Root Cause Hypothesis 和 Evidence Plan；缺失项只标记为 `unknown`，并形成待调查问题
6. 向用户呈现关键发现，每个发现包含：发现什么 + 推断或担忧 + 请用户确认或修正
7. 若分析后未发现隐藏问题，直接说明并建议进入 `plan`
8. 用户确认或补充后回写 `spec.md`
9. 判断是否可以进入 `plan`

## 回退条件

- 若 `spec.md` 不存在，返回 `specify`
- 若澄清过程中发现问题根源是需求本身未收敛，而不是局部歧义，返回 `ideate` 或 `specify`

## 下一步

- 关键歧义已清：进入 `plan`
- 仍有阻塞项：继续 `clarify`

## 阶段完成标准

- 隐藏风险已被识别并呈现给用户，或确认不存在隐藏问题
- 用户已确认或修正 LM 的关键推断
- 术语、边界和关键历史前提已经对齐
- 若启用了架构质量门，已说明关键质量属性、约束和失败代价是否足以支撑 `plan`
- 用户标记为"不重要"的发现已记录为 known risk
- 相关结论已回写 `spec.md`
- 已能解释为什么可以进入 `plan`，或为什么必须继续 `clarify`
