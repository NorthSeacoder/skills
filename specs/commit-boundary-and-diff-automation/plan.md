# Implementation Plan: Commit Boundary And Diff Automation

**Workspace**: `commit-boundary-and-diff-automation` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/commit-boundary-and-diff-automation/spec.md`

---

## Summary

在 SDD closeout 后增加一个可审查的 commit planning gate：先识别当前 feature 相关 diff、排除无关 dirty files、生成 commit plan，经用户明确确认后才执行 `git add` / `git commit`。本期只做本地提交，不自动 push，也不引入 Trellis JSONL context manifest。

方案讨论说明：只有一个合理方向，即增强现有 `closeout` 与模板资产，不新增独立 SDD 阶段。原因是 commit 是 closeout 的 follow-through 事项，新增阶段会让主链变重；用模板 + closeout gate 可以保持轻量。

---

## Architecture Overview

```text
verify PASS / closeout ready
        │
        ▼
acceptance.md / tasks.md / roadmap.md / git status
        │
        ▼
Commit Planning Gate
        │
        ├── Included files
        ├── Excluded files
        ├── Needs user decision
        ├── Commit batches + messages
        └── Risks
        │
        ▼
User confirmation required
        │
        ├── confirmed     → git add approved files → git commit by batch
        └── not confirmed → record "not submitted" and stop
```

核心设计：

- commit plan 是用户可见 artifact，不是内部推理。
- `git add` 只能添加 plan 中批准的文件。
- staged changes、ignored runtime files、symlink、submodule、删除都必须进入风险区。
- commit 结果写回 acceptance / closeout record；roadmap 可记录 commit hash 或"用户选择不提交"。

---

## Architecture Reference

| 参考模式 / 模板 | 来源 URL | 适配点 | 不适配点 | 当前阶段 |
|-----------------|----------|--------|----------|----------|
| Trellis Finish / commit boundary | https://docs.trytrellis.app/start/how-it-works | Trellis 把实现、检查、提交、归档分开，提交前由主线程提出 commit plan | 不引入 `/trellis:finish-work`、task.py 或 `.trellis/` runtime | MVP |
| Trellis README task-centered workflow | https://github.com/mindfold-ai/Trellis | 任务产物和完成记录落盘，后续 session 可恢复 | 不复制 Trellis 多平台 hook 和 JSONL manifest，本期只吸收 commit boundary 思想 | MVP |

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| verify 阶段 | Verdict / Evidence Table | closeout commit planning gate | commit plan 只在 verify PASS 或用户接受的 CONDITIONAL PASS 后生成 |
| acceptance.md | completion evidence / checklist | commit plan | plan 中引用验收文件作为 included/excluded 判断依据 |
| tasks.md / spec.md | feature 边界 | commit plan | included files 的理由能追溯到当前 feature 的任务或需求 |
| git status / git diff | dirty files / staged files / ignored risk | commit plan | plan 中列出 included、excluded、needs decision、risks |
| commit plan | approved batches | git add / git commit | 只有用户确认后执行，且只 add 批准文件 |
| git commit | commit hash / message / files | acceptance / roadmap closeout | completion record 记录 hash 或未提交原因 |

**孤儿 artifact 处理**: 无。若某个 dirty file 无法归属，进入 `Needs user decision`，不允许自动消费。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 安全性 | 不提交无关用户改动 | 引入 included/excluded/needs decision 三分法 | dry run 使用当前 dirty tree 验证不使用 `git add -A` |
| 可审查性 | 用户能确认每个 batch | 新增 commit plan 模板 | 模板包含 batch、files、message、risks |
| 可恢复性 | 失败时知道执行到哪一步 | 每个 batch 单独提交，失败停止 | dry run 说明失败报告格式 |
| 低耦合 | 不新增 SDD 主阶段 | 只 patch closeout 与模板资产 | validate-sdd 仍通过 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: commit planning 归属 | spec 中 UQ-002 询问是否新增 finish 语义 | A: 新增 finish 阶段 / B: 增强 closeout | B：commit 是 closeout follow-through gate，不新增阶段 | closeout 内容更重，需要模板控制 | 本次 plan |
| ADR-002: commit plan 格式 | spec 中 UQ-001 询问模板位置 | A: 嵌入 acceptance-template / B: 新增 commit-plan-template.md | B：新增 `templates/commit-plan-template.md`，职责更清晰 | 多一个模板文件 | 本次 plan |
| ADR-003: ignored runtime files | spec 中 UQ-003 询问处理方式 | A: 只提示 / B: 强制记录分发源同步状态 | A 为 MVP：commit plan 标注不可提交或需源仓同步；closeout 可记录原因 | 不自动解决发布源同步 | 用户已确认本机只验收 skills.sh 安装后的功能实现 |
| ADR-004: git 执行权限 | commit 是外部副作用 | A: 自动提交 / B: 用户确认后提交 / C: 只生成 plan | B：展示 plan 后等待明确确认 | 多一步交互，但安全 | FR-005 |

---

## Key Design Decisions

### Decision 1: Commit Plan Template

新增 `templates/commit-plan-template.md`，结构如下：

```text
# Commit Plan: <feature>

## Summary
## Included Files
## Excluded Files
## Needs User Decision
## Risks
## Commit Batches
## Execution Rules
## User Confirmation
```

模板必须明确：

- 不允许未确认时执行 `git add` 或 `git commit`
- 不允许使用 `git add -A`
- 不自动 push
- staged changes 必须先审计

### Decision 2: Closeout Integration

`closeout.md` 新增 commit planning gate：

1. 检查 `git status --short` 和 staged changes。
2. 根据 spec/tasks/acceptance/roadmap 判断文件归属。
3. 用 `commit-plan-template.md` 生成 commit plan。
4. 等用户确认。
5. 用户确认后，只添加批准文件并按 batch 提交。
6. 将 commit hash 或"用户选择不提交"写回 completion record。

### Decision 3: No Auto Push

提交成功后只报告本地 commit hash。`git push` 不属于本 feature；除非用户另行明确要求，否则不得执行。

---

## Module Design

### Module: `templates/commit-plan-template.md`

**职责**: 提供 commit plan 的统一中文格式。

**关键行为**:

```text
Included file row:
| File | Reason | Evidence |

Excluded file row:
| File | Reason |

Needs decision row:
| File | Why uncertain | Question |

Commit batch:
| Batch | Files | Commit Message | Rationale |
```

### Module: `references/stages/closeout.md`

**职责**: 把 commit planning 作为 closeout follow-through gate。

**关键行为**:

```text
if feature complete and dirty tree exists:
  create commit plan
  show included/excluded/needs-decision/risks
  wait for explicit confirmation
  if confirmed:
    git add approved files only
    git commit by batch
  else:
    record not submitted
```

### Module: `templates/acceptance-template.md`

**职责**: 记录 commit result。

**改动概述**:

- 在 Completion Record 中增加 commit 状态字段。
- 支持 `committed / not submitted / no related diff / failed`。

### Module: `SKILL.md`

**职责**: 在路由原则中声明：SDD 可生成 commit plan，但任何 git 副作用必须等待用户确认。

---

## Data Model

不需要单独 `data-model.md`。状态模型落在 commit plan 和 acceptance record 中：

```text
CommitPlan
  - feature
  - included_files[]
  - excluded_files[]
  - needs_decision_files[]
  - risks[]
  - batches[]
  - confirmation_required

CommitBatch
  - id
  - files[]
  - message
  - rationale

CommitResult
  - status: committed | not_submitted | no_related_diff | failed
  - hashes[]
  - failed_batch
  - remaining_dirty_files
```

---

## Project Structure

```text
skills/sdd/
├── SKILL.md                         # patch
├── templates/
│   ├── acceptance-template.md        # patch
│   └── commit-plan-template.md       # new
└── references/stages/
    └── closeout.md                  # patch

specs/commit-boundary-and-diff-automation/
├── spec.md
├── plan.md
├── tasks.md                         # 后续生成
└── acceptance.md                    # 后续生成
```

---

## Risks and Tradeoffs

- **风险 1**: 误提交无关改动。缓解：三分法 + 用户确认 + 禁止 `git add -A`。
- **风险 2**: staged changes 被覆盖。缓解：commit planning 首先检查 staged 区域。
- **风险 3**: 当前本机 skill 安装路径和远程源仓路径可能不一致。缓解：ignored runtime files 只提示或记录，不强制纳入提交。
- **风险 4**: closeout 变重。缓解：无相关 diff 时 fast path 直接记录无需提交。

---

## Evolution Path

- **MVP**: 模板 + closeout gate + 用户确认后本地 commit。
- **成长期**: 根据仓库 commit 历史自动建议 message 风格。
- **成熟期**: 与 Trellis 风格 context manifest 结合，让 implement/check context 直接参与 diff 归属判断。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。不引入 Trellis runtime 或 JSONL manifest。
- 是否引用了外部模式但没有适配检查：否。只吸收 commit boundary 思想。
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：否。新增状态全部记录在模板中。

---

## Verification Strategy

1. **模板字段验证**: `commit-plan-template.md` 必须包含 included / excluded / needs decision / risks / batches / confirmation。
2. **阶段规则验证**: `closeout.md` 必须要求先展示 commit plan、等待确认、不自动 push。
3. **安全规则验证**: 文档中必须明确禁止 `git add -A` 和未确认提交。
4. **Dry run 验证**: 用当前存在大量 unrelated dirty files 的主仓状态做 dry run，确认 plan 会把不确定文件列入 excluded 或 needs decision，而不是自动包含。
5. **validate-sdd**: 修改完成后运行 `skills/sdd/scripts/validate-sdd.sh`。

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要。状态仅存在于 Markdown commit plan 和 acceptance record。
- 下一步建议：`tasks`
- 阻塞项：无。模板、closeout 集成、副作用确认和验证路径已明确。

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| Trellis task flow / commit boundary | https://docs.trytrellis.app/start/how-it-works | 参考提交边界与 finish 回写思想 |
| Trellis repo workflow framing | https://github.com/mindfold-ai/Trellis | 参考文件驱动任务状态 |
