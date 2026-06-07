# Context Manifest: SDD Knowledge Capture Closeout

**Workspace**: `sdd-knowledge-capture-closeout`
**Created**: 2026-06-08
**Status**: active

> 本文件用于记录 SDD 各阶段必须读取的高信号上下文。它不是待修改源文件清单，也不替代实现阶段按需阅读代码。

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-knowledge-capture-closeout/spec.md` | 实现必须覆盖 Knowledge Capture Gate、外部同步边界、低噪音和 redaction 场景 | implement | yes |
| `specs/sdd-knowledge-capture-closeout/plan.md` | 实现必须遵守 acceptance-only 存储、no default external sync、structural validator 等 ADR | implement | yes |
| `specs/sdd-knowledge-capture-closeout/tasks.md` | 实现需要按 closeout contract、acceptance schema、validator、fixture 和 closeout artifact 顺序推进 | implement | yes |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-knowledge-capture-closeout/spec.md` | 验证 US / FR 是否全部有实现和证据，不把段落存在误判为完成 | verify | yes |
| `specs/sdd-knowledge-capture-closeout/plan.md` | 检查实现是否偏离 ADR、低副作用、低噪音和 validator 结构边界 | verify | yes |
| `specs/sdd-knowledge-capture-closeout/tasks.md` | 检查任务是否全部完成，并定位未覆盖项 | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| `skills/sdd/references/feature-traits.md` | trait 命中决定 Producer-Consumer Matrix、Evidence Gate、acceptance 和 context manifest 是否必需 | plan / implement / verify | yes |
| `skills/sdd/references/status-model.md` | closeout-ready validator 的 acceptance section 规则来源 | implement / verify | yes |
| `skills/sdd/references/stages/closeout.md` | Knowledge Capture Gate 应落入的阶段规则位置 | implement / verify | yes |
| `skills/sdd/templates/acceptance-template.md` | Knowledge Capture 持久记录 schema 应落入的模板位置 | implement / verify | yes |
| `skills/sdd/templates/context-manifest-template.md` | manifest 结构、reason、Required 文件和禁止自动 context injection 的规则来源 | tasks / verify | yes |
| `skills/sdd/scripts/validate-sdd.sh` | validator default / closeout-ready 行为和 shell 约束来源 | implement / verify | yes |

---

## Rules

- 每条 entry 必须有 `Reason`；缺少 reason 的 manifest 不得通过 verify。
- `Required = yes` 的本地文件不存在时，当前阶段必须回退到 `plan` 或 `tasks` 更新 manifest。
- 不要把即将修改的源文件列为固定 context；源文件由 implement / verify 按需检查。
- 不复制长文档；只记录路径、来源、用途和短摘要。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py 或自动 context injection。
