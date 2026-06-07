# Acceptance: SDD Roadmap Feature Orchestration

**Workspace**: `sdd-roadmap-feature-orchestration`
**Date**: 2026-06-06
**Status**: Pass

---

## Verdict Summary

| Dimension | Verdict | Notes |
|---|---|---|
| Component capability | PASS | 运行时 SDD skill 已新增 roadmap 模板、入口规则、ideate/specify/closeout 阶段规则，并通过 `validate-sdd.sh` |
| Workflow closure | PASS | `spec.md -> plan.md -> tasks.md -> implement -> verify` 已走通；本机 skill 由 `skills.sh` 从远程仓库统一安装，本次只验收运行时功能实现 |
| User-visible outcome | PASS | 用户可见的 roadmap 行为规则已写入运行时 skill，后续使用 `sdd` 时可看到多 feature 拆分、roadmap、closeout 回写和 next feature 推荐要求 |

**Overall**: PASS

---

## Evidence Table

| Requirement | Evidence | Test / File | Verdict |
|---|---|---|---|
| FR-001 识别多 feature 需求 | `SKILL.md` 阶段路由前新增 multi-feature preflight；`ideate.md` 新增多 feature 拆分说明 | `.agents/skills/sdd/SKILL.md`; `.agents/skills/sdd/references/stages/ideate.md` | PASS |
| FR-002 生成或更新 roadmap | `specify.md` 新增读取 `roadmap-template.md` 并创建/更新 `specs/<umbrella>/roadmap.md` 的步骤 | `.agents/skills/sdd/references/stages/specify.md` | PASS |
| FR-003 roadmap 字段 | `roadmap-template.md` 和本 feature `roadmap.md` 都包含 Feature / Goal / Status / Depends On / Start Condition / Recommended Stage / Notes | `.agents/skills/sdd/templates/roadmap-template.md`; `specs/sdd-roadmap-feature-orchestration/roadmap.md` | PASS |
| FR-004 首个 feature spec 与 `.active` | `specs/.active` 当前为 `sdd-roadmap-feature-orchestration`；roadmap Current Feature 同名 | `specs/.active`; `specs/sdd-roadmap-feature-orchestration/roadmap.md` | PASS |
| FR-005 closeout 回写 roadmap | `closeout.md` 新增 PASS/CONDITIONAL/BLOCKED 回写 roadmap 和 Completion Log 的步骤 | `.agents/skills/sdd/references/stages/closeout.md` | PASS |
| FR-006 推荐下一个 feature | `closeout.md` 新增 `Next Recommended Feature` 计算和输出要求；roadmap 当前 next 指向 F2 | `.agents/skills/sdd/references/stages/closeout.md`; `roadmap.md` | PASS |
| FR-007 `.active` 失配处理 | `SKILL.md`、`specify.md`、`closeout.md` 都要求 current feature 与 `.active` 不一致时先说明并修正，不得静默继续 | `.agents/skills/sdd/SKILL.md`; `specify.md`; `closeout.md` | PASS |
| FR-008 只评估不写文件 | `SKILL.md` 和 `ideate.md` 都保留"只评估，不写文件"分支 | `.agents/skills/sdd/SKILL.md`; `.agents/skills/sdd/references/stages/ideate.md` | PASS |
| FR-009 后续 feature 不进本期 | `SKILL.md` 明确中文验收、自动提交、Trellis context manifest 应作为后续 feature；roadmap 记录 F2/F3/F4 | `.agents/skills/sdd/SKILL.md`; `roadmap.md` | PASS |
| 分发路径说明 | 本机 skill 由 `skills.sh` 从远程仓库统一安装；当前验收范围只确认本机运行时 skill 功能实现 | 用户确认 | PASS |

---

## Verification Commands

```text
bash /Users/yqg/personal/personal-skills/skills/sdd/scripts/validate-sdd.sh
```

结果：`validate-sdd: OK`

```text
rg -n "roadmap|Current Feature|Next Recommended Feature|只评估|小改动|不得静默继续|自动提交|context manifest" ...
```

结果：入口和阶段文档均能定位到对应规则。

---

## Distribution Note

本机的 skill 通过 `skills.sh` 从远程仓库统一安装。当前工作只确认本机运行时 `sdd` 功能已经实现并通过验证，不把本地 `skills/sdd` symlink、`.agents/` gitignore 或主仓 diff 归属作为 F1 验收阻塞项。

后续若需要发布到远程 skill 源仓，应在对应远程源仓执行同步和提交；这不属于本 feature 的本机功能验收范围。
