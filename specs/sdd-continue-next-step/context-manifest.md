# Context Manifest: SDD Continue Next Step

**Workspace**: `sdd-continue-next-step`
**Created**: 2026-06-07
**Status**: active

> 本文件用于记录 SDD 各阶段必须读取的高信号上下文。它不是待修改源文件清单，也不替代实现阶段按需阅读代码。

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-continue-next-step/spec.md` | 实现必须覆盖续接意图、状态失配、轻量边界等 P1/P2 requirement | implement | yes |
| `specs/sdd-continue-next-step/plan.md` | 实现必须遵守新增 `continuation-routing.md`、入口引用和最小 validator 的方案边界 | implement | yes |
| `specs/sdd-continue-next-step/tasks.md` | 实现任务边界、依赖顺序和验证任务来源 | implement | yes |
| `skills/sdd/SKILL.md` | 入口路由需要增加 continuation preflight；实现时必须保持主链简洁 | implement | yes |
| `skills/sdd/references/stages/ideate.md` | ideate 需要短路续接请求，避免把“继续”当作新需求发散 | implement | yes |
| `skills/sdd/scripts/validate-sdd.sh` | validator 需要新增 continuation reference 的结构校验 | implement | yes |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/sdd-continue-next-step/spec.md` | 验证 FR-001 到 FR-011 和 US1/US2/US3 是否覆盖 | verify | yes |
| `specs/sdd-continue-next-step/plan.md` | 检查实现是否符合最小侵入方案、状态映射和 Trellis 边界 | verify | yes |
| `specs/sdd-continue-next-step/tasks.md` | 检查任务完成范围与 evidence 覆盖 | verify | yes |
| `skills/sdd/references/continuation-routing.md` | 核对续接状态映射、失配处理和输出要求是否完整 | verify | yes |
| `skills/sdd/SKILL.md` | 核对入口是否引用 continuation routing 且不吞掉失配输出 | verify | yes |
| `skills/sdd/references/stages/ideate.md` | 核对续接请求是否不进入 ideate 发散 | verify | yes |
| `skills/sdd/scripts/validate-sdd.sh` | 核对结构校验覆盖新增 reference 和核心关键词 | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| `specs/sdd-trellis-workflow-productization/roadmap.md` | 记录本 feature 在 Trellis workflow productization roadmap 中的顺序、边界和 next feature | plan / verify | yes |
| `specs/sdd-roadmap-feature-orchestration/roadmap-closeout.md` | 既有 Trellis context manifest 吸收边界：不引入 `.trellis/`、Trellis CLI、hook 或自动注入 | plan / verify | yes |

---

## Rules

- 每条 entry 必须有 `Reason`；缺少 reason 的 manifest 不得通过 verify。
- `Required = yes` 的本地文件不存在时，当前阶段必须回退到 `plan` 或 `tasks` 更新 manifest。
- 不要把即将修改的源文件列为固定 context；源文件由 implement / verify 按需检查。
- 不复制长文档；只记录路径、来源、用途和短摘要。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py 或自动 context injection。
