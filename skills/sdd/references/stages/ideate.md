---
source: skills/ideate/SKILL.md
---

# Ideate Stage

在需求模糊时，通过发散→收敛→锐化三阶段帮用户厘清真正要做什么。是 `specify` 的上游，产出可直接进入 `specify` 的需求描述。

## 何时进入

- 用户只有一句模糊想法
- 多个方向混在一起，需要先收敛
- 需求还不足以直接写 `spec.md`

## 目标

- 明确核心意图
- 展开并比较 2-4 个方向
- 收敛到 1-2 个可行方向
- 锐化为足以进入 `specify` 的描述
- 如果一个需求明显适合拆成多个 feature，先拆出候选 feature、依赖顺序和推荐首项，避免把过宽需求直接写成单个 spec

## 产物

- 默认产出到对话中
- 若已经足够清晰，可直接切换到 `specify` 并写入 `specs/<feature>/spec.md`
- 若确认是多 feature 需求，默认先在对话中输出 roadmap 草案；只有用户同意推进正式流程时，才在 `specify` 阶段创建或更新 `specs/<umbrella>/roadmap.md`

## 回退 / 停止条件

- 如果需求已经足够清晰，不继续发散，直接进入 `specify`
- 如果用户表达“继续 / 下一步 / 接着做 / resume / continue”等续接意图，不进入发散；先读取 `../continuation-routing.md` 执行 continuation preflight
- 如果用户实际要做的是极小改动或单点修复，应停止完整 SDD 路由并改走普通实现流程

## 执行原则

- 先发散后收敛，不要一开始就收窄
- 追问“为什么”比“怎么做”更重要
- 不替用户做取舍，但要把取舍摆出来
- 如果发散后发现需求其实很清晰，直接跳到 `specify`
- 如果用户明确说“只评估，不写文件”，只输出拆分评估和推荐路线，不创建 `spec.md`、`roadmap.md` 或更新 `specs/.active`
- 单点小改动、低风险修复或单个清晰 feature 不生成 roadmap
- “可以”“ok”“go on”等只是在确认上一轮推荐动作时，按 continuation routing 恢复阶段，不当作新需求发散

## 三阶段

### 1. 发散

- 复述核心意图
- 展开场景、边界、规模和邻近方向
- 列出 2-4 个可能变体

### 2. 收敛

- 评估价值、代价与用户真实兴趣
- 淘汰低价值方向并说明原因
- 让用户确认保留方向

### 3. 锐化

- 定义 1-3 个核心用户场景
- 明确包含与不包含内容
- 识别关键约束
- 判断是否可以直接进入 `specify`

## 多 Feature 拆分

当需求同时包含多个可独立验收的能力、多个阶段性目标、明确的“先做 A 后做 B”、或完成当前工作后还要推荐后续 feature 时，先输出：

- umbrella 目标
- 候选 feature 列表，每项包含名称、目标、依赖、推荐阶段和启动条件
- 推荐首个 feature 及理由
- 明确后置 feature，不把它们塞进首个 feature 的完成条件

如果用户确认推进，下一步进入 `specify`，由 specify 阶段创建或更新 `specs/<umbrella>/roadmap.md`，并只为首个 feature 写正式 `spec.md`。

## 下一步

- 已足够清晰：进入 `specify`
- 仍有关键不确定：继续 `ideate`

## 阶段完成标准

- 已明确 1-3 个核心用户场景
- 已说明本轮包含与不包含内容
- 若是多 feature 需求，已列出候选 feature、依赖、推荐首项和后置项；若不是，已说明不生成 roadmap 的理由
- 已判断下一步是 `specify`、继续 `ideate`，还是退出完整 SDD 流程
