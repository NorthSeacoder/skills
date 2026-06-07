# Implementation Plan: SDD Continue Next Step

**Workspace**: `sdd-continue-next-step` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-continue-next-step/spec.md`

**Note**: 只有一个合理方向：在现有 SDD 入口和 stage references 上增加续接路由规则，不引入 Trellis runtime、hook 或外部副作用。因此跳过候选架构讨论。

---

## Summary

为 `sdd` 增加 Trellis `continue` 风格的续接路由：当用户说“继续 / 下一步 / 接着做 / resume / continue”时，先读取 active feature 状态，再输出阶段建议和回退原因。推荐方案是新增一份 `references/continuation-routing.md` 作为状态映射单一来源，并由 `SKILL.md`、`ideate.md` 和 validator 引用。

---

## Architecture Overview

本 feature 只修改 SDD skill 的工作流说明和结构校验，不改变 runtime 目录约定。

```text
User continuation intent
  -> SKILL.md routing preflight
  -> references/continuation-routing.md
  -> existing stage references
  -> user-visible next-stage recommendation

Workspace files:
  specs/.active
  specs/<feature>/spec.md
  specs/<feature>/plan.md
  specs/<feature>/tasks.md
  specs/<feature>/context-manifest.md
  specs/<feature>/acceptance.md
  specs/<umbrella>/roadmap.md
```

主要边界：

- `SKILL.md` 负责识别续接意图并在阶段路由前调用 continuation preflight。
- `references/continuation-routing.md` 负责状态映射、失配处理和输出要求。
- `references/stages/ideate.md` 负责说明续接请求不进入发散，而是先做 continuation preflight。
- `scripts/validate-sdd.sh` 负责结构校验：reference 存在、入口引用存在、核心关键词存在。
- 不新增 `data-model.md`，因为没有新的实体、持久化 schema 或状态存储格式。

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| 用户请求 | 续接意图关键词 | `SKILL.md` 阶段路由 preflight | `SKILL.md` 明确列出“继续 / 下一步 / 接着做 / resume / continue”等触发词 |
| `specs/.active` | active feature 名称 | `continuation-routing.md` | routing table 要求先解析 active feature，除非用户显式指定 feature |
| `specs/<feature>/spec.md` | 需求规格 | `continuation-routing.md` | 有 spec 但缺 plan 时推荐 `plan` |
| `specs/<feature>/plan.md` | 技术方案 | `continuation-routing.md` | 有 plan 但缺 tasks 时推荐 `tasks` |
| `specs/<feature>/tasks.md` | 执行任务状态 | `continuation-routing.md` | 任务未完成时推荐 `execute-plan / implement`，任务完成但缺验证时推荐 `verify` |
| `specs/<feature>/context-manifest.md` | implement/check/research 上下文 | `verify.md` 与 continuation routing | 若存在 manifest，verify 前仍按现有 Check Context 覆盖规则读取 |
| `specs/<feature>/acceptance.md` | closeout completion record | `continuation-routing.md` | verify 已通过但缺 acceptance / closeout record 时推荐 `closeout` |
| `specs/<umbrella>/roadmap.md` | current feature 与 next recommendation | `continuation-routing.md` | active feature 属于 roadmap 时必须检查 `Current Feature` 与 `.active` 一致 |
| `continuation-routing.md` | 状态映射规则 | `SKILL.md`、`ideate.md`、validator | 入口和 ideate reference 均引用该文件，validator 检查核心文本 |

**孤儿 artifact 处理**: 无孤儿 artifact。新增 reference 的 consumer 是 `SKILL.md`、`ideate.md` 和 validator。

---

## Continuation State Mapping

| Detected State | Required Response | Rationale |
|---|---|---|
| 用户显式指定 feature | 使用用户指定 feature；说明是否需要更新 `specs/.active` | 显式输入优先于默认 active |
| `specs/.active` 缺失、为空或目录不存在 | 回退到 feature 确认或 `specify` | 不允许猜测续接目标 |
| active feature 属于 roadmap，但 roadmap `Current Feature` 不匹配 | 先报告失配并建议修正 `.active` 或 roadmap | 防止在错误 feature 上推进 |
| 只有 `spec.md`，缺 `plan.md` | 推荐 `plan` | spec 已成形，下一步是方案 |
| 有 `plan.md`，缺 `tasks.md` | 推荐 `tasks` | 方案稳定后拆任务 |
| 有 `tasks.md` 且存在未完成任务 | 推荐 `execute-plan / implement` | 不跳过执行阶段 |
| tasks 已完成但缺 fresh verify evidence | 推荐 `verify` | 没有 fresh evidence 不宣布完成 |
| verify 通过但缺 `acceptance.md` 或 closeout completion record | 推荐 `closeout` | 验证通过不等于收尾完成 |
| feature 已 closeout 且 roadmap 有 next recommended feature | 推荐切换到 roadmap next feature | 支持多 feature 续接 |
| feature 已 closeout 且 roadmap 无 next feature | 说明当前 roadmap 已完成，建议 roadmap closeout 或新需求 | 不重复推进旧 feature |

---

## Key Decisions

| Decision | Choice | Reason | Tradeoff |
|---|---|---|---|
| 续接规则位置 | 新增 `references/continuation-routing.md` | 避免把状态映射塞进 `SKILL.md`，便于 validator 和后续 feature 复用 | 多一个 reference 文件 |
| 入口触发 | 在 `SKILL.md` 阶段路由前增加 continuation preflight | 续接请求应先于普通 ideate/specify 判断 | 需要保持文案简短，避免入口膨胀 |
| ideate 处理 | `ideate.md` 明确续接请求不发散 | “继续”不是新需求探索 | ideate 需多一条短路规则 |
| validator 范围 | 只做结构和关键词校验 | 当前 feature 不实现完整状态 validator，那是后续 feature | 不能发现真实 workspace 状态错误 |
| Trellis 边界 | 不引入 hook / CLI / JSONL / `.trellis/` | 保持 SDD 可移植、低副作用 | 无自动注入能力 |

---

## Implementation Scope

预期实现阶段改动：

- `skills/sdd/SKILL.md`
  - 增加“续接意图”识别规则。
  - 在阶段路由前引用 `references/continuation-routing.md`。
  - 输出要求补充 continuation preflight 的依据说明。
- `skills/sdd/references/continuation-routing.md`
  - 新增 reference，定义触发词、读取顺序、状态映射、失配处理和输出格式。
- `skills/sdd/references/stages/ideate.md`
  - 增加短路规则：续接请求先走 continuation routing，不进入需求发散。
- `skills/sdd/scripts/validate-sdd.sh`
  - 检查 `continuation-routing.md` 存在。
  - 检查 `SKILL.md` 引用 continuation routing。
  - 检查 reference 包含 `.active`、roadmap mismatch、fresh evidence、acceptance / closeout 等关键规则。

不修改：

- `context-manifest-template.md`
- `acceptance-template.md`
- subagent YAML / 生成产物
- 外部 hook、CLI、runtime 配置

---

## Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| 续接规则过长导致 `SKILL.md` 入口臃肿 | 影响可读性 | 入口只放触发和引用，细则放 reference |
| `tasks.md` 完成状态难以机器判断 | 可能误判 implement / verify | 本 feature 只定义 LM 判断规则；完整 validator 留给下一 feature |
| fresh verify evidence 定义不够清楚 | 可能过早 closeout | continuation reference 必须沿用现有 “没有 fresh evidence 不宣布完成” 规则 |
| roadmap 归属不唯一 | 可能选错 umbrella | 明确多个 roadmap 命中时要求人工确认 |
| 与后续 status validator 重叠 | 范围膨胀 | 本 feature 不做深度 validator，只做引用和关键词结构检查 |

---

## Validation Path

实施完成后至少验证：

1. `bash skills/sdd/scripts/validate-sdd.sh` 通过。
2. `rg -n "continuation-routing|继续|下一步|resume|continue" skills/sdd` 能显示入口和 reference 引用。
3. 人工 trace 以下状态映射并写入 verify evidence：
   - spec exists / plan missing -> `plan`
   - plan exists / tasks missing -> `tasks`
   - incomplete tasks -> `execute-plan / implement`
   - completed tasks / no fresh evidence -> `verify`
   - verify passed / no acceptance -> `closeout`
   - roadmap current mismatch -> 先修正状态
4. 确认没有引入 `.trellis/`、Trellis CLI、task.py、JSONL task 或 hook 自动注入文本。

---

## Data Model Decision

不创建 `data-model.md`。本 feature 不新增实体、关系、schema 或持久化状态文件；它只定义现有 workspace artifacts 的读取顺序和阶段路由。

---

## Next Step

进入 `tasks` 阶段，把上述范围拆成可执行任务，并要求 tasks 覆盖每个续接状态分支和 validator 结构检查。
