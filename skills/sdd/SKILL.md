---
name: sdd
description: 单入口的软件交付工作流 skill。覆盖 ideate、specify、clarify、plan、tasks、implement、code-review、execute-plan 的阶段判断、产物约定与下一步衔接。
---

# SDD

你是单入口的 SDD workflow skill。

你的职责不是把所有阶段规则都塞进一个文件，而是根据当前输入判断最合适的阶段，调用对应的阶段说明，并维持统一的工作区约定。

## 何时使用

适用于：

- 用户明确提到 `sdd`
- 用户希望从模糊想法推进到规格、方案、任务、实现或审查
- 当前工作已经在 `specs/<feature>/` 流程中，需要继续下一阶段

通常不必使用：

- 极小改动
- 独立且低风险的单点修复
- 明确只想做非 SDD 类工作

## 工作区约定

所有正式产物默认写入：

- `specs/<feature>/spec.md`
- `specs/<feature>/plan.md`
- `specs/<feature>/tasks.md`
- 按需：`data-model.md`、`acceptance.md`

当前 active feature 记录在：

- `specs/.active`

## 阶段路由

根据当前输入判断进入哪一阶段：

1. **需求模糊、还在探索**
   - 进入 `references/stages/ideate.md`
2. **需求已清晰，需要固化 spec**
   - 进入 `references/stages/specify.md`
3. **spec 已有，但存在关键歧义**
   - 进入 `references/stages/clarify.md`
4. **spec 已稳定，需要技术方案**
   - 进入 `references/stages/plan.md`
5. **plan 已稳定，需要拆执行任务**
   - 进入 `references/stages/tasks.md`
6. **tasks 已明确，需要推进实现**
   - 进入 `references/stages/execute-plan.md` 决定节奏
   - 再进入 `references/stages/implement.md`
7. **实现已完成，需要交付前检查**
   - 进入 `references/stages/code-review.md`

## 路由原则

- 先判断用户当前所处阶段，再进入对应材料
- 不要要求用户记住旧子 skill 名称
- 每一阶段结束时，都要明确下一步推荐
- 如果发现上游产物不足，应返回上游阶段，而不是硬推进

## 模板与资产

工作区模板统一位于：

- `templates/spec-template.md`
- `templates/checklist-template.md`
- `templates/plan-template.md`
- `templates/data-model-template.md`
- `templates/tasks-template.md`

阶段细则统一位于：

- `references/stages/*.md`

## 输出要求

每次进入某一阶段后，输出至少要说明：

1. 当前进入的是哪个阶段
2. 当前依据是什么
3. 本阶段将产出或更新什么
4. 本阶段结束后的下一步建议
