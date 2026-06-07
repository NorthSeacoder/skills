# Verify Evidence: Trellis Style Context Manifests

**Workspace**: `trellis-style-context-manifests`
**Date**: 2026-06-07

---

## Evidence Table Draft

| Requirement | Evidence | Test or File | Verdict |
|---|---|---|---|
| FR-001 / FR-002 / FR-003：定义 implement / check / research context manifest | 新增 `context-manifest-template.md`，包含 Implement Context、Check Context、Research Context 三段，字段覆盖 File / Source、Reason、Phase，并按段记录 Required 或 Verified | `skills/sdd/templates/context-manifest-template.md` | PASS |
| FR-004：manifest 位于 `specs/<feature>/`，不新增 `.trellis/` | 本 feature dogfooding manifest 写入 `specs/trellis-style-context-manifests/context-manifest.md`；模板和阶段规则均未要求 `.trellis/` | `specs/trellis-style-context-manifests/context-manifest.md`; `skills/sdd/SKILL.md` | PASS |
| FR-005：每条 entry 至少包含 file/source、reason、phase | 模板和本 feature manifest 的三段表格都包含 File / Source、Reason、Phase；模板 Rules 明确缺少 reason 不得通过 verify | `skills/sdd/templates/context-manifest-template.md`; `specs/trellis-style-context-manifests/context-manifest.md` | PASS |
| FR-006：implement 阶段先读取 Implement Context，缺失时回退 | `implement.md` 核心原则、执行步骤、回退条件和完成标准均要求读取 Implement Context、校验 Required 文件和 reason，缺失时返回 plan/tasks | `skills/sdd/references/stages/implement.md` | PASS |
| FR-007：verify 阶段先读取 Check Context，覆盖不足不得 PASS | `verify.md` 核心原则、Evidence Package、执行步骤、回退条件和完成标准均要求读取 Check Context，覆盖 P0/P1 requirement，不足时不得 PASS | `skills/sdd/references/stages/verify.md` | PASS |
| FR-008：不把待修改源文件列为固定上下文 | 模板 Rules 和本 feature manifest Notes 明确不要把即将修改的源文件列为固定 context；实现和验证阶段按需读取源文件 | `skills/sdd/templates/context-manifest-template.md`; `specs/trellis-style-context-manifests/context-manifest.md` | PASS |
| FR-009：支持轻量跳过路径并记录原因 | 模板提供 Skip Reason 分区；`tasks.md` 要求小改动可跳过但必须记录原因，阶段完成标准检查该状态 | `skills/sdd/templates/context-manifest-template.md`; `skills/sdd/references/stages/tasks.md` | PASS |
| FR-010：不引入 Trellis CLI、hook、task.py、多平台初始化或自动 context injection | `SKILL.md` 和模板 Rules 均明确只吸收 Trellis 上下文清单思想，不引入 `.trellis/`、Trellis CLI、hook 或自动注入 | `skills/sdd/SKILL.md`; `skills/sdd/templates/context-manifest-template.md` | PASS |

---

## Manifest Field Check

| Target | Implement Context | Check Context | Research Context | Reason 字段 | Verdict |
|---|---|---|---|---|---|
| `skills/sdd/templates/context-manifest-template.md` | 存在，字段含 File / Source、Reason、Phase、Required | 存在，字段含 File / Source、Reason、Phase、Required | 存在，字段含 File / Source、Reason、Phase、Verified | 模板要求每条 entry 必须有 Reason | PASS |
| `specs/trellis-style-context-manifests/context-manifest.md` | 存在，列出 spec、plan、tasks、模板文件 | 存在，列出 spec、plan、tasks、manifest、validate 脚本 | 存在，列出 Trellis docs 与 GitHub repo 来源 | 每条 entry 均有中文 reason | PASS |

---

## Stage Consumption Trace

| Producer | Artifact | Consumer | Consumption Proof | Verdict |
|---|---|---|---|---|
| `tasks` 阶段 | `context-manifest.md` | `implement` 阶段 | `tasks.md` 执行步骤要求命中 trait、存在研究材料或上下文易丢失时读取模板生成或更新 manifest；完成标准要求说明生成或跳过状态 | PASS |
| `context-manifest.md` | Implement Context | `implement` 阶段 | `implement.md` 执行步骤要求先读取 Implement Context，校验 reason 和 Required 本地文件 | PASS |
| `context-manifest.md` | Check Context | `verify` 阶段 | `verify.md` 执行步骤要求读取 Check Context，检查 reason、Required 文件和 P0/P1 requirement 覆盖 | PASS |
| `context-manifest.md` | Research Context | `plan` / `verify` / `closeout` | `context-manifest.md` 记录 Trellis docs 和 repo 来源；`plan.md` Architecture Reference 说明吸收点与不适配点 | PASS |
| `verify` 阶段 | manifest coverage evidence | `acceptance` / `closeout` | 本文件的 Evidence Table Draft、Manifest Field Check 和 Stage Consumption Trace 可被 `acceptance.md` 消费 | PASS |

---

## Workflow Replay Fixture

- **输入摘要**: 一个命中 `multi-stage-workflow`、`artifact-handoff`、`user-visible-output` 和 `prior-closure-failure` 的 SDD feature，需要跨 tasks、implement、verify 保存上下文选择。
- **Producer 行为**: tasks 阶段在 `specs/<feature>/context-manifest.md` 生成 Implement / Check / Research 三段上下文。
- **Consumer 行为**: implement 阶段读取 Implement Context；verify 阶段读取 Check Context 并检查 P0/P1 requirement 覆盖。
- **用户可见结果断言**: 用户能看到每条上下文的 File / Source、Reason、Phase，以及 Required / Verified 状态。
- **Replay 类型**: fixture。该 feature 是 Markdown 规则和模板改动，不需要运行外部服务。

---

## Architecture Drift Check

| Plan Boundary | Actual Result | Verdict |
|---|---|---|
| 使用一个 Markdown `context-manifest.md`，不复制 Trellis JSONL 文件结构 | 已新增单文件模板和 dogfooding manifest | PASS |
| 放在 `specs/<feature>/`，不新增 `.trellis/` | 未新增 `.trellis/`，阶段规则只引用 SDD specs 目录 | PASS |
| 不引入自动注入、hook、CLI、task.py 或新 subagent 协议 | 仅修改 SDD 阶段文档和模板资产 | PASS |
| 小 feature 可跳过但要记录原因 | 模板和 tasks 阶段规则已记录 Skip Reason 路径 | PASS |

---

## Validation

```text
bash /Users/yqg/personal/personal-skills/skills/sdd/scripts/validate-sdd.sh
```

结果：`validate-sdd: OK`

---

## Verify Verdict

**Verdict**: PASS

证据足以进入 closeout。剩余风险是 Markdown manifest 仍依赖阶段执行者主动读取；该风险已在 plan 的 Evolution Path 中留作后续“subagent prompt 结合 / 自动注入”演进，不影响本 feature MVP 完成。
