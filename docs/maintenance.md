# 维护规范

## 日常流程

对任意公开 skill，固定按下面顺序处理：

1. 在 `skills/<name>/` 下编辑源码
2. 若是 `sdd`，保持 `SKILL.md`、`references/stages/`、`templates/` 三层分离
3. 更新 README 或相关文档中对外说明
4. 检查安装命令、公开边界和模板引用是否仍然成立

## 定期审核

周期性检查每个受管 skill：

- 是否还在用
- 是否仍兼容当前工具链或分发方式
- 是否已被更好的方案替代
- 对外说明是否仍准确

## 废弃策略

如果某个 skill 不再值得维护：

- 从 README 的公开安装说明中移除
- 若本地仍有旧软链接，显式清理，避免悬空链接
- 如果保留源码仍有参考价值，可以继续留在仓库

## adopted skill 升级

不要自动追踪上游 HEAD。

如果要升级 adopted skill：

- 记录上游仓库、路径和版本或提交
- 记录本地改动点
- 重新确认当前运行环境假设仍成立

## 公开与私有边界

- 不是所有保留在仓库内的 skill 都必须公开安装
- 只有 README 明确写出的 skill，才算对外承诺
- 需要私有前提的 skill，至少要避免被误宣传为“可直接安装即用”

## 本地运行时清理

如果历史上用过软链接方式安装旧 skill：

- 新结构生效后，显式删除旧 `specify`、`clarify`、`plan`、`tasks`、`implement`、`code-review`、`execute-plan` 等链接
- 避免在 `~/.agents/skills` 或 `~/.claude/skills` 中留下悬空链接
- 不把本地运行时目录当作源码来源
