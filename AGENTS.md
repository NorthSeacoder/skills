# Repository Guidelines

## Project Structure & Module Organization

This repository manages installable skill sources for `skills.sh`.

Repository content is intentionally split into:

- public skills declared in README
- private/adopted skills kept under `skills/` without cross-environment portability promises
- repository governance and workflow assets such as `docs/*`, `skills/sdd/references/`, and `skills/sdd/templates/`

- `skills/<skill-name>/`: canonical source for each maintained skill; every public skill directory must contain `SKILL.md`
- `skills/sdd/references/stages/`: stage-specific guidance used by the single-entry `sdd` workflow skill
- `skills/sdd/templates/`: templates written into `specs/<feature>/`
- `docs/`: architecture, maintenance policy, and adoption guidance
- `.github/workflows/`: CI automation

Current public entrypoint: `skills/sdd/SKILL.md`.
Examples of private skill sources: `skills/knowledge-management/SKILL.md`, `skills/debug/SKILL.md`.

## Build, Test, and Development Commands

Use the repo from the repository root:

- `DISABLE_TELEMETRY=1 npx skills add NorthSeacoder/skills`: install the repository through `skills.sh`
- `DISABLE_TELEMETRY=1 npx skills add git@github.com:NorthSeacoder/skills.git --skill sdd`: install only `sdd`
- `rg --files skills`: inspect skill assets quickly
- `git status` and `git diff --stat`: review repository-wide migrations before cleanup

If you change installable structure or README installation guidance, validate those paths before merging.

## Coding Style & Naming Conventions

Keep Markdown short, explicit, and action-oriented. Prefer simple headings and relative links.

- Skill names should stay stable and use `kebab-case`
- Public skills belong under `skills/<name>/`
- For `sdd`, keep entry routing in `SKILL.md`, stage logic in `references/stages/`, and file templates in `templates/`
- Environment variable conventions should be skill-scoped and prefixed, for example `SDD_*`

Do not rebuild the old `registry + publish-links` model.

## Testing Guidelines

There is no dedicated unit test suite for repository content; verification is structural and workflow-based.

- Ensure every public skill still has a valid `SKILL.md`
- Ensure `sdd` stage references and templates resolve after refactors
- Re-check README installation commands and public/private skill claims after structural changes
- Re-check that governance assets are not described as public install interfaces
- If you clean up old symlinks in local runtime directories, make sure no dangling links remain

## Commit & Pull Request Guidelines

Follow the existing commit style from history: Conventional Commit prefixes such as `feat(skills): ...`, `refactor(skills): ...`, `docs: ...`, and `chore: ...`.

PRs should include:

- a short summary of the skill or repository-structure change
- affected paths, for example `skills/sdd/` or `README.md`
- verification notes with the commands you ran
- screenshots only when documentation rendering or linked outputs materially changed

## Publishing Notes

Do not treat `~/.agents/skills` or `~/.claude/skills` as source directories. Install from this repository via `skills.sh`, and if you retire old linked skills locally, remove the stale links explicitly rather than leaving dangling symlinks behind.
