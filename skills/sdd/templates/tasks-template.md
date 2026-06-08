# Tasks: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期]  
**Input**: `specs/[工作区名称]/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (按需)

**Note**: 此模板由 `tasks` 命令填充。目标是生成一份真正可以执行的任务清单。
**Artifact Rule**: `tasks.md` 是进入 `execute-plan` 或 `implement` 的核心上游产物，不应写成空标题列表。

---

## 执行原则

- 任务应按依赖顺序组织
- 任务应足够具体，后续可以直接进入实现
- 核心需求和关键场景必须被任务覆盖
- 不把 `tasks.md` 写成另一份 `plan.md`

---

## 任务格式

推荐格式：

```text
- [ ] T001 [Phase?] [Story?] 描述
  - scope: [当前任务涉及的关键文件、模块或边界]
  - maps_to: [US / FR / ADR / Quality Attribute，按需填写]
  - verify: [完成后如何验证]
```

---

## Phase 1: [阶段名称]

**目标**: [本阶段完成什么]

- [ ] T001 [US1] [任务描述]
  - scope: [关键文件/模块]
  - maps_to: [US1 / FR-001 / ADR-001 / 性能，按需填写]
  - verify: [局部验证方式]

---

## Bugfix Loop Breaker Tasks *(if `bugfix-loop-breaker`)*

> 当 spec.md 中 `bugfix-loop-breaker` 命中时，任务必须覆盖以下类别；轻量 bugfix 跳过时写明原因。

- [ ] T00X [Bugfix] 记录复现或替代证据
  - scope: [测试 / fixture / 日志 / 人工步骤]
  - maps_to: Bugfix Context / FR-007
  - verify: [before-fails 或无法复现原因]

- [ ] T00X [Bugfix] 维护 Failed Attempt Ledger
  - scope: [tasks.md / verify-evidence.md]
  - maps_to: Failed Attempt Ledger / FR-006
  - verify: [失败尝试、排除假设和下一步证据已记录]

- [ ] T00X [Bugfix] 增加 Regression Guard 和 Diffusion Check
  - scope: [测试 / validator / 相邻路径扫描]
  - maps_to: FR-008
  - verify: [guard 通过，扩散检查有结论或跳过原因]

---

## 依赖与顺序

- 哪些任务必须先完成
- 哪些任务可以并行或相对独立
- 哪些属于关键路径

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 | T001 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001 / 性能 | T001 | T00X |

---

## Notes

- 任务粒度过粗时，后续实现会失控
- 任务粒度过碎时，维护成本会变高
- 如果发现任务无法从 plan 直接落地，应返回 `plan` 调整

---

## Stage Readiness

- 推荐下一步：`implement` / `execute-plan`
- 阻塞项（如有）：[哪些问题仍阻塞执行]
