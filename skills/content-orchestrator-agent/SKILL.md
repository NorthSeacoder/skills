---
name: content-orchestrator-agent
description: >-
  Invoke the local Content Orchestrator Agent CLI for WeChat public-account content production, topic-pool operations, batch article generation, YouMind publishing, or upstream agent integration from Codex, Claude Code, or another agent. Use when the user asks to generate, rewrite, research, validate, publish, resume, batch-produce, or manage topics for configured WeChat accounts through content-orchestrator-agent.
---

# Content Orchestrator Agent

## Overview

Use this skill to call Content Orchestrator Agent as a local CLI-backed agent. Treat it as a subprocess integration: run the CLI, parse stdout JSON envelope, and decide success from `ok`, then `data.phase` plus `data.publishResult.status`.

Prefer a skill over a subagent for this integration. The reusable knowledge is the exact CLI contract and result handling; no separate autonomous persona is required.

## Availability Check

Before any workflow call, choose the executable path in this order:

1. If `command -v content-orchestrator-agent` succeeds and `content-orchestrator-agent --describe` exits 0 with `ok=true`, call the global CLI.
2. Else, if `/Users/yqg/personal/AI/content-orchestrator-agent` exists, run `pnpm build` there and call `node dist/src/cli/index.js`.
3. Else, stop and tell the user to install the CLI:

```bash
npm install -g content-orchestrator-agent
```

For global npm installs, prefer an external config root:

```bash
CONTENT_ORCHESTRATOR_CONFIG_DIR=~/.content-orchestrator/wechat
content-orchestrator-agent --config-dir ~/.content-orchestrator/wechat --help
content-orchestrator-agent --describe
```

Local source fallback:

```bash
cd /Users/yqg/personal/AI/content-orchestrator-agent
pnpm build
node dist/src/cli/index.js --help
```

Do not rely on `pnpm dev` in restricted sandboxes if `tsx` cannot create its IPC pipe. Use the compiled `node dist/src/cli/index.js ...` form.

## Run Content Workflow

The input must contain a configured account alias followed by the task:

Use the executable chosen in Availability Check:

```bash
content-orchestrator-agent run --json-input '{"input":"微雨成春：写一篇关于知识管理的公众号文章","dryRun":true}'
# or local fallback:
node dist/src/cli/index.js run --json-input '{"input":"微雨成春：写一篇关于知识管理的公众号文章","dryRun":true}'
```

With topic lifecycle binding:

```bash
content-orchestrator-agent run --json-input '{"input":"月亮睡了：写一篇关于深度工作的文章","topicId":"<uuid>","dryRun":true}'
```

Configured accounts live under the configured `configs/wechat` root, or the directory passed by `CONTENT_ORCHESTRATOR_CONFIG_DIR` / `--config-dir`. If the account is not recognized, the workflow returns `phase="blocked"` with `missingInputs=["account"]`.

## Parse Results

All commands emit a JSON envelope. Successful stdout uses `{ ok: true, data, meta }`. CLI-layer errors write `{ ok: false, error, meta }` to stderr.

Important: `exit code 0` only means the CLI completed. It does not mean the content workflow published successfully.

Use this priority order:

1. `ok === false`: CLI-layer failure; inspect `error.code`, `error.retryable`, and `error.suggestion`.
2. `ok === true && data.phase === "completed" && data.publishResult.status === "published"`: success; `reference` is the YouMind craft id.
3. `ok === true && data.phase === "completed" && data.publishResult.status === "skipped"`: workflow completed but publish was skipped, usually dry-run or no `YOUMIND_API_KEY`.
4. `ok === true && data.phase === "blocked"`: inspect `data.missingInputs` and `data.nextAction.instructions`.
5. `ok === true && data.phase === "failed"`: unrecoverable unless the failure reason is clearly transient.

Minimal Node integration pattern:

```ts
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export async function runContentOrchestrator(input: string) {
  const { stdout } = await execFileAsync("content-orchestrator-agent", ["run", input], {
    env: { ...process.env, CONTENT_ORCHESTRATOR_CONFIG_DIR: `${process.env.HOME}/.content-orchestrator/wechat` },
  });
  const envelope = JSON.parse(stdout);
  if (!envelope.ok) return { ok: false, reason: envelope.error.code, retryable: envelope.error.retryable };
  const result = envelope.data;

  if (result.phase === "completed" && result.publishResult?.status === "published") {
    return { ok: true, reference: result.publishResult.reference, result };
  }

  return {
    ok: false,
    retryable: result.phase === "blocked" && /HTTP 5\d\d|ECONNREFUSED|ETIMEDOUT|HTTP 429/.test(JSON.stringify(result)),
    reason: result.nextAction?.instructions ?? result.summary,
    result,
  };
}
```

## Topic Operations

Use topic commands when the user asks to manage the topic pool:

```bash
content-orchestrator-agent topic add <account> --title <title> [--angle <angle>] [--priority A|B|C] [--force]
content-orchestrator-agent topic list <account> [--status draft|writing|published|archived] [--priority A|B|C]
content-orchestrator-agent topic get <id>
content-orchestrator-agent topic pick <account>
content-orchestrator-agent topic next <account>
content-orchestrator-agent topic archive <id>
content-orchestrator-agent topic radar <account> [--count 5]
```

`topic add` rejects near duplicates by default when similarity is `>=0.85`; use `--force` only when the user explicitly accepts the duplicate risk. Similarity `>=0.95` is always rejected.

Topic commands require Hermes MCP configuration:

```bash
HERMES_MCP_URL=http://localhost:8080/sse
```

## Batch Operations

Use batch mode for several articles in one serial run:

```bash
content-orchestrator-agent batch run --json-input '{"account":"月亮睡了","limit":3,"dryRun":true,"topics":[{"id":"t1","title":"选题一"},{"id":"t2","title":"选题二"}]}'
```

Batch output is an envelope whose `data` is summary JSON with completed, failed, skipped, and details lists.

## Resume And Retry

Use `resume` only when a previous workflow persisted state and the failure is transient:

```bash
content-orchestrator-agent resume <feature> [statePath]
```

Retry candidates include `HTTP 5xx`, `ECONNREFUSED`, `ETIMEDOUT`, and delayed `HTTP 429`. Do not retry authentication failures (`HTTP 401` or `HTTP 403`) without fixing credentials.

Publishing is not idempotent. Before retrying publish, check whether `publishResult.reference` already exists; a repeated publish can create duplicate YouMind crafts.

## Environment

Publishing needs either an environment variable or account secret:

```bash
YOUMIND_API_KEY=<key>
YOUMIND_BASE_URL=https://youmind.com/openapi/v1
CONTENT_ORCHESTRATOR_CONFIG_DIR=~/.content-orchestrator/wechat
WECHAT_VALIDATE_SKIP=1
```

Set `WECHAT_VALIDATE_SKIP=1` only when skipping draft validation is intended. Without a validation script, validation fails loudly.

## References

For deeper contract details, read only the relevant sections in the repository:

- `README.md`: CLI command list and setup.
- `docs/agent-integration.md`: full `WorkflowResponse`, exit codes, retry strategy, and idempotency.
