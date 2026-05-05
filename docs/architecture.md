# 架构说明

## 目标

这个仓库用于管理一组由我自己维护的 personal skills 源码资产。

`~/.agents/skills`、`~/.claude/skills` 等目录只是发布目标，不是源码编辑位置。

## 三层模型

### 1. 源码层

`skills/<skill-name>/` 是每个 skill 的真实编辑位置。

每个 skill 目录可以包含：

- `SKILL.md`
- `references/`
- `scripts/`
- `assets/`

### 2. 注册表层

`registry/skills.yaml` 负责声明：

- 哪些 skill 归本仓库管理
- 每个 skill 要发布到哪些运行时目录
- 它是原创还是 adopted
- 维护所需的最小元数据

### 3. 发布层

`scripts/` 下的脚本负责把 skill 以软链接形式发布到运行时目录：

- `~/.agents/skills/<name>`
- `~/.claude/skills/<name>`
- 可选：`~/.cursor/skills/<name>`

发布是单向的。运行时目录不能反向当作源码来源。

## 冲突策略

如果目标路径已经存在，且不是指向本仓库的软链接，则发布必须失败并报告冲突。

这样可以避免误覆盖第三方已安装 skill。

## 同步策略

- 所有源码修改只发生在本仓库
- 发布动作只负责创建和维护软链接
- 不从运行时目录反向同步回仓库
- 不自动跟随上游仓库做全量同步

## 演进原则

只有满足以下条件的外部 skill 才适合吸收进来：

- 会被重复使用
- 脱离原始环境后依然成立
- 我愿意自己维护
- 本地修改能在注册表中说明清楚
