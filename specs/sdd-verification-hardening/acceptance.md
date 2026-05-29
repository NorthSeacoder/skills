# Acceptance Record: SDD Verification Hardening

**Workspace**: `sdd-verification-hardening` | **Date**: 2026-05-29 | **Spec**: [spec.md](spec.md)

---

## Evidence Table

| Requirement | Evidence | Test or File | Verdict |
|---|---|---|---|
| FR-001 specify 阶段自动检测 5 traits | specify.md 步骤 5 明确引用 feature-traits.md 逐 trait 检测 | `references/stages/specify.md:37` | PASS |
| FR-002 traits 支持用户 override | feature-traits.md 跳过条件段明确"用户显式 override 为 ❌ 并给出理由 → 下游以用户标注为准" | `references/feature-traits.md` 跳过条件段 | PASS |
| FR-003 matrix 触发条件 | plan.md 步骤 9 条件为 `multi-stage-workflow` OR `artifact-handoff`，与 feature-traits.md 触发规则一致 | `references/stages/plan.md:59` | PASS |
| FR-004 evidence gate 触发条件 | verify.md 步骤 5 条件为 `user-visible-output` OR `external-side-effects`，PARTIAL 判定规则明确 | `references/stages/verify.md:37` | PASS |
| FR-005 replay 触发条件 | closeout.md checklist 新增 replay 项，条件为 `multi-stage-workflow` AND `user-visible-output` | `references/stages/closeout.md:35` | PASS |
| FR-006 三维 verdict | acceptance-template.md 包含 Component/Workflow/User-Visible 三维 + 不一致说明字段 | `templates/acceptance-template.md:26-42` | PASS |
| FR-007 默认开启 + 跳过记录 | feature-traits.md 跳过条件段明确"默认开启"+"跳过时记录格式" | `references/feature-traits.md` 跳过条件段 | PASS |
| FR-008 不命中零开销 | T012 演练确认：全 ❌ 时无强化段落被强制生成，模板段落均标 *(if ...)* | spec-template.md + plan-template.md 条件标注 | PASS |

---

## Verdict Summary *(三维 Verdict)*

| Dimension | Verdict | Notes |
|---|---|---|
| Component capability | PASS | 2 个新文件 + 6 个 patch 全部到位，feature-traits.md 60 行、acceptance-template.md 49 行，均在预估范围内 |
| Workflow closure | PASS | T011 trace 确认：每个 trait 从定义 → specify 触发 → 模板段落 → 阶段执行步骤完整闭环，无断点 |
| User-visible outcome | PASS | SDD skill 行为变化已落地：specify 会检测 traits，plan 会生成 matrix，verify 会生成 evidence 表，closeout 会执行 replay 和三维 verdict |

**Overall**: PASS

---

## Workflow Replay *(self-application)*

本 feature 同时命中 `multi-stage-workflow` 和 `user-visible-output`，以下是 fixture replay：

- **输入摘要**: 本 feature 自身的 spec.md（命中 4/5 traits）走完 specify → plan → tasks → implement → verify → closeout
- **最终 payload 摘要**: 8 个文件变更（2 新建 + 6 patch），所有强化规则在对应阶段正确触发
- **用户可见结果断言**: SDD skill 使用者在下一个 feature 中将看到 spec-template 中的 Feature Traits 段、plan-template 中的 Matrix 段、verify 中的 Evidence Gate 提示、closeout 中的 Replay 和三维 Verdict 要求
- **Replay 类型**: fixture（本 feature 是 skill 自身的改动，无外部服务可 mock，通过文档链路 trace 替代真实 runtime replay）

---

## Verification Traces

### T011: 一致性 trace

| Trait | 定义 (feature-traits.md) | specify 触发 | 模板段落 | 阶段执行步骤 | 结果 |
|---|---|---|---|---|---|
| `multi-stage-workflow` | ✓ 定义 + 检测信号 | ✓ specify.md 步骤 5 | ✓ plan-template Matrix 段 | ✓ plan.md 步骤 9 + closeout checklist | PASS |
| `external-side-effects` | ✓ 定义 + 检测信号 | ✓ specify.md 步骤 5 | ✓ acceptance-template Evidence 段 | ✓ verify.md 步骤 5 | PASS |
| `artifact-handoff` | ✓ 定义 + 检测信号 | ✓ specify.md 步骤 5 | ✓ plan-template Matrix 段 | ✓ plan.md 步骤 9 | PASS |
| `user-visible-output` | ✓ 定义 + 检测信号 | ✓ specify.md 步骤 5 | ✓ acceptance-template Evidence + Verdict 段 | ✓ verify.md 步骤 5 + closeout checklist | PASS |
| `prior-closure-failure` | ✓ 定义 + 检测信号 | ✓ specify.md 步骤 5 | ✓ acceptance-template Verdict 段 (任一 trait) | ✓ closeout 步骤 4 (任一 trait) | PASS |

### T012: Minimal feature 演练

假设 feature = "修复 README 中的错别字"：
- spec.md Feature Traits 段：5 个 trait 全标 ❌
- 结论："本 feature 不触发强化规则，后续阶段按基础流程推进"
- plan.md：无 Producer-Consumer Matrix 段（条件不满足）
- verify：无 Evidence Table（条件不满足）
- closeout：无 Workflow Replay、无三维 Verdict、无 acceptance.md
- **结论**: 不命中 trait 的 feature 零额外开销 ✓

### T013: 新增第 6 个 trait 演练

假设要加 `security-sensitive` trait：
1. 改 `references/feature-traits.md`：定义表加一行 + 触发规则表加一行
2. 改 `templates/spec-template.md`：traits 表加一行
3. 其余阶段文件（specify.md / plan.md / verify.md / closeout.md）因条件判断引用 `../feature-traits.md` 而自动生效
- **结论**: 只需改 2 个文件即可完成新 trait 扩展 ✓
