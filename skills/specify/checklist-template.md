# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validate specification completeness and quality before proceeding to planning  
**Created**: [DATE]  
**Feature**: [Link to spec.md]  
**Iteration**: 1/3

---

## Content Quality

- [ ] 无实现细节（语言、框架、API、数据库）
- [ ] 聚焦用户价值和业务需求
- [ ] 面向非技术干系人可读
- [ ] 所有必填章节已完成

## Requirement Completeness

- [ ] 无 `[NEEDS CLARIFICATION]` 标记残留
- [ ] 需求可测试且无歧义
- [ ] 所有 User Story 均包含 Acceptance Scenarios（Given/When/Then）
- [ ] 涉及复杂逻辑的 User Story 包含 Edge Cases（边界条件、错误场景）
- [ ] 所有 Acceptance Scenario 和 Edge Case 均有唯一编号（US{N}-{M}，同一 Story 内连续编号）
- [ ] 所有 User Story 处于同等粒度层级
- [ ] 功能范围清晰界定
- [ ] 依赖和假设已识别

## Feature Readiness

- [ ] 所有功能需求有明确的验收标准
- [ ] 用户故事覆盖主要流程
- [ ] 无实现细节泄漏到规格中
- [ ] Business Metrics（如有）仅包含上线后度量，不与验收场景重复

---

## Validation Notes

| 检查项 | 状态 | 问题描述 | 修复建议 |
|--------|------|----------|----------|
| [项目] | ❌/✅ | [具体问题] | [如何修复] |

---

## Iteration History

### Iteration 1
- **Date**: [DATE]
- **Issues Found**: [数量]
- **Status**: [通过/需修复]

---

## Next Steps

- [ ] 所有检查项通过 → 进入 `clarify` 或 `plan`
- [ ] 有失败项 → 修复后重新验证（最多 3 次迭代）
