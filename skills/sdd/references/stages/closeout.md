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
- 形成最终 completion record

## 核心原则

- `Closeout` 不是礼貌性收尾，而是最后一道 workflow gate
- 没做退役检查，不应默认旧逻辑可以继续留在主链
- 文档和知识同步只做必要同步，不引入重流程

## Closeout Checklist

- 检查旧逻辑、旧路径、fallback 或临时兼容是否需要退役
- 检查是否还有未处理的发布、提交、CI 或 follow-through 事项
- 检查相关文档、阶段说明、模板或 acceptance 记录是否需要更新
- 检查关键架构决策是否需要保留在 completion record 或后续文档中
- 检查是否留下架构债、临时兼容、演进触发信号或后续重构观察点
- 检查是否需要做必要的知识同步或经验沉淀
- 若 spec.md 中同时命中 `multi-stage-workflow` 和 `user-visible-output`（参考 `../feature-traits.md`），执行 workflow replay 并把输入摘要、最终 payload 摘要、用户可见结果断言写入 acceptance.md

## 执行步骤

1. 读取 `Verify` 的最终 Verdict 和剩余事项
2. 按 checklist 逐项检查
3. 明确哪些项已完成、哪些项刻意延后、哪些项不适用
4. 若 spec.md 中任一强化 trait 命中（参考 `../feature-traits.md`），使用 `../../templates/acceptance-template.md` 写 acceptance.md，包含 Evidence Table 和三维 Verdict（Component / Workflow / User-Visible Outcome）
5. 更新最终 completion record（必要时写入 `acceptance.md`）
6. 宣布 feature 完成或指出未完成收尾项

## 回退条件

- 若 `Verify` 未通过，返回 `verify`
- 若 checklist 暴露出必须修复的旧逻辑或遗漏事项，返回 `implement` 或 `verify`

## 下一步

- 收尾完成：结束当前 feature
- 仍有收尾阻塞：继续 `closeout` 或回退到 `implement` / `verify`

## 阶段完成标准

- closeout checklist 已执行
- 已说明旧逻辑退役、follow-through、文档更新和知识同步状态
- 已说明 ADR 保留、架构债和演进触发信号状态；不适用时也明确标注
- 已形成最终 completion record，或明确说明为什么不能宣布完成
