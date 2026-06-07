# Commit Plan: SDD Multi-Feature Orchestration

**Workspace**: `sdd-roadmap-feature-orchestration`
**Date**: 2026-06-07
**Status**: confirmed_batch_a

> 本计划只做提交边界判断。未获得用户对具体 batch 的明确确认前，不执行 `git add` / `git commit`。

---

## Summary

当前 `personal-skills` 工作树有 56 条变更记录：

- 21 条 untracked。
- 32 条 deleted。
- 3 条 modified。

其中 `skills/sdd` 在 git 视角表现为：原跟踪目录大量删除，同时出现 untracked symlink `skills/sdd -> ../.agents/skills/sdd`。这属于结构性迁移风险，不应自动纳入提交。

---

## Included Files

建议只把 SDD roadmap 与验收记录作为本批提交候选，不自动包含 runtime symlink 迁移。

| File / Pattern | Reason | Batch |
|---|---|---|
| `specs/.active` | 已切回 umbrella closeout 目录，避免后续 `继续` 误回 F4 | A |
| `specs/sdd-roadmap-feature-orchestration/spec.md` | F1 spec，记录多 feature orchestration 需求 | A |
| `specs/sdd-roadmap-feature-orchestration/plan.md` | F1 plan | A |
| `specs/sdd-roadmap-feature-orchestration/tasks.md` | F1 tasks | A |
| `specs/sdd-roadmap-feature-orchestration/acceptance.md` | F1 acceptance PASS | A |
| `specs/sdd-roadmap-feature-orchestration/roadmap.md` | umbrella roadmap，已标记 completed | A |
| `specs/sdd-roadmap-feature-orchestration/roadmap-closeout.md` | umbrella final closeout | A |
| `specs/sdd-roadmap-feature-orchestration/commit-plan.md` | 本提交计划 | A |
| `specs/chinese-acceptance-and-closeout-record/*` | F2 中文验收 feature 的 spec/plan/tasks/evidence/acceptance | A |
| `specs/commit-boundary-and-diff-automation/*` | F3 commit boundary feature 的 spec/plan/tasks/evidence/acceptance | A |
| `specs/trellis-style-context-manifests/*` | F4 Trellis context manifest feature 的 spec/plan/tasks/manifest/evidence/acceptance | A |

---

## Excluded Files

这些文件不建议由本次 SDD roadmap closeout 自动提交。

| File / Pattern | Reason |
|---|---|
| `README.md` | 既有 modified，未在本次 roadmap closeout 中确认归属。 |
| `scripts/verify-skills.sh` | 既有 modified，未在本次 roadmap closeout 中确认归属。 |
| `.claude/skills/sdd` | untracked runtime / agent 安装产物，是否纳入仓库需要单独决策。 |
| `skills/content-orchestrator-agent/*` | 与当前 SDD roadmap feature 无关。 |

---

## Needs User Decision

| File / Pattern | Why Uncertain | Decision Needed |
|---|---|---|
| `skills/sdd/*` deleted + `skills/sdd` symlink | git 视角显示原跟踪目录被删除，并出现 symlink 指向 `../.agents/skills/sdd`。这可能是本机 runtime 安装方式，也可能是仓库结构迁移。 | 明确是否要把 `skills/sdd` 从跟踪目录改成 symlink；若是，需要单独 batch，并确认远程仓库是否接受该结构。 |
| 运行时 SDD 实现文件 | 用户已说明本机 skill 通过 `skills.sh` 从远程仓统一安装，这里只确认功能实现。本仓当前 commit 未必是正式发布源。 | 明确是否需要在远程 skill 源仓同步并提交运行时实现，而不是在当前 `personal-skills` 仓提交 symlink 迁移。 |

---

## Risks

- **symlink migration risk**: 直接提交 `skills/sdd` 可能造成大量文件删除并替换为 symlink，影响远程安装和其他机器。
- **dirty tree mixing risk**: `README.md`、`scripts/verify-skills.sh`、`skills/content-orchestrator-agent/*` 与本次 SDD roadmap 不是同一 feature。
- **runtime-vs-source risk**: 当前验收确认的是本机运行时功能实现，不等于远程 skill 源仓已同步。
- **commit side-effect risk**: 本计划尚未得到用户对 batch 的明确确认，不得执行提交。

---

## Commit Batches

### Batch A: SDD roadmap specs and acceptance records

**Files**:

- `specs/.active`
- `specs/sdd-roadmap-feature-orchestration/*`
- `specs/chinese-acceptance-and-closeout-record/*`
- `specs/commit-boundary-and-diff-automation/*`
- `specs/trellis-style-context-manifests/*`

**Commit message**:

```text
docs(sdd): record multi-feature roadmap closeout
```

**Rationale**: 只提交本次 SDD 复合需求的规格、验收、roadmap 和提交计划记录，不碰运行时 symlink 迁移。

### Batch B: SDD runtime source or symlink migration

**Status**: blocked_by_user_decision

**Files**:

- `skills/sdd/*` deleted entries
- `skills/sdd` symlink
- 可能还包括远程 skill 源仓中的正式运行时文件

**Commit message**:

```text
chore(sdd): sync runtime skill implementation
```

**Rationale**: 只有在确认当前仓库就是要承载 `skills/sdd` symlink 迁移，或确认远程源仓同步路径后，才能执行。

---

## User Confirmation

用户已选择：

1. **只提交 Batch A**：提交 specs / roadmap / acceptance 记录，不碰 `skills/sdd` symlink 迁移。
2. **先不提交**：保留当前工作树，仅使用本计划作为记录。
3. **先处理 Batch B 决策**：确认 `skills/sdd` 是保留 symlink、恢复跟踪目录，还是去远程 skill 源仓同步实现。

本次只允许执行 Batch A。Batch B 仍保持 `blocked_by_user_decision`。
