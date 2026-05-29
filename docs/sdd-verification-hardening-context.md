# SDD Verification Hardening Context

**Target Repo**: `/Users/yqg/personal/personal-skills`  
**Target Skill**: `skills/sdd`  
**Status**: Context for future SDD flow  
**Purpose**: 给后续 agent 提供上下文，用 SDD 流程确认如何优化 `sdd` skill，防止后续再次把“组件存在”误判为“端到端生产闭环完成”。

## 1. 背景

在 `content-orchestrator-agent` 的公众号能力建设中，之前的 SDD feature `wechat-agent-capability-parity` 把多个能力标记为完成：

- Image Manifest
- Image Provider
- Image Policy
- Publish Lifecycle
- Frontmatter generation/writeback

但一次真实工作流对比发现，最终 YouMind 文档仍然缺图片：

- manifest 生成了，但封面没有 prepend 到 body；
- inline image 有规划，但没有插入 Markdown；
- provider upload 接口存在，但 workflow 未稳定调用并消费；
- FrontmatterWriter 只写发布元数据，不写 cover 相关字段。

这说明原 SDD 流程允许“内部组件能力完成”通过验收，却没有强制验证“最终用户可见产物完成”。

## 2. 失败模式

### 2.1 Tasks 粒度偏模块，不偏产物闭环

历史任务中有类似内容：

- Define ImageManifest builder and provider interface
- Implement provider fallback chain
- Add imagePolicy check before publish
- Implement FrontmatterWriter

这些任务都能通过单元测试，但不必然证明：

- manifest 被下游消费；
- publish payload 使用 transformed markdown；
- frontmatter 包含最终图片 URL。

### 2.2 Acceptance 证据不足

历史 acceptance 里 “PASS” 的证据主要来自：

- 测试文件存在；
- 单元测试通过；
- 组件能力有实现。

缺少逐条 requirement 的 evidence 表：

| Requirement | Evidence | Test/File | Verdict |
|---|---|---|---|
| 最终发布正文包含封面 | captured publish markdown starts with image | integration test | PASS |

没有这种 evidence 时，容易把 PARTIAL 误判为 PASS。

### 2.3 缺少 Producer-Consumer 检查

多阶段 workflow 中，SDD 没有强制检查 artifact 是否被下游实际消费。

失败链路示例：

```text
image-prep produces manifest
publish checks manifest policy
publish publishes original draft
```

应该被要求证明：

```text
manifest -> image insertion -> transformed draft -> publish payload
```

## 3. 优化目标

后续应优化 `skills/sdd`，让它在适用场景下主动要求：

1. 用户故事写明最终用户可见结果。
2. plan 写清 producer-consumer artifact matrix。
3. tasks 包含端到端 contract tests。
4. verify 阶段要求 evidence，而不是只看测试通过。
5. closeout 阶段要求真实 workflow replay 或 fixture replay。

## 4. 建议需求

这些是后续 SDD feature 的输入，不是最终实现方案。

### R1: Spec 阶段增加 User-Visible Outcome 提示

当 feature 涉及用户可见产物、发布结果、工作流输出时，`sdd` 应提醒 agent 在 user story 中写清最终可观察结果。

例子：

- 弱：系统生成 image manifest。
- 强：YouMind 文档顶部显示封面图，正文至少显示一张 inline image。

### R2: Plan 阶段增加 Producer-Consumer Matrix

当 feature 涉及多阶段 workflow 或 artifact 传递时，`plan.md` 应要求列出：

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| image-prep | ImageManifest | image-insertion/publish | publish payload contains image markdown |

如果 artifact 没有 consumer，只能算中间能力，不能算闭环。

### R3: Tasks 阶段要求 End-to-End Contract Task

如果 feature 涉及生产链路，tasks 应至少包含：

- producer-consumer contract test；
- final artifact snapshot test；
- workflow-level integration test，可 mock 外部服务。

### R4: Verify 阶段增加 Evidence Gate

`verify` 不应只总结“测试通过”。应对 P0/P1 requirement 逐项给 evidence：

| Requirement | Evidence | File/Test | Verdict |
|---|---|---|---|
| publish uses transformed markdown | mock publish adapter captured transformed draft | test name | PASS |

如果 evidence 不足，verdict 应是 PARTIAL 或 FAIL。

### R5: Closeout 阶段增加 Workflow Replay

对 workflow 类 feature，closeout 应要求：

- 使用代表性输入；
- mock external services；
- 捕获最终 payload / final artifact；
- 对用户可见结果做断言。

### R6: Acceptance 文档区分 Component PASS 与 Workflow PASS

`acceptance.md` 应避免只写总 PASS。建议区分：

- Component capability: PASS/PARTIAL/FAIL
- Workflow closure: PASS/PARTIAL/FAIL
- User-visible outcome: PASS/PARTIAL/FAIL

## 5. 非目标

- 不要求所有小修小改都走重型 evidence gate。
- 不要求 SDD 永远生成很长模板。
- 不要求替代人工判断。
- 不要求一次性改完所有历史 specs。

## 6. 触发条件建议

后续实现时可考虑只在以下场景启用这些强化规则：

- feature 涉及多阶段 workflow；
- feature 涉及 publish/deploy/writeback 等副作用；
- feature 涉及 artifact 从一个阶段传到另一个阶段；
- feature 的最终结果是用户可见内容；
- feature 之前出现过“模块有但闭环断”的复盘。

## 7. References

- `content-orchestrator-agent/specs/wechat-agent-capability-parity/spec.md`
- `content-orchestrator-agent/specs/wechat-agent-capability-parity/plan.md`
- `content-orchestrator-agent/specs/wechat-agent-capability-parity/tasks.md`
- `content-orchestrator-agent/specs/wechat-agent-capability-parity/acceptance.md`
- `content-orchestrator-agent/specs/image-publication-closure/prd.md`
- `personal-skills/skills/sdd/SKILL.md`
- `personal-skills/skills/sdd/references/stages/specify.md`
- `personal-skills/skills/sdd/references/stages/plan.md`
- `personal-skills/skills/sdd/references/stages/tasks.md`
- `personal-skills/skills/sdd/references/stages/verify.md`
- `personal-skills/skills/sdd/references/stages/closeout.md`

## 8. Notes for Future Agent

后续不要直接修改 `sdd` skill。请先用 SDD 为 `personal-skills` 新开 feature，例如：

```text
sdd-verification-hardening
```

先确认 scope，再写 spec/plan/tasks。本文档只提供上下文和需求素材。
