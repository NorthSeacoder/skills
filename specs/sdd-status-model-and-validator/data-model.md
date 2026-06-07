# Data Model: SDD Status Model And Validator

**Workspace**: `sdd-status-model-and-validator` | **Date**: 2026-06-07

> 本文件记录概念状态模型。它不是数据库 schema，不新增持久化格式；所有状态都由现有 SDD workspace artifacts 推断。

---

## Entities

### Active Feature Pointer

**来源**: `specs/.active`

**描述**: 默认续接目标。必须是单行非空 feature 名称，并指向存在的 `specs/<feature>/` 目录。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| value | string | required | active feature 名称 |
| path | file | required | `specs/.active` |
| feature_dir | directory | required | `specs/<value>/` 必须存在 |

### Feature Workspace

**来源**: `specs/<feature>/`

**描述**: 一个可独立交付的 SDD feature 工作区。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| name | string | required | feature workspace 名称 |
| spec | file | required after specify | `spec.md` |
| plan | file | required after plan | `plan.md` |
| tasks | file | required after tasks | `tasks.md` |
| context_manifest | file | required when trait/stage requires, or skipped with reason | `context-manifest.md` |
| verify_evidence | file | required for closeout readiness | `verify-evidence.md` |
| acceptance | file | required after closeout for trait-hit features | `acceptance.md` |

### Roadmap

**来源**: `specs/<umbrella>/roadmap.md`

**描述**: 多 feature umbrella 的当前推进状态和后续推荐。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| umbrella | string | required | roadmap 名称 |
| status | enum | active / completed / blocked / cancelled | roadmap 状态 |
| current_feature | string | required unless completed none | 当前 feature |
| expected_active | string | optional | Current State 中记录的 `.active` 期望 |
| current_stage | enum | optional | specify / plan / tasks / implement / verify / closeout |
| next_recommended_feature | string | optional | closeout 后推荐项 |

### Context Manifest Entry

**来源**: `specs/<feature>/context-manifest.md`

**描述**: implement / verify / research 阶段必须读取的高信号上下文。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| file_or_source | string | required | 本地路径或 URL |
| reason | string | required | 为什么需要该上下文 |
| phase | enum | implement / verify / plan / research | 消费阶段 |
| required | enum | yes / no | Required 本地文件必须存在 |
| verified | enum | yes / no / UNVERIFIED | Research Context 使用 |

### Task State

**来源**: `specs/<feature>/tasks.md`

**描述**: 执行任务完成状态。validator 只检查 Markdown checkbox，不解释任务语义。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| unchecked_count | integer | derived | `- [ ]` 数量 |
| checked_count | integer | derived | `- [x]` 或 `- [X]` 数量 |
| complete | boolean | derived | `unchecked_count == 0` |

### Verification Evidence

**来源**: `specs/<feature>/verify-evidence.md`

**描述**: verify 阶段产生、closeout 消费的 fresh evidence。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| path | file | required for closeout readiness | 默认 `verify-evidence.md` |
| verdict | string | optional | PASS / PARTIAL / FAIL，可由 LM 检查语义 |

### Acceptance Record

**来源**: `specs/<feature>/acceptance.md`

**描述**: closeout 阶段的持久 completion record。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| evidence_table | section | required | `## Evidence Table` |
| verdict_summary | section | required | `## Verdict Summary` |
| closeout_checklist | section | required | `## Closeout Checklist` |
| completion_record | section | required | `## Completion Record` |
| overall | field | required | `Overall` |

### Status Finding

**来源**: validator 输出

**描述**: 结构或一致性检查结果。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| severity | enum | PASS / FAIL | MVP 只使用 PASS/FAIL；多 roadmap ambiguity 使用 FAIL |
| file | path | required for FAIL | 失败定位 |
| reason | string | required for FAIL | 短原因 |
| mode | enum | default / closeout-ready | 检查模式 |

---

## Relationships

```text
Active Feature Pointer 1:1 Feature Workspace
Feature Workspace 0:1 active/current Roadmap
Feature Workspace 0:1 Context Manifest
Feature Workspace 0:1 Task State
Feature Workspace 0:1 Verification Evidence
Feature Workspace 0:1 Acceptance Record
Roadmap 1:N Feature Workspace
Validator 1:N Status Finding
```

关系约束：

- 若 active feature 属于 active roadmap，roadmap `Current Feature` 必须等于 `specs/.active`。
- completed roadmap 且 `Current Feature: none` 不参与 active current 匹配。
- 多个 active/current roadmap 候选同时匹配同一 active feature 时，validator 必须 FAIL。
- context manifest 若 `Status: skipped`，必须存在 skip reason。
- `Required = yes` 且 source 是本地路径时，目标文件必须存在。
- closeout readiness 要求 tasks complete、verify evidence 存在、acceptance record 完整。

---

## State Inference

状态由 artifacts 推断，不新增状态文件。

```text
NO_ACTIVE
  -> ACTIVE_MISSING_DIR
  -> SPEC_MISSING
  -> SPECIFIED        (spec.md exists, plan.md missing)
  -> PLANNED          (plan.md exists, tasks.md missing)
  -> TASKED           (tasks.md exists, has unchecked tasks)
  -> READY_FOR_VERIFY (tasks.md exists, no unchecked tasks, verify evidence missing)
  -> VERIFIED         (verify evidence exists, acceptance.md missing or incomplete)
  -> CLOSED           (acceptance.md complete and Overall is present)
```

说明：

- `TASKED` 不是失败状态；它只表示仍在 execute / implement。
- `READY_FOR_VERIFY` 不是失败状态；它表示不能宣布完成。
- `VERIFIED` 仍需 closeout；验证通过不等于 feature 完成。
- `CLOSED` 的 PASS / CONDITIONAL PASS / FAIL 语义由 `acceptance.md` 记录，validator 只检查字段存在。

---

## Validation Modes

### default

用于日常 repo 结构校验。

必须检查：

- required stage assets 存在。
- `status-model.md` 存在并被入口或 continuation reference 引用。
- `specs/.active` 存在、非空、feature 目录存在。
- active/current roadmap 与 `.active` 一致。
- 若 manifest 存在，检查 reason、Required 本地文件、Check Context 核心覆盖。

不得在当前 feature 仍处于 plan / tasks / implement 时，因缺 `verify-evidence.md` 或 `acceptance.md` 失败。

### closeout-ready

用于 verify / closeout 前的严格检查。

除 default 外，必须检查：

- `tasks.md` 存在且没有 `- [ ]`。
- `verify-evidence.md` 存在。
- `acceptance.md` 若已存在，必须包含 Evidence Table、Verdict Summary、Closeout Checklist、Completion Record 和 Overall。

若 closeout-ready 缺 acceptance，可以根据调用点处理：

- verify 阶段：允许缺 acceptance，但提示下一步 closeout。
- closeout 阶段：缺 acceptance 必须 FAIL。

---

## Severity Rules

| State | default | closeout-ready | 原因 |
|---|---|---|---|
| `.active` 缺失或为空 | FAIL | FAIL | 无法恢复 feature |
| active feature 目录不存在 | FAIL | FAIL | 续接目标失效 |
| active/current roadmap mismatch | FAIL | FAIL | 会污染续接和 closeout |
| 多个 active/current roadmap 候选 | FAIL | FAIL | umbrella 归属不唯一 |
| completed roadmap + `Current Feature: none` | PASS | PASS | 历史 roadmap 不参与 current 匹配 |
| manifest 缺 reason | FAIL if manifest exists | FAIL | manifest 结构无效 |
| Required 本地文件不存在 | FAIL if manifest exists | FAIL | 上下文无法消费 |
| Check Context 缺 spec / plan / tasks | FAIL when manifest required | FAIL | verify 上下文不完整 |
| tasks 有未完成 checkbox | PASS | FAIL | 进行中合法，closeout 不合法 |
| 缺 verify evidence | PASS before closeout | FAIL | 没有 fresh evidence 不得 closeout |
| acceptance 缺关键章节 | PASS before closeout | FAIL when closeout requires acceptance | completion record 不完整 |

---

## Non-Goals

- 不新增数据库表、DDL、迁移脚本或持久化状态文件。
- 不解析复杂 Markdown AST。
- 不判断 evidence 内容是否充分。
- 不引入 `.trellis/`、Trellis CLI、task.py、JSONL task、hook 或外部同步。

---

## Migration Notes

- 现有 workspace 不需要迁移。
- 实现阶段只新增 reference 和 validator 检查。
- 若旧 roadmap 与 active feature 产生多候选冲突，应由维护者清理 roadmap current/status，而不是让 validator 静默选择。
