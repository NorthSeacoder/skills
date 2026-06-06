# Tasks: 中文验收与收尾记录

**Workspace**: `chinese-acceptance-and-closeout-record` | **Date**: 2026-06-06  
**Input**: `specs/chinese-acceptance-and-closeout-record/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (不需要)

---

## 执行原则

- 先检查主仓 `~/personal/personal-skills` 的实际 `sdd` 文件，再落地改动。
- 任务只面向主仓实现路径；本参考工作区只保存 SDD 规格、方案和任务。
- 每个改动都要映射到 evidence gate、completion record、fast path 或中文表达质量之一。
- 验证必须覆盖命中 trait 和无 trait 两条路径。

---

## Phase 1: 主仓现状检查

**目标**: 确认正式 `sdd` skill 的阶段文件、模板和 trait 规则现状，避免基于参考仓路径硬改。

- [x] T001 [Setup] 检查主仓 `sdd` skill 文件布局
  - scope: `~/personal/personal-skills` 中的 `sdd` skill 目录、阶段规则、模板目录
  - maps_to: US3 / FR-010
  - verify: 列出实际存在的 `verify.md`、`closeout.md`、`feature-traits.md`、`acceptance-template.md` 路径；若路径不同，更新执行目标。
  - result: 正式路径确认为 `/Users/yqg/personal/personal-skills/.agents/skills/sdd`，目标文件均存在。

- [x] T002 [Setup] 对比主仓与参考规格的现有能力差距
  - scope: 主仓 `verify`、`closeout`、`acceptance-template`、`feature-traits`
  - maps_to: US1 / US2 / ADR-001 / ADR-002
  - verify: 形成简短差距列表：已具备、需补充、冲突项。
  - result: 现有规则已有 Evidence Table、三维 Verdict、Workflow Replay 和基础 closeout checklist；仍需补 `acceptance.md` 默认落盘语义、Closeout Checklist/Completion Record 模板、verify 证据包输出、closeout 对 verify 结果的消费和摘要输出边界。

---

## Phase 2: 模板与 trait 规则更新

**目标**: 让 `acceptance.md` 成为命中 trait 时的持久中文验收和完成记录。

- [x] T003 [US1] 扩展 `acceptance-template.md`
  - scope: 主仓 `skills/sdd/templates/acceptance-template.md`
  - maps_to: US1 / US2 / FR-003 / FR-004 / FR-005 / FR-006 / ADR-002
  - verify: 模板包含 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist、Completion Record；每个结论字段都要求证据、状态或下一步。
  - result: 临时实现文件已补写作规则、Closeout Checklist 和 Completion Record。

- [x] T004 [US1] 明确 `acceptance.md` 默认落盘规则
  - scope: 主仓 `skills/sdd/references/feature-traits.md`
  - maps_to: FR-002 / FR-009 / ADR-001 / ADR-003
  - verify: 文档说明“任一 trait 命中 -> 默认生成或更新 `acceptance.md`”；无 trait 或用户显式轻量路径时，记录中文跳过原因。
  - result: 临时实现文件已补“任一 trait 命中 -> 默认生成或更新 `acceptance.md`”和轻量路径跳过规则。

- [x] T005 [US2] 补充中文表达质量要求
  - scope: `acceptance-template.md`，必要时补充 closeout stage 说明
  - maps_to: FR-008 / FR-011 / NFR-003 / NFR-005
  - verify: 模板要求简体中文、短句优先、避免空泛段末总结句，且不允许“已实现”“测试通过”单独作为证据。
  - result: 临时实现文件已要求简体中文、短句优先、不得只写不可定位结论。

---

## Phase 3: 阶段规则更新

**目标**: 固化 verify 和 closeout 的职责边界，避免证据、判定和收尾记录分散。

- [x] T006 [US1] 强化 `verify` evidence 输出规则
  - scope: 主仓 `skills/sdd/references/stages/verify.md`
  - maps_to: US1 / FR-003 / FR-007 / Decision 1
  - verify: verify 规则说明 fresh evidence、Evidence Table draft、verdict 和 unresolved risks 的输出要求；证据不足时总 verdict 不得为 PASS。
  - result: 临时实现文件已新增 Evidence Package 规则，明确 verify 输出给 closeout 消费。

- [x] T007 [US2] 强化 `closeout` 消费 verify 结果并写入 `acceptance.md`
  - scope: 主仓 `skills/sdd/references/stages/closeout.md`
  - maps_to: US2 / FR-001 / FR-002 / FR-006 / FR-007 / Decision 1
  - verify: closeout 规则说明 verify 未通过时回退；命中 trait 时写 `acceptance.md`；最终对话输出只摘要路径、verdict、阻塞项和下一步。
  - result: 临时实现文件已新增 Acceptance Record Rules，并明确最终对话输出不替代 `acceptance.md`。

- [x] T008 [US2] 明确 Closeout Checklist 状态语义
  - scope: `closeout.md` 和 `acceptance-template.md`
  - maps_to: US2 / FR-006 / NFR-001 / NFR-002
  - verify: checklist 项支持“已完成 / 延后 / 不适用 / 阻塞”，每项必须有依据；阻塞项存在时不得宣布 feature 完成。
  - result: 临时实现文件已统一“已完成 / 延后 / 不适用 / 阻塞”状态语义。

---

## Phase 4: 验证与示例演练

**目标**: 用两条代表性路径验证规则闭环，而不是只检查文档是否存在。

- [x] T009 [Verify] 命中 trait 的 dry run
  - scope: 任一具备 `multi-stage-workflow` 或 `user-visible-output` 的示例 feature
  - maps_to: US1 / US2 / Evidence Gate / Workflow Replay
  - verify: 能从 verify evidence 进入 closeout，并生成包含 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist 和 Completion Record 的中文 `acceptance.md`。
  - result: `verification-dry-run.md` 记录命中 trait 路径 PASS。

- [x] T010 [Verify] 无 trait 小改动的 fast path dry run
  - scope: 一个纯文案、配置或单点小改动示例
  - maps_to: FR-009 / ADR-003 / 轻量性
  - verify: closeout 不强制完整 `acceptance.md`，但输出或记录中文跳过原因。
  - result: `verification-dry-run.md` 记录 fast path PASS。

- [x] T011 [Verify] 中文质量和可审计性 review
  - scope: T009 / T010 产生的示例输出或 dry run 记录
  - maps_to: FR-008 / FR-011 / NFR-002 / NFR-005
  - verify: 输出中没有不可定位的单独结论；每个 PASS、PARTIAL、FAIL 或 checklist 状态都能指向证据、依据或下一步。
  - result: `verification-dry-run.md` 记录中文质量 review PASS。

---

## Phase 5: 收尾准备

**目标**: 为后续 verify / closeout 阶段准备最终证据和退役检查。

- [x] T012 [Closeout] 汇总变更证据
  - scope: 主仓变更文件、diff 摘要、dry run 记录
  - maps_to: Verify Strategy / FR-003 / FR-007
  - verify: 有可提供给 `sdd_reviewer` 或人工 review 的变更列表、证据摘要和剩余风险。
  - result: `verification-dry-run.md` 已汇总目标文件、命令证据和执行期风险。

- [x] T013 [Closeout] 检查是否需要退役旧逻辑或旧描述
  - scope: 主仓旧 closeout 描述、旧 acceptance 模板段落、重复或冲突规则
  - maps_to: US2 / FR-006 / prior-closure-failure
  - verify: 明确哪些旧描述被替换、哪些保留、保留原因是什么。
  - result: 旧的“closeout 输出完整完成记录”语义被替换为“命中 trait 时写 `acceptance.md`，对话只摘要”；保留 roadmap closeout 逻辑。

---

## 依赖与顺序

- T001 和 T002 是关键路径，必须先完成。
- T003、T004、T005 可在 T002 后顺序执行，避免模板和 trait 语义不一致。
- T006、T007、T008 依赖 T003 和 T004 的产物语义。
- T009、T010、T011 依赖阶段规则和模板更新完成。
- T012、T013 依赖全部实现和 dry run 结果。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1：生成中文验收记录 | T003 / T004 / T006 / T007 / T009 |
| US2：强化 closeout completion record | T003 / T007 / T008 / T013 |
| US3：保持阶段边界和迁移边界 | T001 / T002 / T012 |
| FR-001 - FR-007 | T003 / T004 / T006 / T007 / T008 / T009 |
| FR-008 / FR-011 | T005 / T011 |
| FR-009 | T004 / T010 |
| FR-010 | T001 / T002 |

| 架构决策 / 质量属性 | 对应任务 | 验证任务 |
|----------------------|----------|----------|
| ADR-001：命中 trait 时 `acceptance.md` 默认落盘 | T004 / T007 | T009 / T010 |
| ADR-002：completion record 归入 `acceptance.md` | T003 / T007 / T008 | T009 / T011 |
| ADR-003：知识同步不绑定工具 | T003 / T008 | T009 / T011 |
| 可追溯性 | T003 / T006 / T007 | T009 / T011 |
| 轻量性 | T004 / T010 | T010 |
| 中文质量 | T005 | T011 |

---

## Stage Readiness

- 推荐下一步：`verify`
- 阻塞项（如有）：无。T001-T013 已执行，需进入 `verify` 聚合 fresh evidence。
