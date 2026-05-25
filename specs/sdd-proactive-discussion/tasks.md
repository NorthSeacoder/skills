# Tasks: SDD Proactive Discussion

**Workspace**: `sdd-proactive-discussion` | **Date**: 2026-05-25  
**Input**: `specs/sdd-proactive-discussion/spec.md` + `plan.md`  
**Prerequisites**: spec.md (done), plan.md (done)

---

## 执行原则

- 两个文件独立改动，无依赖关系，可并行
- 改动是行为协议文本，不涉及代码或脚本
- 改完后需要用实际 feature 验证行为变化

---

## Phase 1: Clarify 行为协议重写

**目标**: 把 clarify 从"问卷模式"改为"发现模式"

- [x] T001 重写 clarify.md 的"执行原则"
  - scope: `skills/sdd/references/stages/clarify.md` — "执行原则"小节
  - maps_to: FR-001, FR-002, FR-003
  - 改动要点:
    - 删除"只问高价值问题"等问卷式措辞
    - 新增 LM 角色定位：风险发现者，不是提问者
    - 新增输出形式约束：呈现发现 + 推断 + 请用户确认，不列问题清单
    - 新增"能推断的直接给结论"原则
    - 保留"一次只推进少量关键问题"但改为"一次只呈现少量关键发现"
  - verify: 读改后文本，确认没有"提出问题集"类措辞；确认有"呈现发现"和"给出推断"的明确要求

- [x] T002 重写 clarify.md 的"执行步骤"
  - scope: `skills/sdd/references/stages/clarify.md` — "执行步骤"小节
  - maps_to: FR-001, FR-002
  - 改动要点:
    - 旧步骤: 识别不确定点 → 提出最小问题集 → 用户回答 → 回写
    - 新步骤: 分析 spec + 代码/文档 → 识别隐藏问题和盲点 → 给出推断和发现 → 用户确认或补充 → 回写
    - 保留架构质量门触发条件（步骤 4）
  - verify: 步骤中不再出现"提出问题集"；有明确的"分析→发现→呈现推断"流程

- [x] T003 更新 clarify.md 的"阶段完成标准"
  - scope: `skills/sdd/references/stages/clarify.md` — "阶段完成标准"小节
  - maps_to: US1-3
  - 改动要点:
    - 从"关键歧义已被清理"改为"隐藏风险已识别或确认不存在"
    - 新增"若未发现隐藏问题，已明确说明可直接进入 plan"
  - verify: 完成标准反映"发现模式"而非"问答模式"

---

## Phase 2: Plan 架构讨论环节

**目标**: 在生成 plan.md 前插入候选方案讨论

- [x] T004 重写 plan.md 的"执行步骤"
  - scope: `skills/sdd/references/stages/plan.md` — "执行步骤"小节
  - maps_to: FR-004, FR-005, FR-006
  - 改动要点:
    - 在"探索代码"和"生成 plan.md"之间插入讨论环节
    - 新步骤: 探索完成后 → 提出 2-3 个候选方案（含适配点、代价、参考来源）→ 说明倾向 → 等用户确认 → 再生成 plan.md
    - 明确讨论环节的输出格式
    - 明确讨论后 ADR 需记录被放弃的方案
  - verify: 执行步骤中有明确的"讨论→确认→生成"三段；"生成 plan.md"不再是探索后的直接下一步

- [x] T005 在 plan.md 中新增"跳过讨论的条件"
  - scope: `skills/sdd/references/stages/plan.md` — "执行原则"小节
  - maps_to: FR-007, FR-008, US2-3, US2-4
  - 改动要点:
    - 需求简单、只有一个合理方案 → 说明原因后直接生成
    - 用户明确说"你决定" → 给推荐理由后直接生成
    - 不涉及架构选择的纯实现 → 不强制方案对比
  - verify: 有明确的跳过条件列表；条件覆盖 spec 中的 US2-3 和 US2-4

- [x] T006 更新 plan.md 的"阶段完成标准"
  - scope: `skills/sdd/references/stages/plan.md` — "阶段完成标准"小节
  - maps_to: FR-006
  - 改动要点:
    - 新增"若经过方案讨论，ADR 已记录被放弃的方案及原因"
    - 新增"若跳过讨论，已说明跳过原因"
  - verify: 完成标准覆盖"讨论过"和"跳过"两种路径

---

## Phase 3: 验证

- [x] T007 结构验证
  - scope: 运行 `bash ./scripts/validate-sdd.sh`
  - verify: 脚本通过，无结构性错误

- [ ] T008 行为验证（dry-run）
  - scope: 用一个中等复杂度需求 dry-run sdd 流程
  - verify: clarify 阶段输出"发现"而非"问题清单"；plan 阶段在生成前先讨论候选方案
  - 注意: 此任务在实现完成后手动验证

---

## 依赖与顺序

- T001/T002/T003 互相关联但属于同一文件，建议顺序执行
- T004/T005/T006 互相关联但属于同一文件，建议顺序执行
- Phase 1 和 Phase 2 无依赖，可并行
- T007 依赖 Phase 1 + Phase 2 全部完成
- T008 依赖 T007 通过

---

## 覆盖检查

| 场景 / 需求 | 对应任务 |
|-------------|----------|
| US1 - clarify 主动挖掘 | T001, T002, T003 |
| US2 - plan 架构讨论 | T004, T005, T006 |
| NFR-001 - 小改动不变重 | T005 |
| NFR-002 - 不冗长教学 | T005 |

---

## Stage Readiness

- 推荐下一步：`implement`
- 阻塞项：无
