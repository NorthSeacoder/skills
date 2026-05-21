# Tasks: Evolve personal-skills Repository And Harden SDD

**Workspace**: `evolve-personal-skills-and-sdd` | **Date**: 2026-05-21  
**Input**: `specs/evolve-personal-skills-and-sdd/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (按需)

**Note**: 此任务清单面向当前仓库演进，目标是让后续实现可直接按块推进，并保留局部验证点。

---

## 执行原则

- 任务按依赖顺序组织，先收敛叙事与边界，再收敛 `sdd` 资产，最后补结构校验
- 每个任务都必须能独立验证，不把 `tasks.md` 重新写成方案说明
- 所有关键需求都要能映射回 README/docs、`sdd` 阶段规则、模板或校验入口中的实际改动
- 如果实现中发现任务无法直接落地，应回退更新 `plan.md`，而不是硬做

---

## Phase 1: 收敛仓库叙事与公开边界

**目标**: 让维护者和使用者能从仓库根文档快速理解公开 skill、自用 skill、`sdd` 主流程与治理文档之间的边界。

- [x] T001 [US1] 统一 README 中的公开 skill、自用 skill、安装方式与仓库结构叙事
  - scope: `README.md`
  - verify: README 能清楚说明 `sdd` 是主公开 skill，其他 skill 为自用维护；安装说明与当前目录结构一致

- [x] T002 [US1] 补强治理文档对源码层、分发层、`sdd` 内部资产层的解释，并统一维护边界表述
  - scope: `docs/architecture.md`, `docs/maintenance.md`, `docs/adoption-policy.md`
  - verify: 三份文档对“公开/自用/治理资产”的定义一致，不再混淆目录位置与公开承诺

- [x] T003 [US1] 校准仓库级贡献约束，使后续修改默认遵守新的边界和结构规则
  - scope: `AGENTS.md`
  - verify: AGENTS 中对 `skills/<name>/`、`skills/sdd/` 和公开边界的说明与 README/docs 一致

---

## Phase 2: 收敛 `sdd` 单入口规则与产物模型

**目标**: 明确 `sdd` 的职责边界、阶段进入条件、回退逻辑、产物模型和 `.active` 语义。

- [x] T004 [US2] 更新 `sdd` 入口说明，明确其只负责软件交付流程，不承担其他 skill 的统一路由
  - scope: `skills/sdd/SKILL.md`
  - verify: 入口文档明确写出阶段路由原则、非适用场景、与其他 skill 的职责边界

- [x] T005 [US2] 逐个收敛阶段文档的进入条件、依赖产物、阶段产出、回退条件和下一步建议
  - scope: `skills/sdd/references/stages/ideate.md`, `specify.md`, `clarify.md`, `plan.md`, `tasks.md`, `execute-plan.md`, `implement.md`, `code-review.md`
  - verify: 每个阶段文档都能回答“何时进入、产出什么、缺什么时回退、下一步去哪”

- [x] T006 [US3] 明确 `specs/<feature>/` 核心与可选产物模型，以及 `specs/.active` 的语义和失配处理
  - scope: `skills/sdd/SKILL.md`, 必要的阶段文档，必要时补充规则型说明文件
  - verify: 文档中明确 `spec.md`/`plan.md`/`tasks.md` 的角色，说明 `data-model.md`/`acceptance.md` 的按需条件，并说明 `.active` 如何更新和恢复

- [x] T007 [US3] 校准模板，使模板字段与新的 `sdd` 叙事一致，避免产物层和规则层漂移
  - scope: `skills/sdd/templates/spec-template.md`, `plan-template.md`, `tasks-template.md`, `checklist-template.md`, `data-model-template.md`
  - verify: 模板章节与阶段要求一致，可支持 `spec -> plan -> tasks` 的顺滑续接

---

## Phase 3: 补齐结构校验入口并对齐 CI

**目标**: 让仓库对关键结构漂移具备最小可执行检查，而不是只停留在文档口头约定。

- [x] T008 [US3] 设计并实现最小结构校验脚本，覆盖公开 skill 入口、`sdd` 关键资产、引用关系与 README 声明一致性
  - scope: `scripts/verify-skills.sh`，必要时新增辅助脚本或配置
  - verify: 本地运行 `bash ./scripts/verify-skills.sh` 能完成结构检查，并对缺失/漂移给出失败结果

- [x] T009 [US3] 对齐 CI workflow 与实际校验入口，消除当前 `verify.yml` 指向缺失脚本的断链
  - scope: `.github/workflows/verify.yml`, `scripts/verify-skills.sh`
  - verify: workflow 中引用的命令在仓库内真实存在，且本地可按等价命令执行

---

## Phase 4: 端到端回归与收尾

**目标**: 用当前 feature 工作区验证新约定真实可续接，并为后续实现或审查保留清晰状态。

- [x] T010 [US2] 用真实 `specs/<feature>/` 工作区验证 `sdd` 路由是否能从现有产物正确回退或推进
  - scope: `specs/.active`, `specs/evolve-personal-skills-and-sdd/`, `skills/sdd/*`
  - verify: 以当前 feature 为样本，能解释为何先进入 `plan`、再进入 `tasks`，并能支撑后续 `implement`

- [x] T011 [US1] 汇总本轮验证结果和剩余风险，为进入 `implement` 或 `code-review` 做准备
  - scope: 改动后的相关文档、脚本与必要的工作区记录
  - verify: 能列出已完成验证、未覆盖风险、以及是否满足进入下一阶段的条件

---

## 依赖与顺序

- T001-T003 先做：否则后续 `sdd` 规则和校验会缺少一致的仓库级叙事基础
- T004-T007 依赖 Phase 1 的边界表述稳定后推进，是本次实现关键路径
- T008-T009 依赖前两阶段的结构与规则基本稳定，否则校验脚本会反复返工
- T010-T011 最后做，用于验证新规则能在真实 feature 上闭环

可并行性：

- T001 与 T002 可部分并行，但最好由同一轮统一收口
- T005 与 T007 可交错推进，但模板最终应以后者统一收敛
- T008 与 T009 可在脚本入口确定后紧密连续完成

关键路径：

- T001 -> T004 -> T005 -> T006 -> T007 -> T008 -> T009 -> T010

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1-1 仓库边界清楚 | T001, T002, T003 |
| US1-2 长期维护支持 | T002, T008, T009 |
| US1-3 自用 skill 维护级别清楚 | T001, T002 |
| US1-4 治理文档不被误认为公开接口 | T001, T002 |
| US2-1 `sdd` 明确当前阶段与下一步 | T004, T005 |
| US2-2 能根据现有产物正确回退/推进 | T005, T006, T010 |
| US2-3 `sdd` 不路由其他 skill | T004 |
| US2-4 缺上游产物时回退 | T005, T010 |
| US2-5 小改动场景保持克制 | T004, T005 |
| US2-6 不以拆分 `sdd` 为目标 | T004 |
| US3-1 核心与可选产物清楚 | T006, T007 |
| US3-2 阶段内与产物校验明确 | T005, T007 |
| US3-3 结构漂移可被发现 | T008, T009 |
| US3-4 `.active` 失配处理清楚 | T006, T010 |
| US3-5 可选文档使用条件清楚 | T006, T007 |

---

## Notes

- 当前任务清单足以进入 `implement`，但实现时仍应按 Phase 分块推进，而不是一次性大改全仓。
- 若实现中确认需要新增单独规则文件承载 `.active` 或校验模型说明，可在 T006 内决定，但不应脱离 `skills/sdd/` 当前分层太远。
