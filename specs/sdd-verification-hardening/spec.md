# Feature Specification: SDD Verification Hardening

**Workspace**: `sdd-verification-hardening`
**Created**: 2026-05-28
**Status**: Draft
**Input**: 用户描述: "评估并优化 SDD skill,让它在适用场景下从'组件已实现'判定升级到'端到端闭环已验证',防止再次把'模块存在'误判为'端到端生产闭环完成'"

> 上游 PRD 上下文：`docs/sdd-verification-hardening-context.md`

---

## Feature Traits *(LM 自动检测,用户可 override)*

| Trait | 是否命中 | 依据 |
|---|---|---|
| `multi-stage-workflow` | ✅ | 改动涉及 specify / plan / tasks / verify / closeout 多阶段协同 |
| `external-side-effects` | ❌ | 仅修改 SDD skill 本体的模板与阶段说明,无 publish/deploy 副作用 |
| `artifact-handoff` | ✅ | spec → plan → tasks → verify → closeout 之间存在 traits、matrix、evidence 等 artifact 传递 |
| `user-visible-output` | ✅ | 最终用户可见结果是 SDD 流程行为变化(模板提示、检查项、verdict 区分) |
| `prior-closure-failure` | ✅ | 上游 PRD 明确引用 `wechat-agent-capability-parity` 闭环断裂事故 |

**结论**: 该 feature 自身就是本次强化规则的第一个适用对象。后续 plan / tasks / verify / closeout 必须自我应用对应规则,作为 dogfooding 证据。

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Feature Traits 检测与下游传播 (Priority: P1)

作为 SDD skill 的使用者,我希望 spec 阶段能自动检测 feature 是否触发强化规则的 traits,并显式写入 spec.md 的 `Feature Traits` 段,以便下游 plan/tasks/verify/closeout 阶段无需重新判断,只根据 traits 决定哪些强化规则生效。

**Why this priority**: 这是其余所有强化规则的入口。没有 traits,就要么所有 feature 都被迫走重型流程(违反非目标),要么所有 feature 都靠人记得开启(回到原失败模式)。

**Acceptance Scenarios**:

1. **[US1-1] 多阶段 workflow feature 自动命中**
   **Given** 用户描述涉及 publish / deploy / writeback / 多阶段 artifact 传递
   **When** LM 进入 specify 阶段并写 spec.md
   **Then** spec.md 顶部生成 `## Feature Traits` 段,至少标注命中的 traits、依据,并在结论中说明本 feature 适用哪些强化规则

2. **[US1-2] 小改动 feature 不命中任何 trait**
   **Given** 用户请求是文案修改、配置调整或单点 bugfix
   **When** LM 写 spec.md
   **Then** `Feature Traits` 段所有 trait 标记为 ❌,结论明确说明"本 feature 不触发强化规则,后续阶段按基础流程推进"

3. **[US1-3] 用户 override 检测结果**
   **Given** spec.md 中 LM 把某个 trait 标记为 ✅
   **When** 用户手动改为 ❌ 并给出理由
   **Then** 后续 plan / tasks / verify / closeout 阶段必须以用户最终标注为准,不得自行重新检测

**Edge Cases**:

- **[US1-4]** spec.md 中 `Feature Traits` 段缺失时,plan 阶段必须先回退要求补充,而不是默认全开或全关
- **[US1-5]** 用户在 spec 已稳定后才发现 trait 漏标,应允许在 plan / tasks 阶段补标,但需在 spec.md 中留下 amendment 记录

---

### User Story 2 - Plan 阶段 Producer-Consumer Matrix (Priority: P1)

作为 SDD skill 的使用者,当 feature 命中 `multi-stage-workflow` 或 `artifact-handoff` trait 时,我希望 plan.md 必须包含 Producer-Consumer Matrix,列出每个 artifact 的生产者、消费者和消费证据,以便在设计阶段就识别出"产物没有消费者"的闭环断点。

**Why this priority**: 这是上游 PRD 描述的核心失败模式("manifest 生成了但封面没有 prepend")的直接对策。设计阶段没识别出来的断点,实现阶段不会自己冒出来。

**Acceptance Scenarios**:

1. **[US2-1] 命中 trait 时强制生成 matrix**
   **Given** spec.md 中 `artifact-handoff` 或 `multi-stage-workflow` trait 命中
   **When** LM 进入 plan 阶段写 plan.md
   **Then** plan.md 必须包含 `## Producer-Consumer Matrix` 段,每行至少四列:Producer / Artifact / Consumer / Consumption Proof

2. **[US2-2] 发现孤儿 artifact**
   **Given** matrix 中某个 artifact 找不到 consumer
   **When** 用户或 LM 检查 matrix
   **Then** 该 artifact 必须被标记为"中间能力"或"待消费",plan 必须显式说明它是预留还是实际待补,不允许默认通过

3. **[US2-3] matrix 与 architecture-quality-gate 并列**
   **Given** feature 同时触发 architecture-quality-gate 和 producer-consumer matrix
   **When** plan.md 生成
   **Then** 两者作为 plan.md 中独立的兄弟段落各自存在,不合并、不互相覆盖

**Edge Cases**:

- **[US2-4]** 单阶段 feature 不强制要求 matrix,允许在 plan.md 中以一句话说明"无跨阶段 artifact"代替
- **[US2-5]** 同一个 artifact 有多个 consumer 时必须各列一行,Consumption Proof 各自独立

---

### User Story 3 - Verify 阶段 Evidence Gate (Priority: P1)

作为 SDD skill 的使用者,当 feature 命中 `user-visible-output` 或 `external-side-effects` trait 时,我希望 verify 阶段必须对每条 P0/P1 requirement 提供 evidence(证据 + 来源),并按 PASS / PARTIAL / FAIL 逐条判定,以便区分"测试通过"和"需求满足"。

**Why this priority**: 这是把"组件 PASS"和"workflow PASS"分开的核心机制。没有逐条 evidence 表,verify 阶段的 verdict 就只是总结,不是判定。

**Acceptance Scenarios**:

1. **[US3-1] Evidence 表完整覆盖 P0/P1 requirement**
   **Given** spec.md 中存在 P0/P1 优先级的 requirement,且 trait 命中
   **When** LM 进入 verify 阶段
   **Then** verify 输出或 acceptance.md 必须包含 evidence 表,每行至少四列:Requirement / Evidence / Test or File / Verdict,且每条 P0/P1 requirement 都有对应行

2. **[US3-2] Evidence 不足时不得判 PASS**
   **Given** 某条 requirement 只有"测试存在"作为 evidence,但缺少行为级或产物级证据
   **When** verify 输出 verdict
   **Then** 该行 Verdict 必须为 PARTIAL,且 verify 阶段总 verdict 不得为 PASS

3. **[US3-3] Evidence 来源明确**
   **Given** evidence 列填写
   **When** 检查任意一行
   **Then** Evidence 列必须能定位到具体测试名、文件路径、捕获的 payload 或 fixture,不得只写"已实现"或"测试通过"

**Edge Cases**:

- **[US3-4]** 不命中 trait 的 feature 不强制要求 evidence 表,但 verify 仍需保留现有 fresh evidence 要求
- **[US3-5]** 用户故意接受 PARTIAL 作为最终结果时,verify 必须显式记录"用户接受 PARTIAL"和理由,不能静默通过

---

### User Story 4 - Closeout 阶段 Workflow Replay (Priority: P2)

作为 SDD skill 的使用者,当 feature 命中 `multi-stage-workflow` 且 `user-visible-output` 时,我希望 closeout 阶段必须执行一次 workflow replay(代表性输入 + mock 外部服务 + 捕获最终 payload + 断言用户可见结果),以便最终确认端到端闭环。

**Why this priority**: P1 的 evidence gate 已经能挡住大部分误判,replay 是最后一道兜底。先把 P1 做扎实再加 P2。

**Acceptance Scenarios**:

1. **[US4-1] 命中双 trait 时强制 replay**
   **Given** feature 同时命中 `multi-stage-workflow` 和 `user-visible-output`
   **When** verify 通过进入 closeout
   **Then** closeout checklist 必须新增一项 "workflow replay",且必须执行后才能宣布 feature 完成

2. **[US4-2] Replay 结果纳入 acceptance**
   **Given** replay 已执行
   **When** 写最终 completion record
   **Then** acceptance.md 必须包含 replay 的输入摘要、捕获的最终 payload 摘要、对用户可见结果的断言结论

**Edge Cases**:

- **[US4-3]** 真实 replay 不可行(依赖真实第三方服务且无法 mock)时,允许以 fixture replay 替代,但必须在 closeout 中显式说明"无法做真实 replay"和原因

---

### User Story 5 - Acceptance 三维 Verdict (Priority: P2)

作为 SDD skill 的使用者,我希望 acceptance.md 显式区分 Component capability / Workflow closure / User-visible outcome 三个维度的 verdict,以便事后回顾时不会把局部 PASS 当作整体 PASS。

**Why this priority**: 这是给历史复盘留证据的机制。即使 evidence gate 判定为 PASS,三维拆分能让"哪部分 PASS、哪部分 PARTIAL"在文档层面留下痕迹。

**Acceptance Scenarios**:

1. **[US5-1] Trait 命中时强制三维**
   **Given** feature 命中任一强化 trait
   **When** 写 acceptance.md
   **Then** 必须显式给出 Component / Workflow / User-Visible Outcome 三个维度的 verdict,不允许只写一个总 PASS

2. **[US5-2] 三维 verdict 不一致时显式说明**
   **Given** 三个维度中至少一个为 PARTIAL/FAIL
   **When** 输出 acceptance
   **Then** acceptance.md 必须显式说明为何允许在某些维度未完全通过的情况下宣布 feature 收尾(或承认 feature 未真正完成)

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: SDD skill 必须在 specify 阶段自动检测以下 5 个 traits 并以表格形式写入 spec.md:`multi-stage-workflow` / `external-side-effects` / `artifact-handoff` / `user-visible-output` / `prior-closure-failure`
- **FR-002**: traits 检测结果必须支持用户 override,override 后下游阶段以用户标注为准
- **FR-003**: 当 `multi-stage-workflow` 或 `artifact-handoff` 命中时,plan.md 必须包含 Producer-Consumer Matrix 段,列出 Producer / Artifact / Consumer / Consumption Proof
- **FR-004**: 当 `user-visible-output` 或 `external-side-effects` 命中时,verify 阶段必须对每条 P0/P1 requirement 输出 evidence 表,按 PASS / PARTIAL / FAIL 逐条判定
- **FR-005**: 当 `multi-stage-workflow` 且 `user-visible-output` 同时命中时,closeout checklist 必须执行 workflow replay 项
- **FR-006**: 当任一强化 trait 命中时,acceptance.md 必须区分 Component capability / Workflow closure / User-visible outcome 三个维度的 verdict
- **FR-007**: 所有强化规则采用"默认开启 + 显式跳过需记录原因"模式,与 plan 阶段"跳过候选方案讨论"的现有先例保持一致
- **FR-008**: 不命中任何强化 trait 的小改动 feature 必须能按现有基础流程推进,不被强制走重型流程

### Non-Functional Requirements

- **NFR-001**: 强化规则必须以模板段落 + 阶段说明双层落地。模板提供文档结构,阶段说明提供触发判断,两者解耦,任一可单独演进
- **NFR-002**: 强化规则不得增加 specify / plan / tasks / verify / closeout 之外的新阶段
- **NFR-003**: 现有已完成的 feature 不要求回填,仅对新启动的 feature 生效

### Quality Attributes

| 属性 | 目标 | 为什么重要 | 验收 / 证据 | 是否阻塞 plan |
|------|------|------------|-------------|----------------|
| 可演进性 | 模板与阶段说明可独立修改,不互相耦合 | SDD skill 已有 5 个阶段,任一阶段细则修改都不应触发整个 skill 重写 | plan 阶段需说明模板与阶段说明的责任划分 | 是 |
| 一致性 | 相同 traits 在 specify / plan / tasks / verify / closeout 产生一致的强化规则 | 不一致会让用户在不同阶段看到矛盾要求 | tasks 阶段为每个 trait 设计跨阶段 contract test | 是 |
| 成本 | 不命中 trait 的小改动总开销不超过现有基础流程 | 上游 PRD 明确非目标:不要求所有小修小改走重型流程 | verify 阶段以一个 minimal feature 走通流程做 dogfooding | 是 |
| 可读性 | 增加的所有模板段落必须有自我说明,用户不必查阅外部文档即可填写 | 模板是用户接触最多的界面,可读性差等于规则不存在 | tasks 中包含模板段落的样例填写 | 否 |

### Key Entities

- **Feature Trait**: 一个布尔标签,用于描述 feature 是否触发某类强化规则。包含名称、是否命中、依据。5 个枚举值已在 traits 表中列出
- **Producer-Consumer Matrix**: plan.md 中的表格,描述跨阶段 artifact 流。包含 Producer / Artifact / Consumer / Consumption Proof 四列
- **Evidence Row**: verify / acceptance 中的一行证据,描述某条 requirement 的 evidence 来源和判定。包含 Requirement / Evidence / Test or File / Verdict 四列
- **Three-Dimensional Verdict**: acceptance.md 中区分 Component / Workflow / User-Visible Outcome 三个维度的判定结果

---

## Out of Scope *(if applicable)*

- 历史已完成 feature 的 acceptance 回填(包括 `wechat-agent-capability-parity` 等已结项的)
- 重写或合并现有 architecture-quality-gate(本次仅做并列扩展)
- 替代人工最终判断(LM 检测 traits 后,用户 override 始终具有最高优先级)
- 引入新的 SDD 阶段(本次仅强化现有 5 个阶段)
- 强制要求所有 feature 必须命中至少一个 trait

---

## Unclear Questions *(if applicable)*

- **UQ-001**: traits 检测的实现位置 — 是写入 specify.md 的执行步骤,还是单独抽出一个 reference 文件供各阶段引用? 留给 plan 决定
- **UQ-002**: Evidence 表与现有 verify.md 的 "fresh evidence" 描述如何融合 — 是替换还是增强? 留给 plan 决定
- **UQ-003**: 是否需要为 traits 检测提供一个独立的 sub-skill 或 prompt 片段以保证一致性,还是仅在 specify.md 中以自然语言描述检测规则? 留给 plan 决定

---

## Stage Readiness

- 下一步建议:`plan`(剩余歧义不阻塞方案设计,均为实现位置选择)
- 阻塞项:无
- Self-application 提示:本 feature 自身命中 4/5 traits,plan 阶段必须自我应用 Producer-Consumer Matrix(spec → plan → tasks → verify → closeout 的 artifact 流就是第一个 matrix 实例)
