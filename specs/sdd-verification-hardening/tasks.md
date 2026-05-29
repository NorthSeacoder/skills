# Tasks: SDD Verification Hardening

**Workspace**: `sdd-verification-hardening` | **Date**: 2026-05-29
**Input**: `specs/sdd-verification-hardening/spec.md` + `plan.md`
**Prerequisites**: spec.md (必须), plan.md (必须)

---

## 执行原则

- 先建底（feature-traits.md 是其余规则的依据），再各阶段并行 patch，最后 dogfooding 验证
- 模板段落和阶段引用必须语义一致（同一 trait 在两处必须触发同一规则）
- 本 feature 自身就是第一个 dogfooding 对象

---

## Phase 1: 建立 traits 真相源

**目标**: 让 `feature-traits.md` 成为所有强化规则的单一定义点

- [ ] T001 [US1] 创建 `references/feature-traits.md`
  - scope: `skills/sdd/references/feature-traits.md`（新建）
  - maps_to: FR-001, FR-007, ADR-001
  - verify: 文件存在且包含三段：定义（5 traits）、触发规则（4 条 trait → 规则映射）、跳过条件；总行数 60-80
  - 内容要点:
    - 5 traits 枚举:`multi-stage-workflow` / `external-side-effects` / `artifact-handoff` / `user-visible-output` / `prior-closure-failure`
    - 每个 trait 给 2-4 个检测信号（启发式）
    - 触发规则 4 条:matrix / evidence gate / replay / 三维 verdict 各自的命中条件
    - 跳过条件沿用 plan.md "跳过候选方案讨论" 的语言风格

---

## Phase 2: 模板段落落地

**目标**: 为各阶段产物提供格式定义，与 traits 触发规则对齐

- [ ] T002 [US1] 在 `templates/spec-template.md` 新增 `## Feature Traits` 段
  - scope: `skills/sdd/templates/spec-template.md`
  - maps_to: FR-001, FR-002, US1
  - verify: 模板中存在 traits 表格（Trait / 是否命中 / 依据三列）+ 一行结论提示 + 引用 `../references/feature-traits.md`
  - 位置：`Input` 段之后、`User Scenarios` 段之前

- [ ] T003 [US2] 在 `templates/plan-template.md` 新增 `## Producer-Consumer Matrix` 可选段
  - scope: `skills/sdd/templates/plan-template.md`
  - maps_to: FR-003, US2, ADR-002
  - verify: 模板中存在 matrix 表（Producer / Artifact / Consumer / Consumption Proof 四列）+ 标注 `*(if multi-stage-workflow or artifact-handoff)*` + 孤儿 artifact 处理说明
  - 位置：`Architecture Reference` 之后、`Quality Attribute Targets` 之前

- [ ] T004 [US3,US5] 创建 `templates/acceptance-template.md`
  - scope: `skills/sdd/templates/acceptance-template.md`（新建）
  - maps_to: FR-004, FR-006, US3, US5, ADR-002
  - verify: 文件存在,包含两段:Evidence Table（Requirement / Evidence / Test or File / Verdict 四列）+ 三维 Verdict（Component / Workflow / User-Visible Outcome）+ Overall 行;总行数 40-50
  - 内容要点:
    - Evidence 列必须给出"具体证据来源"的填写示例（测试名/文件路径/捕获 payload）
    - 三维 Verdict 不一致时的说明字段

---

## Phase 3: 阶段说明 patch

**目标**: 各阶段引用 feature-traits.md 决定是否启用对应规则

- [ ] T005 [US1] patch `references/stages/specify.md` 加入 traits 检测步骤
  - scope: `skills/sdd/references/stages/specify.md`
  - maps_to: FR-001, FR-002, US1
  - verify: 执行步骤新增一条"检测 feature traits 并写入 spec.md（参考 `../feature-traits.md`）"; "阶段完成标准" 增加一条 traits 段已写入
  - 增量 ≤ 5 行

- [ ] T006 [US2] patch `references/stages/plan.md` 加入 matrix 触发条件
  - scope: `skills/sdd/references/stages/plan.md`
  - maps_to: FR-003, FR-007, US2
  - verify: 执行步骤新增一条"若 spec 中 `multi-stage-workflow` 或 `artifact-handoff` 命中,在 plan.md 写入 Producer-Consumer Matrix"; "阶段完成标准" 增加 matrix 检查
  - 增量 ≤ 5 行

- [ ] T007 [US3] patch `references/stages/verify.md` 加入 evidence gate 条件
  - scope: `skills/sdd/references/stages/verify.md`
  - maps_to: FR-004, FR-007, US3
  - verify: 执行步骤新增 evidence 表生成条件 + PARTIAL 判定规则（evidence 不足不得判 PASS）;"阶段完成标准" 增加 evidence 表存在性检查
  - 增量 ≤ 5 行

- [ ] T008 [US4] patch `references/stages/closeout.md` checklist 加入 replay 项
  - scope: `skills/sdd/references/stages/closeout.md`
  - maps_to: FR-005, US4
  - verify: closeout checklist 新增一条 "若同时命中 `multi-stage-workflow` 和 `user-visible-output`,执行 workflow replay 并把结论写入 acceptance.md"
  - 增量 ≤ 3 行

- [ ] T009 [US5] patch `references/stages/closeout.md` 引用 acceptance-template.md
  - scope: `skills/sdd/references/stages/closeout.md`
  - maps_to: FR-006, US5
  - verify: 执行步骤中新增 "若任一强化 trait 命中,使用 `../../templates/acceptance-template.md` 写 acceptance.md"
  - 增量 ≤ 3 行
  - 可与 T008 合并到一次 edit

---

## Phase 4: SKILL.md 同步

**目标**: 让 skill 入口知道新加的 reference 和 template 存在

- [ ] T010 [US1] 在 `SKILL.md` 的 "模板与资产" 段补充新文件
  - scope: `skills/sdd/SKILL.md`
  - maps_to: NFR-001, FR-007
  - verify: "模板与资产" 段已列出 `templates/acceptance-template.md`;"references/stages/*.md" 之外的 reference 列表中已列出 `references/feature-traits.md`
  - 增量 ≤ 5 行

---

## Phase 5: Self-application 与 Dogfooding

**目标**: 用本 feature 自身验证强化规则真的能闭环

- [ ] T011 [contract] 一致性 trace
  - scope: `references/feature-traits.md` ↔ 各阶段 patch ↔ 模板段落
  - maps_to: 一致性 quality attribute, US1
  - verify: 对每个 trait 做一次 trace:trait 定义 → specify.md 触发 → 对应模板段落 → 对应阶段执行步骤;任一处缺失即 FAIL

- [ ] T012 [contract] 不命中 trait 的 minimal feature 演练
  - scope: 思想实验 + 文档对照
  - maps_to: 成本 quality attribute, FR-008
  - verify: 假设一个 "改 README 错别字" 的 feature 走 specify → plan,确认:Feature Traits 表全 ❌ 后无强化段落被强制生成;模板没有任何段落变成必填

- [ ] T013 [contract] 新增第 6 个 trait 演练
  - scope: 思想实验
  - maps_to: 可演进性 quality attribute
  - verify: 假设要加 `security-sensitive` trait,确认仅需改 `feature-traits.md` 和 `spec-template.md` 两个文件即可完成（其余阶段文件因引用 feature-traits.md 而自动生效）

- [ ] T014 [self-app] Self-application 验证
  - scope: `specs/sdd-verification-hardening/`
  - maps_to: US1-US5 全部, dogfooding
  - verify: 用本 feature 自身的 spec.md / plan.md 对照新规则:
    - spec.md 已含 Feature Traits 段 ✓（已存在）
    - plan.md 已含 Producer-Consumer Matrix ✓（已存在）
    - 实现完成后写 acceptance.md,使用三维 verdict + evidence 表
    - 触发 workflow replay:用本 feature 的 traits 表走一遍 specify → plan → tasks → verify → closeout 文档链路,捕获每阶段产物,断言"用户可见结果 = SDD skill 行为变化"

---

## 依赖与顺序

**关键路径**: T001 → T002 → T005 → T011 → T014

**必须串行**:
- T001 必须先完成（其余任务都引用 feature-traits.md）
- T011 必须在 T001-T010 全部完成后执行（trace 需要所有改动到位）
- T014 必须最后（self-application 是最终验证）

**可并行**:
- T002 / T003 / T004（三个模板独立）
- T005 / T006 / T007 / T008+T009（四个阶段 patch 独立）
- Phase 2 和 Phase 3 之间也可并行,只要都在 T001 之后

**T008 和 T009 建议合并**为一次 closeout.md edit,避免两次修改同一文件。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 Feature Traits 检测与传播 | T001, T002, T005, T010 |
| US2 Producer-Consumer Matrix | T001, T003, T006 |
| US3 Evidence Gate | T001, T004, T007 |
| US4 Workflow Replay | T001, T008 |
| US5 三维 Verdict | T001, T004, T009 |
| FR-001 traits 检测 | T001, T002, T005 |
| FR-002 用户 override | T001, T005 |
| FR-003 matrix 触发 | T001, T003, T006 |
| FR-004 evidence gate | T001, T004, T007 |
| FR-005 replay 触发 | T001, T008 |
| FR-006 三维 verdict | T001, T004, T009 |
| FR-007 默认开启 + 跳过记录 | T001, T005-T009 |
| FR-008 不命中零开销 | T012 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001 traits 载体 = 独立 reference | T001 | T011, T013 |
| ADR-002 格式嵌入模板 | T002, T003, T004 | T011 |
| ADR-003 默认开启 + opt-out | T005-T009 | T012 |
| 可演进性 | T001 | T013 |
| 一致性 | T001-T009 | T011, T014 |
| 成本 | T005-T009 设计 | T012 |
| 可维护性 | 总文件数 ≤ 2 新增,单文件 ≤ 80 行 | 完成时人工检查 |

---

## Notes

- T011-T013 是思想实验/文档对照,不需要写代码,但必须显式产出 trace 结果（写入 verify 阶段的输出或 acceptance.md）
- T014 的 self-application 是最重要的 dogfooding,如果发现规则有矛盾,优先返回 plan 调整,而不是绕过
- 不要在 closeout 之前删除 `docs/sdd-verification-hardening-context.md`,closeout 中需引用它确认问题已解决

---

## Stage Readiness

- 推荐下一步:`implement`（任务边界清晰、文件改动可控,无需 `execute-plan` 控节奏）
- 阻塞项:无
