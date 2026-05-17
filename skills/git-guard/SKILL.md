---
name: git-guard
description: 阻止危险 git 操作——通过 PreToolUse hook 拦截不可逆命令，防止 force push、硬重置、分支删除等误操作。用于保护工作树和远程仓库完整性。不用于常规 git 工作流指导。
---

# Git Guard

你是 git 操作的安全护栏。

你的职责是通过 PreToolUse hook 拦截危险的 git 命令，防止不可逆操作对工作树和远程仓库造成破坏。你不负责指导 git 工作流——那是 `git-workflow` 的事。

## 何时使用

适用于：

- 在 Claude Code 中执行 git 命令时自动拦截
- 防止误执行不可逆的 git 操作
- 保护未提交的工作和远程分支完整性

通常不必使用：

- 常规 git 操作（commit、push、merge、rebase）
- 非 git 相关的操作
- 用户明确要求跳过保护时

## 核心原则

1. **不可逆操作必须拦截。** 不可逆 = 执行后无法通过简单操作恢复原状态。
2. **拦截时给出明确原因和替代方案。** 只拦截不给替代是制造障碍，不是保护。
3. **保护范围最小化。** 只拦截真正危险的命令，不阻碍正常工作流。
4. **用户有最终决定权。** 用户明确确认后可以执行任何操作。

## 拦截规则

### 硬拦截（默认阻止）

以下命令未经明确确认不得执行：

| 命令 | 危险原因 | 替代方案 |
|------|----------|----------|
| `git push --force` | 覆盖远程历史，他人提交可能丢失 | `git push`（不带 force） |
| `git push -f` | 同上 | 同上 |
| `git reset --hard` | 丢弃所有未提交改动和工作树变更 | `git stash` + `git reset`（不带 --hard） |
| `git clean -f` | 永久删除未跟踪文件 | 先确认文件可删，或手动逐个删除 |
| `git branch -D` | 强制删除分支（含未合并提交） | `git branch -d`（检查合并状态后再删） |
| `git checkout .` | 丢弃所有工作树改动 | `git stash`（保留改动） |
| `git restore .` | 同上 | 同上 |
| `git push origin +<branch>` | force push 的另一种写法 | 普通 push |

### 条件拦截（需确认）

以下命令在特定条件下需要确认：

| 命令 | 触发条件 | 确认内容 |
|------|----------|----------|
| `git push` | 推送到 main/master 分支 | "确认推送到主分支？" |
| `git rebase` | 有未提交改动时 | "先 stash 或 commit 当前改动" |
| `git merge` | 合并到受保护分支 | "确认合并到受保护分支？" |

### 不拦截

以下操作属于正常工作流，不拦截：

- `git commit`、`git add`、`git status`、`git log`、`git diff`
- `git push`（非 force，非推送到主分支）
- `git branch`（创建/切换/列表）
- `git stash`、`git merge`（非受保护分支）
- `git rebase`（无未提交改动时）

## 安装方式

将以下 hook 脚本添加到 Claude Code 的 settings.json 中：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "git-guard-check"
          }
        ]
      }
    ]
  }
}
```

### Hook 脚本

创建 `git-guard-check` 脚本（放在 PATH 中或使用绝对路径）：

```bash
#!/bin/bash
# git-guard-check — PreToolUse hook for Claude Code
# Reads tool input from stdin, blocks dangerous git commands

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Extract the git subcommand and flags
if echo "$COMMAND" | grep -qE '^git\s'; then
  # Hard block patterns
  if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(--force|-f\b)|git\s+push\s+.*\+\w'; then
    echo "BLOCKED: git push --force 会覆盖远程历史，可能导致他人提交丢失。替代方案：使用普通 git push。"
    exit 1
  fi
  if echo "$COMMAND" | grep -qE 'git\s+reset\s+.*--hard'; then
    echo "BLOCKED: git reset --hard 会丢弃所有未提交改动。替代方案：git stash + git reset（不带 --hard）。"
    exit 1
  fi
  if echo "$COMMAND" | grep -qE 'git\s+clean\s+.*-f'; then
    echo "BLOCKED: git clean -f 会永久删除未跟踪文件。替代方案：先 ls 确认文件列表，再逐个删除。"
    exit 1
  fi
  if echo "$COMMAND" | grep -qE 'git\s+branch\s+.*-D\b'; then
    echo "BLOCKED: git branch -D 强制删除分支，未合并的提交会丢失。替代方案：git branch -d（检查合并状态后删除）。"
    exit 1
  fi
  if echo "$COMMAND" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
    echo "BLOCKED: git checkout . / git restore . 会丢弃所有工作树改动。替代方案：git stash（保留改动）。"
    exit 1
  fi
fi

exit 0
```

### 安装步骤

1. 将脚本保存到 `~/.local/bin/git-guard-check`（或任意 PATH 位置）
2. `chmod +x ~/.local/bin/git-guard-check`
3. 在 `~/.claude/settings.json` 的 hooks.PreToolUse 中添加上述配置
4. 测试：在 Claude Code 中尝试 `git push --force`，应被拦截

## 常见借口

| 借口 | 真相 |
|------|------|
| "我知道自己在做什么，跳过保护" | 知道自己在做什么 = 你能说出具体影响并接受后果。那就明确确认，而不是悄悄绕过。 |
| "这个 force push 是必须的" | 必须的 = 你能解释为什么普通 push 不行。如果能解释，确认后可以执行。不能解释 = 不是必须的。 |
| "reset --hard 只是清理本地" | 清理本地 = 丢弃所有未提交改动。你确定没有任何未保存的工作？stash 先，再 reset。 |
| "分支已经合并了，-D 没问题" | 没问题 = 你验证过合并状态。-d 会帮你验证，-D 会跳过验证。用 -d。 |
