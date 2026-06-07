# Roadmap: SDD Multi-Feature Orchestration

**Umbrella**: `sdd-multi-feature-orchestration`
**Created**: 2026-06-06
**Status**: completed
**Current Feature**: `none`
**Next Recommended Feature**: `none`

---

## Summary

本 roadmap 将用户对 `sdd` 的复合优化需求拆成多个可独立交付的 feature，并已完成 F1-F4 的本机运行时功能验收。

---

## Current State

| Field | Value |
|---|---|
| Current feature | `none` |
| specs/.active expected | `sdd-roadmap-feature-orchestration`（umbrella closeout 记录所在目录） |
| Current stage | `completed` |
| Next stage | 无 |
| Current objective | F1-F4 已全部完成，umbrella roadmap closeout 已落盘 |

---

## Feature Roadmap

| Feature | Goal | Status | Depends On | Start Condition | Recommended Stage | Notes |
|---|---|---|---|---|---|---|
| `sdd-roadmap-feature-orchestration` | 自动拆分多 feature 需求，建立 roadmap，完成后回写并推荐下一 feature | done | none | 已完成本机运行时功能验收 | closeout | F1，本期范围 |
| `chinese-acceptance-and-closeout-record` | 强化中文验收文档、中文 Evidence Table 和 closeout completion record | done | `sdd-roadmap-feature-orchestration` | 已完成中文验收与收尾记录能力 | closeout | F2，用户确认已完成，acceptance 为 PASS |
| `commit-boundary-and-diff-automation` | 自动识别相关 diff、排除无关 dirty files、生成 commit plan，经用户确认后提交 | done | `sdd-roadmap-feature-orchestration`, `chinese-acceptance-and-closeout-record` | 已完成本机运行时功能验收 | closeout | F3，涉及 git 副作用，已通过 dry run 验证不自动提交 |
| `trellis-style-context-manifests` | 吸收 Trellis `implement.jsonl` / `check.jsonl` / `research.jsonl` 思路，建立 SDD 上下文清单 | done | `sdd-roadmap-feature-orchestration`, `chinese-acceptance-and-closeout-record`, `commit-boundary-and-diff-automation` | 已完成本机运行时功能验收 | closeout | F4，已落地 `context-manifest.md` 模板和 implement / verify 阶段消费规则 |

---

## Completion Log

| Feature | Date | Verdict | Evidence | Impact On Roadmap |
|---|---|---|---|---|
| `sdd-roadmap-feature-orchestration` | 2026-06-06 | PASS | `acceptance.md` 记录运行时规则验证通过；`validate-sdd.sh` 通过；用户确认本机只验收 skills.sh 安装后的功能实现 | 推荐启动 `chinese-acceptance-and-closeout-record` |
| `chinese-acceptance-and-closeout-record` | 2026-06-06 | PASS | `specs/chinese-acceptance-and-closeout-record/acceptance.md` 三维 Verdict 均为 PASS，用户确认已完成 | 推荐启动 `commit-boundary-and-diff-automation` |
| `commit-boundary-and-diff-automation` | 2026-06-07 | PASS | `specs/commit-boundary-and-diff-automation/acceptance.md` 三维 Verdict 均为 PASS；`validate-sdd.sh` 通过；dry run 证明不会自动提交无关 dirty files | 推荐启动 `trellis-style-context-manifests` |
| `trellis-style-context-manifests` | 2026-06-07 | PASS | `specs/trellis-style-context-manifests/acceptance.md` 三维 Verdict 均为 PASS；`validate-sdd.sh` 通过；manifest 字段检查和阶段消费 trace 均通过 | 推荐进入 `roadmap-closeout` |
| `roadmap-closeout` | 2026-06-07 | PASS | `specs/sdd-roadmap-feature-orchestration/roadmap-closeout.md` 记录 F1-F4 全部 PASS、无剩余 roadmap feature、commit 状态为 not_submitted | roadmap 完成 |

---

## Next Recommendation

当前无推荐的后续 feature。原因：F1 已建立 roadmap，F2 已强化中文验收，F3 已补齐 commit boundary，F4 已吸收 Trellis 上下文清单设计并通过验收，umbrella closeout 已完成。

---

## Deferred Features

- 当前无 deferred feature。roadmap 已完成。
