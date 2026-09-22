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
- "Already changed" banner. The deployed demo has ONE shared database for every visitor, and it stays public for a week: an expert may arrive after someone else already approved everything, the agent finds nothing to do, and the product looks broken. Track it: data/schema.sql gets `CREATE TABLE IF NOT EXISTS demo_state (key TEXT PRIMARY KEY, value TEXT NOT NULL)`; every write tool, after a successful write, runs `INSERT OR REPLACE INTO demo_state (key, value) VALUES ('dirty', '1')`; the reset batch in seedDb runs `DELETE FROM demo_state`. The page (Server Component) reads the flag and, when set, shows one line above the table: «Данные уже изменены предыдущим запуском. Нажмите Reset, чтобы проверить сценарий с начала.» with the Reset button next to it. README step 1 of the check is Reset for the same reason.
- No model key: the page passes `hasKey={hasModelKey()}` (lib/model.ts, true for OPENAI_API_KEY or NVIDIA_API_KEY) from the server into the panel (client code cannot read env); the panel shows "Set OPENAI_API_KEY in .env.local to run the agent" and Run is disabled. Everything else works.

States that must exist: empty table (seed missing), loading, API error (400/500 text shown in the panel), agent running (status === 'streaming'), done.

Acceptance: the SPEC.md scenario runs by pressing Run once and approving once; the table changes visibly; Reset returns the seed.

# Other forms (SPEC.md line "Форма"; see docs/WINNING-SHAPE.md)

The panel, the trace rendering, the approval card, Reset, hasKey and the states above are identical for every form. Only the left column and the final-answer block change.

Form B, document assistant:
- Left: documents list from the db (title, source, chunk count); an upload control only if the task supplies files. Clicking a title opens the text in a drawer or below the list.
- Right: the goal input is a question, prefilled with the control question from SPEC.md. The final answer renders citations: each citation is a small card (document title, chunk position, quoted fragment) taken from the search tool outputs that the answer references; render them under the text, in the order the answer cites them.
- Highlight: documents cited in the current answer get the highlight instead of table rows.
- Acceptance: the control question gets an answer with at least two citations that point at real chunks; Reset restores the seeded documents.

Form C, generator:
- Left: the input form (fields from SPEC.md, zod-validated on submit) or the seeded input records; below it the list of saved results (title, created_at) with a download link (JSON or Markdown).
- Right: same panel. The approval card for the save tool renders the structured proposal field by field (title, findings as a list, recommendations as a list, category as a badge), not as raw JSON, because this card is the product.
- After Approve: the result appears in the saved list with highlight; the final answer text is one sentence.
- Acceptance: Run, one Approve, one row in the results list with every schema field filled; Reset clears saved results.
