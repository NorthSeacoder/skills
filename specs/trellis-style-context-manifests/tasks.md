# Tasks: Trellis Style Context Manifests

**Workspace**: `trellis-style-context-manifests`
**Date**: 2026-06-07
**Spec**: [spec.md](spec.md)
**Plan**: [plan.md](plan.md)

---

## Phase 1: Manifest 模板

- [x] T001 [US1,US2,US3,FR-001,FR-002,FR-003] 创建 `templates/context-manifest-template.md`
  - scope: 新增模板
  - verify: 模板包含 Implement Context、Check Context、Research Context，且每段有 File/Source、Reason、Phase 字段

- [x] T002 [US4,FR-004,FR-010] 为本 feature 创建 `context-manifest.md`
  - scope: dogfooding 产物
  - verify: manifest 位于 `specs/trellis-style-context-manifests/`，不新增 `.trellis/`

## Phase 2: 阶段规则

- [x] T003 [US1,FR-006,FR-009] patch `references/stages/tasks.md`
  - scope: tasks 阶段
  - detail: 命中 trait 或多阶段 feature 时生成/更新 context manifest，小改动可跳过并记录原因
  - verify: tasks 完成标准包含 context manifest 状态

- [x] T004 [US1,FR-006,FR-008] patch `references/stages/implement.md`
  - scope: implement 阶段
  - detail: 实现前读取 Implement Context；缺失或 required 文件不存在时回退
  - verify: 文档明确不把待修改源文件作为固定 context

- [x] T005 [US2,FR-007] patch `references/stages/verify.md`
  - scope: verify 阶段
  - detail: 验证前读取 Check Context；覆盖不足不得 PASS
  - verify: Verify 阶段完成标准包含 check context 覆盖

- [x] T006 [US4,FR-010] patch `SKILL.md`
  - scope: 模板资产和路由原则
  - detail: 声明 context manifest，但不承诺自动注入或 Trellis 平台结构
  - verify: `SKILL.md` 中无 `.trellis/` 引入要求

## Phase 3: 验证

- [x] T007 [contract] manifest 字段覆盖检查
  - scope: `context-manifest-template.md` 和本 feature `context-manifest.md`
  - verify: 每条 entry 有 reason；存在 Implement / Check / Research 三段

- [x] T008 [contract] 阶段消费 trace
  - scope: tasks / implement / verify
  - verify: trace 覆盖 "tasks 生成 -> implement 消费 -> verify 消费"

- [x] T009 [validation] 运行 `validate-sdd.sh`
  - scope: SDD skill 结构
  - verify: 输出 `validate-sdd: OK`

---

## 依赖与顺序

**关键路径**: T001 -> T002 -> T003/T004/T005/T006 -> T007/T008/T009

- T001 先完成，其他阶段引用模板。
- T003-T006 可在 T001 后并行。
- T007-T009 必须在文档 patch 后执行。

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|---|---|
| US1 implement manifest | T001, T002, T003, T004 |
| US2 check manifest | T001, T002, T005 |
| US3 research context | T001, T002 |
| US4 不复制 Trellis 平台 | T002, T006 |
| FR-001/002/003 三类 manifest | T001, T002 |
| FR-004 specs 目录 | T002 |
| FR-005 reason 必填 | T001, T007 |
| FR-006 implement 读取 | T004 |
| FR-007 verify 读取 | T005 |
| FR-008 不固定待修改源文件 | T004 |
| FR-009 轻量跳过 | T003 |
| FR-010 不引入 Trellis 平台 | T006 |

---

## Stage Readiness

- 推荐下一步：`closeout`
- 是否需要 `execute-plan`：不需要。9 个任务已完成，均为 Markdown 模板和阶段规则 patch。
- 阻塞项：无。
