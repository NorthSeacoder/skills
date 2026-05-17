# 架构说明

## 目标

这个仓库用于管理一组由我自己维护、并优先以 `skills.sh` 方式分发的 skill 源码资产。

本仓库的真实编辑位置始终是 `skills/`。本地运行时目录如 `~/.agents/skills`、`~/.claude/skills` 不再是主发布模型。

## 两层模型

### 1. 源码层

`skills/<skill-name>/` 是每个 skill 的真实编辑位置。

常见结构：

- `SKILL.md`：对外入口
- `references/`：说明材料
- `templates/`：写入工作区的模板
- `scripts/`：确有必要时才保留

### 2. 分发与文档层

仓库通过 `skills.sh` 文档化安装方式进行分发：

- 仓库级安装：`npx skills add NorthSeacoder/skills`
- 单 skill 安装：`npx skills add <repo> --skill <name>`

README、AGENTS 和 `docs/*` 共同定义哪些 skill 对外公开、如何安装、如何使用、有哪些配置前提。

## SDD 收敛模型

当前主公开 skill 是 `sdd`。

它不再拆成多个独立 installable skill，而是统一收敛为：

- `skills/sdd/SKILL.md`：单入口路由
- `skills/sdd/references/stages/`：阶段方法论
- `skills/sdd/templates/`：规格、计划、任务等模板

这样做的目的：

- 对外只有一个清晰入口
- 对内仍然保留阶段化方法论
- 模板和流程说明分层维护，避免巨型 `SKILL.md`

## 公开边界

- 公开 skill：会出现在 README 安装说明中，并承诺基本可移植
- 非默认公开 skill：可以保留源码，但不会自动写进公开安装说明

是否公开不由 telemetry 决定。关闭 telemetry 只影响 CLI 统计上报，不影响 skill 源码本身是否公开可见。

## 演进原则

只有满足以下条件的 skill，才适合进入公开安装叙事：

- 会被重复使用
- 脱离原始环境后依然成立
- 我愿意自己维护
- 前置依赖和配置方式可以被清楚说明
