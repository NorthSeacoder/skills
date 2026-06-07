---
source: sdd custom stage
---

# Closeout Stage

在验证通过后做最后收尾，确保旧逻辑退役、发布跟进、文档更新和必要知识同步真正完成，而不是把“验证通过”直接当成“整个 feature 结束”。

## 何时进入

- `Verify` 已给出 `PASS`
- 当前 feature 已具备进入收尾的证据基础

## 目标

- 执行 closeout checklist
- 检查旧逻辑退役与后续跟进事项
- 检查必要的 ADR 保留、架构债记录和演进触发信号
- 使用 verify evidence package 形成最终 completion record
- 当任一 Feature Trait 命中时，生成或更新 `acceptance.md` 作为持久验收记录
- 若当前 feature 属于 roadmap，回写 roadmap 状态并推荐下一个 feature
- 如当前 feature 有相关 diff，生成 commit plan；只有用户明确确认后，才执行本地 `git add` / `git commit`

## 核心原则

- `Closeout` 不是礼貌性收尾，而是最后一道 workflow gate
- 没做退役检查，不应默认旧逻辑可以继续留在主链
- 文档和知识同步只做必要同步，不引入重流程
- `acceptance.md` 是命中 trait 时的持久 completion record；最终对话回复只摘要路径、verdict、阻塞项和下一步
- 中文记录必须短、准、可审计。每个结论都对应状态、证据或下一步，不写空泛段末总结句
- commit 是外部副作用。必须先展示 commit plan，再等待用户明确确认；未确认不得执行 `git add` 或 `git commit`
- 提交只允许添加 commit plan 中批准的文件；不得使用 `git add -A`、`git add .` 或等价宽泛命令；不得自动 `git push`

## Closeout Checklist

- 检查旧逻辑、旧路径、fallback 或临时兼容是否需要退役
- 检查是否还有未处理的发布、提交、CI 或 follow-through 事项
- 若需要提交，使用 `../../templates/commit-plan-template.md` 生成 commit plan，列出 included files、excluded files、needs user decision、risks 和 commit batches
- 检查相关文档、阶段说明、模板或 acceptance 记录是否需要更新
- 检查关键架构决策是否需要保留在 completion record 或后续文档中
- 检查是否留下架构债、临时兼容、演进触发信号或后续重构观察点
- 检查是否需要做必要的知识同步或经验沉淀
- 检查当前 feature 是否属于 `specs/<umbrella>/roadmap.md`；若属于，检查 roadmap 的 `Current Feature` 与 `specs/.active` 是否一致
- 若 spec.md 中同时命中 `multi-stage-workflow` 和 `user-visible-output`（参考 `../feature-traits.md`），执行 workflow replay 并把输入摘要、最终 payload 摘要、用户可见结果断言写入 acceptance.md

每个 checklist 项必须标注状态：`已完成` / `延后` / `不适用` / `阻塞`。每项都必须给出一句证据或依据；出现 `阻塞` 时不得宣布 feature 完成。

## Acceptance Record Rules

- 若 spec.md 中任一 Feature Trait 命中，且用户未显式选择轻量路径，必须使用 `../../templates/acceptance-template.md` 写入或更新 `specs/<feature>/acceptance.md`
- `acceptance.md` 必须包含 verify 产出的 Evidence Table、三维 Verdict、必要的 Workflow Replay、Closeout Checklist 和 Completion Record
- 若所有 trait 均为 ❌，或用户显式选择轻量路径，可跳过完整 `acceptance.md`，但必须用中文记录跳过原因
- closeout 对话输出不得替代 `acceptance.md`；只摘要验收文件路径、Overall verdict、阻塞项、延后项和下一步

## Commit Planning Rules

- 若工作树存在 dirty files 或 staged changes，必须先判断是否与当前 feature 相关。
- commit plan 必须包含：
  - Included Files：建议提交的文件和归属依据
  - Excluded Files：明确不提交的文件和排除理由
  - Needs User Decision：归属不确定、必须由用户确认的文件
  - Risks：staged changes、ignored runtime files、symlink、submodule、删除等结构性风险
  - Commit Batches：每批文件、commit message 和拆分依据
- 只要存在 Needs User Decision，或用户尚未明确确认，不得执行提交。
- 执行提交时只允许 `git add <approved-file...>`；不得使用 `git add -A` 或宽泛 add。
- 每个 batch 单独 `git commit`；任一 batch 失败时停止并报告已执行到哪一步。
- 不自动 `git push`。push 必须由用户另行明确要求。
- 如果没有相关 diff，记录 `no related diff`，不得创建空 commit。

## 执行步骤

1. 读取 `Verify` 的 evidence package、最终 Verdict 和剩余事项
2. 按 checklist 逐项检查
3. 明确哪些项已完成、哪些项刻意延后、哪些项不适用、哪些项阻塞
4. 若 spec.md 中任一强化 trait 命中（参考 `../feature-traits.md`），使用 `../../templates/acceptance-template.md` 写 acceptance.md，包含 Evidence Table、三维 Verdict（Component / Workflow / User-Visible Outcome）、必要的 Workflow Replay、Closeout Checklist 和 Completion Record
5. 若未命中 trait 或用户显式选择轻量路径，记录中文跳过原因，并给出简短 closeout 结论
6. 若当前 feature 属于 roadmap：
   - `PASS` 时将当前 feature 标记为 `done`
   - `CONDITIONAL PASS` 时标记为 `conditional`，并记录缺口
   - 仍有阻塞时标记为 `blocked`
   - 写入 Completion Log，包含日期、verdict、验收文档路径或证据摘要、对后续 feature 的影响
   - 按依赖和启动条件重新计算 `Next Recommended Feature`
7. 如果存在待提交相关 diff 或用户要求提交：
   - 使用 `../../templates/commit-plan-template.md` 生成 commit plan
   - 展示 included / excluded / needs decision / risks / batches
   - 等待用户明确确认
   - 确认后只 add 批准文件并按 batch commit
   - 将 commit hash、message、文件摘要或未提交原因写入 completion record
8. 摘要验收文件路径、verdict、commit 状态、阻塞项、延后项和下一个推荐 feature；若无可推荐项，建议做 roadmap closeout

## 回退条件

- 若 `Verify` 未通过，返回 `verify`
- 若 checklist 暴露出必须修复的旧逻辑或遗漏事项，返回 `implement` 或 `verify`
- 若 roadmap 的 `Current Feature` 与 `specs/.active` 不一致，先修正 roadmap 或 `.active` 后再继续 closeout
- 若 commit plan 存在 Needs User Decision，等待用户决策；不得继续执行提交
- 若 git add/commit 失败，停止后续 batch，记录失败命令、失败原因和已完成步骤

## 下一步

- 收尾完成：结束当前 feature
- 收尾完成且 roadmap 仍有未完成项：推荐下一个 feature 及建议阶段
- 收尾完成且 roadmap 无未完成项：建议做 roadmap closeout
- commit plan 已生成但未确认：等待用户确认、修改计划或选择暂不提交
- 仍有收尾阻塞：继续 `closeout` 或回退到 `implement` / `verify`

## 阶段完成标准

- closeout checklist 已执行
- 已说明旧逻辑退役、follow-through、文档更新和知识同步状态
- 已说明 ADR 保留、架构债和演进触发信号状态；不适用时也明确标注
- 已形成最终 completion record，或明确说明为什么不能宣布完成
- 若任一 Feature Trait 命中且未选择轻量路径，`acceptance.md` 已写入或更新
- 最终对话输出是 `acceptance.md` 的摘要，不是唯一完成记录
- 若当前 feature 属于 roadmap，已更新 roadmap 状态、Completion Log 和 Next Recommended Feature；若未更新，已说明不适用或阻塞原因
- 若存在相关 diff，已生成 commit plan 并记录用户确认状态；若已提交，completion record 已记录 commit hash；若未提交，已记录原因和剩余 dirty files
