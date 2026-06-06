# Feature Traits

Feature Traits 是一组布尔标签，用于在 specify 阶段标注 feature 特征，让下游阶段据此决定是否启用对应的强化规则。

## 定义

| Trait | 含义 | 检测信号 |
|---|---|---|
| `multi-stage-workflow` | feature 涉及 2+ 阶段协同或 pipeline | 描述中出现 publish → consume、generate → render、build → deploy 等多步骤串联；涉及定时任务链、事件驱动流水线 |
| `external-side-effects` | 涉及不可逆外部副作用 | 描述中出现 publish / deploy / send / writeback / 调用第三方 API / 写入外部存储；操作失败后无法自动回滚 |
| `artifact-handoff` | 一个阶段的产物被另一个阶段消费 | 存在明确的"A 生成 X，B 使用 X"关系；中间产物有格式约定或存储位置 |
| `user-visible-output` | 最终结果是用户可见内容 | 产出 UI 变化、文档、通知、报告、文件下载等用户直接感知的内容 |
| `prior-closure-failure` | 该 feature 或同类 feature 有过闭环断裂历史 | 上游 PRD 或讨论中引用了过去"模块有但端到端没通"的事故；存在已知的 regression 风险 |

## 触发规则

| 条件 | 触发的强化规则 | 生效阶段 |
|---|---|---|
| `multi-stage-workflow` OR `artifact-handoff` | Producer-Consumer Matrix | plan |
| `user-visible-output` OR `external-side-effects` | Evidence Gate | verify |
| `multi-stage-workflow` AND `user-visible-output` | Workflow Replay | closeout |
| 任一 trait 命中 | 三维 Verdict（Component / Workflow / User-Visible Outcome） | closeout / acceptance |
| 任一 trait 命中 | 默认生成或更新 `acceptance.md`，作为持久 completion record | closeout |

## 跳过条件

强化规则默认开启。以下情况可跳过，但必须在对应产物中记录跳过原因：

- spec.md 中 Feature Traits 段所有 trait 均标记为 ❌ → 后续阶段按基础流程推进，无需生成强化段落，也无需生成完整 `acceptance.md`
- 用户显式 override 某个 trait 为 ❌ 并给出理由 → 下游阶段以用户标注为准
- 用户显式选择轻量路径 → 可跳过完整 `acceptance.md`，但 closeout 必须用中文记录跳过原因
- 极小改动（文案修改、配置调整、单点 bugfix）→ 不强制走 traits 检测，也不强制生成完整 `acceptance.md`；但若已有 spec.md 则仍建议填写 traits

跳过时的记录格式：在对应段落位置写一行 `> 跳过：[原因]`，不留空白段落。

若任一 trait 命中且未被用户显式跳过，closeout 应使用 `templates/acceptance-template.md` 生成或更新 `specs/<feature>/acceptance.md`。最终对话回复只摘要验收文件路径、verdict、阻塞项和下一步，不替代持久记录。
