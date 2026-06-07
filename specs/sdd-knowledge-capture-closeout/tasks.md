# Tasks: SDD Knowledge Capture Closeout

**Workspace**: `sdd-knowledge-capture-closeout` | **Date**: 2026-06-08  
**Input**: `specs/sdd-knowledge-capture-closeout/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (不需要)

**Note**: 本 feature 命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output`、`prior-closure-failure`，因此必须生成 `context-manifest.md`，并覆盖实现、验证和 closeout 任务。

---

## Phase 1: Closeout Contract

**目标**: 先固定 Knowledge Capture Gate 的阶段语义和字段词表，避免模板、validator 和入口说明分叉。

- [x] T001 [US1] 更新 SDD 入口对 closeout 知识沉淀的描述
  - scope: `skills/sdd/SKILL.md`
  - maps_to: FR-001, FR-007, ADR-002
  - verify: 入口明确 closeout 使用 Knowledge Capture Gate，且说明外部同步不默认启用。

- [x] T002 [US1,US2] 在 closeout 阶段新增 Knowledge Capture Gate
  - scope: `skills/sdd/references/stages/closeout.md`
  - maps_to: US1-1, US1-2, US1-3, US2-1, FR-001, FR-002, FR-003, FR-004, FR-007, FR-009
  - verify: closeout 规则包含 durable knowledge 判断、`none + reason`、redaction、证据来源、sync status、外部同步边界和完成标准。

- [x] T003 [US3] 更新 status model 的 closeout-ready acceptance 要求
  - scope: `skills/sdd/references/status-model.md`
  - maps_to: US3-3, FR-006, ADR-003
  - verify: closeout-ready section 要求 acceptance 包含 Knowledge Capture 或明确跳过原因，并说明 validator 只检查结构。

---

## Phase 2: Acceptance Schema

**目标**: 把 Knowledge Capture 固化到持久 completion record 模板中。

- [x] T004 [US1,US3] 在 acceptance 模板增加 `## Knowledge Capture`
  - scope: `skills/sdd/templates/acceptance-template.md`
  - maps_to: US1-1, US1-2, US3-1, US3-2, FR-002, FR-003, FR-004, FR-005
  - verify: 模板包含 Type / Title / Summary / Evidence / Scope / Sync Status / Follow-up 表头，以及 `none` 示例。

- [x] T005 [US2] 在 acceptance 模板说明 Sync Status 枚举和外部同步边界
  - scope: `skills/sdd/templates/acceptance-template.md`
  - maps_to: US2-1, US2-2, US2-3, FR-007, FR-008, FR-009
  - verify: 模板列出 `recorded-only`、`synced-by-session-memory`、`skipped`、`redacted`、`follow-up`，且禁止默认外部同步。

- [x] T006 [US3] 给 Knowledge Capture 写作规则加入低噪音约束
  - scope: `skills/sdd/templates/acceptance-template.md`
  - maps_to: US3-2, NFR-001, NFR-003
  - verify: 模板要求单条 summary 1-3 句、必须引用 evidence、不得粘贴长日志或完整 diff。

---

## Phase 3: Validator

**目标**: 让 `--closeout-ready` 能抓住缺失 Knowledge Capture 的 acceptance，但不升级为语义审查器。

- [x] T007 [US3] 扩展 `validate-sdd.sh --closeout-ready` 的 acceptance section 检查
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-3, FR-006, ADR-003, NFR-002
  - verify: 缺 `## Knowledge Capture` 的 closeout-ready acceptance FAIL，失败输出包含 `acceptance.md` 和原因。

- [x] T008 [US2,US3] 校验 Knowledge Capture 关键字段和类型词表
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: FR-002, FR-003, FR-004, FR-007
  - verify: acceptance 缺 `Sync Status` 或缺允许类型词时 FAIL；`none` 示例可 PASS。

- [x] T009 [Boundary] 保持 default validator 不强制历史 acceptance 迁移
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: 兼容风险, ADR-003
  - verify: `bash skills/sdd/scripts/validate-sdd.sh` 在当前未 closeout feature 上仍 PASS；历史 feature 不因缺 Knowledge Capture 失败。

---

## Phase 4: Verification Fixtures And Evidence

**目标**: 用真实 workspace 和临时 fixture 证明规则有效，而不是只靠文档存在。

- [x] T010 [Verification] 运行基础脚本检查
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: NFR-002, 低副作用
  - verify: `bash -n skills/sdd/scripts/validate-sdd.sh` PASS；`bash skills/sdd/scripts/validate-sdd.sh` PASS。

- [x] T011 [Verification] 构造 missing Knowledge Capture 负向 fixture
  - scope: 临时 workspace fixture
  - maps_to: US3-3, FR-006
  - verify: `--closeout-ready` 对缺 `## Knowledge Capture` 的 acceptance FAIL，输出可定位。

- [x] T012 [Verification] 构造 `none + reason` 正向 fixture
  - scope: 临时 workspace fixture
  - maps_to: US1-2, FR-004, NFR-003
  - verify: acceptance 包含 `Type=none`、skip reason、Sync Status 后，`--closeout-ready` PASS。

- [x] T013 [Verification] 边界扫描默认外部副作用
  - scope: `skills/sdd`, `specs/sdd-knowledge-capture-closeout`
  - maps_to: US2-1, FR-010, 低副作用
  - verify: 扫描 `.trellis`、Trellis CLI、`task.py`、JSONL task、hook 自动、自动提交、`git push`、默认外部 API 调用，仅命中边界说明。

---

## Phase 5: Closeout Artifacts

**目标**: 让本 feature 自身使用新增规则完成验收和 roadmap 回写。

- [x] T014 [Closeout] 写入 `verify-evidence.md`
  - scope: `specs/sdd-knowledge-capture-closeout/verify-evidence.md`
  - maps_to: FR-001..FR-010, Verification Strategy
  - verify: Evidence Table 覆盖模板、closeout、status model、validator、fixture 和 boundary scan。

- [x] T015 [Closeout] 写入 `acceptance.md` 并 dogfood Knowledge Capture
  - scope: `specs/sdd-knowledge-capture-closeout/acceptance.md`
  - maps_to: US1-1, US2-2, US3-2, ADR-001, ADR-002
  - verify: acceptance 包含 `## Knowledge Capture`，至少记录一个 `decision` 或 `pattern`，并写明 Sync Status。

- [x] T016 [Closeout] 回写 roadmap 和生成 commit plan
  - scope: `specs/sdd-trellis-workflow-productization/roadmap.md`, `specs/sdd-knowledge-capture-closeout/commit-plan.md`
  - maps_to: roadmap current, closeout commit planning rules
  - verify: closeout 后 roadmap 标记本 feature done，并推荐 `sdd-break-loop-for-bugfix`；commit plan 只列当前 feature 相关 diff，等待用户确认。

---

## 依赖与顺序

- T001-T003 是规则契约，必须先于模板和 validator 完成。
- T004-T006 是 acceptance schema，必须先于 T007-T008 完成。
- T007-T009 是 validator 关键路径，必须先于 T011-T012 fixture 验证。
- T010-T013 是 verify 前置证据，必须全部完成后才能进入 closeout。
- T014-T016 是收尾任务，必须在实现和验证通过后执行。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 Capture Durable Closeout Knowledge | T002, T004, T006, T014, T015 |
| US2 Keep External Sync Optional | T001, T002, T005, T013, T015 |
| US3 Auditable And Low Noise | T004, T006, T007, T008, T011, T012 |
| FR-001 closeout gate | T001, T002 |
| FR-002 categories | T002, T004, T008 |
| FR-003 required fields | T004, T008 |
| FR-004 none + reason | T002, T004, T012 |
| FR-005 acceptance template | T004, T005, T006 |
| FR-006 validator | T007, T008, T011, T012 |
| FR-007 local vs external sync | T001, T002, T005 |
| FR-008 session memory status | T005, T015 |
| FR-009 redaction | T002, T005 |
| FR-010 no Trellis / side effects | T013 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001 Store capture in `acceptance.md` | T004, T015 | T014, T015 |
| ADR-002 No default external sync | T001, T005 | T013, T015 |
| ADR-003 Validator remains structural | T003, T007, T008 | T010, T011, T012 |
| 可审计性 | T004, T006, T015 | T014, T015 |
| 低副作用 | T001, T005 | T013 |
| 可维护性 | T003, T007, T008 | T010 |
| 低噪音 | T006, T012 | T012 |

---

## Notes

- 不创建 `data-model.md`，因为 schema 已在 `plan.md` 中定义，且无新增存储实体。
- 不新增外部同步实现；后续只在 `sdd-optional-lifecycle-integrations` 中评估 opt-in 出口。
- 实现阶段不要把临时 fixture 提交为正式 runtime 文件，除非后续决定新增持久测试目录。

---

## Stage Readiness

- 推荐下一步：`execute-plan`
- 阻塞项：无。
