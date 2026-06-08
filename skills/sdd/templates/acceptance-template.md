# Acceptance Record: [功能名称]

**Workspace**: `[工作区名称]` | **Date**: [日期] | **Spec**: [spec.md](spec.md)

> 当任一 Feature Trait 命中时使用本模板。详见 [`../references/feature-traits.md`](../references/feature-traits.md)。
> 不命中任何 trait，或用户显式选择轻量路径时，可省略本文件，但必须在 closeout 中用中文记录跳过原因。
> 本文件是持久 completion record；closeout 对话回复只摘要路径、verdict、阻塞项和下一步。

## 写作规则

- 使用简体中文；必要英文术语仅用于保持 SDD 阶段语义。
- 短句优先。每个结论都必须对应状态、证据或下一步。
- 不得只写“已实现”“测试通过”“review 通过”“已完成”等不可定位结论。
- PARTIAL、FAIL、阻塞、延后项必须说明缺口或恢复条件。

---

## Evidence Table

> 当 `user-visible-output` 或 `external-side-effects` 命中时必填。每条 P0/P1 requirement 必须有对应行。

| Requirement | Evidence | Test or File | Verdict |
|---|---|---|---|
| [FR-XXX 简述] | [具体证据：捕获的 payload 摘要 / 行为观察 / 文件内容片段] | [测试名 / 文件路径 / commit SHA / 日志位置] | PASS / PARTIAL / FAIL |

**Evidence 填写规范**:

- 必须能定位到具体测试名、文件路径、捕获的 payload 或 fixture
- 不得只写"已实现"、"测试通过"、"代码 review 通过"等抽象描述
- PARTIAL 的行必须说明缺什么证据才能升 PASS

---

## Verdict Summary *(三维 Verdict)*

> 当任一强化 trait 命中时必填。三维不一致时必须在最后说明。

| Dimension | Verdict | Notes |
|---|---|---|
| Component capability | PASS / PARTIAL / FAIL | [组件层面是否实现：函数、模块、接口存在且行为正确] |
| Workflow closure | PASS / PARTIAL / FAIL | [跨组件协同是否闭环：producer-consumer 链路完整] |
| User-visible outcome | PASS / PARTIAL / FAIL | [用户实际可见结果是否与 spec 对齐] |

**Overall**: PASS / CONDITIONAL PASS / FAIL

**三维不一致说明** *(任一维度非 PASS 时必填)*:

[说明为何允许在某维度未完全通过的情况下宣布收尾，或承认 feature 未真正完成。引用具体哪条 requirement / scenario 决定了该判断。]

---

## Workflow Replay *(if `multi-stage-workflow` AND `user-visible-output`)*

- **输入摘要**: [代表性输入]
- **最终 payload 摘要**: [捕获到的端到端结果]
- **用户可见结果断言**: [对照 spec 中 user-visible-output 的期望]
- **Replay 类型**: 真实 / fixture（fixture 时说明无法做真实 replay 的原因）

---

## Bugfix Closure *(if `bugfix-loop-breaker`)*

> 当 spec.md 中 `bugfix-loop-breaker` 命中时必填。轻量 bugfix 跳过完整闭环时，写 `> 跳过 bugfix-loop-breaker：[原因]`。

| Field | Value |
|---|---|
| Root Cause / Hypothesis | [已验证 root cause；未知或未完全证实时写 hypothesis] |
| Fix Mechanism | [修复如何改变行为] |
| Prevention Mechanism | [防复发机制：测试、validator、约定、文档或 follow-up] |
| Failed Attempts Summary | [失败尝试、排除假设或无失败尝试的说明] |
| Regression Guard | [测试、fixture、validator 或人工检查] |
| Diffusion Check | [同类路径 / 共享规则 / 模板 / 状态机检查结果或跳过原因] |
| Remaining Risk | [无 / 剩余风险和恢复条件] |

---

## Closeout Checklist

> 每一项必须写状态和依据。可用状态：已完成 / 延后 / 不适用 / 阻塞。
> 出现“阻塞”时，Overall 不得为 PASS，也不得宣布 feature 完成。

| Item | Status | Evidence / Rationale | Next Step |
|---|---|---|---|
| 旧逻辑、旧路径、fallback 或临时兼容退役 | 已完成 / 延后 / 不适用 / 阻塞 | [具体文件、diff 摘要、保留原因或不适用依据] | [无 / 后续触发条件 / 回退阶段] |
| 发布、提交、CI 或 follow-through | 已完成 / 延后 / 不适用 / 阻塞 | [commit / CI / 发布状态 / 不适用依据] | [无 / 待执行动作] |
| 文档、阶段说明、模板或验收记录更新 | 已完成 / 延后 / 不适用 / 阻塞 | [文件路径或不适用依据] | [无 / 待更新位置] |
| ADR、架构债或演进触发信号 | 已完成 / 延后 / 不适用 / 阻塞 | [保留的决策、债务、阈值或不适用依据] | [无 / 观察条件] |
| Knowledge Capture | 已完成 / 延后 / 不适用 / 阻塞 | [记录的条目、none 原因、redaction 或同步状态] | [无 / 后续同步或恢复条件] |

---

## Knowledge Capture

> Closeout 必填。默认只记录到本地 `acceptance.md`，不得把外部同步、hook、自动提交或 API 调用作为默认行为。
> 每条 Summary 控制在 1-3 句，必须有 Evidence。不得粘贴长日志、完整 diff、密钥、隐私、客户数据或不可公开原文。

| Type | Title | Summary | Evidence | Scope | Sync Status | Follow-up |
|---|---|---|---|---|---|---|
| decision / convention / pattern / anti-pattern / gotcha / common-mistake / follow-up / none | [短标题] | [1-3 句可复用内容；none 时写跳过原因] | [文件、测试、verify evidence 或 completion record] | [适用范围] | recorded-only / synced-by-session-memory / skipped / redacted / follow-up | [无 / 后续动作] |

**Type 规则**:

- `decision`: 影响后续实现或流程的取舍
- `convention`: 后续应遵守的约定
- `pattern`: 可复用做法
- `anti-pattern`: 明确不应采用的做法
- `gotcha`: 容易踩坑的边界
- `common-mistake`: 常见错误和预防方式
- `follow-up`: 缺证据或需后续处理，暂不作为确定知识
- `none`: 无可沉淀知识，必须写一句跳过原因

**Sync Status 规则**:

- `recorded-only`: 仅写入本地 acceptance
- `synced-by-session-memory`: 已由环境级 memory 规则另行同步
- `skipped`: 明确跳过，并给出原因
- `redacted`: 已脱敏或因敏感内容不记录原文
- `follow-up`: 后续人工或可选 lifecycle integration 处理

---

## Commit Result *(if commit planning ran)*

| Field | Value |
|---|---|
| Status | committed / not_submitted / no_related_diff / failed |
| Commit Hashes | [hash 列表，未提交时写无] |
| Commit Messages | [message 列表，未提交时写无] |
| Included Files | [已提交文件摘要，未提交时写无] |
| Excluded / Remaining Files | [未提交或剩余 dirty files 摘要] |
| Reason | [未提交、无需提交或失败原因] |

> 记录原则：提交前必须有 commit plan 和用户确认。不得把 `git add -A`、自动 push 或未确认提交作为完成依据。

---

## Completion Record

- **最终结论**: PASS / CONDITIONAL PASS / FAIL
- **完成依据**: [引用 Evidence Table、Verdict Summary、Workflow Replay 或 Closeout Checklist 中的具体证据]
- **阻塞项**: [无 / 阻塞项列表；有阻塞项时不得宣布完成]
- **延后项**: [无 / 延后项及触发条件]
- **退役结论**: [旧逻辑已退役 / 保留及原因 / 不适用]
- **提交结论**: [committed / not_submitted / no_related_diff / failed；如 committed，写 commit hash]
- **后续动作**: [无 / 下一阶段 / 后续 feature / roadmap closeout]
