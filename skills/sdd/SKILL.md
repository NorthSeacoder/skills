---
name: sdd
description: 单入口的软件交付工作流 skill。覆盖 ideate、specify、clarify、plan、tasks、implement、code-review、execute-plan 的阶段判断、产物约定与下一步衔接。
---

# SDD

你是单入口的 SDD workflow skill。

你的职责不是把所有阶段规则都塞进一个文件，而是根据当前输入判断最合适的阶段，调用对应的阶段说明，并维持统一的工作区约定。

如果当前运行环境支持 subagent，并且当前阶段适合并行探索、方案挑战、文档核验或交付审查，应优先使用本 skill 配套的 `sdd_*` subagents，避免把所有读工作堆在主线程。

## 何时使用

适用于：

- 用户明确提到 `sdd`
- 用户希望从模糊想法推进到规格、方案、任务、实现或审查
- 当前工作已经在 `specs/<feature>/` 流程中，需要继续下一阶段

通常不必使用：

- 极小改动
- 独立且低风险的单点修复
- 明确只想做非 SDD 类工作

## 工作区约定

所有正式产物默认写入：

- `specs/<feature>/spec.md`：核心必备，定义需求、场景、范围与验收语义
- `specs/<feature>/plan.md`：核心必备，定义实现方案、模块边界、风险与验证路径
- `specs/<feature>/tasks.md`：核心必备，定义可执行任务、依赖顺序与验证点
- `specs/<feature>/data-model.md`：按需，仅在实体、状态、关系或存储变化需要单独展开时创建
- `specs/<feature>/acceptance.md`：按需，通常在实现完成后用于记录最终验收结论

当前 active feature 记录在：

- `specs/.active`

`specs/.active` 的语义：

- 表示默认续接的 feature 名称
- 当用户没有显式指定 feature 时，优先据此恢复上下文
- 若它指向的产物不存在、与用户当前目标明显不符，或发现内容失配，应显式说明失配并回退到“重新确认 feature / 上游阶段 / 更新 `.active`”之一
- 在新建 `spec.md` 或显式切换 feature 后，应同步更新 `specs/.active`

## Subagent 约定

本 skill 在 Codex 和 Claude Code 中都支持配套 subagents。职责分工固定如下：

- `sdd_explorer` / `sdd-explorer`：只读探索代码库和现状
- `sdd_reviewer` / `sdd-reviewer`：交付前审查
- `sdd_docs_researcher` / `sdd-docs-researcher`：查官方文档和版本行为

使用原则：

- 主线程保留用户澄清、最终决策、写入产物和结果整合
- subagent 只返回压缩后的事实、风险、建议，不回灌长日志
- 读多写少的阶段优先派发 subagent
- 写操作和最终合并留给主线程

安装方式：

- `skills.sh` 只安装 `sdd` skill 本体
- subagents 需要在 skill 安装后再单独安装到 Codex / Claude Code runtime 目录
- skill 包内自带 `scripts/install-sdd-subagents.sh` 和 `scripts/check-installed-sdd-subagents.sh`
- 默认安装目标是用户级 runtime；如需项目级 runtime，可用 `--scope project`

## 前置检查

进入阶段路由之前，先执行一次 subagent 可用性检查：

1. 检测当前运行环境的 agents 目录下是否存在 `.sdd-agents-manifest`
   - Claude Code: `~/.claude/agents/.sdd-agents-manifest`（user scope）或 `.claude/agents/.sdd-agents-manifest`（project scope）
   - Codex: `~/.codex/agents/.sdd-agents-manifest`（user scope）或 `.codex/agents/.sdd-agents-manifest`（project scope）
2. 若 manifest 存在，对比其中各 agent 版本与 skill 包内 `agents/source/*.yaml` 的 version 字段
3. 根据对比结果：
   - 全部匹配或 ahead：正常进入阶段路由，subagent 可用
   - 存在 STALE 或 MISSING：提示用户可运行 `bash <skill-path>/scripts/install-sdd-subagents.sh` 更新，但不阻塞流程
   - manifest 不存在：提示 subagent 未安装，退回单线程模式，不阻塞

此检查是 LM 层面的指令判断，不是 shell 执行。目的是让主线程在派发 subagent 前知道是否可用，避免派发后才发现缺失。

## 阶段路由

根据当前输入判断进入哪一阶段：

1. **需求模糊、还在探索**
   - 进入 `references/stages/ideate.md`
2. **需求已清晰，需要固化 spec**
   - 进入 `references/stages/specify.md`
3. **spec 已有，但存在关键歧义**
   - 进入 `references/stages/clarify.md`
4. **spec 已稳定，需要技术方案**
   - 进入 `references/stages/plan.md`
5. **plan 已稳定，需要拆执行任务**
   - 进入 `references/stages/tasks.md`
6. **tasks 已明确，需要推进实现**
   - 进入 `references/stages/execute-plan.md` 决定节奏
   - 再进入 `references/stages/implement.md`
7. **实现已完成，需要交付前检查**
   - 进入 `references/stages/code-review.md`

## 委派模板

进入适合并行的阶段时，应明确写出要派发的 agents、等待策略和回传格式。

探索 + 文档核验（specify / plan 阶段）：

```text
请并行派发 sdd_explorer 和 sdd_docs_researcher。
sdd_explorer 负责梳理当前代码路径和现状，sdd_docs_researcher 负责核对官方文档和版本行为。
等两个 subagent 都返回后，只保留压缩结论，不要回灌原始日志。
```

交付审查（code-review 阶段）：

```text
请派发 sdd_reviewer 对本次变更做交付前审查。
输入：变更文件列表和 diff 摘要。
输出：按 CRITICAL/HIGH/MEDIUM/LOW 分级的发现列表 + 最终 Verdict。
```

Claude Code 中使用连字符版本（`sdd-explorer`、`sdd-docs-researcher`、`sdd-reviewer`）。
如果前置检查发现 subagent 未安装或版本过旧，退回单线程流程，不阻塞。

## 路由原则

- 先判断用户当前所处阶段，再进入对应材料
- 不要要求用户记住旧子 skill 名称
- 每一阶段结束时，都要明确下一步推荐
- 如果发现上游产物不足，应返回上游阶段，而不是硬推进
- `sdd` 只负责软件交付流程，不负责统一路由 `debug`、`git-guard`、`knowledge-management` 等其他 skill
- 对明显不适合走完整 SDD 流程的小改动，应明确说明不进入完整工作区流程，而不是勉强套阶段

## 模板与资产

工作区模板统一位于：

- `templates/spec-template.md`
- `templates/checklist-template.md`
- `templates/plan-template.md`
- `templates/data-model-template.md`
- `templates/tasks-template.md`

阶段细则统一位于：

- `references/stages/*.md`

## 输出要求

每次进入某一阶段后，输出至少要说明：

1. 当前进入的是哪个阶段
2. 当前依据是什么
3. 本阶段将产出或更新什么
4. 本阶段结束后的下一步建议

如果发现上游产物不足或 `specs/.active` 失配，还必须补充：

5. 为什么需要回退或切换
6. 建议回到哪个阶段或更新哪个工作区文件
