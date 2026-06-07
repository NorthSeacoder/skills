# SDD Status Model

本 reference 定义 SDD workspace 的状态来源、推断顺序、validator 检查边界和失配处理。它是 `continuation-routing.md`、阶段规则和 `scripts/validate-sdd.sh` 的共享状态词表。

## State Sources

| Source | Meaning | Consumer |
|---|---|---|
| `specs/.active` | 默认续接 feature 名称 | continuation preflight, validator |
| `specs/<feature>/spec.md` | 需求、trait、验收语义 | plan, tasks, verify |
| `specs/<feature>/plan.md` | 实现方案、ADR、验证路径 | tasks, implement, verify |
| `specs/<feature>/tasks.md` | 执行任务和完成状态 | execute-plan, implement, closeout readiness |
| `specs/<feature>/context-manifest.md` | implement/check/research 必读上下文 | implement, verify, validator |
| `specs/<feature>/verify-evidence.md` | fresh verification evidence | verify, closeout |
| `specs/<feature>/acceptance.md` | 持久 completion record | closeout, roadmap closeout |
| `specs/<umbrella>/roadmap.md` | umbrella current feature、状态和 next recommendation | continuation, closeout, validator |

## Inference Order

当用户没有显式指定 feature 时，先读取 `specs/.active`。有效 active feature 必须满足：

1. `specs/.active` 存在。
2. 内容非空。
3. `specs/<active-feature>/` 目录存在。

然后按 artifacts 推断当前阶段：

| Detected State | Recommended Stage | Completion Meaning |
|---|---|---|
| 缺 `spec.md` | `specify` | 没有可消费的需求规格 |
| 有 `spec.md`，缺 `plan.md` | `plan` | 需求已成形，方案缺失 |
| 有 `plan.md`，缺 `tasks.md` | `tasks` | 方案已成形，执行清单缺失 |
| 有 `tasks.md` 且存在 `- [ ]` | `execute-plan / implement` | 仍在执行，不得宣布完成 |
| tasks 完成但缺 `verify-evidence.md` | `verify` | 没有 fresh evidence，不得宣布完成 |
| 有 verify evidence，但缺 `acceptance.md` 或 completion record | `closeout` | 验证通过不等于收尾完成 |
| `acceptance.md` 有 completion record 和 Overall | current feature 可进入完成判断 | 仍需根据 verdict 和 roadmap 状态决定下一步 |

## Roadmap Consistency

当 active feature 属于 active roadmap 时，roadmap `Current Feature` 必须等于 `specs/.active`。

| Situation | Validator Handling |
|---|---|
| active roadmap `Current Feature` 与 `.active` 不一致 | FAIL: `roadmap current mismatch` |
| 多个 active/current roadmap 都指向同一 active feature | FAIL: `multiple roadmap candidates` |
| completed roadmap 且 `Current Feature: none` | PASS，历史 roadmap 不参与 current 匹配 |
| 用户显式指定 feature 与 `.active` 不同 | LM 应说明切换来源；validator 仍检查 `.active` 的本地一致性 |

## Context Manifest Rules

若 `context-manifest.md` 存在，validator 必须检查：

- 每条 context entry 都有 `Reason`。
- `Required = yes` 且 source 是本地路径时，文件必须存在。
- `Check Context` 至少覆盖当前 feature 的 `spec.md`、`plan.md`、`tasks.md`。
- URL 或外部 source 不做本地文件存在性检查，但仍必须有 reason。

若 manifest `Status: skipped`，必须有 `Skip Reason`。命中强化 trait 的 feature 在 implement / verify 前通常不应跳过 manifest。

## Validation Modes

### default

用于日常结构校验。必须检查 stage assets、入口引用、active feature、roadmap current 和 manifest 结构。

default mode 不得因为当前 feature 仍在 plan / tasks / implement 阶段而要求 `verify-evidence.md` 或 `acceptance.md`。

### closeout-ready

用于 verify / closeout 前。除 default checks 外，还必须检查：

- `tasks.md` 存在且没有 `- [ ]`。
- `verify-evidence.md` 存在。
- `acceptance.md` 存在并包含 Evidence Table、Verdict Summary、Closeout Checklist、Knowledge Capture、Completion Record 和 Overall。
- Knowledge Capture 必须包含 Type、Title、Summary、Evidence、Scope、Sync Status、Follow-up 字段，或明确记录 `none` 和跳过原因。

## Boundaries

- validator 只检查结构、一致性和可定位失败原因。
- validator 不判断 evidence 或 Knowledge Capture 内容是否充分，不替代 verify/reviewer 的语义判断。
- 不引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入、外部同步或自动提交。
