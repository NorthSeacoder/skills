# Tasks: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator` | **Date**: 2026-06-07
**Input**: `specs/sdd-status-model-and-validator/spec.md` + `plan.md` + `data-model.md`
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (必须)

**Note**: 本 feature 命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output`、`prior-closure-failure`，因此必须生成 `context-manifest.md`，并覆盖实现、验证和 closeout 准备任务。

---

## Phase 1: Status Model And Routing Alignment

**目标**: 先固定状态词表和消费关系，避免脚本实现与 SDD 路由规则分叉。

- [x] T001 [US1] 新增 `skills/sdd/references/status-model.md`
  - scope: `skills/sdd/references/status-model.md`
  - maps_to: FR-001, FR-002, FR-003, FR-010, ADR-001, data-model State Inference
  - verify: 文件存在，包含 active feature、roadmap、manifest、tasks、verify evidence、acceptance、default / closeout-ready、completed roadmap none、多 roadmap fail 等规则。

- [x] T002 [US1] 在 SDD 入口和 continuation reference 中引用 status model
  - scope: `skills/sdd/SKILL.md`, `skills/sdd/references/continuation-routing.md`
  - maps_to: FR-002, FR-010, ADR-001
  - verify: `rg -n "status-model|Status Model" skills/sdd/SKILL.md skills/sdd/references/continuation-routing.md` 能定位引用；入口不复制长规则。

- [x] T003 [US3] 在 verify / closeout 阶段说明 validator 使用方式
  - scope: `skills/sdd/references/stages/verify.md`, `skills/sdd/references/stages/closeout.md`
  - maps_to: FR-007, FR-008, FR-009, ADR-005
  - verify: verify 阶段建议 default validator；closeout 阶段建议 `--closeout-ready` 或等效 strict check，且不把 verify 通过等同于 closeout 完成。

---

## Phase 2: Default Validator State Checks

**目标**: 扩展现有 `validate-sdd.sh`，保持零依赖、只读、短输出。

- [x] T004 [Foundation] 给 `validate-sdd.sh` 增加 mode parsing 和 helper 函数骨架
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: ADR-002, NFR-001, 可维护性
  - verify: default mode 行为保持兼容；未知参数失败并输出用法；脚本仍以 `set -euo pipefail` 运行。

- [x] T005 [US1] 校验 `specs/.active` 存在、非空、且 feature directory 存在
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US1-1, US1-2, US1-4, FR-001
  - verify: 当前 workspace default validator 通过；fixture 中 `.active` 缺失、空值、目录不存在均 FAIL，失败包含 `specs/.active` 或 `specs/<feature>`。

- [x] T006 [US1] 校验 active roadmap current 一致性
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US1-3, US1-5, US1-6, FR-002, FR-003, ADR-003, ADR-004
  - verify: active roadmap `Current Feature` mismatch FAIL；多个 active/current roadmap 候选 FAIL；completed roadmap + `Current Feature: none` 不触发 mismatch。

- [x] T007 [US2] 校验 context manifest 结构
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US2-1, US2-2, US2-3, US2-5, FR-004, FR-005, FR-006
  - verify: manifest 每条 entry 有 reason；`Required = yes` 本地文件必须存在；Check Context 覆盖 spec / plan / tasks；URL 不做本地文件存在性检查。

- [x] T008 [Boundary] 保持 default validator 阶段感知
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-4, ADR-005, 低副作用
  - verify: 当前 feature 仍未 closeout 时，default validator 不因缺 `verify-evidence.md` 或 `acceptance.md` 失败。

---

## Phase 3: Closeout Readiness Checks

**目标**: 提供 strict mode，避免未完成任务、缺 fresh evidence 或缺验收记录时进入完成态。

- [x] T009 [US3] 增加 `--closeout-ready` 模式
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-1, US3-2, US3-3, FR-007, FR-008, FR-009, ADR-005
  - verify: `bash skills/sdd/scripts/validate-sdd.sh --closeout-ready` 能运行 strict checks；当前未完成 feature 预期会因 tasks/evidence/acceptance 状态失败或明确说明缺口。

- [x] T010 [US3] 检查 `tasks.md` 未完成项
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-1, FR-007
  - verify: fixture 中存在 `- [ ]` 时 strict mode FAIL，输出 `tasks incomplete` 和 tasks 文件路径；全 `- [x]` 时通过该检查。

- [x] T011 [US3] 检查 verify evidence 是否存在
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-2, FR-008
  - verify: strict mode 缺 `verify-evidence.md` 时 FAIL，输出 `missing fresh evidence`；存在文件时通过该检查。

- [x] T012 [US3] 检查 acceptance record 关键章节和 Overall 字段
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - maps_to: US3-3, FR-009
  - verify: 缺 Evidence Table、Verdict Summary、Closeout Checklist、Completion Record 或 Overall 时 FAIL；完整 acceptance 通过该检查。

---

## Phase 4: Validation Evidence And Closeout Preparation

**目标**: 用可定位证据证明 validator 覆盖 spec 场景，并准备后续 closeout。

- [x] T013 [Verification] 建立 fixture / 临时副本验证策略
  - scope: `specs/sdd-status-model-and-validator/verify-evidence.md`
  - maps_to: Verification Strategy, 低副作用
  - verify: evidence 记录每个失配场景的构造方式、命令、期望结果；验证过程不污染真实 workspace。

- [x] T014 [Verification] 跑 default validator 正向验证
  - scope: `skills/sdd/scripts/validate-sdd.sh`, `specs/.active`, `specs/sdd-trellis-workflow-productization/roadmap.md`
  - maps_to: US1-1, FR-001, FR-002, FR-010
  - verify: `bash skills/sdd/scripts/validate-sdd.sh` 在当前 workspace 返回 OK。

- [x] T015 [Verification] 跑 negative fixture 验证
  - scope: temporary fixture workspace or documented manual fixture
  - maps_to: US1-2, US1-3, US1-4, US1-6, US2-2, US2-3, US3-1, US3-2, US3-3
  - verify: 每个 negative case 都有命令、失败摘要和目标 requirement 映射。

- [x] T016 [Boundary] 扫描禁止引入的 Trellis / 外部副作用
  - scope: `skills/sdd`, `specs/sdd-status-model-and-validator`
  - maps_to: FR-011, 低副作用
  - verify: `rg -n "\\.trellis|Trellis CLI|task\\.py|JSONL|hook 自动|git push|自动提交" skills/sdd specs/sdd-status-model-and-validator` 的命中均为边界说明，不是新增实现机制。

- [x] T017 [Acceptance] 生成或更新 `acceptance.md`
  - scope: `specs/sdd-status-model-and-validator/acceptance.md`
  - maps_to: user-visible-output, prior-closure-failure, FR-009
  - verify: acceptance 包含 Evidence Table、三维 Verdict、Closeout Checklist、Commit Result、Completion Record；Overall 不得在 evidence 缺失时写 PASS。

- [x] T018 [Roadmap] closeout 时回写 umbrella roadmap
  - scope: `specs/sdd-trellis-workflow-productization/roadmap.md`
  - maps_to: artifact-handoff, roadmap current consistency
  - verify: feature closeout 后 roadmap 标记 `sdd-status-model-and-validator` done/conditional/blocked，并推荐 `sdd-knowledge-capture-closeout` 或说明阻塞原因。

---

## 依赖与顺序

- T001 是关键路径起点；T002、T003 依赖 T001。
- T004 是所有脚本校验任务的基础；T005-T008 可在 T004 后顺序实现。
- T009 依赖 T004；T010-T012 依赖 T009。
- T013 应在开始 negative fixture 前完成验证记录结构。
- T014-T016 依赖 T005-T012。
- T017 依赖 fresh evidence；T018 只在 closeout 阶段执行。

并行空间：

- T001-T003 可以与脚本实现前的准备并行阅读，但最终 diff 需统一审查。
- T010-T012 在 `--closeout-ready` mode 骨架完成后相对独立。
- T014-T016 可作为 verify 阶段的独立检查组。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1-1 valid active feature | T005, T014 |
| US1-2 missing active directory | T005, T015 |
| US1-3 roadmap current mismatch | T006, T015 |
| US1-4 active 缺失或为空 | T005, T015 |
| US1-5 completed roadmap none | T006, T015 |
| US1-6 multiple roadmap candidates | T006, T015 |
| US2-1 Required files exist | T007, T015 |
| US2-2 missing reason | T007, T015 |
| US2-3 Check Context misses core artifacts | T007, T015 |
| US2-4 lightweight manifest skip | T007, T008 |
| US2-5 URL / external source handling | T007 |
| US3-1 tasks incomplete | T009, T010, T015 |
| US3-2 missing verify evidence | T009, T011, T015 |
| US3-3 acceptance missing verdict | T009, T012, T015 |
| US3-4 in-progress feature does not require evidence | T008, T014 |
| US3-5 concise output | T004, T005-T012 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001 status model reference | T001, T002 | T014 |
| ADR-002 single shell validator | T004 | T014, T015 |
| ADR-003 multiple roadmap fail | T006 | T015 |
| ADR-004 completed roadmap none | T006 | T015 |
| ADR-005 closeout readiness mode | T008, T009 | T010-T012, T015 |
| 可审计性 | T004-T012 | T013-T015 |
| 可维护性 | T001, T004 | code review in verify |
| 低副作用 | T013, T016 | T014-T016 |

---

## Context Manifest

已生成 [context-manifest.md](context-manifest.md)。本 feature 的实现和验证跨多个阶段与 artifact，不能跳过 manifest。

---

## Stage Readiness

- 推荐下一步：`execute-plan`
- 原因：任务数量为 18 个，涉及 reference、入口路由、validator、stage guidance、fixture evidence 和 closeout record；需要按阶段 checkpoint 控制 drift。
- 阻塞项：无。
