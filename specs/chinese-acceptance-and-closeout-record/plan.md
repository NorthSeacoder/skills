# Implementation Plan: 中文验收与收尾记录

**Workspace**: `chinese-acceptance-and-closeout-record` | **Date**: 2026-06-06 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/chinese-acceptance-and-closeout-record/spec.md`

---

## Summary

本方案把中文验收与收尾记录落到 SDD 主仓的阶段规则和模板中：`verify` 负责产出 fresh evidence 与 verdict，`closeout` 负责把验收结论、退役检查和 completion record 写入 `acceptance.md`。当前工作区只保留迁移设计，不直接改造正式 `sdd` skill。

---

## Architecture Overview

本 feature 不新增系统、存储或外部依赖，只调整 SDD 文档工作流中的产物关系。

```text
spec.md
  └─ defines Feature Traits, requirements, acceptance scenarios

verify stage
  └─ produces fresh evidence, Evidence Table draft, verdict

closeout stage
  ├─ consumes verify verdict and evidence
  ├─ runs retirement / follow-through / docs / knowledge checks
  └─ writes acceptance.md as the durable completion record

final response
  └─ summarizes acceptance.md path, verdict, blockers or next step
```

### 跳过候选方案讨论

只有一个合理方向：在主仓现有 `sdd` 阶段规则和模板上做轻量增强。原因是 spec 已明确不新增阶段、不绑定外部工具、不把参考工作区当正式实现仓；拆成新系统或新入口会扩大维护面，也会破坏现有 SDD 单入口语义。

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| `specify / clarify` | `spec.md` 中的 Feature Traits、P0/P1 scenarios、FR/NFR | `plan`、`verify`、`closeout` | `plan.md` 写入 Producer-Consumer Matrix；verify/closeout 按 trait 决定 evidence gate 和 `acceptance.md` 是否必需。 |
| `verify` | Fresh evidence、Evidence Table draft、PASS / CONDITIONAL PASS / FAIL verdict | `closeout` | closeout 只有在 verify PASS 或满足明确条件时继续；`acceptance.md` 引用具体测试、文件、日志或人工验证记录。 |
| `closeout` | Closeout Checklist 状态、retirement 结论、follow-through 状态、knowledge sync 状态 | `acceptance.md` 和最终用户回复 | `acceptance.md` 包含 Closeout Checklist 与 Overall verdict；最终回复只摘要路径、结论和阻塞项。 |
| `acceptance-template.md` | 中文验收记录结构 | closeout stage | 新生成的 `acceptance.md` 包含 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist 和 completion record。 |

**孤儿 artifact 处理**: 无孤儿 artifact。`acceptance.md` 是持久记录，最终用户回复是它的摘要，不再承载完整 completion record。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可追溯性 | 关键结论都有可定位证据 | `acceptance.md` 必须包含 Evidence Table，禁止只写抽象结论 | 示例 feature closeout 时检查每条 P0/P1 requirement 是否有证据行 |
| 可维护性 | 阶段职责和模板职责清晰 | verify 只判定证据和 verdict，closeout 负责最终记录与退役检查 | review 阶段检查是否出现重复职责或冲突说明 |
| 轻量性 | 小 feature 可以走跳过路径 | 无 trait 命中或用户显式轻量路径时，只记录跳过原因 | 使用无 trait 示例确认不强制生成完整 `acceptance.md` |
| 中文质量 | 中文短、准、可审计 | 模板应要求状态、证据、下一步，不写空泛段末总结 | 人工 review `acceptance.md` 示例是否存在套话式结论 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001：命中 trait 时 `acceptance.md` 默认落盘 | closeout 输出不可持久追溯，后续 review 难定位历史判断 | A. 只在对话中输出；B. 命中 trait 时落盘；C. 全部 feature 强制落盘 | 选择 B | 小 feature 需要额外判断跳过原因 | `spec.md` Clarified Decisions |
| ADR-002：completion record 归入 `acceptance.md` | completion record 和 Evidence Table 分散会降低审计性 | A. 写在 closeout 回复；B. 写在独立文件；C. 归入 `acceptance.md` | 选择 C | `acceptance.md` 模板需要扩展 closeout checklist | `spec.md` Clarified Decisions |
| ADR-003：知识同步不绑定工具 | 当前环境可能有 nmem、飞书或主仓文档，强绑定会降低可迁移性 | A. 固定 nmem；B. 固定飞书；C. 只记录目标和状态 | 选择 C | 需要人工判断何时同步 | `spec.md` Clarified Decisions |

---

## Key Design Decisions

### Decision 1: Verify 产出证据，Closeout 写入持久记录

- **背景**: verify 的职责是判断是否有 fresh evidence 支撑 PASS；closeout 的职责是最终 gate 和记录。
- **选项**:
  - A: verify 直接生成完整 `acceptance.md`，closeout 只总结。优点是证据靠近验证阶段；缺点是退役检查和 follow-through 尚未完成。
  - B: verify 输出证据和 verdict，closeout 消费后生成 `acceptance.md`。优点是完成记录集中；缺点是 closeout 必须拿到 verify 摘要。
- **结论**: 选择 B。
- **影响**: `verify.md` 应强调 evidence/verdict 的输出形态；`closeout.md` 应强调消费 verify 结果并写 `acceptance.md`。
- **来源**: UNVERIFIED，本仓 SDD 阶段语义。

### Decision 2: `acceptance-template.md` 扩展 Closeout Checklist

- **背景**: 现有 acceptance 模板已有 Evidence Table、三维 Verdict 和 Workflow Replay，但缺少 closeout completion record 的结构化位置。
- **选项**:
  - A: 不改模板，只让 closeout 自由追加文字。实现简单，但容易重新变成空泛总结。
  - B: 模板新增 Closeout Checklist 和 Completion Record 段。更明确，也更可审计。
- **结论**: 选择 B。
- **影响**: 后续实现应在模板中加入中文状态列：已完成 / 延后 / 不适用 / 阻塞，并要求每项有一句证据或依据。
- **来源**: `acceptance-template.md`、`closeout.md`。

### Decision 3: 保留 fast path

- **背景**: SDD 不能把极小改动都拖入完整验收记录流程。
- **选项**:
  - A: 所有 feature 都强制 `acceptance.md`。一致性强，但流程重。
  - B: 只在任一 trait 命中时默认落盘，无 trait 时允许中文跳过记录。
- **结论**: 选择 B。
- **影响**: `feature-traits.md`、`closeout.md` 和 `acceptance-template.md` 要保持同一套跳过语义。
- **来源**: `feature-traits.md`。

---

## Module Design

### Module: `verify` stage rule

**职责**: 汇总 fresh evidence，给出 PASS / CONDITIONAL PASS / FAIL。

**改动概述**: 强化 verify 输出形态，确保 closeout 能消费。verify 不负责最终 completion record，但要留下足够证据。

**关键行为**:

```text
if user-visible-output or external-side-effects:
  build Evidence Table draft for P0/P1 requirements
  mark rows PASS / PARTIAL / FAIL
  if any required row lacks evidence:
    overall verdict cannot be PASS

return verdict + evidence summary + unresolved risks
```

**注意事项**:

- Evidence 可以是测试、文件、日志、payload 摘要或人工验证记录。
- 没有 fresh evidence 时必须返回 implement 或继续 verify。

### Module: `closeout` stage rule

**职责**: 执行最后 gate，生成中文 completion record。

**改动概述**: closeout 消费 verify verdict 和 evidence，执行 checklist，命中 trait 时写入 `acceptance.md`。

**关键行为**:

```text
if verify verdict is not PASS and no explicit conditional path:
  return verify or implement

run closeout checklist:
  retirement
  release / commit / CI / follow-through
  docs
  ADR / architecture debt
  evolution triggers
  knowledge sync

if any trait matched:
  write acceptance.md with evidence, verdict, checklist, completion record
else:
  record lightweight skip reason
```

**注意事项**:

- 每个 checklist 项必须有状态和依据，不留空段落。
- 阻塞项存在时，不宣布 feature 完成。

### Module: `acceptance-template.md`

**职责**: 提供中文验收记录结构。

**改动概述**: 在现有 Evidence Table、三维 Verdict、Workflow Replay 之外，加入 Closeout Checklist 和 Completion Record。

**关键行为**:

```text
Acceptance Record
  Evidence Table
  Verdict Summary
  Workflow Replay
  Closeout Checklist
  Completion Record
```

**注意事项**:

- 中文表达短句优先。
- 每个结论对应状态、证据或下一步。

### Module: `feature-traits.md`

**职责**: 决定是否启用强化规则。

**改动概述**: 对“任一 trait 命中 -> acceptance.md 默认落盘”和“无 trait / 用户轻量路径 -> 记录跳过原因”补充一致表述。

**注意事项**:

- 不新增 trait。
- 不改变已有 trait 检测语义，只补 downstream effect。

---

## Project Structure

目标落地位置在主仓 `~/personal/personal-skills`，本参考工作区只保留 SDD 产物。

```text
specs/chinese-acceptance-and-closeout-record/
  spec.md
  plan.md

~/personal/personal-skills/skills/sdd/
  references/stages/verify.md
  references/stages/closeout.md
  references/feature-traits.md
  templates/acceptance-template.md
```

---

## Risks and Tradeoffs

- **流程变重**: 命中 trait 时强制落盘会增加 closeout 工作量。用 fast path 和跳过原因控制范围。
- **职责漂移**: verify 和 closeout 都接触 Evidence Table，容易重复。用“verify 产出证据，closeout 持久化记录”划清边界。
- **中文模板化**: 新增模板容易生成套话。模板必须要求状态、证据、下一步，避免空泛收尾句。
- **主仓差异**: 当前工作区不是正式实现仓。执行阶段必须先检查主仓实际文件，避免基于参考路径硬改。

---

## Evolution Path

- **MVP**: 更新阶段规则和 acceptance 模板，确保命中 trait 的 feature 能生成中文 `acceptance.md`。
- **成长期**: 为常见 feature 生成示例 `acceptance.md`，帮助 reviewer 判断证据质量。
- **成熟期**: 如果 SDD 使用频率增加，可考虑把 Evidence Table 和 Closeout Checklist 做成更强的结构化 schema 或自动检查脚本。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。本 feature 只改文档规则和模板，不引入新系统。
- 是否引用了外部模式但没有适配检查：否。没有采用外部成熟架构模式。
- 是否新增未记录的状态、依赖、缓存、队列或失败模式：否。没有运行时状态或外部依赖。

---

## Verification Strategy

- 检查 `spec.md` 中命中 trait 的 feature，closeout 是否要求生成 `acceptance.md`。
- 检查 `acceptance-template.md` 是否包含 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist 和 Completion Record。
- 用一个命中 trait 的示例 dry run 验证：verify evidence 能传给 closeout，closeout 能给出中文 completion record。
- 用一个无 trait 的小改动示例 dry run 验证：系统能跳过完整 `acceptance.md`，但记录中文跳过原因。
- 人工 review 中文输出，确认没有“已完成”“测试通过”这类不可定位结论单独出现。

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要。本 feature 不涉及实体、状态、关系或存储变化。
- 下一步建议：`tasks`
- 阻塞项（如有）：无。方案已能拆成主仓文件检查、模板更新、阶段规则更新和 dry run 验证任务。

---

## Design Artifacts

本次计划涉及的产物：

| 产物 | 是否需要 | 说明 |
|------|---------|------|
| plan.md | 必须 | 主实现计划 |
| data-model.md | 不需要 | 不涉及实体、状态、关系或存储变化 |
| tasks.md | 后续阶段生成 | 由 `tasks` 阶段产出 |
| acceptance.md | 后续阶段生成 | verify / closeout 通过后记录最终验收结论 |

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| ADR-001 / ADR-002 / ADR-003 | UNVERIFIED | 来源为本仓 SDD 规格与阶段语义，不依赖外部框架文档 |
