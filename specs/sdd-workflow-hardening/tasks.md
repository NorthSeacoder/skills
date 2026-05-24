# Tasks: SDD Workflow Hardening

**Workspace**: `sdd-workflow-hardening` | **Date**: 2026-05-24  
**Input**: `specs/sdd-workflow-hardening/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (不需要)

---

## 执行原则

- 先重构主入口语义，再改阶段资产，最后补校验与收尾记录
- 所有任务都必须服务“吸收优点强化现有 `sdd`”，而不是引入外部仓库结构
- `Verify / Closeout` 是本次关键增量，优先级高于措辞润色
- 每个阶段完成后都要有局部验证，避免最后一次性发现主链断裂

---

## Phase 1: 重构主链入口与阶段语义

**目标**: 让 `skills/sdd/SKILL.md` 先具备新的主链视图，明确 `Clarify / Domain Alignment`、`Verify`、`Closeout` 的位置与边界

- [x] T001 [US1][US2] 重写 `skills/sdd/SKILL.md` 的阶段描述与总览文案
  - scope: `skills/sdd/SKILL.md`
  - verify: 文件中明确主链强化目标，不再把现状描述停留在旧链路；“吸收优点而非迁移”口径在总说明中可见

- [x] T002 [US1] 将现有 `clarify` 阶段在 `SKILL.md` 中重定义为 `Clarify / Domain Alignment`
  - scope: `skills/sdd/SKILL.md`
  - verify: 阶段路由与输出要求中能看出 `clarify` 不再只是补缺口，而是负责术语、边界、历史决策对齐

- [x] T003 [US2] 在 `SKILL.md` 中引入独立 `Verify` 阶段，并将 `code-review` 降为其中一个检查动作
  - scope: `skills/sdd/SKILL.md`
  - verify: 主入口不再把 `code-review` 描述为最终交付前独立顶层阶段；`Verify` 明确承载 evidence gate、review、runtime/browser 检查

- [x] T004 [US2] 在 `SKILL.md` 中加入 `Closeout` 阶段的职责和与 `Verify` 的交接关系
  - scope: `skills/sdd/SKILL.md`
  - verify: 文件中存在 `Closeout` 的进入条件、核心职责和下一步建议；不只是尾注式补充

- [x] T005 [US4] 调整 `SKILL.md` 的委派模板与路由原则，使 `tasks`、`execute-plan`、`implement` 明确退到执行支撑层
  - scope: `skills/sdd/SKILL.md`
  - verify: 文案能区分“主链阶段”和“执行支撑资产”；用户能理解为什么 `tasks` 仍存在但不与主链终态竞争

---

## Phase 2: 重组阶段文档资产

**目标**: 让阶段说明文件与新主链对齐，并新增 `Verify / Closeout` 的正式资产

- [x] T006 [US1] 重写 `skills/sdd/references/stages/clarify.md`，突出 `Domain Alignment`
  - scope: `skills/sdd/references/stages/clarify.md`
  - verify: 文档明确聚焦术语、边界、上下文冲突、既有决策对齐；不再只像“spec 补缺问答”

- [x] T007 [US2] 更新 `skills/sdd/references/stages/plan.md`，加入 execution governance 与验证路径要求
  - scope: `skills/sdd/references/stages/plan.md`
  - verify: 文档要求 plan 明确 checkpoint、drift、验证路径或等价治理语义，而不是只写模块边界

- [x] T008 [US2] 更新 `skills/sdd/references/stages/execute-plan.md`，明确节奏控制和偏移处理
  - scope: `skills/sdd/references/stages/execute-plan.md`
  - verify: 文档中有 checkpoint / drift / resume / handoff 的明确表述

- [x] T009 [US2] 更新 `skills/sdd/references/stages/implement.md`，定义最小任务包和实现期纪律
  - scope: `skills/sdd/references/stages/implement.md`
  - verify: 文档体现最小任务包、增量实现、必要验证的要求，不依赖整段上下文自由发挥

- [x] T010 [US2] 新增 `skills/sdd/references/stages/verify.md`
  - scope: `skills/sdd/references/stages/verify.md`
  - verify: 文档明确输入、检查动作、evidence gate、Verdict 语义，以及与 `Closeout` 的衔接

- [x] T011 [US2] 新增 `skills/sdd/references/stages/closeout.md`
  - scope: `skills/sdd/references/stages/closeout.md`
  - verify: 文档包含可执行 checklist，至少覆盖旧逻辑退役、发布跟进、文档更新、必要知识同步

- [x] T012 [US2] 重写或降级 `skills/sdd/references/stages/code-review.md`，使其变成 `Verify` 的检查子资产
  - scope: `skills/sdd/references/stages/code-review.md`
  - verify: 文档不再把自己描述为顶层终点阶段；明确输入输出与 `Verify` 的从属关系

---

## Phase 3: 补内建 validator 与仓库校验入口

**目标**: 防止新主链落地后继续静默漂移

- [x] T013 [US4] 新增 `skills/sdd/scripts/validate-sdd.sh`
  - scope: `skills/sdd/scripts/validate-sdd.sh`
  - verify: 脚本至少检查阶段文件存在性、关键阶段名、关键引用路径、`code-review` 是否仍被当作顶层终点

- [x] T014 [US4] 将 validator 接入仓库现有验证入口
  - scope: 仓库级 verify 脚本或 CI 配置；如有必要同时更新 `README.md`
  - verify: 运行现有验证入口时会执行 `validate-sdd.sh`；当故意制造阶段文件失配时返回非零

- [x] T015 [US4] 为 validator 补充失败场景说明，帮助维护者理解如何修复结构漂移
  - scope: `skills/sdd/scripts/validate-sdd.sh` 注释、`README.md`、或 `skills/sdd/SKILL.md`/相关文档
  - verify: 出现 drift 时，维护者能从输出或文档中知道下一步修复方向

---

## Phase 4: 收尾资产与端到端回归

**目标**: 让 `Verify / Closeout` 不只是文档存在，还能自然嵌入当前工作区约定

- [x] T016 [US2] 决定 `Closeout` checklist 与 `acceptance.md` 的关系，并补必要模板或约定
  - scope: `skills/sdd/templates/`、`skills/sdd/references/stages/closeout.md`、必要时 `SKILL.md`
  - verify: 能解释 closeout checklist 写在哪里、最终 completion record 写在哪里，两者不冲突

- [x] T017 [US2][US4] 对 `skills/sdd/` 新主链做一次端到端走读
  - scope: `skills/sdd/SKILL.md` + `references/stages/*.md` + validator
  - verify: 可以顺畅说明 `Clarify -> Spec -> Plan -> Execute -> Verify -> Closeout` 的进入条件、回退条件、交接关系

- [x] T018 [US3] 检查所有新增或修改文案是否仍保持“吸收优点”口径，而非“迁移/复刻”口径
  - scope: `skills/sdd/SKILL.md`、新旧阶段文档、必要的 README/说明文档
  - verify: 不再出现把外部 skill 当作待迁移结构的表述；参考源只作为优点来源

- [x] T019 [US2] 做一次主链完成判定回归，确认 “没有 fresh evidence 不算完成” 已成为显式 gate
  - scope: `verify.md`、`closeout.md`、`code-review.md`、`SKILL.md`
  - verify: 文档层无法再把“写完了”直接等同于“完成了”；至少存在 evidence gate 和 closeout checklist 两层收口

---

## 依赖与顺序

- T001-T005 必须先完成：主入口定义决定后续所有阶段文档的落点
- T006-T012 依赖主入口语义稳定，尤其是 `clarify`、`verify`、`closeout` 的边界
- T010-T012 是 `Verify` 重构关键路径，必须在 validator 设计前稳定下来
- T013 依赖阶段资产大体成型，否则校验规则会频繁返工
- T014-T015 依赖 T013
- T016 依赖 `closeout.md` 基本定稿
- T017-T019 放在最后，作为端到端回归与口径清理

关键路径：

- T001 -> T003 -> T010 -> T011 -> T013 -> T014 -> T017 -> T019

可并行项：

- T007/T008/T009 可在 T001-T005 后并行推进
- T015 可与 T016 并行
- T018 可在大部分文档改动接近完成时穿插执行

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 在写 spec 前完成关键澄清与领域对齐 | T002, T006, T017 |
| US2 计划、执行、验证和收尾形成连续主链 | T003, T004, T007, T008, T009, T010, T011, T012, T016, T019 |
| US3 以吸收优点方式进入现有 sdd | T001, T005, T018 |
| US4 路由和校验成为 sdd 主链基础设施 | T005, T013, T014, T015, T017 |
| FR-005 Verify evidence gate | T003, T010, T019 |
| FR-005A Closeout checklist | T004, T011, T016, T019 |
| FR-010 sdd 内建 validator | T013, T014, T015 |
| FR-011 不重做 subagent 基础设施 | T001, T018 |

---

## Notes

- 如果在重写 `SKILL.md` 时发现 `tasks`、`execute-plan`、`implement` 很难与新主链并存，应该先回到 `plan` 调整层次，而不是硬改文案
- `Verify` 和 `Closeout` 的术语必须简洁，不要引入外部仓库特有术语负担
- validator 第一版应保持足够小，重点抓住真正会导致主链漂移的结构问题

---

## Stage Readiness

- 推荐下一步：`verify` / `closeout`
- 阻塞项（如有）：无
