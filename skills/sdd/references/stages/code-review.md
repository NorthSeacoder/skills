---
source: skills/code-review/SKILL.md
---

# Code Review Check

作为 `Verify` 阶段内的一个检查动作，针对当前改动做交付前审查，优先识别风险、回归、缺失测试、CI 和发布问题，而不是泛泛讲优化建议。

## 何时进入

- 一组改动已经完成并进入 `Verify`
- 需要形成 review 结论，作为完成判定的一部分
- feature 已按 `implement` 或 `execute-plan` 推进到可验证状态

## 审查重点

- 功能错误
- 回归风险
- 测试缺口
- 边界条件遗漏
- 配置、CI、workflow、发布问题

## 核心原则

- 先看行为风险，再看代码风格
- 先读 diff，再下结论
- 优先指出会影响合并或发布的问题
- 验证状态必须说清楚

## 回退条件

- 若改动尚未形成可审查的实现单元，返回 `implement`
- 若审查中发现阻塞性问题、缺失验证或明显回归风险，返回 `implement`

## 下一步

- 有阻塞问题：返回 `implement`
- 无阻塞问题：把结论汇入 `Verify`，继续 runtime 检查、evidence 判定或进入 `Closeout`

## Subagent 派发

若前置检查确认 subagent 可用，进入审查时派发：

- `sdd-reviewer`：输入为变更文件列表 + diff 摘要（或 git diff 输出）；期望输出为按 CRITICAL/HIGH/MEDIUM/LOW 分级的发现列表（≤20 条）+ 末尾 `Verdict:` 行（PASS / CONDITIONAL PASS / FAIL）

派发后等待返回，将审查结论整合到主线程的最终判断中。不可用时退回主线程手动审查。

## 阶段完成标准

- 已明确列出阻塞问题或确认无阻塞问题
- 已说明验证覆盖与残余风险
- 已给出下一步是返回实现还是继续 `Verify`
