# Context Manifest: Trellis Style Context Manifests

**Workspace**: `trellis-style-context-manifests`
**Created**: 2026-06-07
**Status**: active

---

## Implement Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/trellis-style-context-manifests/spec.md` | 定义 manifest 的需求、trait、边界和非目标 | implement | yes |
| `specs/trellis-style-context-manifests/plan.md` | 定义 Markdown 单文件 manifest 方案、ADR 和阶段改动面 | implement | yes |
| `specs/trellis-style-context-manifests/tasks.md` | 定义实现任务和验证任务 | implement | yes |
| `skills/sdd/templates/context-manifest-template.md` | 目标模板文件；实现时创建，不作为待修改源固定上下文 | implement | no |

---

## Check Context

| File / Source | Reason | Phase | Required |
|---|---|---|---|
| `specs/trellis-style-context-manifests/spec.md` | 验证 FR-001 到 FR-010 和 user scenarios | verify | yes |
| `specs/trellis-style-context-manifests/plan.md` | 验证 ADR、质量属性和不引入 Trellis 平台边界 | verify | yes |
| `specs/trellis-style-context-manifests/tasks.md` | 验证任务完成状态 | verify | yes |
| `specs/trellis-style-context-manifests/context-manifest.md` | dogfooding manifest 本身 | verify | yes |
| `skills/sdd/scripts/validate-sdd.sh` | SDD 结构校验命令 | verify | yes |

---

## Research Context

| File / Source | Reason | Phase | Verified |
|---|---|---|---|
| `https://docs.trytrellis.app/start/how-it-works` | Trellis implement/check/research context 分离和 task flow 参考 | plan | yes |
| `https://github.com/mindfold-ai/Trellis` | Trellis 文件驱动任务状态和 repo memory 参考 | plan | yes |

---

## Notes

- 待修改源文件不作为固定 context；实现和验证阶段按需检查。
- 本 feature 不引入 `.trellis/`、Trellis CLI、hook 或自动 context injection。
