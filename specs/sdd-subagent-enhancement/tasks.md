# Tasks: SDD Subagent Enhancement

**Workspace**: `sdd-subagent-enhancement` | **Date**: 2026-05-23  
**Input**: `specs/sdd-subagent-enhancement/spec.md` + `plan.md`  
**Prerequisites**: spec.md (必须), plan.md (必须)

---

## 执行原则

- 先建立单源定义和派生流程，再改造安装与自检
- 派生层文件被视为产物，每次源变化后重新生成
- 每个任务结束后必须能局部验证（diff/运行/对比）
- 移除 planner 的清理动作必须与新 agent 安装对齐，避免出现"旧文件残留"

---

## Phase 1: 建立单源定义与派生层

**目标**: 让 3 个 subagent 有唯一的 YAML 源，并能派生出 .md 与 .toml 两种格式

- [ ] T001 [US3] 设计单源 YAML schema 并写出 3 份初始源文件
  - scope: `skills/sdd/agents/source/sdd-explorer.yaml`, `sdd-reviewer.yaml`, `sdd-docs-researcher.yaml`
  - verify: 3 份 YAML 通过 `yq '.' file.yaml` 校验，包含 name/version/description/model/tools/permission_mode/prompt 全部字段

- [ ] T002 [US1] 在 source/*.yaml 的 prompt 字段中补强输入/输出/禁止规则
  - scope: 同 T001 的 3 份 YAML 的 prompt 字段
  - verify: 每份 prompt 至少包含 ## Task / ## Output format / ## Prohibited 三个小节，explorer 限 30 行、reviewer 限 20 条、docs-researcher 限 15 行

- [ ] T003 [US1] 修复 sdd-docs-researcher 的工具列表，加入 WebFetch、WebSearch
  - scope: `skills/sdd/agents/source/sdd-docs-researcher.yaml`
  - verify: tools.claude-code 包含 WebFetch、WebSearch；source 里能查到这两个工具名

- [ ] T004 [US3] 实现派生脚本 generate-agents.sh，支持 YAML -> .md/.toml
  - scope: `skills/sdd/scripts/generate-agents.sh`
  - verify: 运行后 `agents/claude-code/*.md` 与 `agents/codex/*.toml` 全部生成；文件头含 AUTO-GENERATED 标记和 version 行

- [ ] T005 [US3] 在派生脚本中实现 model 名称映射 (haiku/sonnet -> Codex 模型名)
  - scope: 同 T004
  - verify: explorer/docs-researcher 的 .toml 输出 `model = "gpt-5.4-mini"`、effort=medium；reviewer 的 .toml 输出 `model = "gpt-5.5"`、effort=high

- [ ] T006 [US3] 验证派生脚本的幂等性
  - scope: 同 T004
  - verify: 连续运行两次 generate-agents.sh，`git diff agents/claude-code agents/codex` 为空

- [ ] T007 [US1] 删除 sdd-planner 的派生文件与（如有）source 残留
  - scope: `skills/sdd/agents/claude-code/sdd-planner.md`, `skills/sdd/agents/codex/sdd-planner.toml`
  - verify: 仓库内不再存在任何 sdd-planner 相关文件；生成脚本不再为它输出

---

## Phase 2: 改造安装与版本控制

**目标**: 安装脚本支持版本比较、防降级，并写入 manifest 供自检使用

- [ ] T008 [US2] 重写 install-sdd-subagents.sh，按版本头比较后再复制
  - scope: `skills/sdd/scripts/install-sdd-subagents.sh`
  - verify: 模拟"目标已存在更新版本"场景执行脚本，输出"skip: target newer"且文件未被覆盖

- [ ] T009 [US4] 在安装脚本中增加 --force 参数，强制覆盖并 stderr 提示
  - scope: 同 T008
  - verify: 同样目标场景下加 `--force` 后文件被覆盖，stderr 出现警告

- [ ] T010 [US2] 安装时写入或更新 manifest 文件（{agent: version} JSON）
  - scope: 同 T008，新增 `~/.claude/agents/.sdd-agents-manifest` / `~/.codex/agents/.sdd-agents-manifest`
  - verify: 安装后 manifest 存在；包含 explorer/reviewer/docs-researcher 三项；版本与 source 中一致

- [ ] T011 [US2] 更新 check-installed-sdd-subagents.sh 兼容 manifest，并校验版本
  - scope: `skills/sdd/scripts/check-installed-sdd-subagents.sh`
  - verify: 安装最新版后 check 全 OK；手动改 manifest 中某项版本为旧值后 check 报告 STALE

---

## Phase 3: 接入自检与阶段文档

**目标**: sdd 激活时主动检查 subagent 状态；plan/specify/code-review 三个阶段补"建议派发"

- [ ] T012 [US2] 在 SKILL.md 阶段路由前新增"前置检查"小节，描述自检流程
  - scope: `skills/sdd/SKILL.md`
  - verify: SKILL.md 含"前置检查"独立小节；包含检测 manifest、对比版本、提示安装命令、不阻塞退回单线程的明确表述

- [ ] T013 [US1] 在 references/stages/specify.md 中补充"Subagent 派发"小节
  - scope: `skills/sdd/references/stages/specify.md`
  - verify: 文件含 Subagent 派发小节，明确 explorer 的输入与期望输出格式

- [ ] T014 [US1] 在 references/stages/plan.md 中补充"Subagent 派发"小节
  - scope: `skills/sdd/references/stages/plan.md`
  - verify: 文件含 Subagent 派发小节，覆盖 explorer 与 docs-researcher 的派发场景

- [ ] T015 [US1] 在 references/stages/code-review.md 中补充"Subagent 派发"小节
  - scope: `skills/sdd/references/stages/code-review.md`
  - verify: 文件含 Subagent 派发小节，明确 reviewer 的输入与输出格式

- [ ] T016 [US1] 同步 SKILL.md 中关于 subagent 集合的描述（4 -> 3，移除 planner）
  - scope: `skills/sdd/SKILL.md` 的 "Subagent 约定" 与 "委派模板"
  - verify: 文件中不再出现 sdd_planner / sdd-planner；委派模板示例以 explorer + docs-researcher 为主

---

## Phase 4: 文档对齐与端到端回归

**目标**: README/AGENTS 与新机制一致，并以一次完整流程验证 source -> 派生 -> 安装 -> 自检 全链路

- [ ] T017 [US2] 更新 README 安装与使用说明，反映新的 subagent 集合与版本机制
  - scope: `README.md`
  - verify: README 中 subagent 列表为 3 个；安装段说明 generate + install 两步，且提及自检会在缺失时自动提示

- [ ] T018 [US3] 更新 AGENTS.md，记录 source/* 是唯一编辑入口、派生层禁止手改
  - scope: `AGENTS.md`
  - verify: AGENTS 含 "source/* 唯一真相" 与 "claude-code/、codex/ 自动生成" 两条明确约束

- [ ] T019 [US3] 把 generate-agents.sh 接入仓库的 verify 入口（CI 与本地脚本）
  - scope: `scripts/verify-skills.sh`，必要时 `.github/workflows/verify.yml`
  - verify: verify-skills.sh 中执行 generate-agents.sh --check 模式（或等价 diff），派生层与源不一致时返回非零

- [ ] T020 [US1][US2] 端到端回归：在干净环境下走一遍 source -> generate -> install -> 模拟 sdd 激活
  - scope: 全链路
  - verify: 全程无错误；删除某 agent 后激活 sdd 能输出正确的安装提示；version 不匹配时给出 STALE 提示而不降级

---

## 依赖与顺序

- T001-T002 必须先完成：源是后续一切的输入
- T003 与 T002 可并行（同一文件不同小节）
- T004-T006 是派生层关键路径，T007 可在 T004 之后任意时机执行
- T008-T011 依赖 Phase 1 已稳定，否则版本比较没有可信源
- T012 依赖 T010（manifest 已可写）才有意义
- T013-T016 与 Phase 2 互不依赖，可并行
- T017-T019 在 Phase 1-3 稳定后做，避免文档反复改
- T020 是关键收尾，必须放在最后

关键路径：

- T001 -> T004 -> T008 -> T010 -> T012 -> T020

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1-1 explorer 压缩输出 | T002 |
| US1-2 reviewer 严重度排序 | T002 |
| US1-3 docs-researcher 能查文档 | T003 |
| US1-4 缺失 subagents 不阻塞 | T012, T020 |
| US1-5 输出超长截断 | T002（输出格式约束）|
| US1-6 移除 planner 不降质 | T007, T014, T016 |
| US2-1 首次激活自动提示 | T012, T020 |
| US2-2 更新自动同步 | T008, T010, T011 |
| US2-3 scope user/project | T008 |
| US2-4 目录不存在自动创建 | T008 |
| US2-5 版本比较决定覆盖 | T008, T009 |
| US2-6 失败给出清晰错误 | T008, T011 |
| US3-1 单源派生两格式 | T001, T004, T005 |
| US3-2 派生幂等 | T006 |
| US3-3 新增 agent 自动生成 | T004 |
| US3-4 model 映射差异 | T005 |
| US3-5 检测手改派生文件 | T019（CI verify 中体现）|
| US4-1 拒绝降级 | T008 |
| US4-2 --force 覆盖 | T009 |
| US4-3 自检版本不匹配提示 | T011, T012 |
| US4-4 ISO 日期版本格式 | T001（schema 中固化）|
| US4-5 首次安装无版本 | T008 |

---

## Notes

- generate-agents.sh 依赖 yq；脚本开头需检测并报错提示安装
- 自检逻辑写在 SKILL.md 中作为 LLM 指令，本身不是 shell 脚本
- manifest 文件命名 `.sdd-agents-manifest`，前缀 `.` 避免被 runtime 当成 agent 文件加载
- 删除 sdd-planner 时连带清理 ~/.claude/agents 与 ~/.codex/agents 中的旧副本是用户机器上的事，可在 README 中说明，不强制脚本处理

---

## Stage Readiness

- 推荐下一步：`execute-plan`（任务量 20 项，分 4 个 phase，建议先编排节奏）
- 阻塞项：无
