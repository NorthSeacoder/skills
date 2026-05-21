# skills

[![skills.sh](https://skills.sh/b/NorthSeacoder/skills)](https://skills.sh/NorthSeacoder/skills)

这是我维护的一组个人 skills 源仓库，现以 `skills.sh` 兼容仓库的方式分发。

仓库里的内容分三类：

- 公开分发 skill：当前明确对外承诺的 installable skill
- 自用 skill：仍放在 `skills/` 下维护，但默认不承诺跨环境可用
- 仓库治理与 workflow 资产：用于说明、维护或支撑 skill 演进，不属于公开安装接口

## 当前公开 skill

- `sdd`：单入口的软件交付工作流 skill，覆盖 ideate、specify、clarify、plan、tasks、implement、code-review、execute-plan

## 当前自用 skill

以下 skill 同样放在 `skills/` 下，并可通过 `skills` 统一安装到本地运行时，但默认按自用 workflow 维护，不作为跨环境可用性承诺，也不因为与 `sdd` 同仓存在就自动进入公开分发叙事：

- `knowledge-management`
- `debug`
- `git-guard`

## 安装

推荐直接安装整个仓库：

```bash
DISABLE_TELEMETRY=1 npx skills add NorthSeacoder/skills
```

只安装 `sdd`：

```bash
DISABLE_TELEMETRY=1 npx skills add git@github.com:NorthSeacoder/skills.git --skill sdd
```

> `DISABLE_TELEMETRY=1` 用于关闭 `skills` CLI 的匿名 telemetry。  
> 这只是安装时的隐私设置，不代表仓库内所有 skill 都适合公开分发。

## 使用方式

安装后，直接在会话里提到 `sdd` 即可，不需要再手动切换 `specify`、`plan`、`tasks` 等旧子 skill 名称。

`sdd` 会按当前输入判断阶段：

- 需求模糊时先 `ideate`
- 需求清晰后写 `spec`
- 再进入 `clarify`、`plan`、`tasks`
- 实现阶段通过 `execute-plan` 控节奏，再进入 `implement`
- 收尾时进入 `code-review`

`sdd` 只负责软件交付 workflow 本身，不负责统一路由 `debug`、`git-guard`、`knowledge-management` 等其他 skill。

## 仓库结构

```text
docs/
  architecture.md
  maintenance.md
  adoption-policy.md
skills/
├── debug/
├── git-guard/
├── knowledge-management/
├── sdd/
│   ├── SKILL.md
│   ├── references/stages/
│   └── templates/
```

约定：

- `skills/<name>/` 是 skill 源码目录
- `skills/sdd/references/stages/` 存放 `sdd` 的阶段方法论
- `skills/sdd/templates/` 存放写入 `specs/<feature>/` 的模板
- `docs/` 存放仓库治理、维护边界和纳入策略
- 不再使用 `registry + publish-links` 的本地软链接发布模型

说明：

- `sdd` 是当前主公开 skill
- 其他 skill 可以保留在仓库里继续维护，但不自动成为公开 skill
- `skills/` 下的目录位置不等于公开承诺；是否公开以 README 和相关治理文档为准
- 关闭 telemetry 只影响匿名上报，不等于这些 skill 自动具备公开分发承诺

## 配置约定

需要私有配置的 skill 应按 skill 维度说明环境变量，而不是混用单一仓库级配置。

- 优先使用带 skill 前缀的变量名，例如 `SDD_*`
- 若提供示例配置，放在 skill 自身目录下
- README 只说明约定，不假设 `skills.sh` 平台会自动隔离或加载每个 skill 的 `.env`

## 维护边界

本仓库优先收录：

- 会重复使用的 workflow skill
- 可单独理解、可维护的 skill
- 我明确愿意继续维护的 adopted skill

不适合公开分发但仍有保留价值的 skill，可以继续保留源码，但不会默认写进公开安装说明。

仓库治理文档、模板、阶段说明和未来的校验脚本，都是仓库资产，不属于对外安装接口。

## 文档

- [架构说明](./docs/architecture.md)
- [维护规范](./docs/maintenance.md)
- [纳入策略](./docs/adoption-policy.md)

## 致谢

部分 skill 设计和工作流表达参考了以下仓库中的公开实践：

- `~/personal/skills/agent-skills`
- `~/personal/skills/gstack`
- `~/personal/skills/skills`
- `~/personal/skills/Waza`
