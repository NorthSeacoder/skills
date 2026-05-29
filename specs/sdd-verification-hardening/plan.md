# Implementation Plan: SDD Verification Hardening

**Workspace**: `sdd-verification-hardening` | **Date**: 2026-05-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/sdd-verification-hardening/spec.md`

---

## Summary

在 SDD skill 中引入 Feature Traits 机制，让 specify 阶段显式标注 feature 特征，下游阶段据此决定是否启用 Producer-Consumer Matrix、Evidence Gate 和 Workflow Replay 等强化规则。采用"1 个新 reference + 模板段落就地定义格式"的方式落地，保持 skill 可维护性。

---

## Architecture Overview

```text
spec-template.md          ──→  spec.md (含 Feature Traits 段)
                                    │
references/feature-traits.md ◄──────┘ (traits 定义 + 触发规则)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              plan-template.md  verify.md    closeout.md
              (含 Matrix 段)   (含 Evidence   (含 Replay
                                Gate 条件)    条件)
                    │               │               │
                    ▼               ▼               ▼
              plan.md          verify 输出    acceptance.md
              (含 Matrix)      (含 Evidence   (含三维 Verdict)
                                表)
```

核心数据流：`Feature Traits → 各阶段条件判断 → 对应模板段落生效`

---

## Producer-Consumer Matrix *(self-application)*

本 feature 自身命中 `artifact-handoff` trait，以下是自己的 artifact 流：

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| specify.md | Feature Traits 段 | plan.md / verify.md / closeout.md | 各阶段根据 traits 决定是否启用强化规则 |
| feature-traits.md | traits 定义 + 触发规则 | specify.md (检测时引用) | spec.md 中 traits 表的依据列引用了定义 |
| plan-template.md | Matrix 段落格式 | plan.md | plan.md 中出现完整 matrix 表 |
| acceptance-template.md | 三维 Verdict 格式 | acceptance.md | acceptance.md 中出现 Component/Workflow/User-Visible 三行 |
| verify.md | Evidence Gate 条件 | verify 输出 | verify 输出中出现逐条 evidence 表 |
| closeout.md | Replay 条件 | closeout 执行 | closeout 中出现 replay 结论 |

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可演进性 | 新增 trait 只改 1 个文件 | traits 定义集中在 feature-traits.md | 模拟加第 6 个 trait，确认只需改 feature-traits.md + spec-template.md |
| 一致性 | 同一 trait 在所有阶段产生相同行为 | 各阶段引用同一 reference 而非各自定义 | 用本 feature 自身走通全流程做 dogfooding |
| 成本 | 不命中 trait 的 feature 零额外开销 | 所有强化段落标记为"按需"，不命中时不生成 | 用一个 minimal feature 走 specify→plan 确认无额外段落 |
| 可维护性 | 总新增文件 ≤ 2，单文件 ≤ 80 行 | 格式定义就地放在模板里，不单独成文件 | 交付时检查文件数和行数 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: traits 载体 | 需要一个地方集中定义 traits 和触发规则 | A: 嵌入 specify.md / B: 集中 reference / C: 独立 reference 并列 quality-gate | C 精简版：1 个 reference 文件 | 多一个文件要维护，但 ≤80 行 | 本次讨论确认 |
| ADR-002: matrix 和 evidence 格式位置 | 格式定义需要有归属 | A: 各自独立 reference / B: 嵌入模板 | B: 嵌入模板（plan-template + acceptance-template） | 格式和触发条件分离在两处 | 可维护性优先 |
| ADR-003: 强制级别 | 需要决定默认开还是默认关 | A: 默认关 + opt-in / B: 默认开 + opt-out | B: 默认开 + 显式跳过需记录原因 | 小改动需要多写一句"不适用" | 本次讨论确认，沿用 plan.md 跳过先例 |

---

## Key Design Decisions

### Decision 1: 新增文件清单与职责

只新增 2 个文件，其余全部是对现有文件的 patch：

| 文件 | 类型 | 职责 | 预估行数 |
|------|------|------|----------|
| `references/feature-traits.md` | 新增 reference | 定义 5 个 traits、检测规则、各 trait 触发什么、跳过条件 | 60-80 行 |
| `templates/acceptance-template.md` | 新增 template | 定义 evidence 表格式 + 三维 verdict 格式 | 40-50 行 |

### Decision 2: 现有文件 patch 清单

| 文件 | 改动 | 预估增量 |
|------|------|----------|
| `templates/spec-template.md` | 新增 `## Feature Traits` 可选段 | +15 行 |
| `templates/plan-template.md` | 新增 `## Producer-Consumer Matrix` 可选段 | +15 行 |
| `references/stages/specify.md` | 执行步骤中新增 traits 检测步骤，引用 feature-traits.md | +5 行 |
| `references/stages/plan.md` | 执行步骤中新增 matrix 条件，引用 feature-traits.md | +5 行 |
| `references/stages/verify.md` | 执行步骤中新增 evidence gate 条件 | +5 行 |
| `references/stages/closeout.md` | checklist 新增 replay 条件项 | +3 行 |

### Decision 3: feature-traits.md 内部结构

```text
# Feature Traits

## 定义
(5 个 traits 的名称、含义、检测信号)

## 触发规则
(每个 trait 命中后，哪些阶段的哪些规则生效)

## 跳过条件
(什么时候可以跳过，跳过时需要记录什么)
```

保持单文件、三段式、无嵌套引用。LM 读一次就能知道所有规则。

### Decision 4: 与 architecture-quality-gate.md 的关系

- 并列兄弟，不合并
- quality-gate 关注"架构选择对不对"，feature-traits 关注"闭环验证够不够"
- 两者可以同时触发（一个 feature 既有架构选择又有 artifact 传递）
- plan.md 中两者各自独立段落，互不覆盖

---

## Module Design

### Module: references/feature-traits.md

**职责**: 定义 traits 枚举、检测信号和触发规则的单一真相源

**关键行为**:

```text
Traits 枚举:
- multi-stage-workflow: feature 涉及 2+ 阶段协同或 pipeline
- external-side-effects: 涉及 publish/deploy/writeback/发送等不可逆副作用
- artifact-handoff: 一个阶段的产物被另一个阶段消费
- user-visible-output: 最终结果是用户可见内容（UI/文档/通知等）
- prior-closure-failure: 该 feature 或同类 feature 有过"模块有但闭环断"的历史

触发规则:
- multi-stage-workflow OR artifact-handoff → plan 必须含 Producer-Consumer Matrix
- user-visible-output OR external-side-effects → verify 必须含 Evidence Gate
- multi-stage-workflow AND user-visible-output → closeout 必须含 Workflow Replay
- 任一 trait 命中 → acceptance 必须含三维 Verdict
```

**注意事项**:

- 检测信号是给 LM 的启发式提示，不是精确算法
- 用户 override 优先级高于 LM 检测

### Module: templates/acceptance-template.md

**职责**: 提供 evidence 表和三维 verdict 的文档格式

**关键行为**:

```text
## Evidence Table (when traits triggered)

| Requirement | Evidence | Test/File | Verdict |
|---|---|---|---|
| [P0/P1 requirement] | [具体证据] | [来源] | PASS/PARTIAL/FAIL |

## Verdict Summary

| Dimension | Verdict | Notes |
|---|---|---|
| Component capability | PASS/PARTIAL/FAIL | ... |
| Workflow closure | PASS/PARTIAL/FAIL | ... |
| User-visible outcome | PASS/PARTIAL/FAIL | ... |

**Overall**: PASS / CONDITIONAL PASS / FAIL
```

---

## Risks and Tradeoffs

- **风险 1**: LM 可能对 traits 检测不一致（同一个 feature 不同 session 判断不同）。缓解：feature-traits.md 中给出明确的检测信号列表，减少模糊空间
- **风险 2**: 用户可能觉得 Feature Traits 段是多余的仪式。缓解：不命中时只需一句"无强化 trait 命中"，成本极低
- **风险 3**: 模板段落增多后 spec-template / plan-template 变长。缓解：新增段落都标记 `*(if applicable)*`，不命中时不生成

---

## Verification Strategy

1. **Self-application（dogfooding）**: 本 feature 自身走完 specify → plan → tasks → verify → closeout，每个阶段自我应用对应规则
2. **Minimal feature 对照**: 用一个不命中任何 trait 的小改动走 specify → plan，确认无额外段落被强制生成
3. **新增 trait 模拟**: 假设要加第 6 个 trait，确认只需改 feature-traits.md + spec-template.md 两个文件

---

## Execution Governance

- **Checkpoint**: 每完成一个文件的修改，检查是否与 feature-traits.md 中的触发规则一致
- **Drift 检测**: 如果实现时发现某个阶段的条件判断与 feature-traits.md 不一致，以 feature-traits.md 为准并修正阶段文件
- **验证收口**: 所有文件修改完成后，用本 feature 自身的 spec.md 中的 traits 表做一次端到端 trace，确认每个 trait 都能正确触发对应规则

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要，无实体/状态/存储变化
- 下一步建议：`tasks`
- 阻塞项：无
