# Tasks: Migrate Repository To Skills.sh Distribution

**Workspace**: `migrate-to-skills-sh-distribution` | **Date**: 2026-05-16  
**Input**: `specs/migrate-to-skills-sh-distribution/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须), data-model.md (按需)

---

## 执行原则

- 任务按依赖顺序组织，先收敛结构，再迁移内容，最后清理和验证
- 任务描述必须能直接落地到具体目录、文档或模板
- 核心用户故事、迁移边界和验证任务必须都有承接
- 不在 `tasks.md` 重复讨论方案，只定义执行单元

---

## Phase 1: 建立 `sdd` 新骨架

**目标**: 先把新的公开 skill 入口和内部资产目录搭起来，作为后续迁移承载点。

- [ ] T001 [US2] 新建 `skills/sdd/` 基础目录与占位资产结构
  - scope: `skills/sdd/`, `skills/sdd/references/stages/`, `skills/sdd/templates/`, `skills/sdd/examples/`
  - verify: 仓库中出现计划定义的 `sdd` 目标目录结构，且不再依赖旧子 skill 路径作为唯一来源

- [ ] T002 [US2] 编写 `skills/sdd/SKILL.md` 的单入口协议
  - scope: `skills/sdd/SKILL.md`
  - verify: `SKILL.md` 能说明何时触发 `sdd`、如何判断阶段、当前会产出什么、以及如何提示下一步

- [ ] T003 [US2] 评估并收编 `ideate` 为 `sdd` 的可选前置阶段
  - scope: `skills/ideate/`, `skills/sdd/references/stages/ideate.md`
  - verify: `ideate` 若保留，其定位被明确为 `sdd` 内部可选阶段，而非独立 installable skill

---

## Phase 2: 迁移 SDD 阶段说明与模板

**目标**: 把旧 SDD skill 的可复用内容安全迁移到 `sdd` 内部，完成方法论与模板收口。

- [ ] T004 [US2] 迁移阶段方法论到 `skills/sdd/references/stages/`
  - scope: `skills/specify/`, `skills/clarify/`, `skills/plan/`, `skills/tasks/`, `skills/implement/`, `skills/code-review/`, `skills/execute-plan/` → `skills/sdd/references/stages/`
  - verify: 每个主阶段在 `references/stages/` 都有对应文档，且职责边界与旧 skill 一致或更清晰

- [ ] T005 [US2] 迁移并统一所有工作区模板到 `skills/sdd/templates/`
  - scope: 旧 `spec-template.md`, `plan-template.md`, `tasks-template.md` 及其他 SDD 模板 → `skills/sdd/templates/`
  - verify: 所有会写入工作区的模板都集中在 `templates/`，无重复来源或继续分散维护的旧模板

- [ ] T006 [US2] 清理 `sdd` 中阶段说明与模板之间的引用关系
  - scope: `skills/sdd/SKILL.md`, `skills/sdd/references/stages/*`, `skills/sdd/templates/*`
  - verify: 入口、阶段说明、模板三层之间引用清晰，没有把模板正文堆回 `SKILL.md`

---

## Phase 3: 重写公开文档与仓库规则

**目标**: 让仓库对外叙事与新架构保持一致，用户能直接理解安装和使用方式。

- [ ] T007 [US1] 重写 `README.md` 为 `skills.sh` 分发模型
  - scope: `README.md`
  - verify: README 包含 badge、仓库安装方式、单 skill 安装示例、`sdd` 使用方式、配置约定、致谢，且不再主推本地软链接发布

- [ ] T008 [US1] 更新仓库规范文档以匹配新架构
  - scope: `AGENTS.md`, `docs/architecture.md`, `docs/maintenance.md`
  - verify: 文档统一描述 `skills.sh` 模型，不再把 `registry`、`publish-links` 或运行时目录当作主流程

- [ ] T009 [US3] 为公开 skill 补充配置约定说明
  - scope: `README.md`, `skills/sdd/` 下相关说明文件，按需新增 `.env.example` 或等价文档
  - verify: 用户能看懂配置是 skill 级约定，变量命名有前缀，且文档未误导为 `skills.sh` 平台自动能力

---

## Phase 4: 清理旧资产并收敛公开边界

**目标**: 删除与新模型冲突的旧发布资产，收束 installable skill 边界。

- [ ] T010 [US1] 删除 `registry` 和旧发布脚本
  - scope: `registry/skills.yaml`, `scripts/publish-links.sh`, `scripts/unpublish-links.sh`, `scripts/list-conflicts.sh`
  - verify: 仓库主路径中不再存在旧发布模型的核心实现文件

- [ ] T011 [US2] 下线旧 SDD 子 skill 的独立安装形态
  - scope: `skills/specify/`, `skills/clarify/`, `skills/plan/`, `skills/tasks/`, `skills/implement/`, `skills/code-review/`, `skills/execute-plan/`, `skills/ideate/`
  - verify: 仓库不再把这些目录当作公开 installable skill；若暂时保留目录，也已明确为迁移材料而非公开入口

- [ ] T012 [US2] 明确 `knowledge-management` 的公开状态
  - scope: `skills/knowledge-management/`, `README.md`
  - verify: 若暂不公开，README 不宣传其可直接安装；若决定公开，则必须补齐前置依赖和可移植性说明

---

## Phase 5: 一致性检查与收尾验证

**目标**: 确保仓库结构、文档和 skill 入口叙事一致，减少后续实现返工。

- [ ] T013 [US1] 对照 `spec` 与 `plan` 做结构和文档一致性检查
  - scope: `README.md`, `AGENTS.md`, `docs/*`, `skills/sdd/`, 仓库目录树
  - verify: installable skill、目录结构、使用方式、配置约定四者无冲突

- [ ] T014 [US1][US2][US3] 补充迁移后的验证记录或验收说明
  - scope: 当前 workspace 下的交付说明，按需补 `acceptance` 相关材料
  - verify: 记录本次迁移至少完成了哪些验证，哪些联网安装验证仍待后续环境执行

---

## 依赖与顺序

- `T001-T003` 是关键前置，先决定 `sdd` 骨架和入口模型。
- `T004-T006` 依赖 `Phase 1`，因为阶段文档和模板必须迁入既定目录结构。
- `T007-T009` 依赖 `Phase 2`，因为 README 和文档需要基于最终 `sdd` 结构描述。
- `T010-T012` 应在文档基本完成后执行，避免删掉旧资产后失去迁移参照。
- `T013-T014` 是最后收尾与验收阶段。
- 关键路径：`T001 → T002 → T004 → T005 → T007 → T010 → T011 → T013`

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1-1 仓库主模型迁移到 `skills.sh` | T007, T008, T010, T013 |
| US1-2 README 清晰说明安装与前置条件 | T007, T009, T013 |
| US2-1 SDD 收敛为单一 `sdd` | T001, T002, T004, T011 |
| US2-2 `knowledge-management` 不阻塞主迁移 | T012 |
| US2-5 `sdd` 单入口使用方式 | T002, T006 |
| US3-1 / US3-2 skill 级配置约定 | T009, T013 |
| 清理旧模型避免误导 | T008, T010, T011 |

---

## Notes

- 如果在迁移模板时发现旧 skill 中还有未纳入计划的重要产物，应先补到 `sdd/templates/`，不要继续保留双来源。
- `knowledge-management` 的处理以“不阻塞主迁移”为原则；没有完成可移植性清理前，不要把它写进公开安装说明。
- 若后续需要真实运行 `npx skills add ...` 做联网验证，应在实现后另行执行，不把它作为当前离线拆任务的前置条件。
