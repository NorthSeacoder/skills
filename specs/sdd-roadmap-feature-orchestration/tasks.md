# Tasks: SDD Roadmap Feature Orchestration

**Workspace**: `sdd-roadmap-feature-orchestration`
**Date**: 2026-06-06
**Spec**: [spec.md](spec.md)
**Plan**: [plan.md](plan.md)

---

## 执行原则

- 只实现 F1 roadmap 编排能力，不实现 F2 中文验收、F3 自动提交、F4 context manifest。
- 任务按依赖顺序排列；同一 phase 内独立文件可并行编辑。
- 每个任务都必须能追溯到 spec 的 user story、FR 或 plan 的 ADR。
- 实现时不得回滚当前仓库已有的 `skills/sdd` symlink 状态或其他无关 dirty files。

---

## Phase 1: Roadmap 模板与 dogfooding 产物

- [x] T001 [US2,FR-002,FR-003] 创建 `skills/sdd/templates/roadmap-template.md`
  - scope: 新增 roadmap 模板
  - detail: 模板包含 Summary、Current State、Feature Roadmap、Completion Log、Next Recommendation、Deferred Features
  - verify: 模板中 Feature Roadmap 表包含 `Feature / Goal / Status / Depends On / Start Condition / Recommended Stage / Notes`

- [x] T002 [US2,US4] 对齐本 feature 的 `specs/sdd-roadmap-feature-orchestration/roadmap.md`
  - scope: dogfooding roadmap 产物
  - detail: 确认 F1 current、F2/F3/F4 backlog、next recommendation 指向 F2
  - verify: `Current Feature` 与 `specs/.active` 一致

## Phase 2: SDD 入口与阶段规则

- [x] T003 [US1,FR-001,FR-008] patch `skills/sdd/SKILL.md` 加入 multi-feature preflight 语义
  - scope: `SKILL.md` 工作区约定、阶段路由、路由原则、输出要求
  - detail: 声明 `specs/<umbrella>/roadmap.md`；在进入阶段前先判断是否适合拆成多个 feature；支持"只评估不写文件"
  - verify: `SKILL.md` 能回答何时生成 roadmap、何时不生成 roadmap、下一 feature 如何推荐

- [x] T004 [US1,FR-001,FR-008] patch `references/stages/ideate.md` 加入多 feature 拆分评估
  - scope: ideate 阶段说明
  - detail: 增加触发信号、候选 feature 输出格式、首个 feature 推荐、只评估不写文件规则
  - verify: ideate 阶段能在需求发散时先输出候选 feature，而不是直接写 spec

- [x] T005 [US2,FR-002,FR-004,FR-007] patch `references/stages/specify.md` 加入 roadmap 创建/更新步骤
  - scope: specify 阶段说明
  - detail: 确认拆分后读取 roadmap 模板，创建或更新 `specs/<umbrella>/roadmap.md`，首个 feature 标记 current，后续 feature 标记 backlog，同步 `.active`
  - verify: specify 阶段完成标准包含 roadmap 与 `.active` 对齐检查

- [x] T006 [US3,FR-005,FR-006] patch `references/stages/closeout.md` 加入 roadmap 回写和 next recommendation
  - scope: closeout 阶段说明
  - detail: closeout 后按 PASS/CONDITIONAL/BLOCKED 更新 roadmap，写 Completion Log，重新计算 next recommended feature
  - verify: closeout 阶段完成标准要求输出下一个 feature 或 roadmap closeout 建议

## Phase 3: Cross-stage 对齐与防漂移

- [x] T007 [US2,FR-007] 增加 `.active` 与 roadmap current 的失配处理规则
  - scope: `SKILL.md` 或相关阶段说明，优先放入口约定，必要时在 specify/closeout 引用
  - detail: 若 roadmap current 与 `specs/.active` 不一致，必须说明失配并先修正
  - verify: 文档中存在明确的"不得静默继续"规则

- [x] T008 [US4,FR-009] 明确后续 feature 边界
  - scope: `SKILL.md` 或 roadmap 模板说明
  - detail: 中文验收、自动提交、Trellis context manifest 必须作为后续 feature 记录，不作为 F1 完成条件
  - verify: 实现后的文档没有要求本期自动 git commit 或生成 JSONL manifest

## Phase 4: 验证与自应用

- [x] T009 [contract] Roadmap 字段覆盖检查
  - scope: `templates/roadmap-template.md`、本 feature `roadmap.md`
  - detail: 对照 FR-003 检查字段是否完整，状态枚举是否包含 backlog/current/done/conditional/blocked/cancelled
  - verify: 输出检查结论，供 verify / acceptance 使用

- [x] T010 [contract] 阶段责任 trace
  - scope: `SKILL.md`、`ideate.md`、`specify.md`、`closeout.md`
  - detail: 对照 plan 的阶段责任表，逐项确认每个阶段只承担自己的 roadmap 责任
  - verify: trace 覆盖入口识别、拆分评估、roadmap 创建、closeout 回写、next recommendation

- [x] T011 [contract] 小改动对照检查
  - scope: `SKILL.md`、`ideate.md`
  - detail: 确认单点小改动不强制生成 roadmap，且"只评估不写文件"被保留
  - verify: 文档中存在明确跳过条件

- [x] T012 [self-app] 更新本 feature roadmap 的完成预期
  - scope: `specs/sdd-roadmap-feature-orchestration/roadmap.md`
  - detail: 在实现完成前不标记 done；verify/closeout 阶段再写 Completion Log
  - verify: 当前阶段从 `tasks` 继续推进，不提前宣布完成

---

## 依赖与顺序

**关键路径**: T001 → T003 → T004/T005/T006 → T007 → T009/T010 → verify

- T001 必须先完成，因为 specify 阶段需要引用 roadmap 模板。
- T003 是入口约定，T004/T005/T006 都依赖它的统一语义。
- T004、T005、T006 可在 T003 后并行编辑，但 T007 需要它们语义稳定后再做失配规则对齐。
- T009-T011 是验证任务，必须在文档 patch 完成后执行。
- T012 只更新 dogfooding roadmap 的当前阶段，不得提前写 completion。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|---|---|
| US1 自动识别多 feature 并拆分 | T003, T004, T011 |
| US2 建立可续接 roadmap | T001, T002, T005, T007, T009 |
| US3 完成后更新后续顺序 | T006, T010, T012 |
| US4 明确后续 feature 边界 | T002, T008, T011 |
| FR-001 拆分识别 | T003, T004 |
| FR-002 roadmap 生成/更新 | T001, T005 |
| FR-003 roadmap 字段 | T001, T009 |
| FR-004 首个 feature spec + `.active` | T005, T007 |
| FR-005 closeout 回写 | T006, T010 |
| FR-006 自动推荐下一个 feature | T006, T010 |
| FR-007 `.active` 失配处理 | T007 |
| FR-008 只评估不写文件 | T003, T004, T011 |
| FR-009 后续 feature 不进本期 | T002, T008 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|---|---|---|
| ADR-001 roadmap 位置 | T002, T005 | T010 |
| ADR-002 roadmap 模板 | T001 | T009 |
| ADR-003 `.active` 单值语义 | T003, T007 | T010 |
| ADR-004 Trellis 吸收边界 | T008 | T011 |
| 可续接性 | T001, T002, T005, T007 | T009, T010 |
| 低耦合 | T003-T006 | T010 |
| 可演进性 | T001, T002 | T009 |
| 可审查性 | T006 | T010 |

---

## Notes

- T009-T011 可以作为 verify 阶段的 evidence 来源，不需要新增测试脚本。
- 如果实现阶段发现 `skills/sdd` symlink 目标不在当前仓可写范围内，应先停下说明权限问题，不要绕开到安装副本。
- F3 自动提交会涉及 git 副作用，本期不得以"顺手"方式加入。

---

## Stage Readiness

- 推荐下一步：`implement`
- 是否需要 `execute-plan`：不需要。任务数 12 个，主要是 Markdown 文档 patch，边界清晰，可直接实现。
- 阻塞项：无。
