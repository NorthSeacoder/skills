# Feature Specification: SDD Subagent Enhancement

**Workspace**: `sdd-subagent-enhancement`  
**Created**: 2026-05-23  
**Status**: Draft  
**Input**: 用户描述: "优化 sdd skill 的 subagent 体系：收敛 subagent 集合、补强 prompt、改造安装方式为单源派生+自检自动安装，注意版本控制"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Subagent 在适合的阶段真正发挥作用 (Priority: P1)

作为 sdd 使用者，我希望 subagent 只在真正有独立价值的场景被派发，且返回的结果是压缩可用的，以便主线程不被无效信息淹没，也不因为 subagent 缺失必要工具而空转。

**Why this priority**: 当前 docs-researcher 缺少网络工具无法查文档（空壳），planner 与主线程职责重叠导致"双层规划"，prompt 过于简略导致返回结果不可控。

**Acceptance Scenarios**:

1. **[US1-1]**
   **Given** sdd 进入 plan 或 specify 阶段，需要了解代码现状  
   **When** 主线程派发 sdd-explorer  
   **Then** explorer 返回压缩结论（路径+行号+一句概括），不回灌原始代码块，主线程可直接复用

2. **[US1-2]**
   **Given** sdd 进入 code-review 阶段  
   **When** 主线程派发 sdd-reviewer  
   **Then** reviewer 返回按严重度排序的发现列表，每条包含文件引用和具体问题，不包含风格建议

3. **[US1-3]**
   **Given** sdd 进入 plan 阶段，需要核对框架 API 行为  
   **When** 主线程派发 sdd-docs-researcher  
   **Then** docs-researcher 能通过网络工具查询官方文档，返回带来源链接的事实性结论

**Edge Cases**:

- **[US1-4]** 当前环境未安装 subagents 时，sdd 退回单线程流程，不阻塞也不报错
- **[US1-5]** subagent 返回结果超出预期长度时，主线程应截断并标注"结果已压缩"
- **[US1-6]** 移除 planner subagent 后，plan 阶段的方案推演完全由主线程承担，不降低质量

### User Story 2 - 安装一步到位，更新自动同步 (Priority: P1)

作为 sdd 安装者，我希望 subagents 不需要单独手动安装，skill 激活时能自检并自动安装缺失的 subagents，且更新后不需要重新手动同步。

**Why this priority**: 当前两步安装容易遗漏，cp 方式导致源更新后副本不同步，skills.sh update 不感知 subagents。

**Acceptance Scenarios**:

1. **[US2-1]**
   **Given** 用户通过 skills.sh 安装了 sdd skill  
   **When** 首次在会话中触发 sdd  
   **Then** sdd 检测到 subagents 缺失，提示一行安装命令或自动安装（取决于权限）

2. **[US2-2]**
   **Given** sdd skill 源更新了 subagent 定义  
   **When** 用户重新安装或更新 sdd  
   **Then** subagents 自动同步到最新版本，无需额外手动步骤

3. **[US2-3]**
   **Given** 用户在项目级和用户级都可能安装 subagents  
   **When** 安装脚本执行  
   **Then** 能正确处理 scope 选择，不覆盖用户已有的非 sdd subagent 文件

**Edge Cases**:

- **[US2-4]** 安装目标目录不存在时，自动创建
- **[US2-5]** 安装目标目录中已有同名但内容不同的文件时，比较版本后决定是否覆盖
- **[US2-6]** 网络不可用或 skill 目录被移动时，自检失败应给出清晰错误信息而非静默跳过

### User Story 3 - 单源派生消除双格式漂移 (Priority: P2)

作为 sdd 维护者，我希望 subagent 定义只维护一份源，自动派生出 Claude Code (.md) 和 Codex (.toml) 两种格式，以便不再手工同步两套几乎相同的内容。

**Why this priority**: 当前 agents/claude-code/*.md 和 agents/codex/*.toml 内容几乎一致但分别维护，长期必然漂移。

**Acceptance Scenarios**:

1. **[US3-1]**
   **Given** 维护者修改了 subagent 的 prompt 或配置  
   **When** 运行派生脚本  
   **Then** 自动生成 claude-code/*.md 和 codex/*.toml，内容与源一致

2. **[US3-2]**
   **Given** 派生后的文件已存在  
   **When** 源文件未变化  
   **Then** 派生脚本不产生无意义的 diff（幂等）

3. **[US3-3]**
   **Given** 新增一个 subagent  
   **When** 在源目录添加定义并运行派生  
   **Then** 两种格式的文件都被正确生成，无需手动创建

**Edge Cases**:

- **[US3-4]** 源格式中某些字段只适用于一种目标格式时，派生脚本应正确处理差异（如 model 名称映射：haiku -> gpt-5.4-mini）
- **[US3-5]** 派生脚本应能检测到手工修改了派生文件（而非源文件）并发出警告

### User Story 4 - 版本控制防止意外降级 (Priority: P2)

作为 sdd 使用者，我希望 subagent 安装和更新有版本感知能力，以便不会因为旧版 skill 覆盖新版 subagent，也能在出问题时回退。

**Why this priority**: 用户可能在不同机器、不同时间安装，缺少版本标记会导致无法判断当前安装是否最新。

**Acceptance Scenarios**:

1. **[US4-1]**
   **Given** subagent 文件包含版本标记  
   **When** 安装脚本检测到目标位置已有更新版本  
   **Then** 不降级，给出提示

2. **[US4-2]**
   **Given** 用户想强制安装特定版本  
   **When** 使用 --force 参数  
   **Then** 覆盖安装并记录操作

3. **[US4-3]**
   **Given** 自检发现版本不匹配  
   **When** sdd 激活时  
   **Then** 提示版本差异和建议操作，不自动降级

**Edge Cases**:

- **[US4-4]** 版本标记格式应简单（如 ISO 日期或语义版本），不引入复杂依赖
- **[US4-5]** 首次安装时目标位置无版本信息，视为"无版本"直接安装

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 移除 sdd-planner subagent，plan 阶段方案推演由主线程完成
- **FR-002**: 修复 sdd-docs-researcher 的工具配置，添加 WebFetch、WebSearch 及可用的文档查询 MCP 工具
- **FR-003**: 为每个 subagent 补强 prompt，明确输入格式、输出格式、最大行数限制和禁止行为
- **FR-004**: 建立单源定义格式（YAML 或 TOML），包含所有 subagent 的 prompt、model、tools、版本等元数据
- **FR-005**: 实现派生脚本，从单源生成 claude-code/*.md 和 codex/*.toml
- **FR-006**: 派生文件头部包含生成标记和版本号，防止手工修改和版本混淆
- **FR-007**: 安装脚本支持版本比较，拒绝降级（除非 --force）
- **FR-008**: sdd SKILL.md 入口增加自检逻辑描述：激活时检测 subagent 是否已安装且版本匹配
- **FR-009**: 自检失败时提供一行可复制的安装/更新命令
- **FR-010**: 安装脚本保持 --scope user/project 能力，正确处理目标目录
- **FR-011**: 在 references/stages/ 的适用阶段文档中，补充"建议派发"小节，说明该阶段派哪个 agent、传什么、期望什么

### Non-Functional Requirements

- **NFR-001**: 派生脚本必须幂等，重复运行不产生无意义 diff
- **NFR-002**: 版本标记格式为 `YYYY-MM-DD` 或 semver，不引入外部版本管理工具
- **NFR-003**: 整体方案不依赖 skills.sh 平台的任何新能力，完全在 skill 内部闭环
- **NFR-004**: 自检逻辑不阻塞 sdd 主流程，缺失 subagent 时退回单线程即可

### Key Entities

- **SubagentSource**: 单源定义文件，包含 name、description、model、tools、version、prompt
- **DerivedAgent**: 从 SubagentSource 派生的目标格式文件（.md 或 .toml）
- **VersionMarker**: 嵌入派生文件头部的版本标识，用于安装时比较
- **InstallManifest**: 安装后写入目标目录的清单文件，记录已安装的 subagent 及其版本

---

## Out of Scope

- 修改 skills.sh 平台本身的安装机制
- 为非 sdd 的 skill 建设 subagent 体系
- 把 subagent 做成独立可安装的 skill
- 运行时动态加载/卸载 subagent
- 跨仓库的 subagent 共享或注册

---

## Unclear Questions

- 单源格式选 YAML 还是 TOML？YAML 更灵活但需要额外解析，TOML 与 Codex 原生格式一致但 Claude Code 端需要转换
- 自检逻辑写在 SKILL.md 的哪个位置？是作为"阶段路由前的前置检查"还是"Subagent 约定"小节的一部分？
- model 名称映射表（haiku -> gpt-5.4-mini, sonnet -> gpt-5.5）是硬编码在派生脚本中还是作为配置文件维护？

---

## Stage Readiness

- 下一步建议：`clarify`（解决上述 3 个 Unclear Questions）或直接 `plan`（如果你对这些问题已有偏好）
- 阻塞项：单源格式选型会影响后续所有脚本实现
