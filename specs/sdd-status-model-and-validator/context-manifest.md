# Context Manifest: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator`
**Created**: 2026-06-07
**Status**: active

> 本文件用于记录 SDD 各阶段必须读取的高信号上下文。它不是待修改源文件清单，也不替代实现阶段按需阅读代码。

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-status-model-and-validator/spec.md` | 实现必须覆盖 active、roadmap、manifest、tasks、evidence、acceptance 的 P1/P2 场景和边界 | implement | yes |
| `specs/sdd-status-model-and-validator/plan.md` | 实现必须遵守 status-model reference、single validator、default/closeout-ready mode 和 ADR 边界 | implement | yes |
| `specs/sdd-status-model-and-validator/data-model.md` | 实现需要对齐概念实体、状态推断、validation modes 和 severity rules | implement | yes |
| `specs/sdd-status-model-and-validator/tasks.md` | 实现需要按任务依赖和覆盖矩阵推进，避免把验证或 closeout 任务漏掉 | implement | yes |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-status-model-and-validator/spec.md` | 验证每个 US / FR 是否有实现和证据，不把结构存在误认为完成 | verify | yes |
| `specs/sdd-status-model-and-validator/plan.md` | 检查实现是否偏离 ADR、default/closeout-ready 边界和低副作用约束 | verify | yes |
| `specs/sdd-status-model-and-validator/data-model.md` | 检查 validator 行为是否符合状态推断和 severity rules | verify | yes |
| `specs/sdd-status-model-and-validator/tasks.md` | 检查任务是否全部完成，并定位未覆盖项 | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| `skills/sdd/references/feature-traits.md` | trait 命中决定 Producer-Consumer Matrix、Evidence Gate、acceptance 和 context manifest 是否必需 | plan / implement / verify | yes |
| `skills/sdd/templates/context-manifest-template.md` | manifest 结构、reason、Required 文件和禁止自动 context injection 的规则来源 | plan / implement / verify | yes |
| `skills/sdd/templates/acceptance-template.md` | acceptance 关键章节和 Completion Record 检查项来源 | plan / implement / verify | yes |
| `skills/sdd/templates/roadmap-template.md` | roadmap Current State、status 枚举、Completion Log 和 Next Recommendation 的结构来源 | implement / verify | yes |

---

## Rules

- 每条 entry 必须有 `Reason`；缺少 reason 的 manifest 不得通过 verify。
- `Required = yes` 的本地文件不存在时，当前阶段必须回退到 `plan` 或 `tasks` 更新 manifest。
- 不要把即将修改的源文件列为固定 context；源文件由 implement / verify 按需检查。
- 不复制长文档；只记录路径、来源、用途和短摘要。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py 或自动 context injection。
