# Context Manifest: [Feature Name]

**Workspace**: `[feature-workspace]`
**Created**: [date]
**Status**: active / skipped

> 本文件用于记录 SDD 各阶段必须读取的高信号上下文。它不是待修改源文件清单，也不替代实现阶段按需阅读代码。

---

## Skip Reason *(if skipped)*

[若 feature 很小或用户选择轻量路径，在此说明为什么跳过 context manifest。未跳过时删除本段。]

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/[feature]/spec.md` | [实现需要理解的需求边界] | implement | yes |
| `specs/[feature]/plan.md` | [实现需要遵守的方案、ADR 或质量属性] | implement | yes |
| `specs/[feature]/tasks.md` | [实现任务边界和验证点] | implement | yes |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/[feature]/spec.md` | [验证 P0/P1 requirement 和场景] | verify | yes |
| `specs/[feature]/plan.md` | [检查架构漂移、ADR 和风险] | verify | yes |
| `specs/[feature]/tasks.md` | [检查任务完成范围] | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| [URL 或本地研究文件] | [为什么需要这个来源] | plan / implement / verify | yes / no / UNVERIFIED |

---

## Rules

- 每条 entry 必须有 `Reason`；缺少 reason 的 manifest 不得通过 verify。
- `Required = yes` 的本地文件不存在时，当前阶段必须回退到 `plan` 或 `tasks` 更新 manifest。
- 不要把即将修改的源文件列为固定 context；源文件由 implement / verify 按需检查。
- 不复制长文档；只记录路径、来源、用途和短摘要。
- 不引入 `.trellis/`、Trellis CLI、hook、task.py 或自动 context injection。
