# Implementation Plan: SDD Architecture Quality Gate

**Workspace**: `sdd-architecture-quality-gate` | **Date**: 2026-05-25 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `specs/sdd-architecture-quality-gate/spec.md`

---

## Summary

把 `awesome-architecture` 的架构思考框架、核心模式和系统模板转化为 `sdd` 的轻量架构质量门。推荐方案是在现有阶段中嵌入规则和模板字段，而不是新增并列 skill 或复制外部仓库内容。

---

## Architecture Overview

`sdd` 保持单入口，架构能力分布到现有主链：

```text
User input
  |
  v
clarify  ->  architecture questions, constraints, quality attributes
  |
  v
spec     ->  functional requirements + quality attribute table
  |
  v
plan     ->  reference patterns + architecture sketch + lightweight ADR
  |
  v
tasks    ->  tasks mapped to stories / decisions / quality attributes
  |
  v
verify   ->  architecture drift and evidence checks
  |
  v
closeout ->  ADR retention, architecture debt, evolution triggers
```

---

## Key Design Decisions

### Decision 1: Reference external architecture patterns, do not vendor them

- **背景**: `awesome-architecture` 提供成熟架构模式和 21 个类系统模板，适合方案阶段参考。
- **选项**:
  - A: 复制模式内容到 `skills/sdd/references/` - 离线可用，但维护和授权边界更重，也容易过期。
  - B: 只保存外部 URL 和引用规则 - 轻量，尊重来源，更新成本低。
- **结论**: 选择 B。第一版只在 SDD 中定义引用方式、适配检查和 sources 记录。
- **影响**: `plan` 可以引用模式，但必须说明“为什么适配/为什么不适配”。
- **来源**: https://github.com/study8677/awesome-architecture

### Decision 2: Embed architecture checks into existing SDD stages

- **背景**: `architecture-copilot` 是独立架构共创 skill，但当前 `sdd` 的目标是单入口软件交付流程。
- **选项**:
  - A: 把 `architecture-copilot` 作为并列入口加入仓库。
  - B: 把它的提问和 ADR 纪律拆进 `clarify / plan / verify / closeout`。
- **结论**: 选择 B。避免用户在 `sdd` 之外再记一个入口。
- **影响**: 阶段说明和模板需要增强，但路由模型保持稳定。
- **来源**: https://github.com/study8677/architecture-copilot

### Decision 3: Keep ADR lightweight inside plan.md

- **背景**: 架构决策的价值在于保留“为什么”和“代价”，但重 ADR 流程会压垮小项目。
- **选项**:
  - A: 每个关键决策生成独立 ADR 文件。
  - B: 在 `plan.md` 中维护轻量 ADR 表和关键决策小节。
- **结论**: 选择 B。后续如果大型项目需要，再扩展独立 ADR 文件。
- **影响**: `verify` 和 `closeout` 直接读取 `plan.md` 即可检查架构漂移。
- **来源**: https://github.com/study8677/awesome-architecture/blob/main/tutorial/08-%E6%9E%B6%E6%9E%84%E5%86%B3%E7%AD%96%E8%AE%B0%E5%BD%95%E4%B8%8E%E6%BC%94%E8%BF%9B.md

---

## Module Design

### Module: Architecture Quality Reference

**职责**: 定义 SDD 如何引用外部成熟架构模式。

**改动概述**:

- 新增 `skills/sdd/references/architecture-quality-gate.md`
- 记录可参考的模式类别、类系统模板入口、适配检查和反模式
- 不复制外部教程正文，只保留摘要级索引和 URL

**关键接口 / 行为**:

```text
When planning a medium/large feature:
  1. classify the system or feature type
  2. search for matching architecture pattern or system template
  3. compare current product stage with reference maturity
  4. record selected / rejected patterns in plan.md
  5. cite source URLs
```

### Module: Clarify Stage

**职责**: 在进入技术方案前清理架构前提。

**改动概述**:

- 在 `clarify.md` 增加 Architecture Questions
- 明确只问阻塞 plan 的高价值问题
- 增加“灵魂六问”式检查：规模、读写比、一致性、增长、失败代价、硬约束

### Module: Spec Template

**职责**: 把关键质量属性写成后续 plan 可使用的输入。

**改动概述**:

- 强化 `Non-Functional Requirements`
- 增加质量属性表：属性、目标、原因、验收方式、是否阻塞方案

### Module: Plan Stage and Template

**职责**: 把架构参考、候选方案、ADR 和演进路线写入计划。

**改动概述**:

- 在 `plan.md` 阶段说明中增加模式参考和适配检查
- 在 `plan-template.md` 增加：
  - Architecture Reference
  - Quality Attribute Targets
  - Capacity / Scale Notes
  - Lightweight ADR
  - Evolution Path
  - Anti-Pattern Check

### Module: Verify and Closeout Stages

**职责**: 防止实现漂移，并保留必要的演进信号。

**改动概述**:

- `verify.md` 增加 architecture drift evidence
- `closeout.md` 增加 ADR retention、architecture debt、evolution trigger 检查

---

## Architecture Pattern Reference Policy

可以引用 `awesome-architecture` 的两类内容：

- **核心架构模式**: 分层、单体、微服务、事件驱动、消息队列/异步处理、CQRS、发布订阅、BFF、管道过滤器、微内核/插件化。
- **类系统模板**: 普通网站、AI 对话产品、AI 网关、RAG 知识库、支付系统、实时通讯、搜索引擎、票务、云存储、通知系统等。

引用规则：

- 只作为候选参考，不作为默认答案。
- 必须说明当前项目阶段：MVP、成长期、成熟期。
- 必须说明适配点和不适配点。
- 必须保留来源 URL。
- 不能因为模板成熟，就把复杂架构套到小功能。

---

## Project Structure

```text
skills/sdd/
  references/
    architecture-quality-gate.md        # new
    stages/
      clarify.md                        # update
      plan.md                           # update
      tasks.md                          # update
      verify.md                         # update
      closeout.md                       # update
  templates/
    spec-template.md                    # update
    plan-template.md                    # update
    tasks-template.md                   # update

specs/sdd-architecture-quality-gate/
  spec.md
  plan.md
  tasks.md                             # next stage
```

---

## Risks and Tradeoffs

- 外部引用可能过期：第一版用 URL + 来源表，不缓存全文。
- 架构问题可能让小改动变重：阶段说明必须保留“小改动跳过架构质量门”的判断。
- 模式参考可能诱导过度设计：plan 必须要求 MVP/成长期/成熟期适配检查。
- ADR 可能变成形式主义：只记录影响实现、验证或维护的关键决策。

---

## Verification Strategy

- 结构验证：运行 `bash ./scripts/check-installed-skill.sh sdd`，必要时检查安装副本差异。
- 内容验证：检查 `references/` 与 `templates/` 的相互引用是否存在。
- 行为验证：用一个小改动和一个中大型功能分别 dry-run 阶段判断，确认小改动不会被强行套架构流程。
- 引用验证：所有外部模式引用必须出现在 `Sources` 或对应字段中。

---

## Stage Readiness

- 是否需要 `data-model.md`：不需要。本次改动是 workflow 与模板增强，不涉及实体存储模型。
- 下一步建议：`tasks`
- 阻塞项（如有）：无

---

## Sources

| 决策 | 来源 URL | 备注 |
|------|---------|------|
| 架构判断流程与核心模式 | https://github.com/study8677/awesome-architecture | 外部参考仓库 |
| 架构共创阶段 | https://github.com/study8677/architecture-copilot | 外部参考 skill |
| 核心架构模式 | https://github.com/study8677/awesome-architecture/blob/main/tutorial/04-%E5%8D%81%E5%A4%A7%E6%A0%B8%E5%BF%83%E6%9E%B6%E6%9E%84%E6%A8%A1%E5%BC%8F.md | 模式参考 |
| ADR 与演进 | https://github.com/study8677/awesome-architecture/blob/main/tutorial/08-%E6%9E%B6%E6%9E%84%E5%86%B3%E7%AD%96%E8%AE%B0%E5%BD%95%E4%B8%8E%E6%BC%94%E8%BF%9B.md | 决策记录参考 |
| 模板库 | https://github.com/study8677/awesome-architecture/tree/main/templates | 类系统模板参考 |
