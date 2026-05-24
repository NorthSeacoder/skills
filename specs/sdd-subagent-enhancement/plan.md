# Implementation Plan: SDD Subagent Enhancement

**Workspace**: `sdd-subagent-enhancement` | **Date**: 2026-05-23 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-subagent-enhancement/spec.md`

---

## Summary

收敛 sdd subagent 集合（4 -> 3），建立 YAML 单源 + 派生脚本消除双格式漂移，并在安装流程中引入版本标记和自检机制，使 subagent 的安装、更新和校验对用户透明。

---

## Architecture Overview

改动涉及三层：

1. **源定义层** (`skills/sdd/agents/source/*.yaml`)
   - 每个 subagent 一份 YAML 源文件，包含 prompt、model、tools、version 等全部元数据
   - 这是唯一需要手工编辑的位置

2. **派生层** (`skills/sdd/agents/claude-code/*.md`, `skills/sdd/agents/codex/*.toml`)
   - 由派生脚本从 source/ 自动生成
   - 文件头部带生成标记和版本号，禁止手工修改

3. **安装与自检层** (`skills/sdd/scripts/`)
   - install 脚本：从派生层复制到 runtime 目录，带版本比较
   - SKILL.md 前置检查：激活时检测已安装版本，提示更新命令

数据流：

```text
source/*.yaml
  -> generate-agents.sh -> claude-code/*.md + codex/*.toml (带版本头)
  -> install-sdd-subagents.sh -> ~/.claude/agents/ + ~/.codex/agents/ (带版本比较)
  -> sdd SKILL.md 自检 -> 检测版本匹配 -> 正常路由 / 提示更新
```

---

## Key Design Decisions

### Decision 1: 单源格式选 YAML

- **背景**: 需要存储多行 prompt 文本和结构化元数据，且派生目标是两种不同格式
- **选项**:
  - A: YAML — `|` 块标量天然支持多行文本，bash 中可用 yq 或简单 sed/awk 解析
  - B: TOML — 与 Codex 原生格式一致，但多行字符串语法笨拙，Claude Code 端仍需转换
- **结论**: 选 A (YAML)
- **影响**: 派生脚本需要 `yq` 作为依赖（macOS 可通过 brew 安装），或退化为纯 bash 解析简单 YAML
- **来源**: UNVERIFIED

### Decision 2: 移除 sdd-planner，保留 3 个 subagent

- **背景**: planner 与主线程 plan 阶段职责重叠，派出去再回灌"压缩结论"反而割裂连续上下文
- **选项**:
  - A: 保留 planner 但限制为"方案挑战者"角色 — 仍有双层规划风险
  - B: 移除 planner，plan 阶段由主线程完成 — 简化，且 plan 阶段本来就需要与 spec/clarify 连续对话
- **结论**: 选 B
- **影响**: 减少一个 agent 的维护面；如果未来需要"方案挑战"，可作为 reviewer 的可选模式
- **来源**: UNVERIFIED

### Decision 3: 版本标记用 ISO 日期 (YYYY-MM-DD)

- **背景**: 需要简单的版本比较机制，不引入外部工具
- **选项**:
  - A: semver (1.0.0) — 语义清晰但对文档型资产过重，需要手动 bump
  - B: ISO 日期 (2026-05-23) — 自然排序，派生时自动取当前日期，无需手动管理
- **结论**: 选 B
- **影响**: 版本比较退化为字符串比较（ISO 日期天然支持）；同一天多次修改视为同版本
- **来源**: UNVERIFIED

### Decision 4: 自检逻辑作为 SKILL.md 的"前置检查"小节

- **背景**: 需要在阶段路由前确认 runtime 就绪
- **选项**:
  - A: 放在"Subagent 约定"小节内 — 混淆描述性内容和运行时行为
  - B: 独立为"前置检查"小节，位于阶段路由之前 — 语义清晰：先检查环境，再路由阶段
- **结论**: 选 B
- **影响**: SKILL.md 新增一个小节，位于"工作区约定"之后、"阶段路由"之前
- **来源**: UNVERIFIED

### Decision 5: model 映射硬编码在派生脚本中

- **背景**: Claude Code 和 Codex 使用不同的模型标识符
- **选项**:
  - A: 外部配置文件 — 灵活但过度设计
  - B: 脚本内 case 语句 — 当前只有 haiku/sonnet 两个映射，极简
- **结论**: 选 B
- **影响**: 新增模型时需改脚本，但频率极低
- **来源**: UNVERIFIED

---

## Module Design

### Module: 单源定义 (agents/source/)

**职责**: 作为所有 subagent 元数据的唯一真相

**改动概述**: 新建 `skills/sdd/agents/source/` 目录，每个 subagent 一份 YAML 文件

**关键接口 / 行为**:

```yaml
# agents/source/sdd-explorer.yaml
name: sdd-explorer
version: "2026-05-23"
description: Read-only SDD explorer for mapping code paths and current behavior.
model: haiku
tools:
  claude-code: [Read, Glob, Grep, Agent]
  codex: []  # codex 不需要显式声明
permission_mode: plan
prompt: |
  You are the SDD exploration agent.

  ## Task
  Gather facts about the codebase. Do not edit files.

  ## Output format
  Return a compact list:
  - One line per finding: `file:line — one-sentence summary`
  - Group by theme (data flow, dependencies, risks)
  - Max 30 lines total
  - End with "Open questions:" section if any

  ## Prohibited
  - Do not return raw code blocks
  - Do not expand into implementation suggestions
  - Do not exceed 30 lines
```

**注意事项**:

- `tools` 字段按目标平台分列，因为 Claude Code 和 Codex 的工具声明方式不同
- `model` 使用通用名（haiku/sonnet），派生时映射为平台特定标识符
- `version` 由派生脚本在生成时自动更新为当前日期

### Module: 派生脚本 (scripts/generate-agents.sh)

**职责**: 从 source/*.yaml 生成 claude-code/*.md 和 codex/*.toml

**改动概述**: 新建脚本，读取 YAML 源文件，输出两种格式的派生文件

**关键接口 / 行为**:

```text
输入: agents/source/*.yaml
输出: agents/claude-code/*.md, agents/codex/*.toml

每个派生文件头部包含:
  # AUTO-GENERATED from source/sdd-explorer.yaml — DO NOT EDIT
  # version: 2026-05-23

Claude Code .md 格式:
  ---
  name: sdd-explorer
  description: ...
  tools: Read, Glob, Grep, Agent
  model: haiku
  permissionMode: plan
  ---
  [prompt content]

Codex .toml 格式:
  # AUTO-GENERATED from source/sdd-explorer.yaml — DO NOT EDIT
  # version: 2026-05-23
  name = "sdd_explorer"
  description = "..."
  model = "gpt-5.4-mini"
  model_reasoning_effort = "medium"
  sandbox_mode = "read-only"
  developer_instructions = """..."""
```

**注意事项**:

- 脚本依赖 `yq`（YAML 解析）；如果 yq 不可用，报错退出并提示安装
- model 映射: haiku -> gpt-5.4-mini (effort: medium), sonnet -> gpt-5.5 (effort: high)
- Codex 的 name 用下划线（sdd_explorer），Claude Code 用连字符（sdd-explorer）
- 幂等：源未变化时输出不变（通过比较内容而非时间戳）

### Module: 安装脚本改造 (scripts/install-sdd-subagents.sh)

**职责**: 将派生文件安装到 runtime 目录，带版本比较

**改动概述**: 重写现有安装脚本，增加版本检测和防降级逻辑

**关键接口 / 行为**:

```text
install-sdd-subagents.sh [codex|claude-code|all] [--scope user|project] [--project-dir DIR] [--force]

流程:
1. 确定源目录 (skill 内的 agents/claude-code/ 或 agents/codex/)
2. 确定目标目录 (根据 scope)
3. 对每个文件:
   a. 读取源文件版本头 (# version: YYYY-MM-DD)
   b. 读取目标文件版本头 (如存在)
   c. 如果目标版本 > 源版本 且无 --force: 跳过并警告
   d. 如果目标版本 <= 源版本 或 --force: 复制并报告
4. 写入/更新 .sdd-agents-manifest (JSON: {agent: version} 映射)
```

**注意事项**:

- manifest 文件用于自检时快速判断版本，不依赖逐文件解析
- --force 覆盖时在 stderr 输出警告
- 不删除目标目录中非 sdd 前缀的文件

### Module: 自检逻辑 (SKILL.md 前置检查)

**职责**: sdd 激活时检测 subagent 安装状态和版本

**改动概述**: 在 SKILL.md 的"阶段路由"之前新增"前置检查"小节

**关键接口 / 行为**:

```text
## 前置检查

在进入阶段路由前，检查当前环境的 subagent 状态：

1. 检测当前 runtime 类型 (Claude Code / Codex)
2. 查找对应 runtime 目录下的 .sdd-agents-manifest
3. 如果 manifest 不存在或版本落后于 skill 内的源版本:
   - 输出: "sdd subagents 需要安装/更新，运行: bash <skill-path>/scripts/install-sdd-subagents.sh all"
   - 不阻塞主流程，退回单线程模式继续
4. 如果版本匹配: 正常启用 subagent 派发
```

**注意事项**:

- 自检是建议性的，不阻塞 sdd 核心流程
- 检测逻辑写在 SKILL.md 中作为指令，由 LLM 在激活时执行（不是 shell 脚本）
- 需要在 SKILL.md 中明确 skill 自身路径的获取方式

### Module: Subagent prompt 补强

**职责**: 让每个 subagent 的输出可控、可压缩

**改动概述**: 在 source/*.yaml 的 prompt 中明确输入/输出约定

**关键接口 / 行为**:

```text
每个 subagent prompt 必须包含:
1. ## Task — 一句话职责
2. ## Output format — 明确格式、行数上限、分组方式
3. ## Prohibited — 明确禁止行为（防止输出膨胀）

explorer:
  - 输出: file:line + 一句概括，按主题分组，max 30 行
  - 禁止: 原始代码块、实现建议

reviewer:
  - 输出: severity + file:line + 问题描述，按严重度排序，max 20 条
  - 禁止: 风格建议、重构建议（除非隐藏真实 bug）

docs-researcher:
  - 输出: 事实 + 来源链接，max 15 行
  - 禁止: 推测性结论、无来源的断言
```

### Module: 阶段文档补充"建议派发"

**职责**: 让主线程在每个阶段知道何时、如何派发 subagent

**改动概述**: 在 `references/stages/` 的 plan.md、specify.md、code-review.md 中补充"Subagent 派发"小节

**关键接口 / 行为**:

```text
## Subagent 派发（如已安装）

- 派发: sdd-explorer
- 输入: "梳理 <scope> 的代码路径、依赖和现有行为"
- 期望输出: 压缩事实列表
- 等待策略: 等返回后再开始方案设计
```

---

## Project Structure

```text
skills/sdd/
├── SKILL.md                          # 新增"前置检查"小节
├── agents/
│   ├── source/                       # 新增：单源定义
│   │   ├── sdd-explorer.yaml
│   │   ├── sdd-reviewer.yaml
│   │   └── sdd-docs-researcher.yaml
│   ├── claude-code/                  # 派生产物（自动生成）
│   │   ├── sdd-explorer.md
│   │   ├── sdd-reviewer.md
│   │   └── sdd-docs-researcher.md
│   └── codex/                        # 派生产物（自动生成）
│       ├── sdd-explorer.toml
│       ├── sdd-reviewer.toml
│       └── sdd-docs-researcher.toml
├── scripts/
│   ├── generate-agents.sh            # 新增：派生脚本
│   ├── install-sdd-subagents.sh      # 重写：带版本比较
│   └── check-installed-sdd-subagents.sh  # 更新：适配新版本机制
├── references/stages/
│   ├── plan.md                       # 补充"Subagent 派发"小节
│   ├── specify.md                    # 补充"Subagent 派发"小节
│   └── code-review.md               # 补充"Subagent 派发"小节
└── templates/
```

---

## Risks and Tradeoffs

- **yq 依赖**: 派生脚本依赖 yq，用户机器可能未安装。缓解：脚本开头检测并给出安装提示；或退化为纯 bash 解析（牺牲健壮性）
- **自检是 LLM 指令而非硬编码**: 依赖 LLM 遵循 SKILL.md 中的检查指令，不保证 100% 执行。缓解：措辞明确为"必须"而非"建议"
- **同一天多次修改版本号不变**: ISO 日期粒度为天。缓解：对于同一天的修改，派生脚本可追加 `-N` 后缀（如 2026-05-23-2），但初期不实现，等出现实际问题再加
- **移除 planner 后 plan 阶段质量**: 主线程独自承担方案推演。缓解：plan 阶段仍可派发 explorer 做只读探索，方案本身由主线程基于探索结果完成

---

## Verification Strategy

1. **派生正确性**: 修改 source/*.yaml 后运行 generate-agents.sh，diff 输出与预期一致
2. **安装版本控制**: 模拟"目标已有更新版本"场景，确认脚本拒绝降级
3. **自检触发**: 在 Claude Code 中激活 sdd，确认缺失 subagent 时输出安装提示
4. **subagent 输出质量**: 在真实 feature 中派发 explorer 和 reviewer，确认输出符合格式约定
5. **幂等性**: 连续两次运行 generate-agents.sh，git diff 为空
6. **回归**: 现有 check-installed-sdd-subagents.sh 仍能正确校验

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要，实体已在 spec 和 plan 中覆盖
- 下一步建议：`tasks`
- 阻塞项：无

---

## Design Artifacts

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 不需要 | 实体简单，已在 plan 内覆盖 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | 用于最终验收结论 |

---

## Notes

- sdd-planner 的派生文件在实现时需要从 claude-code/ 和 codex/ 中删除
- 现有 README 中的 subagent 安装说明需要同步更新
- generate-agents.sh 应在 CI 中作为 verify 的一部分运行（确认派生文件与源一致）

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| YAML 单源格式 | UNVERIFIED | 基于多行文本处理便利性 |
| 移除 planner | UNVERIFIED | 基于职责重叠分析 |
| ISO 日期版本 | UNVERIFIED | 基于简单性原则 |
| model 映射硬编码 | UNVERIFIED | 基于当前规模判断 |
