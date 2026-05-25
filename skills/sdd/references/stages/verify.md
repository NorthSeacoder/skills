---
source: sdd custom stage
---

# Verify Stage

把“已经做完”转化为“已经被验证”，聚合代码审查、测试、runtime/browser 检查和 fresh evidence，决定当前 feature 是否真的可以进入收尾。

## 何时进入

- 当前执行范围已经完成
- `implement` 已产出局部验证结果或其他 fresh evidence
- 需要判断当前 feature 是 PASS、CONDITIONAL PASS 还是 FAIL

## 目标

- 收集并评估 fresh evidence
- 完成 review、测试和必要的 runtime/browser 检查
- 检查实现是否偏离 plan 中的架构边界、质量属性和关键 ADR
- 给出明确 Verdict
- 决定是返回 `implement`，还是进入 `closeout`

## 核心原则

- 没有 fresh evidence，不应宣布完成
- 先看行为和风险，再看表达是否漂亮
- `code-review` 是 `Verify` 的一个检查动作，不是整个阶段本身
- 验证结论必须能支持下一步是否进入 `Closeout`
- 若实现暴露 plan 假设错误，应返回 `plan` 或 `clarify`，而不是只在实现层补丁

## 执行步骤

1. 汇总当前实现范围、局部验证结果和剩余风险
2. 执行或检查代码审查结论
3. 检查是否存在 architecture drift：模块边界、数据流、状态、依赖、缓存、队列、外部调用或失败模式是否偏离 plan
4. 检查测试、runtime 或 browser 级证据
5. 判断证据是否足以支持完成判定
6. 输出 `PASS` / `CONDITIONAL PASS` / `FAIL`
7. 若通过，进入 `closeout`

## 回退条件

- 若缺少 fresh evidence，返回 `implement`
- 若 review 或测试发现阻塞性问题，返回 `implement`
- 若验证中发现当前 plan 假设与实现不符，返回 `plan` 或 `clarify`
- 若新增关键架构决策但未记录，返回 `plan` 补充轻量 ADR

## 下一步

- `FAIL`：返回 `implement`
- `CONDITIONAL PASS`：补齐剩余验证后继续 `verify`
- `PASS`：进入 `closeout`

## Subagent 派发

若前置检查确认 subagent 可用，进入验证时可派发：

- `sdd-reviewer`：输入为变更文件列表 + diff 摘要（或 git diff 输出）；期望输出为按 CRITICAL/HIGH/MEDIUM/LOW 分级的发现列表（≤20 条）+ 末尾 `Verdict:` 行（PASS / CONDITIONAL PASS / FAIL）

派发后等待返回，将审查结论与其他 evidence 一起整合到最终 Verdict 中。不可用时退回主线程手动验证。

## 阶段完成标准

- 已形成明确的 fresh evidence 集合
- 已说明 review、测试和 runtime/browser 检查的状态
- 已说明架构漂移检查状态；若不适用，也说明原因
- 已输出可支撑下一步的 Verdict
- 若通过，已能解释为什么可以进入 `closeout`
