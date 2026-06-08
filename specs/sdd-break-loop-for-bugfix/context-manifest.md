# Context Manifest: SDD Break Loop For Bugfix

**Workspace**: `sdd-break-loop-for-bugfix`
**Created**: 2026-06-08
**Status**: active

> 本文件用于记录 SDD 各阶段必须读取的高信号上下文。它不是待修改源文件清单，也不替代实现阶段按需阅读代码。

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-break-loop-for-bugfix/spec.md` | Defines bugfix loop-breaker requirements, trait signals, boundaries and P1/P2 scenarios. | implement | yes |
| `specs/sdd-break-loop-for-bugfix/plan.md` | Defines ADRs, module boundaries, validator boundary and verification strategy. | implement | yes |
| `specs/sdd-break-loop-for-bugfix/tasks.md` | Defines execution order, task scope, maps_to requirements and local verify checks. | implement | yes |
| `skills/sdd/references/feature-traits.md` | Existing trait model must be updated consistently with the new bugfix trait. | implement | yes |
| `skills/sdd/references/status-model.md` | Existing closeout-ready boundaries constrain validator behavior. | implement | yes |
| `skills/sdd/scripts/validate-sdd.sh` | Structural validator is a primary implementation target and must remain shell-readable. | implement | yes |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-break-loop-for-bugfix/spec.md` | Verify P1/P2 user scenarios, FR-001..FR-012 and out-of-scope boundaries. | verify | yes |
| `specs/sdd-break-loop-for-bugfix/plan.md` | Check architecture drift against ADRs, Producer-Consumer Matrix and verification strategy. | verify | yes |
| `specs/sdd-break-loop-for-bugfix/tasks.md` | Check all tasks are complete and mapped to requirements before closeout. | verify | yes |
| `specs/sdd-break-loop-for-bugfix/context-manifest.md` | Validate manifest coverage and required context availability. | verify | yes |
| `skills/sdd/references/bugfix-loop-breaker.md` | Planned shared vocabulary; after T001, verify it exists and matches stage/template references. | verify | no |
| `skills/sdd/references/stages/verify.md` | Verify before/after evidence, regression guard and diffusion check rules are present. | verify | yes |
| `skills/sdd/references/stages/closeout.md` | Verify bugfix closeout fields integrate with Knowledge Capture Gate. | verify | yes |
| `skills/sdd/templates/acceptance-template.md` | Verify persistent completion record can store bugfix fields and Knowledge Capture. | verify | yes |
| `skills/sdd/scripts/validate-sdd.sh` | Verify default and closeout-ready checks behave as designed. | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| `skills/sdd/references/stages/tasks.md` | Tasks stage rules require context manifest for trait-heavy work. | tasks | yes |
| `skills/sdd/templates/context-manifest-template.md` | Template source for this manifest. | tasks | yes |
| `specs/sdd-knowledge-capture-closeout/acceptance.md` | Prior feature proves Knowledge Capture schema and roadmap dependency are complete. | implement / verify | yes |
| `specs/sdd-trellis-workflow-productization/roadmap.md` | Umbrella roadmap owns current feature and next recommendation. | implement / verify | yes |

---

## Rules

- 每条 entry 必须有 `Reason`；缺少 reason 的 manifest 不得通过 verify。
- `Required = yes` 的本地文件不存在时，当前阶段必须回退到 `plan` 或 `tasks` 更新 manifest。
- 不要把即将修改的源文件列为固定 context；源文件由 implement / verify 按需检查。
- 不复制长文档；只记录路径、来源、用途和短摘要。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py 或自动 context injection。
