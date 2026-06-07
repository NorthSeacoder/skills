# Verify Evidence: Commit Boundary And Diff Automation

**Workspace**: `commit-boundary-and-diff-automation`
**Date**: 2026-06-07

---

## Evidence Table Draft

| Requirement | Evidence | Test or File | Verdict |
|---|---|---|---|
| FR-001 / FR-002：先生成 commit plan 且字段完整 | 新增 `commit-plan-template.md`，包含 Included Files、Excluded Files、Needs User Decision、Risks、Commit Batches、User Confirmation | `.agents/skills/sdd/templates/commit-plan-template.md` | PASS |
| FR-003 / FR-004：从 SDD 产物和 git diff 判断归属，不确定需用户决策 | `closeout.md` 新增 Commit Planning Rules，要求 dirty files / staged changes 先分类；Needs User Decision 存在时不得提交 | `.agents/skills/sdd/references/stages/closeout.md` | PASS |
| FR-005 / FR-006：用户确认前不得提交，只 add 批准文件 | `closeout.md` 和 commit plan 模板均明确未确认不得 `git add` / `git commit`，且不得使用 `git add -A` 或宽泛 add | `.agents/skills/sdd/references/stages/closeout.md`; `.agents/skills/sdd/templates/commit-plan-template.md` | PASS |
| FR-007 / FR-008：多 batch 提交且不自动 push | commit plan 模板要求每个 batch 单独提交，失败停止；`closeout.md` 明确不自动 push | `.agents/skills/sdd/templates/commit-plan-template.md`; `.agents/skills/sdd/references/stages/closeout.md` | PASS |
| FR-009：staged / ignored / symlink / deletion 风险 | commit plan 模板和 closeout 规则都把 staged changes、ignored runtime files、symlink、submodule、删除列入风险 | `.agents/skills/sdd/templates/commit-plan-template.md`; `.agents/skills/sdd/references/stages/closeout.md` | PASS |
| FR-010：记录 commit result | `acceptance-template.md` 新增 Commit Result 表，并在 Completion Record 中增加提交结论字段 | `.agents/skills/sdd/templates/acceptance-template.md` | PASS |

---

## Dry Run: 当前 Dirty Tree 风险演练

本次 dry run 不执行 `git add` 或 `git commit`。

### Included Files（本 feature 相关）

| File | Reason | Evidence |
|---|---|---|
| `specs/commit-boundary-and-diff-automation/spec.md` | F3 spec | 当前 active feature |
| `specs/commit-boundary-and-diff-automation/plan.md` | F3 plan | 当前 active feature |
| `specs/commit-boundary-and-diff-automation/tasks.md` | F3 tasks | 当前 active feature |
| `.agents/skills/sdd/templates/commit-plan-template.md` | F3 运行时模板 | T001 |
| `.agents/skills/sdd/references/stages/closeout.md` | F3 closeout 规则 | T002 / T003 |
| `.agents/skills/sdd/templates/acceptance-template.md` | F3 commit result 记录 | T004 |
| `.agents/skills/sdd/SKILL.md` | F3 入口规则 | T005 |

### Excluded Files（不应由 F3 自动提交）

| File / Pattern | Reason |
|---|---|
| `README.md` | 工作树已有改动，归属不属于当前 F3 |
| `scripts/verify-skills.sh` | 工作树已有改动，归属不属于当前 F3 |
| `skills/content-orchestrator-agent/*` | 与当前 SDD F3 无关 |
| `specs/sdd-roadmap-feature-orchestration/*` | F1 roadmap 记录，已作为上游状态存在，不应与 F3 实现混批自动提交 |

### Needs User Decision

| File / Pattern | Why Uncertain | Question |
|---|---|---|
| `skills/sdd` symlink / tracked directory deletion | 当前主仓 git 视角显示大量 `skills/sdd/*` 删除和 `skills/sdd` symlink，属于结构性迁移状态 | 是否由主仓维护者单独提交 symlink 迁移，还是恢复跟踪目录？ |

### Dry Run Verdict

PASS。当前 dirty tree 包含无关改动和结构性迁移风险，F3 的规则会生成 commit plan 并阻止自动提交；这正是本 feature 要求的安全行为。

---

## Validation

```text
bash /Users/yqg/personal/personal-skills/skills/sdd/scripts/validate-sdd.sh
```

结果：`validate-sdd: OK`
