---
name: hackathon-day
description: Day-of protocol for a 5-hour hackathon build. Turns one-word user commands (spec, старт, го, блок N, чекпоинт, стоп) into the full procedure - draft SPEC from the task, restate the plan, work strictly block by block from TASKS.md with commits and five-line reports, hourly wip checkpoints, git sync with the teammate's agent. Use in a repo that has AGENTS.md, docs/TASK.md and TASKS.md whenever the user sends one of these commands.
---

# Hackathon day protocol (Alexander's agent, code owner)

The user sends short commands. Each one means the full procedure below. Never ask the user to restate what a command means.
Before every command: `git pull --rebase origin main`, then read TASKS.md and the last lines of PROGRESS.md to learn what the teammate's agent did.

## "spec"
Read AGENTS.md, docs/WINNING-SHAPE.md, docs/TASK.md and docs/SPEC.template.md.
Write SPEC.md following the template for this task: one entity, two read tools, one or two write tools, a six-step scenario, the expected state for verify, a "Не делаем" section.
Bind every mandatory requirement from docs/TASK.md to a tool or a screen in a table; any requirement that does not fit gets its own line "НЕ ЗАКРЫТО".
If the task needs a library outside AGENTS.md, name it and why, but do not add it.
Write no code. Commit "spec: <case>". Finish with: "SPEC.md готов, правь и скажи «старт»."

## "старт"
Read AGENTS.md, docs/TASK.md, SPEC.md and TASKS.md.
Reply with one paragraph: what we build, and which mandatory requirement each agent tool in SPEC.md covers. List any requirement covered by nothing.
Write no code until the user says "го".

## "го"
Begin block 1 from TASKS.md (or the block the user named). Same rules as "блок N".

## "блок N" (optionally with a timebox in minutes)
Mark block N in TASKS.md as "🔄 А", commit. Work only block N. Use the skill named in the block (scaffold, ai-sdk-agent, agent-console, verify-script, deploy-first, design-pass, security-pass).
Done means: the block criterion is met, `pnpm typecheck` is green, one commit with a one-line message, TASKS.md block marked "✅", push.
Then report in five lines: done, verified by hand (what was clicked or run), not done, risks, next block. Do not start the next block.
If the timebox runs out, stop, commit what works, report honestly.
Machine outputs meant for the README go to docs/verify.log and docs/test.log; README.md and PROGRESS.md are never edited by this agent.

## "чекпоинт"
Commit the current state as "wip: <what exists>". `pnpm typecheck` must pass; if it does not, comment out the breaking part and mark TODO.
Check `git status --short`: no .env* files may be staged. Push. Print `git log --since="70 minutes ago" --format="%an: %s"` so the user sees both authors' work. Continue the current block.

## "стоп"
Discard uncommitted changes outside the current block, return to the current block and its criterion, confirm in one line.

## Requests to the teammate
If the docs side needs something from the code side (a screenshot, a value, a command output), the request appears in TASKS.md under "requests". Handle open requests addressed to А at the start of each block, in one commit, then continue.

## Always
- Libraries only from AGENTS.md; for anything else ask first with one sentence.
- Never print or commit .env* contents. Logs and command output: last 50 lines only.
- Before any code, the four sources of truth are AGENTS.md, docs/TASK.md, SPEC.md, TASKS.md.
