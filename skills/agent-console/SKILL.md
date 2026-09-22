---
name: agent-console
description: Layout and states of the operator console — domain table on the left, agent panel with live trace and approval cards on the right, reset button. Use when building the main screen of a hackathon product with a visibly acting agent.
---

# Operator console

Layout (desktop two columns 7/5, mobile stacked):
- Left: the domain records from the db (table or cards). One row per entity, status badge, updated_at. Rows the agent changed in the current run get a subtle highlight until the next Run or Reset (the table is a Server Component: keep changed skus in a small client context and call `router.refresh()` in `onFinish` so the table re-reads the db).
- Right: AgentPanel. Top: one-line goal input prefilled with the example from SPEC.md and a Run button. Middle: trace. Bottom: final answer text.

Trace rendering from message.parts, in order:
- text part: plain paragraph.
- tool part, state input-streaming / input-available: card with tool name, JSON input, spinner.
- state approval-requested: card with tool name, human-readable summary of the input, buttons Approve / Reject calling addToolApprovalResponse.
- state output-available: card with tool name, elapsed ms, compact result (first 3 fields or row count).
- state output-error / output-denied: red border, message.
Each card carries a step number chip. Monospace for JSON, sans for text.

Controls:
- Reset demo: POST /api/reset, then refetch the table. Always present, top right.
- No model key: the page passes `hasKey={hasModelKey()}` (lib/model.ts, true for OPENAI_API_KEY or NVIDIA_API_KEY) from the server into the panel (client code cannot read env); the panel shows "Set OPENAI_API_KEY in .env.local to run the agent" and Run is disabled. Everything else works.

States that must exist: empty table (seed missing), loading, API error (400/500 text shown in the panel), agent running (status === 'streaming'), done.

Acceptance: the SPEC.md scenario runs by pressing Run once and approving once; the table changes visibly; Reset returns the seed.
