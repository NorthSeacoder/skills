# Commit Plan: SDD Knowledge Capture Closeout

**Workspace**: `sdd-knowledge-capture-closeout`  
**Date**: 2026-06-08  
**Status**: Confirmed For Commit

---

## Included Files

| File | Reason |
|---|---|
| `skills/sdd/SKILL.md` | SDD entry now names Knowledge Capture Gate and external sync boundary |
| `skills/sdd/references/stages/closeout.md` | Defines Knowledge Capture Gate, Type enum, redaction and sync status rules |
| `skills/sdd/references/status-model.md` | Adds Knowledge Capture to closeout-ready acceptance requirements |
| `skills/sdd/templates/acceptance-template.md` | Adds persistent `## Knowledge Capture` schema and writing rules |
| `skills/sdd/scripts/validate-sdd.sh` | Adds closeout-ready structural checks for Knowledge Capture |
| `specs/.active` | Points continuation to `sdd-knowledge-capture-closeout` |
| `specs/sdd-trellis-workflow-productization/roadmap.md` | Records feature completion and next recommendation |
| `specs/sdd-knowledge-capture-closeout/spec.md` | Feature specification |
| `specs/sdd-knowledge-capture-closeout/plan.md` | Implementation plan and ADRs |
| `specs/sdd-knowledge-capture-closeout/tasks.md` | Executed task plan |
| `specs/sdd-knowledge-capture-closeout/context-manifest.md` | Implement / verify context manifest |
| `specs/sdd-knowledge-capture-closeout/verify-evidence.md` | Verification evidence |
| `specs/sdd-knowledge-capture-closeout/acceptance.md` | Final acceptance and Knowledge Capture |
| `specs/sdd-knowledge-capture-closeout/commit-plan.md` | Commit planning gate |

---

## Excluded Files

| File | Reason |
|---|---|
| none | Current dirty status only contains files related to this feature |

---

## Needs User Decision

| File / Topic | Reason |
|---|---|
| none | 用户已确认执行本地 commit |

---

## Risks

| Risk | Assessment | Mitigation |
|---|---|---|
| Broad add accidentally includes unrelated files | Low but possible if using `git add -A` | Only add listed files explicitly after confirmation |
| External sync side effects | None in implementation | Feature records sync status only |
| Historical acceptance files missing Knowledge Capture | Expected | Default validator does not require migration |

---

## Commit Batches

| Batch | Files | Commit Message | Reason |
|---|---|---|---|
| 1 | Included Files 全部 | `feat(sdd): add knowledge capture closeout` | Single cohesive SDD workflow feature |

---

## Confirmation Options

- 用户已确认：execute the listed batch with explicit file paths only.
