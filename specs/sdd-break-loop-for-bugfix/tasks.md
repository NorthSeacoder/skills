# Tasks: SDD Break Loop For Bugfix

**Workspace**: `sdd-break-loop-for-bugfix` | **Date**: 2026-06-08  
**Input**: `specs/sdd-break-loop-for-bugfix/spec.md` + `plan.md`  
**Prerequisites**: spec.md, plan.md

**Note**: 本 feature 命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output`、`prior-closure-failure`，并计划新增 `bugfix-loop-breaker` trait，因此必须生成 `context-manifest.md`。

---

## Phase 1: Shared Contract And Trait

**目标**: 建立 bugfix loop-breaker 的单一词表、触发条件和跳过条件，供后续阶段和模板引用。

- [x] T001 [US1,US2] 新增 bugfix loop-breaker 共享 reference
  - scope: `skills/sdd/references/bugfix-loop-breaker.md`
  - maps_to: FR-001, FR-002, FR-003, FR-006, ADR-002, 可追溯性, 低噪音
  - verify: reference 包含 Trigger Signals、Skip Conditions、Bugfix Context、Failed Attempt Ledger、Before/After Evidence、Regression Guard、Diffusion Check、Prevention Mechanism 和 Closeout Fields。

- [x] T002 [US1] 在 feature traits 中新增 `bugfix-loop-breaker`
  - scope: `skills/sdd/references/feature-traits.md`
  - maps_to: FR-001, FR-011, ADR-001
  - verify: trait 表和触发规则说明复杂 bugfix 命中；极小单点 bugfix 可记录跳过原因。

- [x] T003 [US1] 更新 spec 模板以支持 bugfix trait 标注
  - scope: `skills/sdd/templates/spec-template.md`
  - maps_to: FR-001, FR-011, ADR-001
  - verify: Feature Traits 表包含 `bugfix-loop-breaker` 行，且说明轻量 bugfix skip path。

- [x] T004 [US1] 回写当前 feature spec 的新增 trait
  - scope: `specs/sdd-break-loop-for-bugfix/spec.md`
  - maps_to: ADR-001, Stage consistency
  - verify: 当前 spec 的 Feature Traits 段包含 `bugfix-loop-breaker` 且命中依据与本 feature 一致。

---

## Phase 2: Stage And Template Rules

**目标**: 让每个 SDD 阶段在复杂 bugfix 中产出正确证据，而不是把任务推给最终验证。

- [x] T005 [US1] 在 clarify 阶段加入 bugfix unknown 处理规则
  - scope: `skills/sdd/references/stages/clarify.md`
  - maps_to: FR-003, ADR-002
  - verify: root cause / reproduction / failed attempts 缺失时要求显式 `unknown` 和调查问题，不允许编造 root cause。

- [x] T006 [US1,US3] 在 plan 阶段加入 bugfix strategy 要求
  - scope: `skills/sdd/references/stages/plan.md`
  - maps_to: FR-004, ADR-002
  - verify: 命中 bugfix trait 时 plan 必须覆盖 Root Cause Hypothesis、Fix Boundary、Regression Guard Strategy、Diffusion Check Strategy、Failed Attempt Handling 和 Verification Path。

- [x] T007 [US1,US3] 更新 plan 模板的 bugfix strategy 段
  - scope: `skills/sdd/templates/plan-template.md`
  - maps_to: FR-004, NFR-001
  - verify: 模板提供可填写段落，且不会强制所有非 bugfix feature 填写。

- [x] T008 [US2,US3] 在 tasks 阶段加入 bugfix task coverage 要求
  - scope: `skills/sdd/references/stages/tasks.md`
  - maps_to: FR-005, ADR-003
  - verify: tasks 阶段要求覆盖 reproduce/evidence、failed-attempt ledger、fix、guard、diffusion、verify evidence、acceptance 和 Knowledge Capture。

- [x] T009 [US2,US3] 更新 tasks 模板的 bugfix 任务提示
  - scope: `skills/sdd/templates/tasks-template.md`
  - maps_to: FR-005, NFR-001
  - verify: 模板提示不把 bugfix tasks 写成“改代码并测试”。

- [x] T010 [US2] 在 implement 阶段加入失败尝试控制流
  - scope: `skills/sdd/references/stages/implement.md`
  - maps_to: FR-006, ADR-003
  - verify: 同一失败条件再次出现时要求更新 ledger、排除假设并获取 fresh evidence，或回退 clarify / plan。

- [x] T011 [US3] 在 verify 阶段加入 bugfix evidence 要求
  - scope: `skills/sdd/references/stages/verify.md`
  - maps_to: FR-007, FR-008, ADR-004
  - verify: verify 要求 before/after proof 或替代证据，并记录 Regression Guard 与 Diffusion Check。

- [x] T012 [US4] 在 closeout 阶段加入 bugfix completion record 要求
  - scope: `skills/sdd/references/stages/closeout.md`
  - maps_to: FR-009, ADR-005
  - verify: closeout 要求 Root Cause、Fix Mechanism、Prevention Mechanism、Failed Attempts Summary、Remaining Risk 和 Knowledge Capture。

- [x] T013 [US4] 更新 acceptance 模板的 bugfix closeout 段
  - scope: `skills/sdd/templates/acceptance-template.md`
  - maps_to: FR-009, NFR-004
  - verify: 模板包含 bugfix completion fields，并说明只在 bugfix trait 命中时填写。

---

## Phase 3: Status Model And Validator

**目标**: 让结构校验能抓住缺失的 bugfix evidence，同时保持语义判断留给 verify/reviewer。

- [x] T014 [US3,US4] 更新 status model 的 bugfix closeout-ready 边界
  - scope: `skills/sdd/references/status-model.md`
  - maps_to: FR-007, FR-008, FR-009, FR-010, ADR-004
  - verify: status model 说明 bugfix 只做字段级结构检查，不判断 root cause 语义正确性。

- [x] T015 [US3,US4] 扩展 `validate-sdd.sh` default mode 的资产引用检查
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: ADR-002, 可维护性
  - verify: default validator 检查新增 reference 存在，并检查关键 stage/template 引用 `bugfix-loop-breaker` 或 `Bugfix Loop Breaker`。

- [x] T016 [US3,US4] 扩展 `validate-sdd.sh --closeout-ready` 的 bugfix 字段检查
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: FR-007, FR-008, FR-009, FR-010, ADR-004
  - verify: active spec 命中 `bugfix-loop-breaker` 时，缺 Root Cause / Regression Guard / Diffusion Check / Prevention Mechanism 的 evidence 或 acceptance 会 FAIL。

- [x] T017 [Boundary] 保持历史和轻量 feature 不被强制迁移
  - scope: `skills/sdd/scripts/validate-sdd.sh`, `skills/sdd/references/status-model.md`
  - maps_to: FR-011, NFR-001
  - verify: default validator 不要求历史 feature 补 bugfix fields；skip path fixture 可通过。

---

## Phase 4: Verification Fixtures And Evidence

**目标**: 用真实 workspace 和临时 fixture 证明规则有效，而不是只靠文档存在。

- [x] T018 [Verification] 运行基础结构校验
  - scope: repo root
  - maps_to: NFR-003, 可维护性
  - verify: `bash skills/sdd/scripts/validate-sdd.sh` PASS。

- [x] T019 [Verification] dogfood 当前 feature 的 bugfix trait 和任务覆盖
  - scope: `specs/sdd-break-loop-for-bugfix/spec.md`, `tasks.md`, `context-manifest.md`
  - maps_to: FR-001, FR-005
  - verify: 当前 spec 命中 `bugfix-loop-breaker`，tasks 覆盖 reference/stage/template/validator/verify/closeout，manifest 覆盖 implement 和 check context。

- [x] T020 [Verification] 构造 missing Regression Guard 负向 fixture
  - scope: 临时 workspace fixture
  - maps_to: FR-008, FR-010
  - verify: `--closeout-ready` 对缺 Regression Guard 的 bugfix fixture FAIL，输出可定位到 evidence 或 acceptance。

- [x] T021 [Verification] 构造 missing Prevention Mechanism 负向 fixture
  - scope: 临时 workspace fixture
  - maps_to: FR-009, FR-010
  - verify: `--closeout-ready` 对缺 Prevention Mechanism 的 bugfix fixture FAIL，输出可定位。

- [x] T022 [Verification] 构造 skip path 正向 fixture
  - scope: 临时 workspace fixture
  - maps_to: FR-011, NFR-001
  - verify: 低风险单点 bugfix 记录 skip reason 后不被强制要求完整 loop-breaker fields。

- [x] T023 [Verification] 执行 prohibited side effects 边界扫描
  - scope: `skills/sdd`, `specs/sdd-break-loop-for-bugfix`
  - maps_to: FR-012, 低副作用
  - verify: 扫描 `.trellis|Trellis CLI|task\\.py|JSONL|hook 自动|自动提交|git push|外部 API|issue tracker`，只允许出现在明确边界说明中。

- [x] T024 [Verification] 写入 `verify-evidence.md`
  - scope: `specs/sdd-break-loop-for-bugfix/verify-evidence.md`
  - maps_to: Verify evidence package
  - verify: Evidence Table 覆盖 P1/P2 scenarios、validator、fixtures、boundary scan 和 drift 检查。

---

## Phase 5: Closeout Artifacts

**目标**: 完成 SDD 持久验收记录、Knowledge Capture、roadmap 回写和提交计划。

- [x] T025 [Closeout] 写入 `acceptance.md` 并 dogfood bugfix closeout fields
  - scope: `specs/sdd-break-loop-for-bugfix/acceptance.md`
  - maps_to: FR-009, Knowledge Capture Gate
  - verify: acceptance 包含 Root Cause / Fix Mechanism / Prevention Mechanism / Failed Attempts Summary / Remaining Risk / Knowledge Capture / Completion Record。

- [x] T026 [Closeout] 回写 roadmap 状态
  - scope: `specs/sdd-trellis-workflow-productization/roadmap.md`
  - maps_to: roadmap current, closeout
  - verify: closeout 后本 feature 标记 done；若用户未要求外部同步，推荐 roadmap closeout 而不是自动启动 lifecycle integrations。

- [x] T027 [Closeout] 生成 commit plan
  - scope: `specs/sdd-break-loop-for-bugfix/commit-plan.md`
  - maps_to: commit boundary
  - verify: commit plan 只列当前 feature 相关 diff，并等待用户确认，不自动 commit/push。

---

## 依赖与顺序

- T001-T004 是共享契约和 trait 基础，必须先于阶段、模板和 validator 改动。
- T005-T013 是阶段与模板规则，可按文件相对独立推进，但 T001 应先完成。
- T014-T017 是 validator 关键路径，必须在 T020-T022 fixture 验证前完成。
- T018-T024 是 verify 前置证据，必须全部完成后才能进入 closeout。
- T025-T027 是收尾任务，必须在实现和验证通过后执行。
- 关键路径：T001 -> T002/T003/T004 -> T014/T015/T016 -> T020/T021/T022 -> T024 -> T025。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 Capture Bugfix Context Before Fixing | T001, T002, T003, T004, T005, T006, T019 |
| US2 Prevent Repeating Failed Fix Attempts | T001, T008, T009, T010, T024 |
| US3 Prove The Bugfix Breaks The Loop | T006, T011, T014, T016, T018, T020, T021, T024 |
| US4 Preserve Lessons In Closeout | T012, T013, T025, T026, T027 |
| FR-001 trigger signals | T001, T002, T003, T004 |
| FR-002 bugfix context | T001, T005, T006 |
| FR-003 unknown root cause | T001, T005 |
| FR-004 plan strategy | T006, T007 |
| FR-005 task coverage | T008, T009, T019 |
| FR-006 failed attempt control | T001, T010 |
| FR-007 before/after evidence | T011, T016, T024 |
| FR-008 regression guard / diffusion check | T011, T016, T020, T024 |
| FR-009 closeout bugfix fields | T012, T013, T016, T021, T025 |
| FR-010 validator structural boundary | T014, T016, T020, T021 |
| FR-011 lightweight skip path | T001, T002, T003, T017, T022 |
| FR-012 no prohibited defaults | T023, T027 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001 Add `bugfix-loop-breaker` trait | T002, T003, T004 | T019 |
| ADR-002 Shared bugfix reference | T001, T005-T013 | T015, T018 |
| ADR-003 Ledger in existing artifacts | T008, T010, T024 | T024, T025 |
| ADR-004 Validator stays structural | T014, T016 | T020, T021 |
| ADR-005 No default external integration | T023, T027 | T023 |
| 可追溯性 | T001, T011, T024, T025 | T024, T025 |
| 低噪音 | T001, T002, T017, T022 | T022 |
| 防回归 | T011, T016, T020 | T020, T024 |
| 可维护性 | T001, T015, T018 | T018 |
| 低副作用 | T023, T027 | T023 |

---

## Notes

- 不创建 `data-model.md`；plan 已说明无新增持久数据模型。
- 临时 fixture 不应提交为正式 runtime 文件，除非 verify 阶段决定需要新增持久测试目录并更新 plan。
- `validate-sdd.sh --closeout-ready` 的 bugfix 检查只做结构性检查，不判断 root cause 语义正确性。
- 本 feature 不启动 `sdd-optional-lifecycle-integrations`，也不默认同步外部 issue tracker 或知识库。

---

## Stage Readiness

- 推荐下一步：`execute-plan`
- 阻塞项：无。
