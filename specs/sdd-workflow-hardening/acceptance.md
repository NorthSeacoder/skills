# Acceptance: SDD Workflow Hardening

**Workspace**: `sdd-workflow-hardening`  
**Date**: 2026-05-24  
**Status**: PASS

---

## Scope

本次验收覆盖以下目标：

- 将 `sdd` 主链强化为 `Clarify / Domain Alignment -> Spec -> Plan -> Execute -> Verify -> Closeout`
- 将 `code-review` 从顶层终点阶段降为 `Verify` 内的检查动作
- 为 `Verify` 和 `Closeout` 增加正式阶段资产
- 为 `skills/sdd/` 增加内建 validator，防止路由和阶段文档漂移
- 保持“吸收外部 skill 的优点”口径，而不是迁移或复刻外部结构

---

## Evidence

### 1. 主链入口已重构

- [skills/sdd/SKILL.md](/Users/yqg/personal/personal-skills/skills/sdd/SKILL.md)
  - 已引入 `verify`、`closeout`
  - 已将 `clarify` 重定义为 `Clarify / Domain Alignment`
  - 已明确 `code-review` 不再是主链终点

### 2. 阶段资产已对齐

- [clarify.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/clarify.md)
- [plan.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/plan.md)
- [execute-plan.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/execute-plan.md)
- [implement.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/implement.md)
- [code-review.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/code-review.md)
- [verify.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/verify.md)
- [closeout.md](/Users/yqg/personal/personal-skills/skills/sdd/references/stages/closeout.md)

### 3. 结构校验已接入

- [skills/sdd/scripts/validate-sdd.sh](/Users/yqg/personal/personal-skills/skills/sdd/scripts/validate-sdd.sh)
- [scripts/verify-skills.sh](/Users/yqg/personal/personal-skills/scripts/verify-skills.sh)

### 4. 对外说明已更新

- [README.md](/Users/yqg/personal/personal-skills/README.md)

---

## Verification Results

已执行并通过：

```bash
bash skills/sdd/scripts/validate-sdd.sh
bash scripts/verify-skills.sh
```

验证结论：

- 新增阶段文件存在且被主入口引用
- `code-review` 已不再被描述为顶层终点
- `Verify` 和 `Closeout` 已进入结构校验范围
- subagent 派生与现有校验未被本次改动破坏

---

## Closeout Checklist

- [x] 检查旧主链收尾语义是否仍把 `code-review` 当最终终点
- [x] 检查 `Verify` 是否具备 fresh evidence gate
- [x] 检查 `Closeout` 是否具备可执行 checklist
- [x] 检查 README 是否已同步新主链说明
- [x] 检查结构校验是否已覆盖新增阶段
- [x] 检查工作区文档 `spec / plan / tasks / acceptance` 是否齐全

---

## Residual Risks

- 当前 validator 仍是第一版，只覆盖 `skills/sdd/` 的结构漂移，不覆盖更深层语义一致性
- `Closeout` 与未来更多 feature 的真实使用反馈还未经过多轮实战检验

---

## Final Verdict

PASS

本次 feature 已达到进入主仓使用的条件。后续若继续增强，应优先根据真实使用反馈迭代 `Verify / Closeout` 细节，而不是再扩展新的顶层阶段。
