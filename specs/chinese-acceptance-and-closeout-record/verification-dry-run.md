# Verification Dry Run: 中文验收与收尾记录

**Workspace**: `chinese-acceptance-and-closeout-record`  
**Date**: 2026-06-06  
**Target repo**: `/Users/yqg/personal/personal-skills`  
**Target skill path**: `skills/sdd -> ../.agents/skills/sdd`

---

## Changed Runtime Files

| File | Evidence |
|---|---|
| `skills/sdd/templates/acceptance-template.md` | 包含 `写作规则`、`Closeout Checklist`、`Completion Record`。 |
| `skills/sdd/references/feature-traits.md` | 包含“任一 trait 命中 -> 默认生成或更新 `acceptance.md`”规则。 |
| `skills/sdd/references/stages/verify.md` | 包含 `Evidence Package`，要求 verify 输出 closeout 可消费的证据包。 |
| `skills/sdd/references/stages/closeout.md` | 包含 `Acceptance Record Rules`，要求 closeout 消费 verify 结果并写 `acceptance.md`。 |

---

## Command Evidence

| Check | Command | Result |
|---|---|---|
| SDD asset validation | `bash skills/sdd/scripts/validate-sdd.sh` | PASS: `validate-sdd: OK` |
| Required phrase check | `rg -n "Acceptance Record Rules|Evidence Package|默认生成或更新|Closeout Checklist|Completion Record|写作规则" skills/sdd` | PASS: 目标短语均存在。 |
| Git path check | `ls -ld skills/sdd .agents/skills/sdd` | PASS: `skills/sdd` 是指向 `.agents/skills/sdd` 的符号链接。 |

---

## Dry Run 1: 命中 Trait 的 Feature

**输入摘要**: feature 同时命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output`。  
**Verify 输出**: `verify.md` 要求形成 evidence package，包括实现范围、验证命令、Evidence Table draft、architecture drift、unresolved risks 和 verdict。  
**Closeout 消费**: `closeout.md` 要求读取 verify evidence package，并在任一 trait 命中时写入 `specs/<feature>/acceptance.md`。  
**Acceptance Record**: `acceptance-template.md` 可承载 Evidence Table、三维 Verdict、Workflow Replay、Closeout Checklist 和 Completion Record。

**Verdict**: PASS。命中 trait 路径能从 verify evidence 闭环到持久中文 `acceptance.md`。

---

## Dry Run 2: 无 Trait 的小改动

**输入摘要**: feature 的 Feature Traits 全部为 ❌，或用户显式选择轻量路径。  
**Trait 规则**: `feature-traits.md` 允许跳过完整 `acceptance.md`，但必须记录中文跳过原因。  
**Closeout 输出**: `closeout.md` 要求 closeout 对话输出只摘要 verdict、阻塞项、延后项和下一步，不替代持久记录。

**Verdict**: PASS。fast path 不强制完整 `acceptance.md`，但仍保留中文跳过记录。

---

## Chinese Quality Review

| Check | Verdict | Evidence |
|---|---|---|
| 禁止不可定位结论 | PASS | 模板和 verify 规则明确禁止只写“已实现”“测试通过”“review 通过”“已完成”。 |
| checklist 状态可审计 | PASS | `Closeout Checklist` 要求“已完成 / 延后 / 不适用 / 阻塞”并附依据。 |
| completion record 有下一步 | PASS | `Completion Record` 包含阻塞项、延后项、退役结论和后续动作。 |

---

## Execution Risk

- 主仓当前已有与我无关的大量变更，且 `skills/sdd` 是符号链接。`git diff skills/sdd/...` 会受既有迁移状态影响，不能单独作为本次内容 diff 的证据。
- 本次验证以实际运行路径内容、`rg` 关键段落检查和 `validate-sdd.sh` 为证据。
