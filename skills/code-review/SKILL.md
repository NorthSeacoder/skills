---
name: code-review
description: 针对当前改动做交付前代码审查，优先找风险、回归、缺失测试、CI 和发布问题，而不是泛泛讲优化建议。
---

# Code Review

你是交付前的审查者。

你的首要目标不是给出泛泛而谈的建议，而是识别：

- 功能错误
- 回归风险
- 测试缺口
- 边界条件遗漏
- 配置、CI、GitHub Actions、发布流程问题

## 何时使用

在以下场景使用：

- 用户说“review 一下”“看看代码有没有问题”“合并前检查”
- 一组改动已经完成，准备进入提交、合并或发布
- 一个 feature 已经按 `implement` 或 `execute-plan` 推进完成
- diff 涉及 workflow、release、依赖、版本、构建配置

以下情况通常不必使用：

- 仍在需求澄清阶段
- 还没有形成可审查的代码改动
- 只是想讨论方案方向

## 核心原则

1. 先看行为风险，再看代码风格。
2. 先读 diff，再下结论。
3. 优先指出会影响合并或发布的问题。
4. 风格建议只有在影响维护性时才提高优先级。
5. 能安全自动修复的小问题可以直接修；行为变化类问题要明确说明。

## 审查深度

先判断本次审查深度：

### `quick`

适用于：

- 改动小
- 文件少
- 不涉及共享基础设施、认证、数据模型、workflow、发布

### `standard`

适用于：

- 常规 feature 或 bugfix
- 涉及多个文件或跨层改动
- 可能影响测试、状态或配置

### `deep`

适用于：

- 涉及认证、支付、权限、删除逻辑、共享基础库
- 改动 GitHub Actions / CI / 发布流程
- 新增依赖、修改版本或生成产物
- 跨前后端或影响面较大

审查深度越高，越要扩大验证和发布影响面的检查。

## 执行流程

### 1. 获取审查范围

优先读取：

- 当前工作树 diff
- 当前分支相对基线分支的 diff

如果范围不明确，先确认：

- 审当前工作树还是整个分支
- 审哪几个提交

### 2. 提取项目上下文

在开始审查前，按需读取公共项目上下文：

- README
- AGENTS / CLAUDE 说明（如存在）
- package manifests / lockfiles
- build config
- test config
- GitHub workflow 文件
- changelog / release notes

重点提取：

- 推荐验证命令
- 受保护或生成文件
- 依赖与构建方式
- CI / release 约束

如果项目文档或 CI 已明确验证命令，优先用它，而不是自行猜测。

### 3. 核对改动是否跑偏

先判断：

- 改动是否对准当前目标
- 是否混入无关重构
- 是否引入无明确理由的新依赖或新抽象

给出结论：

- `on-target`
- `drift`
- `incomplete`

### 4. 风险审查

按以下顺序检查：

1. **功能正确性**
2. **回归风险**
3. **错误处理与边界条件**
4. **数据与状态一致性**
5. **测试覆盖**
6. **配置 / CI / GitHub Actions / Workflow 影响**
7. **文档 / 发布影响**

详细检查点见：

- `checklist.md`
- `risk-patterns.md`

### 5. 硬阻塞项

以下问题默认归为硬阻塞：

- 会导致错误行为或数据破坏的缺陷
- 明显的回归风险且无保护
- 改动关键逻辑但没有必要测试
- GitHub Actions / workflow 改坏验证或发布链路
- 版本、生成产物、release 文件明显不一致
- 引入依赖但理由不清或影响未知
- 隐藏的自动执行破坏性操作

### 6. Findings 分类

把发现分成四类：

- `must-fix`：不修不应合并
- `should-fix`：建议本轮修
- `follow-up`：可后续处理
- `note`：仅提示

### 7. 验证要求

审查结论里必须明确验证状态。

规则：

- 如果项目已有验证命令，优先使用该命令
- 如果没有清晰命令，应明确写出“验证命令未知”
- 不能把“没跑验证”说成“已通过”

至少说明：

- 跑了什么
- 结果如何
- 是否仍有验证空白

### 8. GitHub Actions / Release 专项检查

如果 diff 涉及以下内容，必须单独检查：

- `.github/workflows/*`
- release scripts
- version 字段
- changelog
- package / artifact / publish 配置

重点检查：

- workflow 是否还能正常触发
- 权限、缓存、matrix、并发策略是否合理
- 版本号是否同步
- 生成产物是否应该更新
- 发布链路是否缺失关键步骤

### 9. 输出审查结果

先给 findings，再给总结。

如果没有明显问题，也要明确说明：

- 审查范围
- 审查深度
- 验证状态
- 剩余风险
- 是否适合合并 / 发布

## 输出格式

建议使用以下结构：

```markdown
## Findings

1. [must-fix|should-fix|follow-up|note] path/to/file
   - problem
   - impact
   - suggested fix

## Open Questions

- ...

## Summary

- scope: on-target / drift / incomplete
- review depth: quick / standard / deep
- verification: [command] -> pass / fail / unknown
- merge/release recommendation
```

## 注意事项

- 不要把 review 退化成“可以再抽个函数”
- 不要用大量低价值样式建议淹没真正风险
- 不要在没看 diff 时泛泛而谈
- 如果涉及 GitHub Actions、CI 或发布流程，必须把这些文件纳入主审查范围
