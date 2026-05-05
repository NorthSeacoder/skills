---
name: knowledge-management
description: 使用 nmem CLI 管理个人知识库。支持总结对话、扫描目标内容、主动搜索相关知识、检测过时内容。
---

# 知识库管理

## 触发条件

### 触发词（用户说的话）

| 类型 | 示例 |
|------|------|
| 总结请求 | "总结一下"、"记录一下"、"保存这个"、"归档" |
| 知识库引用 | "结合知识库"、"参考知识库"、"查一下"、"我们为什么选择 X？" |
| 目标扫描 | "扫描 xxx 记录到知识库"、"把这个文件/目录记录下来"、"提取 xxx 的知识点" |
| 会话保存 | "保存此会话"、"checkpoint"（仅此时使用 `thread_persist`） |

### 自动行为（无需触发词）

**主动搜索时机**（应自动执行 `memory_search`）：
- 当前主题与先前工作相关时
- 问题类似于过去解决的问题时
- 用户询问之前的决策
- 复杂调试可能匹配过去的根本原因时

**过时检测**：
- 当基于知识库内容进行代码修改后，自动检测知识库是否过时并提醒用户

## 记忆质量标准

### 何时保存（`memory_add`）

- 解决复杂问题或调试后
- 做出重要决策并附带理由时
- 发现关键洞察（"啊哈"时刻）后
- 记录流程或工作流时

### 何时跳过

- 常规修复
- 进行中的工作
- 通用问答

### 质量要求

| 要求 | 说明 |
|------|------|
| **原子性** | 每条记忆独立、可操作，不模糊 |
| **独立上下文** | 不需要对话即可理解 |
| **关注学到什么** | 而非"讨论了什么" |

## 核心工作流

### 1. 知识库搜索（引用知识时）

```bash
# 1. 先搜索相关内容
nmem m search "关键词"

# 2. 结合搜索结果进行工作
# 3. 如果搜索结果与实际情况不符 → 进入更新流程
```

### 2. 知识总结（总结请求时）

当用户请求总结时，采用**多维度批量处理**流程：

#### 第 1 步：多维度知识提取

从对话中识别并拆分多个独立的知识点：

```
拆分维度参考：
- 按主题：不同的技术问题/功能模块
- 按类型：决策 vs 实现 vs 调试经验
- 按独立性：能否独立理解和复用

拆分原则：
- 每个知识点应该是"原子化"的，可独立检索和复用
- 相关但不同的内容应拆分（如：问题原因 vs 解决方案）
- 紧密耦合的内容保持在一起
```

输出格式：

```
📋 识别到 N 个知识点：

1. [类型] 标题
   摘要：...
   
2. [类型] 标题
   摘要：...
   
...
```

#### 第 2 步：捕获代码上下文（自动执行）

- 执行脚本：`python scripts/capture_code_context.py`
- 获取 JSON 输出：包含 project、branch、commit、git_root 等信息
- 从对话上下文中识别相关文件路径（如有）
- 为每个知识点关联对应的代码位置

#### 第 3 步：逐一去重检测

对**每个知识点**分别执行去重检测：

```bash
# 对于每个知识点 i：
nmem m search "知识点i的核心内容" -n 3
# 记录匹配结果（score > 0.75 视为重复）
```

#### 第 4 步：汇总展示 + 用户确认

先向用户展示完整的处理计划（文本输出），然后使用 `AskQuestion` 工具获取确认：

**文本展示**：
```
📋 知识总结计划（共 N 个知识点）：

1. [decision] 使用 Preact 替代 React
   labels: decision,oa,preact
   去重结果: ✅ 无相似内容 → 新建

2. [experience] 表格渲染性能问题排查
   labels: experience,oa,react,performance
   去重结果: ⚠️ 发现相似(72%): "React 表格优化经验..."
   建议: 合并到已有知识

3. [procedure] BatchModal 组件实现
   labels: procedure,oa,react
   去重结果: ✅ 无相似内容 → 新建
```

**调用 AskQuestion 工具**：
```json
AskQuestion({
  "title": "知识总结确认",
  "questions": [{
    "id": "confirm_action",
    "prompt": "请选择如何处理以上知识点",
    "options": [
      {"id": "all", "label": "全部确认执行"},
      {"id": "each", "label": "逐个确认（可调整/跳过/合并）"},
      {"id": "cancel", "label": "取消操作"}
    ]
  }]
})
```

**如果用户选择"逐个确认"**，对每个有相似内容的知识点继续调用：
```json
AskQuestion({
  "title": "知识点 2 处理方式",
  "questions": [{
    "id": "item_2_action",
    "prompt": "[experience] 表格渲染性能问题排查\n发现相似(72%): \"React 表格优化经验...\"",
    "options": [
      {"id": "create", "label": "仍然新建"},
      {"id": "merge", "label": "合并到已有知识"},
      {"id": "skip", "label": "跳过此条"}
    ]
  }]
})
```

#### 第 5 步：批量执行

根据用户确认的结果，批量执行操作：

```
执行结果：
✅ 知识点 1: 已新建 (memory_id: xxx)
✅ 知识点 2: 已合并到 memory_id: yyy
✅ 知识点 3: 已新建 (memory_id: zzz)

共处理 3 个知识点
```

#### 简化模式

如果用户明确只想记录单一知识点（如"记录：xxx"），则跳过拆分步骤，直接进入去重检测

### 3. 过时检测（自动执行）

当基于知识库搜索结果进行代码改动后，**自动**检查知识库是否过时：

```
判断标准：
- 知识库描述的实现方式与实际代码不符
- 知识库提到的 API/接口已变更
- 知识库记录的最佳实践已过时

如果过时 → 主动提醒用户并建议更新（无需用户请求）
```

### 4. 目标内容扫描（扫描请求时）

当用户请求扫描目标内容时，提取知识点并写入知识库。

**支持的目标类型**：

| 类型 | 示例 | 提取重点 |
|------|------|----------|
| 代码文件 | `.ts`, `.tsx`, `.js`, `.py` 等 | 关键实现、设计模式、API 用法 |
| 代码目录 | `src/components/` | 目录结构、模块划分、组件关系 |
| 文档文件 | `README.md`, `设计文档.md` | 架构决策、使用说明、约定 |
| 配置文件 | `tsconfig.json`, `vite.config.ts` | 关键配置项、配置决策 |

**扫描流程**：

```
1. 解析目标
   - 识别文件类型
   - 读取内容/遍历目录
   - 提取结构信息

2. 知识提取
   - 根据类型提取关键知识点
   - 每个知识点独立、原子化
   - 生成合适的标签

3. 后续流程（复用现有）
   - 去重检测
   - 用户确认
   - 批量执行
```

**扫描示例**：

```
用户: "扫描 src/hooks/use-batch-confirm.ts 记录到知识库"

系统执行:
1. 读取文件内容
2. 识别为 React Hook 实现
3. 提取知识点:
   - Hook 的功能和用途
   - 关键 API 设计
   - 使用示例
4. 生成 labels: procedure,oa,react,hooks
5. 进入去重检测 → 用户确认 → 保存
```

## Labels 规范

Labels 采用**扁平化设计**，用逗号分隔的字符串，无强制维度。

### 硬约束

| 约束 | ❌ 错 | ✅ 对 |
|------|------|------|
| `-l` 每次只传一个 label | `nmem m add ... -l "decision,note"` | `nmem m add ... -l decision -l note` |
| 单个 label 内**不含空格**，用连字符代替 | `-l "skill architecture"` | `-l skill-architecture` |
| 单个 label **小写** | `-l React` | `-l react` |

违反任何一条都会报 `validation error`，且错误信息不会直接指出是 labels 的问题。

### 推荐标签分类（仅作参考）

| 分类 | 推荐标签 | 说明 |
|------|----------|------|
| 类型 | `insight`, `decision`, `fact`, `procedure`, `experience` | 描述记忆性质 |
| 项目 | `oa`, `fintopia`, `yqg-slimfit` 等 | 根据实际项目名 |
| 技术 | `react`, `typescript`, `antd`, `css` 等 | 涉及的技术栈 |
| 其他 | `best-practice`, `bug-fix`, `api`, `experimental` 等 | 自由使用 |

### 类型标签说明

| 标签 | 何时使用 |
|------|----------|
| `insight` | 关键学习、领悟、"啊哈"时刻 |
| `decision` | 带有理由和权衡的选择 |
| `fact` | 重要信息、数据点 |
| `procedure` | 操作知识、工作流、实现方案 |
| `experience` | 调试经验、事件结果 |

### 项目标签生成

首次遇到新项目时：

```bash
# 1. 先查已有标签（通过搜索间接查看）
nmem m search "项目关键词" -n 5   # 看结果里用了哪些 label

# 2. 如果已有 → 复用已有名称（保持一致性）

# 3. 如果是新项目 → 按以下优先级推断：
#    a. package.json 的 name 字段
#    b. 项目根目录名（如 oa-next → oa）
#    c. 用户明确指定的名称
```

### Labels 示例

```
# OA 项目的技术决策
"decision,oa,react,typescript"

# Fintopia 基础库的实现方案
"procedure,fintopia,vue2"

# 关键领悟
"insight,react,performance,best-practice"

# 调试经验
"experience,oa,antd,bug-fix"
```

### 向后兼容

现有标签（`implementation`, `debugging`, `knowledge` 等）全部保留有效

## 内容格式

### ⚠️ Title 与 Content 分离（重要）

`memory_add` / `memory_update` 都提供了**独立的 `title` 参数**。必须遵守：

| 字段 | 要求 |
|------|------|
| `title` | **纯文本**，≤ 200 字符。**不要**带 `#`、`##`、反引号、emoji 前缀等 markdown 语法 |
| `content` | markdown 正文，**不要再以 `## 标题` 开头**（标题已经在 `title` 里了） |

**为什么**：如果 `title` 不传，后端会从 content 首行自动截取当 title，结果就是 title 里混进 `## `、`# 📍` 这种 markdown 符号，检索和展示都会非常难看。

### ❌ 错误示例

```python
memory_add(
    content="## 使用 Preact 替代 React\n\n通过 Vite 别名配置...",  # 标题写在 content 里
    labels="decision,astro-resume",
    # ❌ 没传 title，后端会把 "## 使用 Preact 替代 React" 当标题
)
```

### ✅ 正确示例

```python
memory_add(
    title="使用 Preact 替代 React",                    # 纯文本，独立字段
    content=(                                           # 正文直接从要点开始，不再写 ## 标题
        "通过 Vite 别名配置实现无缝替换，打包体积减小约 30%。\n"
        "\n"
        "### 📍 代码位置\n"
        "- **文件**: `vite.config.ts:15-20`\n"
        "- **分支**: `main`\n"
        "- **提交**: `f15008a`\n"
        "- **项目**: `astro-resume`\n"
    ),
    labels="decision,astro-resume,preact,performance",
    importance=0.8,
)
```

### Content 推荐结构（不含一级标题）

```markdown
（一句话摘要或核心结论）

（展开说明 / 理由 / 权衡）

### 📍 代码位置（自动捕获）

- **文件**: `src/components/Hero.tsx:15-20`
- **分支**: `main`
- **提交**: `f15008a`
- **项目**: `astro-resume`

### 相关代码（如有）

\`\`\`tsx
// 代码示例
\`\`\`
```

**代码位置格式说明**：
- 文件路径使用相对路径（相对于项目根目录）
- 如果知识涉及特定行号，使用 `文件名:起始行-结束行` 格式
- 分支和提交信息帮助追溯知识产生时的代码状态
- 项目名称用于区分多项目场景

### Title 命名建议

- 动宾或名词短语，一眼看懂讲的是什么
- 好：`使用 Preact 替代 React`、`表格选中行状态丢失问题`、`useBatchConfirm Hook 实现`
- 差：`## 决策`、`关于 React 的记录`、`标题`、`笔记 1`

## 操作速查

| 场景 | 命令 |
|------|------|
| 捕获代码上下文 | `python scripts/capture_code_context.py [--pretty]` |
| 搜索知识 | `nmem m search "关键词"` |
| 搜索知识（按 label 过滤）| `nmem m search "关键词" -l work -l react` |
| 添加知识 | `nmem m add "内容" -t "标题" -l label1 -l label2 -i 0.8`<br>⚠️ `-l` 每次只传一个 label，不能逗号拼接，详见 [Labels 规范](#labels-规范) |
| 管道输入多行内容 | `echo "长内容" \| nmem m add --stdin -t "标题" -l work` |
| 查看单条 | `nmem m show <memory_id>` |
| 更新知识 | 见下方「更新知识」章节 |
| 删除知识 | 先 `nmem m search` 获取 `memory_id`，再 `nmem m delete <memory_id>` |
| 保存会话 | `nmem t search`（仅用户明确请求时） |
| 搜索会话 | `nmem t search "关键词"` |
| 读取工作记忆 | `nmem wm` 或 `nmem wm read` |
| 更新工作记忆章节 | `nmem wm patch -s "章节名" "内容"` |

## 重要性评分参考

| 分数 | 适用情况 | 示例 |
|------|----------|------|
| 0.8-1.0 | 关键决策、突破性发现 | 核心架构决策、反复使用的最佳实践、经过生产验证 |
| 0.5-0.7 | 有用洞察、标准决策 | 常规技术实现、有参考价值的经验、解决方案 |
| 0.1-0.4 | 背景信息、次要细节 | 临时解决方案、待验证的探索（建议加 `experimental` 标签） |

## 更新知识

### 命令格式

```bash
# 仅改标题/重要性
nmem m update <id> -t "新标题" -i 0.9

# 替换整个 content（-c 传短内容）
nmem m update <id> -c "新内容"

# 替换整个 content（管道传长内容）
echo "$FULL_CONTENT" | nmem m update <id> -t "新标题"
```

⚠️ **没有 `--append`**：`nmem m update` 只支持整体替换 content，不支持追加。不要用 `--append`，会报错。

### 更新策略

`nmem m update -c` / 管道是**整体替换**，不是增量追加。因此更新前必须判断旧内容的哪些部分已过时：

| 旧内容状态 | 策略 | 做法 |
|-----------|------|------|
| 全部过时 | 整体重写 | 直接写新 content，丢弃旧内容 |
| 部分过时 | 编辑式替换 | 读取旧内容 → 定位过时段落 → 用新段落替换 → 整体写回 |
| 仅需补充 | 追加 | 读取旧内容 → 在末尾拼接新段落 → 整体写回 |

### 操作流程

```
1. nmem m show <id>        # 读取当前内容
2. 判断哪些段落过时/缺失
3. 构造完整的新 content（不是只写增量部分！）
4. echo "$NEW_CONTENT" | nmem m update <id> -t "标题（如需改）"
```

### 常见错误

| ❌ 错误做法 | ✅ 正确做法 |
|-----------|-----------|
| `nmem m update <id> --append "补充内容"` | 不存在 --append，用管道整体写入 |
| `nmem m update <id> -c "补充内容"` | -c 只传补充部分 → 旧内容被丢弃，只剩补充 |
| 不读旧内容直接管道写入 | 先 show 读取 → 构造完整内容 → 再写入 |

## Troubleshooting

### `nmem m add` 报错 `validation error`

按以下顺序排查：

1. **`-l` 传了逗号拼接的多 label？** → 每个 label 独立 `-l`：`-l decision -l note`，不是 `-l "decision,note"`
2. **label 内部有空格？** → 换成连字符：`-l skill-architecture`，不是 `-l "skill architecture"`
3. **label 含大写？** → 必须全小写：`-l react`，不是 `-l React`
4. **`-i` 超出 [0, 1]？** → 检查小数点位置

### `nmem m update` 报错 `unrecognized arguments: --append`

`nmem m update` 不支持 `--append` 参数。更新内容只能通过 `-c CONTENT` 或管道整体替换。详见上方「更新知识」章节。

### 连续多条 `nmem m add` 全部失败

```bash
# 检查服务健康
curl https://mem.mengpeng.tech/health
# status: ok + database_connected: true → 参数格式问题，按上面步骤排查
# status: degraded → 服务端问题，NAS 宿主机执行：
sudo systemctl restart nmem
```

### 搜索不到刚写入的内容

- embedding 索引异步更新，写入后立刻搜 score 会偏低，**等 1-2 秒再搜**
- 或用 `-l` 精确过滤已知 label 绕开相似度问题：`nmem m search "关键词" -l myproject`

## 自动行为清单

无需用户触发，AI 应主动执行：

| 时机 | 行为 |
|------|------|
| 当前主题与先前工作相关 | 主动执行 `nmem m search "关键词"` 查找相关知识 |
| 问题类似过去解决的问题 | 主动搜索可能的解决方案 |
| 复杂调试场景 | 搜索可能匹配的根本原因 |
| 基于知识库改动代码后 | 检测知识库是否过时，过时则使用 AskQuestion 询问是否更新 |
| 发现知识库与实际代码不符 | 主动建议更新知识库 |
| 对话即将结束且有新知识 | 使用 AskQuestion 询问是否需要总结记录 |
| 用户请求"总结"时 | 先分析对话是否涉及多个方面，如果是则拆分成多个知识点分别处理 |

### thread_persist 使用规则

**仅当用户明确请求时**使用 `thread_persist`：
- "保存此会话"
- "checkpoint"
- "保存对话"

**不要**在未询问的情况下自动保存对话线程

### 自动行为的 AskQuestion 示例

**对话结束时询问是否记录**：
```json
AskQuestion({
  "title": "知识总结提醒",
  "questions": [{
    "id": "should_summarize",
    "prompt": "本次对话涉及了一些技术知识，是否需要记录到知识库？",
    "options": [
      {"id": "yes", "label": "是，帮我总结"},
      {"id": "no", "label": "不需要"}
    ]
  }]
})
```

**知识库过时时询问是否更新**：
```json
AskQuestion({
  "title": "知识库可能过时",
  "questions": [{
    "id": "should_update",
    "prompt": "刚才的代码改动可能导致知识库内容过时：\n\"xxx 的实现方式\"\n\n是否需要更新？",
    "options": [
      {"id": "update", "label": "更新知识库"},
      {"id": "ignore", "label": "暂不更新"}
    ]
  }]
})
```

## 使用示例

### 场景1：记录架构决策（展示代码位置自动捕获）

**用户**："记录到知识库：使用 Preact 替代 React 以减小打包体积"

**系统执行流程**：

1. **提取知识**：使用 Preact 替代 React 以减小打包体积约 30%
2. **捕获代码上下文**：
   - 执行 `python scripts/capture_code_context.py`
   - 获得输出：`{"project": "astro-resume", "branch": "main", "commit": "f15008a", "in_git_repo": true, ...}`
   - 从对话识别文件：`vite.config.ts`
3. **生成 labels**：`decision,astro-resume,preact,performance`
4. **去重检测**：
   - 执行 `nmem m search "Preact React 打包" -n 3`
   - 未发现相似知识（score < 0.5）
5. **保存知识**：
   ```bash
   nmem m add "通过 Vite 别名配置实现无缝替换，打包体积减小约 30%。

   ### 📍 代码位置
   - **文件**: vite.config.ts:15-20
   - **分支**: main
   - **提交**: f15008a
   - **项目**: astro-resume" \
     -t "使用 Preact 替代 React" \
     -l decision -l astro-resume -l preact -l performance \
     -i 0.8
   ```

### 场景2：发现重复知识（展示智能去重检测）

**用户**："记录：Tailwind 配置使用 darkMode: class"

**系统执行流程**：

1. **提取知识**：Tailwind 配置使用 darkMode: class 实现主题切换
2. **捕获代码上下文**：`tailwind.config.ts`, `main`, `f15008a`
3. **去重检测**：
   - 执行 `nmem m search "Tailwind darkMode class" -n 3`
   - 发现相似知识：
     - [相似度: 85%] "Tailwind 主题配置：使用 darkMode: ['class'] 方案..."
4. **使用 AskQuestion 询问用户**：
   ```json
   AskQuestion({
     "title": "发现相似知识",
     "questions": [{
       "id": "duplicate_action",
       "prompt": "发现高度相似知识（相似度 85%）：\n\"Tailwind 主题配置：使用 darkMode: ['class'] 方案...\"\n\n建议合并到已有知识",
       "options": [
         {"id": "merge", "label": "合并到已有知识"},
         {"id": "create", "label": "单独保存"},
         {"id": "cancel", "label": "取消操作"}
       ]
     }]
   })
   ```
5. **用户选择 "合并到已有知识"**
6. **更新知识**：
   ```bash
   nmem m update mem_xxx "原有内容...

   ---

   补充：配置示例见 tailwind.config.ts:10-15"
   ```

### 场景3：多维度知识总结（展示批量处理流程）

**用户**："总结一下这个 chat"

**背景**：本次对话涉及了表格批量操作功能的开发，包含架构讨论、调试过程、最终实现。

**系统执行流程**：

1. **多维度知识提取**：
   ```
   📋 识别到 3 个知识点：

   1. [decision] 批量操作 Modal 的状态管理方案
      摘要：选择使用 useReducer 而非多个 useState，便于处理复杂的表单联动逻辑

   2. [experience] 表格选中行状态丢失问题
      摘要：rowKey 配置错误导致 selectedRowKeys 失效，需确保 rowKey 与数据源字段一致

   3. [procedure] PR 批量确认 Modal 组件
      摘要：封装了 useBatchConfirm hook，支持多种审批类型的批量处理
   ```

2. **捕获代码上下文**：
   - 项目：`oa-next`，分支：`feature/batch-modal`，提交：`a1b2c3d`
   - 关联文件：
     - 知识点1: `pr-batch-confirm-modal/index.tsx`
     - 知识点2: `affair-table/index.tsx`
     - 知识点3: `hooks/use-batch-confirm.ts`

3. **逐一去重检测**：
   ```bash
   nmem m search "useReducer useState 复杂表单" -n 3  # 无相似内容
   nmem m search "rowKey selectedRowKeys 表格选中" -n 3  # score 68%，发现 "Ant Design Table 选中问题"
   nmem m search "批量审批 hook Modal" -n 3  # 无相似内容
   ```

4. **汇总展示 + AskQuestion 确认**：
   
   先输出文本展示计划：
   ```
   📋 知识总结计划（共 3 个知识点）：

   1. [decision] 批量操作 Modal 的状态管理方案
      labels: decision,oa,react,hooks
      去重结果: ✅ 无相似内容 → 新建

   2. [experience] 表格选中行状态丢失问题
      labels: experience,oa,antd,bug-fix
      去重结果: ⚠️ 发现相似(68%): "Ant Design Table 选中问题"
      建议: 考虑合并

   3. [procedure] PR 批量确认 Modal 组件
      labels: procedure,oa,react,hooks
      去重结果: ✅ 无相似内容 → 新建
   ```
   
   然后调用 AskQuestion：
   ```json
   AskQuestion({
     "title": "知识总结确认",
     "questions": [{
       "id": "confirm_action",
       "prompt": "请选择如何处理以上 3 个知识点",
       "options": [
         {"id": "all", "label": "全部确认执行"},
         {"id": "each", "label": "逐个确认"},
         {"id": "cancel", "label": "取消操作"}
       ]
     }]
   })
   ```

5. **用户选择 "逐个确认"** → 对有冲突的知识点 2 继续调用：
   ```json
   AskQuestion({
     "title": "知识点 2 处理方式",
     "questions": [{
       "id": "item_2_action",
       "prompt": "[experience] 表格选中行状态丢失问题\n发现相似(68%): \"Ant Design Table 选中问题\"",
       "options": [
         {"id": "create", "label": "仍然新建"},
         {"id": "merge", "label": "合并到已有知识"},
         {"id": "skip", "label": "跳过此条"}
       ]
     }]
   })
   ```
   用户选择"合并到已有知识"

6. **批量执行**：
   ```
   执行结果：
   ✅ 知识点 1: 已新建 (memory_id: mem_abc)
   ✅ 知识点 2: 已合并到 memory_id: mem_xyz
   ✅ 知识点 3: 已新建 (memory_id: mem_def)

   共处理 3 个知识点
   ```

### 场景4：目标内容扫描（展示文件/目录扫描流程）

**用户**："扫描 src/hooks/use-table-selection.ts 记录到知识库"

**系统执行流程**：

1. **解析目标**：
   - 识别为 TypeScript 文件
   - 读取文件内容
   - 识别为 React Hook 实现

2. **知识提取**：
   ```
   📋 从文件中识别到 2 个知识点：

   1. [procedure] useTableSelection Hook 实现
      摘要：封装表格行选择逻辑，支持全选、反选、跨页保持选中状态

   2. [fact] 表格选中状态管理 API
      摘要：selectedRowKeys 与 onSelectChange 的配合使用方式
   ```

3. **捕获代码上下文**：
   - 项目：`oa-next`，分支：`main`，提交：`e5f6g7h`
   - 文件：`src/hooks/use-table-selection.ts`

4. **去重检测**：
   ```
   知识点1: memory_search("useTableSelection Hook 表格选择") → 无相似内容
   知识点2: memory_search("selectedRowKeys onSelectChange") → 相似度 45%（低于阈值）
   ```

5. **汇总展示 + 用户确认**：
   ```
   📋 知识扫描计划（共 2 个知识点）：

   1. [procedure] useTableSelection Hook 实现
      labels: procedure,oa,react,hooks,antd
      去重结果: ✅ 无相似内容 → 新建

   2. [fact] 表格选中状态管理 API
      labels: fact,oa,react,antd
      去重结果: ✅ 无相似内容 → 新建
   ```

6. **用户确认后保存**：
   ```bash
   nmem m add "封装表格行选择逻辑，支持全选、反选、跨页保持选中状态。

   ### 核心 API

   \`\`\`typescript
   const { selectedRowKeys, onSelectChange, clearSelection } = useTableSelection();
   \`\`\`

   ### 📍 代码位置
   - **文件**: src/hooks/use-table-selection.ts
   - **分支**: main
   - **提交**: e5f6g7h
   - **项目**: oa-next" \
     -t "useTableSelection Hook 实现" \
     -l procedure -l oa -l react -l hooks -l antd \
     -i 0.7
   ```
