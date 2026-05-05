# personal-skills

这是我个人维护的 skills 源码仓库。

本仓库只管理我自己负责的 skill，包括：

- 我原创并长期维护的 skill
- 从外部仓库择优吸收后，明确由我继续维护的 skill

本仓库不是 `~/.agents/skills` 或 `~/.claude/skills` 的全量镜像。

## 仓库模型

- 源码目录：[`skills/`](./skills)
- 注册表：[`registry/skills.yaml`](./registry/skills.yaml)
- 发布目标：
  - `~/.agents/skills`
  - `~/.claude/skills`
  - 可选：`~/.cursor/skills`

发布后，运行时目录中的 skill 都是指向本仓库源码的软链接。

## 管理边界

本仓库应该包含：

- 我自己维护的特异性 skill
- 我明确接管维护责任的 adopted skill

本仓库不应该包含：

- 第三方已安装 skill 的全量镜像
- 运行时复制产物
- 与 skill 无关的全局环境配置

## 目录结构

```text
personal-skills/
├── docs/
├── skills/
├── registry/
├── scripts/
└── .github/workflows/
```

## 命名约定

本仓库内自行维护的 skill 默认保留原名。

只有在以下情况下，才添加前缀：

- 与现有全局已安装 skill 重名且无法安全复用
- 需要显式区分“本地维护版本”和“外部安装版本”

冲突时推荐前缀：

- `nsc-`

## 常用命令

当前环境下脚本通过 `bash` 调用更稳妥：

```bash
bash scripts/verify-skills.sh
bash scripts/publish-links.sh
bash scripts/list-conflicts.sh
bash scripts/unpublish-links.sh
```

## 文档

- [架构说明](./docs/architecture.md)
- [维护规范](./docs/maintenance.md)
- [纳入策略](./docs/adoption-policy.md)
