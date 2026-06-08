# Bugfix Loop Breaker

Bugfix Loop Breaker 是复杂 bugfix 的强化规则。目标是打断重复猜测、重复失败和只修症状的循环，而不是把所有小修复升级为重流程。

## Trigger Signals

命中任一信号时，spec 应标记 `bugfix-loop-breaker`，除非用户明确选择轻量路径：

- regression：已知行为退化或历史功能被破坏
- repeated failure：同一修复方向或同一验证条件重复失败
- unknown root cause：症状明确但 root cause 未确认
- fix still failing：修复后原问题仍复现
- diffusion risk：同类问题可能存在于共享规则、模板、状态机、调用点或相邻模块
- user intent：用户明确要求 root cause、failed attempts、break loop、防复发或复杂 bugfix

## Skip Conditions

以下情况可跳过完整 loop-breaker，但必须在 spec、tasks 或 closeout 中写明原因：

- 文案、注释、配置或局部小修复，失败代价低
- root cause、修复边界和验证路径已经显然唯一
- 用户显式选择轻量路径
- 仅做探索或临时诊断，不宣布 bugfix 完成

跳过时写：`> 跳过 bugfix-loop-breaker：[原因]`

## Bugfix Context

复杂 bugfix 进入 plan 前应尽量记录：

| Field | Meaning |
|---|---|
| Observed Behavior | 实际错误、退化或失败现象 |
| Expected Behavior | 期望行为或回归前行为 |
| Impact Scope | 受影响用户、路径、模块或工作流 |
| Environment / Constraints | 运行环境、版本、权限、数据或边界条件 |
| Reproduction Status | reproducible / intermittent / not-reproduced / unknown |
| Known Failed Attempts | 已尝试但失败或不足的修复方向 |
| Root Cause Hypothesis | 当前假设；未知时写 `unknown` |
| Evidence Plan | 下一步要获取的证据或验证方式 |

不得把未验证的假设写成事实。root cause 未确认时写 `unknown`，并说明下一步调查路径。

## Failed Attempt Ledger

每次失败尝试至少记录：

| Field | Meaning |
|---|---|
| Attempt | 尝试编号或简述 |
| Change / Action | 修改、验证或排查动作 |
| Result | 失败现象、测试输出、用户反馈或日志摘要 |
| Excluded Hypothesis | 本次失败排除了什么假设 |
| Next Evidence | 下一步要新增的证据或改写的假设 |

若同一失败条件再次出现，必须先更新 ledger 并调整 hypothesis 或 evidence plan，再继续修改。

## Evidence Requirements

Verify 阶段应优先记录 before/after proof：

- Before: 修复前如何失败，定位到测试、脚本、fixture、日志或人工步骤
- After: 修复后同一条件如何通过
- Substitute Evidence: 无法复现时的替代证据和剩余风险
- Regression Guard: 防回归测试、validator、fixture、文档约束或人工验证
- Diffusion Check: 同类路径、共享规则、模板、状态机或调用点是否受影响

不得只写“测试通过”。证据必须可定位。

## Closeout Fields

命中 `bugfix-loop-breaker` 且未跳过时，acceptance 应包含：

- Root Cause 或 Root Cause Hypothesis
- Fix Mechanism
- Prevention Mechanism
- Failed Attempts Summary
- Regression Guard
- Diffusion Check
- Remaining Risk
- Knowledge Capture 条目或 `none + reason`

## Boundaries

- 不新增 debug runtime、issue tracker sync、外部知识库同步、hook、自动提交或自动 push。
- validator 只检查结构字段是否存在，不判断 root cause 是否真实正确。
- 临时 fixture 默认不提交为正式 runtime 文件，除非 plan/tasks 明确新增持久测试目录。
