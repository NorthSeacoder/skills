# personal-skills Feature Brief: 优化 `sdd` skill 与相关 subagent

## 目的

把本次参考研究沉淀为一个可直接迁移到 `~/personal/personal-skills` 的 feature 输入。

这个 feature 不是“新增一个全新的 `sdd`”，而是：

- 优化现有 `sdd` skill 的阶段设计
- 优化与 `sdd` 相关的 subagent / reviewer / executor 协作方式
- 让 `sdd` 从“spec/plan 偏前段”升级为覆盖 `clarify -> spec -> plan -> execute -> verify -> closeout` 的完整工作链

## Feature 名称

`sdd-workflow-hardening`

可选中文名：

- `sdd 工作流强化`
- `sdd 全链路优化`

## 背景

当前参考分析得到的主要结论是：

1. `agent-skills` 适合提供 `sdd` 生命周期骨架
2. `Aegis` 最适合增强 `sdd` 的执行后半段治理
3. `skills` 里的 `grill-with-docs`、`to-issues`、`tdd` 很适合补前期讨论、任务拆解和实现纪律
4. `Waza` 适合补高频入口与 review / closeout 体验
5. `gstack` 只适合选择性补 browser QA 与重验证闭环
6. `khazix-skills` 更适合补任务后知识沉淀，不适合进入 `sdd` 主干

因此，`personal-skills` 里的 `sdd` 不应再只聚焦：

- 写 spec
- 写 plan

而应升级为一条更完整的主链。

## 要解决的问题

### 问题 1：前期需求讨论与 spec 编写之间缺中间层

现在常见的问题是：

- 模糊需求直接进入 spec
- 术语、边界、已有决策没有先被压实
- spec 写得越来越正式，但误解也越来越正式

需要补的能力：

- `Clarify / Domain Alignment`

### 问题 2：plan 与 execute 之间治理不足

现在常见的问题是：

- 计划写完后，执行阶段重新漂移
- 任务粒度不稳定
- subagent 拿到整段上下文，但没有最小 handoff 协议

需要补的能力：

- 更细粒度的 task contract
- checkpoint / drift / evidence
- subagent context packet

### 问题 3：verify / closeout 太弱

现在常见的问题是：

- “写完了”被当成“完成了”
- 没有 fresh evidence 就宣布 done
- 旧逻辑继续留在主链里，但没有 retirement closure

需要补的能力：

- completion evidence gate
- review / release follow-through
- retirement / closeout

## 建议的目标形态

将 `sdd` 重构为六段式工作链：

1. `Clarify / Domain Alignment`
2. `Spec`
3. `Plan`
4. `Execute`
5. `Verify / Closeout`
6. `Post-Closeout Knowledge Sync`

其中主干阶段至少要覆盖前五段，第六段可以作为收尾增强。

## 建议吸收源

### 主骨架

来源：

- `agent-skills`

吸收内容：

- `define / plan / build / verify / review / ship` 生命周期映射
- `spec-driven-development`
- `planning-and-task-breakdown`

### 前期需求讨论

来源：

- `skills/grill-with-docs`
- `Waza/think`

吸收内容：

- 一问一答式拷打
- `CONTEXT.md` / ADR / code cross-check
- 推荐答案式澄清

### 计划与执行治理

来源：

- `Aegis/writing-plans`
- `Aegis/subagent-driven-development`

吸收内容：

- plan 粒度下沉
- checkpoint / drift / evidence
- fresh subagent per task
- 双阶段 review

### 实现纪律

来源：

- `skills/tdd`
- `skills/to-issues`

吸收内容：

- integration-style TDD
- vertical slice 拆解

### 验证与收尾

来源：

- `Aegis/verification-before-completion`
- `Waza/check`
- `gstack` 的 browser QA 思路

吸收内容：

- evidence card
- browser/runtime verification
- release follow-through
- retirement closure

## Feature 范围

### In Scope

- 优化 `sdd` skill 的阶段模型
- 明确 `Clarify / Domain Alignment` 在 `sdd` 主链中的位置
- 明确 `Spec` 与 `Plan` 的边界
- 优化 `Execute` 阶段与相关 subagent 的协作协议
- 增强 `Verify / Closeout`
- 定义哪些能力由主 skill 负责，哪些由 subagent 负责
- 形成新的路由、references、reviewer prompt 或 subagent prompt 设计

### Out of Scope

- 直接引入 `gstack` 式重平台编排
- 整套复制 `Aegis` 的 workspace / artifact schema
- 重写整个 `personal-skills` 仓的所有 skill
- 先行实现完整 memory / knowledge 系统改造

## 建议的设计原则

### 原则 1：先补链路，再补重量

优先保证：

- 链路完整
- 阶段清晰
- 验证收口

不要一开始就引入过多治理术语和重 artifact。

### 原则 2：把 `grill-with-docs` 前移

不要把前期需求讨论直接简化成“写 spec”。

应该先有：

- `Clarify / Domain Alignment`

再进入：

- `Spec Authoring`

### 原则 3：subagent 要最小任务包，不要继承整段上下文

controller 与 implementer 的边界要更清楚：

- controller 持有主链状态
- implementer 接收最小任务包
- reviewer 负责 spec / quality gate

### 原则 4：没有 fresh evidence，不算完成

`Verify / Closeout` 必须从“礼貌收尾”升级为真正 gate。

### 原则 5：默认检查旧逻辑退役

bugfix、refactor、contract change 都应检查：

- old path 是否仍然悬挂
- fallback 是否应保留
- 删除触发条件是什么

## 建议的实施顺序

### Phase 1

- 重写 `sdd` 总体阶段定义
- 补 `Clarify / Domain Alignment`
- 明确 `Spec` / `Plan` / `Execute` / `Verify` / `Closeout` 的职责

### Phase 2

- 优化 `sdd` 相关 subagent 结构
- 增加 implementer / reviewer 边界
- 增加 task packet / checkpoint / drift 的轻量协议

### Phase 3

- 强化 verify / closeout
- 增加 evidence gate
- 增加 retirement closure

### Phase 4

- 视情况补 browser QA
- 视情况补 post-closeout knowledge sync

## 进入主仓后建议先产出的产物

到 `~/personal/personal-skills` 后，建议按 `sdd` 流程先产出：

1. 一份 spec
   - 主题：`sdd-workflow-hardening`
2. 一份 implementation plan
3. 一组与 `sdd` 相关的 skill / subagent 调整任务

## 迁移说明

本文件是参考研究工作区产出的 feature 输入。

它的作用是：

- 作为 `~/personal/personal-skills` 中下一轮 `sdd` 流程的起点

它不是：

- 主仓中的最终 spec
- 主仓中的最终 plan
- 主仓中的实现结果

