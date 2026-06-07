# Continuation Routing

当用户表达“继续 / 下一步 / 接着做 / resume / continue”等续接意图时，先执行本 reference 的 preflight，再进入普通阶段路由。目标是恢复正确 feature 和阶段，而不是把续接请求误判为新的 ideate。

## 触发信号

命中任一信号时进入 continuation preflight：

- 中文：`继续`、`下一步`、`接着做`、`继续做`、`往下做`、`按计划做`
- 英文：`resume`、`continue`、`next step`、`proceed`
- 用户没有提出新需求，只确认上一轮推荐动作，例如“可以”“ok”“go on”

若用户同时提出新需求和续接词，先判断新需求是否改变当前 feature；改变时回到 `ideate` 或 `specify`，不得静默沿用旧 `.active`。

## 读取顺序

1. 若用户显式指定 feature，优先使用该 feature，并说明是否需要更新 `specs/.active`。
2. 若未显式指定 feature，读取 `specs/.active`。
3. 检查 `specs/<feature>/` 是否存在。
4. 检查该 feature 是否属于某个 `specs/<umbrella>/roadmap.md`。
5. 若属于 roadmap，检查 roadmap 的 `Current Feature` 与 `specs/.active` 是否一致。
6. 读取当前 feature 的 `spec.md`、`plan.md`、`tasks.md`、`context-manifest.md`、`acceptance.md` 和可用 verify evidence，判断下一阶段。

## 失配处理

| State | Required Handling |
|---|---|
| `specs/.active` 缺失或为空 | 说明无法恢复 active feature，回到 feature 确认或 `specify` |
| `specs/.active` 指向的目录不存在 | 说明 active feature 失效，回到 feature 确认或 `specify` |
| 用户显式指定 feature 与 `.active` 不同 | 使用用户指定 feature；说明是否应同步更新 `.active` |
| roadmap `Current Feature` 与 `.active` 不一致 | 先报告 roadmap mismatch，并建议修正 `.active` 或 roadmap；不得进入下游阶段 |
| 多个 roadmap 都引用同一 feature | 要求用户确认 umbrella 归属；不得静默选择 |
| 当前 feature 已 closeout，但 roadmap 有 next recommended feature | 推荐切换到 next recommended feature，并说明依据 |
| 当前 feature 已 closeout，且 roadmap 无 next feature | 说明当前 roadmap 已完成，建议 roadmap closeout 或新需求 |

## 状态映射

| Detected State | Recommended Stage | Required Rationale |
|---|---|---|
| feature 目录存在但缺 `spec.md` | `specify` | 没有可消费的需求规格 |
| 有 `spec.md`，缺 `plan.md` | `plan` | spec 已成形，下一步是方案 |
| 有 `plan.md`，缺 `tasks.md` | `tasks` | 方案稳定后拆执行任务 |
| 有 `tasks.md` 且存在未完成任务 | `execute-plan / implement` | 不跳过执行阶段 |
| `tasks.md` 全部完成但缺 fresh evidence | `verify` | 没有 fresh evidence 不应宣布 feature 完成 |
| verify evidence 为 `FAIL` 或有阻塞缺口 | `implement` 或上游阶段 | 先修复阻塞项，再重新验证 |
| verify evidence 为 `PASS`，但缺 `acceptance.md` 或 closeout completion record | `closeout` | 验证通过不等于收尾完成 |
| 有 `acceptance.md` 且 completion record 表示 PASS | 当前 feature 完成 | 若 roadmap 有 next recommended feature，推荐切换；否则建议 roadmap closeout 或新需求 |

## 输出要求

续接路由输出至少说明：

1. 当前进入 continuation preflight，而不是普通 ideate。
2. 使用的 feature 来源：用户显式指定或 `specs/.active`。
3. 检查到的关键 artifact 状态。
4. 推荐阶段和依据。
5. 将产出或更新什么。
6. 下一步建议。

若存在失配，还必须说明：

7. 失配类型，例如 missing active、missing feature directory、roadmap mismatch 或 multiple roadmap candidates。
8. 建议回退到哪个阶段，或建议更新哪个文件。
9. 在失配修正前不得进入下游阶段。

## 边界

- 只吸收 Trellis `continue` 式续接路由思想。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py、JSONL task 或自动 context injection。
- 不自动提交、不自动 push、不触发外部任务系统同步。
- 本 reference 定义 LM 续接判断规则；完整机器化状态 validator 属于后续 feature。
