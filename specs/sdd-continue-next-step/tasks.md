# Tasks: SDD Continue Next Step

**Workspace**: `sdd-continue-next-step` | **Date**: 2026-06-07  
**Input**: `specs/sdd-continue-next-step/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (不适用)

**Artifact Rule**: 本 feature 命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output` 和 `prior-closure-failure`，因此必须生成 `context-manifest.md` 并在 verify 阶段检查覆盖。

---

## 执行原则

- 先建立 continuation routing reference，再让入口和阶段文件引用它。
- 不引入 `.trellis/`、Trellis CLI、task.py、JSONL task 或 hook 自动注入。
- 本 feature 只做最小结构 validator，不做完整 workspace 状态 validator。
- 验证必须覆盖每个续接状态分支，不能只验证文件存在。

---

## Phase 1: Continuation Routing Reference

**目标**: 建立续接规则的单一来源，避免把状态映射散落到多个阶段文件。

- [x] T001 [US1,US2,FR-001..FR-010] 新增 `skills/sdd/references/continuation-routing.md`
  - scope: 新 reference 文件
  - detail: 定义触发词、读取顺序、状态映射、roadmap mismatch、用户显式指定 feature、多个 roadmap 命中、输出要求
  - verify: reference 包含 `.active`、`roadmap`、`fresh evidence`、`acceptance`、`closeout`、`resume`、`continue` 等核心规则

- [x] T002 [US1,FR-004..FR-008] 在 reference 中写完整状态映射表
  - scope: `continuation-routing.md`
  - detail: 覆盖 spec-only、plan-without-tasks、incomplete-tasks、completed-tasks-without-verify、verify-without-closeout、closed-feature-with-next、closed-feature-without-next
  - verify: 每个 spec acceptance scenario 在映射表中有对应行

- [x] T003 [US2,FR-003,FR-009] 在 reference 中写失配处理规则
  - scope: `continuation-routing.md`
  - detail: `.active` 缺失/空/目录不存在、roadmap current 不一致、多个 roadmap 命中、显式 feature override
  - verify: 失配规则均要求“先报告并回退/确认”，不得静默推进

---

## Phase 2: Entry Routing Integration

**目标**: 让 SDD 入口在普通阶段路由前识别续接意图并调用 reference。

- [x] T004 [US1,FR-001,FR-002,FR-010] 更新 `skills/sdd/SKILL.md` 的阶段路由前置规则
  - scope: `skills/sdd/SKILL.md`
  - detail: 增加续接意图识别；明确先读 `references/continuation-routing.md`；输出当前阶段、依据、产物、下一步建议
  - verify: `rg -n "continuation-routing|继续|下一步|resume|continue" skills/sdd/SKILL.md`

- [x] T005 [US2,FR-003,FR-009] 更新 `SKILL.md` 的失配输出要求
  - scope: `skills/sdd/SKILL.md`
  - detail: 若 continuation preflight 发现 `.active` 或 roadmap mismatch，必须先说明失配并回退，不进入下游阶段
  - verify: `SKILL.md` 输出要求包含 continuation 失配说明

---

## Phase 3: Stage Integration

**目标**: 避免用户说“继续”时误进入 ideate 发散。

- [x] T006 [US1,FR-001] 更新 `skills/sdd/references/stages/ideate.md`
  - scope: `ideate.md`
  - detail: 增加短路规则：续接请求不是需求发散，先走 `continuation-routing.md`
  - verify: `rg -n "continuation-routing|继续|resume|continue" skills/sdd/references/stages/ideate.md`

- [x] T007 [US1,FR-006,FR-007] 检查 `execute-plan.md`、`implement.md`、`verify.md` 现有下一步语义是否需要补充
  - scope: `skills/sdd/references/stages/execute-plan.md`, `implement.md`, `verify.md`
  - detail: 若已有语义足够，只记录无需修改；若缺少明显衔接，做最小补充
  - verify: 人工说明 continuation routing 与现有阶段下一步语义无冲突

---

## Phase 4: Validator Coverage

**目标**: 为新 reference 和入口引用增加最小结构校验。

- [x] T008 [US3,FR-011] 更新 `skills/sdd/scripts/validate-sdd.sh`
  - scope: validator 脚本
  - detail: 检查 `continuation-routing.md` 存在，`SKILL.md` 和 `ideate.md` 引用它
  - verify: `bash skills/sdd/scripts/validate-sdd.sh` 通过

- [x] T009 [US1,US2,FR-001..FR-010] 在 validator 中加入核心关键词检查
  - scope: `validate-sdd.sh`
  - detail: 检查 reference 包含 `.active`、roadmap mismatch、fresh evidence、acceptance、closeout、resume、continue
  - verify: validator 能防止 reference 被误删或核心规则被删空

---

## Phase 5: Verification Evidence

**目标**: 证明续接路由覆盖 spec 的核心状态分支，并且没有引入 Trellis runtime。

- [x] T010 [US1,FR-004..FR-008] 编写或更新 `specs/sdd-continue-next-step/verify-evidence.md`
  - scope: verify evidence
  - detail: 记录状态映射 trace：spec-only -> plan；plan-without-tasks -> tasks；incomplete-tasks -> implement；tasks-complete-no-evidence -> verify；verify-pass-no-acceptance -> closeout
  - verify: evidence 表覆盖 US1 所有 acceptance scenarios 和 edge cases

- [x] T011 [US2,FR-003,FR-009] 在 verify evidence 中记录失配 trace
  - scope: verify evidence
  - detail: 覆盖 missing active directory、roadmap current mismatch、explicit feature override、multiple roadmap candidates
  - verify: 每个失配分支都以“报告并回退/确认”为结论

- [x] T012 [US3,FR-011] 执行 Trellis boundary scan
  - scope: `skills/sdd` 与本 feature specs
  - detail: 确认没有引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 自动注入作为依赖
  - verify: `rg -n "\\.trellis|Trellis CLI|task.py|JSONL|hook 自动注入" skills/sdd specs/sdd-continue-next-step`

- [x] T013 [all] 运行结构验证
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - detail: 确认新增 reference、入口引用和 validator 均通过
  - verify: `bash skills/sdd/scripts/validate-sdd.sh`

---

## Phase 6: Closeout Prep

**目标**: 为 verify / closeout 留出清晰交接。

- [x] T014 [artifact-handoff] 更新 roadmap 当前 feature 阶段和下一步
  - scope: `specs/sdd-trellis-workflow-productization/roadmap.md`
  - detail: 实现完成后将当前阶段更新为 `verify`，closeout 后再回写 completion log
  - verify: roadmap current feature 与 `specs/.active` 一致

- [x] T015 [artifact-handoff] 准备 acceptance 输入
  - scope: `specs/sdd-continue-next-step/acceptance.md`（closeout 阶段生成）
  - detail: closeout 时使用 verify evidence、三维 verdict、closeout checklist 和 completion record
  - verify: closeout 阶段能直接使用 evidence 填写 acceptance

---

## 依赖与顺序

- T001 必须先完成，T004、T006、T008 都依赖新 reference。
- T002、T003 是 T001 的核心内容，可与 T004 之前连续完成。
- T004、T005、T006 是入口和阶段集成，必须在 validator 深化前完成。
- T008、T009 必须在验证前完成，因为 verify 依赖 validator。
- T010-T013 是验证任务，必须在 closeout 前完成。
- T014-T015 是收尾准备，不代表 feature 已完成。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|---|---|
| US1 resume active feature | T001, T002, T004, T006, T010 |
| US2 broken active state | T001, T003, T005, T011 |
| US3 lightweight boundary | T008, T012, T013 |
| FR-001 续接意图识别 | T001, T004, T006, T009 |
| FR-002 `.active` 优先读取 | T001, T004 |
| FR-003 active 缺失回退 | T003, T005, T011 |
| FR-004 spec-only -> plan | T002, T010 |
| FR-005 plan-without-tasks -> tasks | T002, T010 |
| FR-006 incomplete tasks -> implement | T002, T010 |
| FR-007 completed tasks no evidence -> verify | T002, T010 |
| FR-008 verify no closeout -> closeout | T002, T010 |
| FR-009 roadmap current 检查 | T003, T005, T011 |
| FR-010 输出说明依据 | T001, T004, T010 |
| FR-011 不引入 Trellis runtime | T008, T012 |

| 架构决策 / 风险 | 对应任务 | 验证任务 |
|---|---|---|
| 新 reference 作为单一来源 | T001, T004, T006 | T008, T013 |
| validator 只做结构校验 | T008, T009 | T013 |
| 不做完整状态 validator | T008 | T010, T011 以人工 trace 覆盖 |
| Trellis 轻量边界 | T012 | T012 |

---

## Context Manifest

已生成 [context-manifest.md](context-manifest.md)。实现阶段必须先读 Implement Context；验证阶段必须先读 Check Context，并确认 Required 文件存在。

---

## Stage Readiness

- 推荐下一步：`execute-plan`
- 原因：任务数量较多，涉及 reference、入口、stage、validator 和 verify evidence，适合先按任务节奏执行。
- 阻塞项：无。
