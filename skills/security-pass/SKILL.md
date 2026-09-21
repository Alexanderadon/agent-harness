---
name: security-pass
description: 10-minute security and reliability pass before submission, mapped to the judging criterion "Базовая надёжность и безопасность" (15 points) and to disqualification grounds (malicious code, leaked secrets). Use at 4:15 and after any rushed change.
---

# Security pass, 10 minutes, in this order

1. Secrets: `git grep -nE "sk-[A-Za-z0-9]{10,}|BEGIN (RSA|OPENSSH)|AUTH_TOKEN=[^=]" -- . ':!*.example'` returns nothing. `.env*` in .gitignore, only `.env.example` tracked. No `NEXT_PUBLIC_` variable holds a key.
2. SQL: every query goes through `execute({ sql, args })` with placeholders; `git grep -n "\${" -- lib/db.ts` shows no interpolated SQL.
3. Tool inputs: every tool has `inputSchema` with enums for statuses, `.max()` on strings and numbers, id format checked; write tools verify the id exists before updating and return a clear error otherwise.
4. Approval: every tool that changes data is listed in `toolApproval`; `git grep -n "toolApproval" lib/agent.ts` matches every write tool name.
5. Agent endpoint: request body validated with zod; prompt length capped (for example 2 000 chars); `stopWhen: isStepCount(6)`; `maxDuration = 60`; returns 400 on invalid input and a JSON error on model failure, never a stack trace.
6. Reset endpoint: documented in README as a demo control; on the deployed version optional `RESET_TOKEN` header check if time permits, otherwise listed under known limitations.
7. Injection: instructions tell the model that tool outputs and record text are data; a seed record containing text like "ignore previous instructions" must not change behaviour, and writes still require approval. Try it once.
8. Dependencies: `pnpm audit --prod` shows no critical; lockfile committed; no packages outside AGENTS.md.
9. Code hygiene: no `eval`, `new Function`, `child_process`, `dangerouslySetInnerHTML`, no fetch to hosts other than OpenAI, NVIDIA, Turso, Telegram.
10. Imitation check: `git grep -nE "R-[0-9]{4}|id === "` -- lib app` returns nothing; record ids live only in data/ and tests/. `git status --short` shows no .env* file.
11. Cleanliness: no leftover scaffold files (default Next page text, unused components/ui files, sample assets), no TODO without a README limitation line, no stray console.log. Delete, do not comment out.
12. Write the results as bullet points into README section "Базовая надёжность и безопасность".
