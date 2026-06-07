# Tasks: Commit Boundary And Diff Automation

**Workspace**: `commit-boundary-and-diff-automation`
**Date**: 2026-06-07
**Spec**: [spec.md](spec.md)
**Plan**: [plan.md](plan.md)

---

## 执行原则

- 只实现 commit plan、diff 边界识别和用户确认后本地 commit 规则。
- 不实现自动 push、stash/rebase/merge conflict 处理、Trellis context manifest。
- 所有 git 副作用必须先展示 commit plan 并等待用户确认。
- 实现文件位于本机运行时 skill 路径；本机通过 `skills.sh` 管理 skill 安装，本 feature 只验收功能实现。

---

## Phase 1: Commit Plan 模板

- [x] T001 [US2,FR-002] 创建 `templates/commit-plan-template.md`
  - scope: 新增模板
  - detail: 包含 Summary、Included Files、Excluded Files、Needs User Decision、Risks、Commit Batches、Execution Rules、User Confirmation
  - verify: 模板明确禁止未确认提交、禁止 `git add -A`、不自动 push

## Phase 2: Closeout 集成

- [x] T002 [US1,FR-001,FR-003,FR-004] patch `references/stages/closeout.md` 加入 commit planning gate
  - scope: closeout 执行步骤和 checklist
  - detail: closeout 后检查 git status/staged changes，按 included/excluded/needs decision 生成 commit plan
  - verify: 文档要求无法判断归属时停下询问用户

- [x] T003 [US2,US3,FR-005,FR-006,FR-007,FR-008] patch `closeout.md` 加入确认后提交规则
  - scope: closeout 执行步骤和下一步
  - detail: 未确认不得 `git add`/`git commit`；确认后只 add 批准文件，按 batch commit；不 push
  - verify: 文档中出现"不得使用 git add -A"和"不得自动 push"

## Phase 3: Acceptance 与入口规则

- [x] T004 [US4,FR-010] patch `templates/acceptance-template.md` 增加 Commit Result 记录
  - scope: acceptance 模板 completion record
  - detail: 支持 committed / not_submitted / no_related_diff / failed，记录 hash/message/files 或原因
  - verify: 模板中能记录用户选择不提交和剩余 dirty files

- [x] T005 [US2,FR-005] patch `SKILL.md` 路由原则
  - scope: `SKILL.md`
  - detail: 声明 SDD 可生成 commit plan，但任何 git 副作用必须等待用户确认
  - verify: 入口规则不承诺自动 push

## Phase 4: 验证与 Dry Run

- [x] T006 [contract] commit plan 字段覆盖检查
  - scope: `commit-plan-template.md`
  - detail: 检查 included/excluded/needs decision/risks/batches/confirmation 字段
  - verify: 字段完整

- [x] T007 [contract] closeout 安全规则 trace
  - scope: `closeout.md`
  - detail: trace "verify PASS -> commit plan -> user confirmation -> approved add/commit -> result record"
  - verify: trace 覆盖 FR-001 到 FR-010

- [x] T008 [dry-run] 当前 dirty tree 风险演练
  - scope: 当前主仓工作树作为 fixture
  - detail: 不执行 git add/commit，只说明哪些文件会 included/excluded/needs decision
  - verify: unrelated dirty files 不会被自动纳入提交

- [x] T009 [validation] 运行 `validate-sdd.sh`
  - scope: SDD skill 结构
  - detail: 修改后运行校验
  - verify: 输出 `validate-sdd: OK`

---

## 依赖与顺序

**关键路径**: T001 -> T002/T003 -> T004/T005 -> T006/T007/T008/T009

- T001 必须先完成，closeout 需要引用模板。
- T002 和 T003 修改同一文件，建议一次 patch。
- T004 与 T005 可在 closeout 规则稳定后并行。
- T006-T009 是验证任务，必须在文档 patch 后执行。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|---|---|
| US1 识别当前 feature 相关 diff | T002, T008 |
| US2 生成 commit plan | T001, T002, T006 |
| US3 用户确认后提交且不 push | T003, T005, T007 |
| US4 closeout / roadmap 记录 commit | T004, T007 |
| FR-001 先生成 commit plan | T002 |
| FR-002 commit plan 字段 | T001, T006 |
| FR-003 从 SDD 产物和 git diff 推断归属 | T002, T008 |
| FR-004 不确定归属需用户决策 | T002 |
| FR-005 用户确认前不得提交 | T003, T005 |
| FR-006 只 add 批准文件 | T003 |
| FR-007 多 batch 提交 | T001, T003 |
| FR-008 不自动 push | T003, T005 |
| FR-009 staged/ignored/symlink 风险 | T001, T002, T008 |
| FR-010 记录 commit result | T004 |

---

## Stage Readiness

- 推荐下一步：`implement`
- 是否需要 `execute-plan`：不需要。任务数 9 个，均为 Markdown 规则和模板 patch，边界清晰。
- 阻塞项：无。
