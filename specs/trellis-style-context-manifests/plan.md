# Implementation Plan: Trellis Style Context Manifests

**Workspace**: `trellis-style-context-manifests` | **Date**: 2026-06-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/trellis-style-context-manifests/spec.md`

---

## Summary

为 SDD feature 增加轻量 `context-manifest.md`：用 Markdown 分区记录 Implement / Check / Research 三类上下文清单。实现阶段和验证阶段必须先读取对应分区；缺失或引用不存在文件时回退到 plan/tasks 更新 manifest。

方案讨论说明：不采用 Trellis 的 `.trellis/tasks/*/implement.jsonl` / `check.jsonl` / `research.jsonl` 原结构。SDD 更适合一个人类可读 Markdown manifest，放在 `specs/<feature>/context-manifest.md`，兼顾轻量、可审查和跨阶段交接。

---

## Architecture Overview

```text
spec.md / plan.md / tasks.md / research notes
        │
        ▼
specs/<feature>/context-manifest.md
        │
        ├── Implement Context  ──→ implement stage reads before editing
        ├── Check Context      ──→ verify stage reads before verdict
        └── Research Context   ──→ plan/tasks/verify trace sources
```

边界：

- 只新增 Markdown 模板和阶段规则。
- 不新增 `.trellis/`、hook、CLI、自动注入或新 subagent 协议。
- 不把待修改源文件写成固定上下文；源文件仍由 implement / verify 按需检查。

---

## Architecture Reference

| 参考模式 / 模板 | 来源 URL | 适配点 | 不适配点 | 当前阶段 |
|-----------------|----------|--------|----------|----------|
| Trellis context files | https://docs.trytrellis.app/start/how-it-works | implement/check/research context 分离，避免会话记忆丢失 | 不复制 `.trellis/tasks/`、JSONL 文件和自动注入机制 | MVP |
| Trellis repo workflow framing | https://github.com/mindfold-ai/Trellis | 文件驱动任务状态和上下文可恢复 | 不引入 Trellis CLI、hook、多平台初始化 | MVP |

---

## Producer-Consumer Matrix

| Producer | Artifact | Consumer | Consumption Proof |
|---|---|---|---|
| plan / tasks 阶段 | `context-manifest.md` | implement 阶段 | implement.md 要求先读取 Implement Context |
| plan / tasks 阶段 | Check Context 分区 | verify 阶段 | verify.md 要求先读取 Check Context，缺失风险不得 PASS |
| research / docs exploration | Research Context 分区 | plan / verify / closeout | manifest 记录 source URL、本地研究文件和用途 |
| context manifest | Manifest Entry | implement / verify | 每条 entry 至少有 File/Source、Reason、Phase |
| verify 阶段 | manifest coverage evidence | acceptance.md | acceptance 记录 manifest 字段和阶段消费证据 |

**孤儿 artifact 处理**: 无。若 manifest 存在但阶段未消费，verify 必须判 PARTIAL。

---

## Quality Attribute Targets

| 属性 | 目标 | 设计影响 | 验证方式 |
|------|------|----------|----------|
| 可续接性 | 压缩/恢复后知道该读什么 | manifest 落在 feature 目录 | dry run 从 manifest 恢复 implement/check 入口 |
| 可审查性 | 用户能审查上下文选择 | Markdown 表格 + reason 必填 | 字段检查 |
| 低耦合 | 不依赖 Trellis runtime | 不新增 hook/CLI/JSONL 注入 | validate-sdd 通过 |
| 成本 | 小 feature 可跳过 | 跳过时记录原因 | 阶段规则检查 |

---

## Lightweight ADR

| 决策 | 背景 | 候选 | 结论 | 代价 | 来源 |
|------|------|------|------|------|------|
| ADR-001: manifest 格式 | spec UQ-001 | A: Markdown / B: JSONL | A：Markdown，更适合人工审查 | 机器解析弱于 JSONL | 本次 plan |
| ADR-002: manifest 文件数 | spec UQ-002 | A: 三个文件 / B: 一个文件三分区 | B：`context-manifest.md` 一文件三分区 | 单文件稍长 | 本次 plan |
| ADR-003: 强制时机 | spec UQ-003 | A: 所有 feature 强制 / B: 命中 trait 或文件存在时强制 | B：命中 trait 时强制，小改动可跳过并记录原因 | 需要阶段判断 | 本次 plan |
| ADR-004: Trellis 吸收边界 | 避免平台化 | A: 复制 Trellis / B: 只吸收上下文清单 | B：只吸收 context manifest 思想 | 无自动注入 | Trellis docs |

---

## Module Design

### Module: `templates/context-manifest-template.md`

**职责**: 提供 `context-manifest.md` 的标准结构。

**关键行为**:

```text
## Implement Context
| File / Source | Reason | Phase | Required |

## Check Context
| File / Source | Reason | Phase | Required |

## Research Context
| File / Source | Reason | Phase | Verified |
```

规则：

- 每行必须有 reason。
- 待修改源文件不作为固定 context；可在 Notes 中写"实现阶段按需检查"。
- 缺失 required 文件时，阶段必须回退到 plan/tasks。

### Module: `references/stages/tasks.md`

**职责**: 在任务拆解结束时要求生成或更新 context manifest。

**改动概述**:

- 命中 trait 或多阶段 feature 时，使用模板生成 `specs/<feature>/context-manifest.md`。
- manifest 至少包含 spec、plan、tasks。
- 根据需要加入 research / reference / roadmap / acceptance template。

### Module: `references/stages/implement.md`

**职责**: 实现前读取 Implement Context。

**改动概述**:

- 若 context manifest 存在，先读取 Implement Context。
- 若命中 trait 但 manifest 缺失，回退到 tasks/plan。
- 发现 required 文件不存在时停止并修正 manifest。

### Module: `references/stages/verify.md`

**职责**: 验证前读取 Check Context。

**改动概述**:

- verify 前读取 Check Context。
- check context 必须覆盖 P0/P1 requirement 和风险材料。
- 若无法覆盖，不得 PASS，回退到 plan/tasks 更新 manifest。

### Module: `SKILL.md`

**职责**: 在模板资产和路由原则中声明 context manifest。

---

## Data Model

不需要独立 `data-model.md`。状态模型落在模板：

```text
ContextManifest
  - feature
  - status
  - implement_entries[]
  - check_entries[]
  - research_entries[]
  - skip_reason?

ManifestEntry
  - file_or_source
  - reason
  - phase
  - required_or_verified
```

---

## Project Structure

```text
skills/sdd/
├── SKILL.md                         # patch
├── templates/
│   └── context-manifest-template.md  # new
└── references/stages/
    ├── tasks.md                      # patch
    ├── implement.md                  # patch
    └── verify.md                     # patch

specs/trellis-style-context-manifests/
├── spec.md
├── plan.md
├── tasks.md
├── context-manifest.md               # dogfooding manifest
├── verify-evidence.md
└── acceptance.md
```

---

## Risks and Tradeoffs

- **风险 1**: manifest 变成形式主义。缓解：每条 reason 必填，verify 检查覆盖 P0/P1。
- **风险 2**: 小改动流程变重。缓解：允许跳过，但必须记录原因。
- **风险 3**: 没有自动注入，agent 可能忘读。缓解：阶段文档明确 implement/verify 必须先读。
- **风险 4**: Markdown 不如 JSONL 易机器处理。缓解：本期优先人类可审查，后续再评估机器化。

---

## Evolution Path

- **MVP**: 一个 Markdown manifest + 阶段读取规则。
- **成长期**: 与 subagent prompt 结合，要求 subagent 启动时读取 manifest。
- **成熟期**: 如确有需要，再增加 JSONL 导出或自动注入。

---

## Anti-Pattern Check

- 是否把成熟期架构套到了 MVP：否。不引入 Trellis runtime、hook 或 CLI。
- 是否引用了外部模式但没有适配检查：否。只吸收 implement/check/research context 分离。
- 是否新增未记录的状态或依赖：否。状态在模板中定义。

---

## Verification Strategy

1. **模板字段验证**: context manifest 模板必须有 Implement / Check / Research 三段，每段含 File/Source、Reason、Phase。
2. **阶段规则验证**: tasks 生成/更新 manifest；implement 读取 Implement Context；verify 读取 Check Context。
3. **Dogfooding 验证**: 为本 feature 写 `context-manifest.md`，从中恢复 implement/check 所需上下文。
4. **validate-sdd**: 修改完成后运行 `skills/sdd/scripts/validate-sdd.sh`。

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要。manifest 状态模型已在 plan 中定义。
- 下一步建议：`tasks`
- 阻塞项：无。
