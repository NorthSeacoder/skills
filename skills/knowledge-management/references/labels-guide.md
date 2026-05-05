# Labels 生成指南

## 设计理念

Labels 采用**扁平化、可读**的设计，将原来需要在内容头部声明的元信息（Type, Domain, Scope）编码到 labels 中，实现：

1. **一致性**：所有元信息通过统一的 labels 机制管理
2. **可搜索**：可以通过任意维度组合搜索
3. **简洁性**：内容部分不再需要重复声明元信息

## 必填 Labels 详解

### Type（记录类型）

| 值 | 含义 | 适用场景 |
|----|------|----------|
| `decision` | 技术决策 | 选型理由、架构设计、为什么这样做 |
| `implementation` | 实现方案 | 具体代码、配置、步骤说明 |
| `debugging` | 调试经验 | 问题排查、踩坑记录、错误解决 |
| `knowledge` | 客观知识 | API 文档、目录结构、概念解释 |
| `preference` | 个人偏好 | 工具配置、习惯设置、个人约定 |

### Domain（所属领域）

| 值 | 含义 |
|----|------|
| `work` | 工作相关 |
| `personal` | 个人项目、学习 |

### Scope（具体项目）

**Scope 不预设固定值**，根据实际项目动态生成。

#### 确定 Scope 的流程

```bash
# 1. 先查已有标签（通过宽泛搜索间接查看）
nmem m search "项目关键词" -n 5   # 看结果里用了哪些 label

# 2. 已有 scope → 复用已有名称
#    例如：已有 "oa" 标签，继续使用 "oa"

# 3. 新项目 → 按优先级推断：
#    a. package.json 的 name 字段
#    b. 项目根目录名（如 oa-next → oa）
#    c. 用户明确指定

# 4. 首次使用新 scope 时，向用户确认
```

#### Scope 命名规范

- 使用小写字母
- 使用连字符分隔（如 `my-project`）
- 简短但能识别（如 `oa` 而非 `oa-next-system`）
- 同一项目始终使用相同名称

## 可选 Labels

| 标签 | 何时添加 |
|------|----------|
| `experimental` | 实验性方案，未经充分验证 |
| `deprecated` | 已废弃，仅作历史参考 |
| 技术栈标签 | 见下方 |

## 技术栈 Labels（推荐）

根据内容涉及的技术添加相关标签：

**前端框架：** `react`, `vue2`, `vue3`, `nextjs`
**语言：** `typescript`, `javascript`, `nodejs`, `python`
**UI 库：** `antd`, `element-ui`, `tailwind`
**工具：** `webpack`, `vite`, `rollup`, `jest`
**其他：** `css`, `less`, `sass`, `graphql`, `rest-api`

## Labels 组合示例

### 工作项目

```
# OA 系统中关于表单组件的技术决策
"decision, work, oa, react, typescript, antd"

# Fintopia 中 @yqg/enum 的实现说明
"implementation, work, fintopia, vue2, typescript"

# OA 中遇到的构建问题排查
"debugging, work, oa, webpack"

# 新项目首次记录（实验性）
"implementation, work, new-project, nodejs, experimental"
```

### 个人项目

```
# 周刊中关于 RSS 抓取的实现
"implementation, personal, weekly, nodejs"

# 知识库系统的设计决策
"decision, personal, memory"

# React 学习中的探索
"knowledge, personal, learning, react, experimental"
```

## Labels 生成流程

```
1. 确定 Type
   └─ 问：这是决策、实现、调试、知识还是偏好？

2. 确定 Domain
   └─ 问：这是工作相关还是个人项目？

3. 确定 Scope
   └─ 问：属于哪个项目？（先查 list_memory_labels）

4. 添加技术栈标签（可选）
   └─ 问：涉及哪些技术？

5. 添加状态标签（可选）
   └─ 问：是否实验性/已废弃？

6. 组合为逗号分隔的字符串
```

## 搜索技巧

```bash
# 搜索 OA 项目的所有决策
nmem m search "决策" -l oa

# 搜索 React 相关的调试经验
nmem m search "调试" -l react

# 搜索实验性方案
nmem m search "实验" -l experimental

# 搜索某个项目的所有内容
nmem m search "任意词" -l oa -n 20
```

## 从旧格式迁移

如果知识库中有使用旧格式（内容头部包含元信息）的条目：

1. `memory_search` 找到旧条目
2. 从内容中提取元信息
3. 转换为 labels（去掉 confidence，用 importance 分数代替）
4. `memory_update` 更新条目
