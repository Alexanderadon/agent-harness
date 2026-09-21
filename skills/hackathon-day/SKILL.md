---
name: hackathon-day
description: Day-of protocol for a 5-hour hackathon build. Turns one-word user commands (spec, старт, го, блок N, чекпоинт, ревью, стоп) into the full procedure - draft SPEC from the task, restate the plan, work strictly block by block from TASKS.md with commits and five-line reports, parallel subagents for disjoint files, a read-only compliance review, hourly push-what-exists checkpoints, git sync with the teammate's agent. Use in a repo that has AGENTS.md, docs/TASK.md and TASKS.md whenever the user sends one of these commands.
---

# Hackathon day protocol (Alexander's agent, code owner)

The user sends short commands. Each one means the full procedure below. Never ask the user to restate what a command means.
Before every command: `git pull --rebase --autostash origin main`, then read TASKS.md and the last lines of PROGRESS.md to learn what the teammate's agent did. Never `git push --force`. You own rows 0–10 of TASKS.md and the "contract" section; rows starting with Э and the "requests" answers belong to the captain. Git author strings: you are `Alexander Kurchakov`, the captain is her `git config user.name`.

## "Я Александр" (first message of the day, role switch)
Reply in four lines: "Роль: код, ноутбук Александра." Then `git config user.name` and `user.email` (must be Alexander Kurchakov / fistin103@gmail.com; if not, say so and stop). Then `git pull --rebase --autostash origin main` and the current branch. Then the list of your commands: scaffold, spec, старт, го, блок N, чекпоинт, ревью, стоп. Do nothing else until the next command. If someone sends captain commands (task, progress, readme, testdata, audit, submit) on this laptop, answer that these belong to the captain's laptop and do not run them.

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
Parallel work inside a block is allowed only on disjoint files and only through subagents you spawn yourself: in block 1 a subagent may write data/seed.json while you write lib/db.ts; in block 6 a subagent may write tests/tools.test.ts while you write scripts/verify.ts. At most two subagents at a time, each told exactly which files it owns; you merge nothing by hand, they write different files. If the harness has no subagents, work sequentially.
Done means: the block criterion is met, `pnpm typecheck` is green, one commit with a one-line message, TASKS.md block marked "✅", push.
Then report in five lines: done, verified by hand (what was clicked or run), not done, risks, next block. Do not start the next block.
If the timebox runs out, stop, commit what works, report honestly.
Machine outputs meant for the README go to docs/verify.log and docs/test.log; README.md and PROGRESS.md are never edited by this agent.

## "чекпоинт" (every hour at :50–:55, or whenever the user says so)
Push what exists. Never delete, revert or stash work to make a checkpoint look clean: an hour of work that is not in the remote does not exist for the organizers (Положение 6.6).
Steps: `git add -A` (check `git status --short`: no .env* files, no data/app.db), commit "wip: <what exists, one line>"; if `pnpm typecheck` fails, still commit, with the message "wip (typecheck failing: <reason>)", and fix it in the next 15 minutes. Push. Print `git log --since="70 minutes ago" --format="%an: %s"`. Continue the current block from the same place.
The manual deploy is the user's job and only when typecheck is green; remind them in one line if it is.

## "ревью" (compliance review, read-only; run at the end of block 4 and at the start of block 10)
Spawn a read-only subagent (or do it yourself without editing) that reads docs/TASK.md, SPEC.md, AGENTS.md and the code, and returns a numbered list of violations in this order: (1) mandatory requirements from docs/TASK.md not fully implemented or not verifiable by hand; (2) AGENTS.md rules broken: hardcoded record ids in lib/ or app/, write tool without toolApproval, API input without zod, canned model output, README or PROGRESS edited, library outside the list, leftover scaffold files; (3) README claims that the code does not back (compare README.md to files). Each item: file path, what is wrong, the smallest fix. Nothing is edited by the review. Then fix items of group 1 and 2 in one commit; hand group 3 to the PM via TASKS.md requests.

## "стоп"
Discard uncommitted changes outside the current block, return to the current block and its criterion, confirm in one line.

## Seed from the captain
At the start of block 1 (and again at block 3), check docs/seed-draft.json. If it exists, it becomes data/seed.json (adapt field names to lib/types.ts, keep every row and the problem rows), and the request line in TASKS.md is marked done. One dataset for the app and for the README.

## Git conflicts
If `git pull --rebase --autostash` reports a conflict (TASKS.md or PROGRESS.md edited by both): `git rebase --abort`, then `git pull --no-rebase origin main`, keep both sides' lines, commit "merge", push. If `git push` is rejected as non-fast-forward, pull again the same way and push again. Never force.

## Requests to the teammate
If the docs side needs something from the code side (a screenshot, a value, a command output), the request appears in TASKS.md under "requests". Handle open requests addressed to А at the start of each block, in one commit, then continue.

## Always
- Libraries only from AGENTS.md; for anything else ask first with one sentence.
- Never print or commit .env* contents. Logs and command output: last 50 lines only.
- Before any code, the four sources of truth are AGENTS.md, docs/TASK.md, SPEC.md, TASKS.md.
