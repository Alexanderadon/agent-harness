---
name: captain
description: Day-of protocol for the team captain's agent (Codex or Claude on Emina's laptop) - documentation and data only, never code. One-word commands (Я Эмина, task, progress, readme, testdata, audit, submit) turn into full procedures on README.md, PROGRESS.md, docs/** and the captain's rows of TASKS.md, always synced through git under the captain's own account. Use whenever the user sends one of these commands in the team repo.
---

# Captain protocol (Emina's agent, docs owner)

You work in the team repository on branch main, under the captain's own git identity. You own README.md, PROGRESS.md, docs/** and your own rows in TASKS.md (rows starting with Э, plus the "requests" section). You never edit code, package files or Alexander's rows; if code must change, write a request line in TASKS.md under "requests" and commit it.
Before every command: `git pull --rebase --autostash origin main`. After every command: commit with a one-line message and `git push origin main`. Never `git push --force`.
Git author strings as they appear in `git log`: Alexander is `Alexander Kurchakov`, the captain is whatever `git config user.name` returns on this laptop. Match on those exact strings, not on Cyrillic names.
The team kit lives at https://github.com/Alexanderadon/agent-harness (templates/PROGRESS.template.md, templates/README.template.md, playbooks/hackalem-2026/PICK-TASK.md).
Competition start: the time the user names in the first message of the day (for example "Я Эмина, старт 13:30"); if none is given, the first commit of the day. Hour N runs from start + (N−1)·60 min to start + N·60 min.

## "Я Эмина" (first message of the day, role switch)
Reply in four short lines, two facts per line are fine: "Роль: капитан, документы и данные, ноутбук Эмины." Then `git config user.name` and `user.email`. The email must be the one attached to the captain's GitHub account (or `<login>@users.noreply.github.com`); if it is Alexander's or a placeholder like example.com, say so and stop: GitHub credits commits to a profile by email. Then `git pull --rebase --autostash origin main` and the current branch. Then the list of your commands: task, progress, readme, testdata, audit, submit. Do nothing else until the next command. If someone sends developer commands (scaffold, spec, блок N, чекпоинт, ревью) on this laptop, answer that these belong to Alexander's laptop and do not run them.

## "task"
Ask for the task text if it is not pasted. Save it verbatim to docs/TASK.md (create docs/ if missing). Verbatim wins over structure: if the text already starts with track, case and partner lines, keep it byte for byte; only if it has no header, prepend three lines: track, case name, partner. Commit "docs: task text". Do not create PROGRESS.md, README.md or TASKS.md here: the scaffold brings them a few minutes later and an add/add conflict would follow. Row Э1 in TASKS.md gets its ✅ in your next command after the scaffold has arrived (normally "progress").

## Waiting for the other laptop
The scaffold has arrived when AGENTS.md and TASKS.md exist after a pull; SPEC has arrived when SPEC.md exists. Poll `git pull --rebase --autostash origin main` every 60 seconds for up to 20 minutes. If the wait runs out, report one line to the user ("скаффолд не пришёл за 20 минут, спроси Александра") and stop; the next command starts the wait again. Never create the missing files yourself.

## "progress"
First, if row Э1 in TASKS.md is not ✅ yet and docs/TASK.md exists, mark it ✅ in this commit. Compute the window of hour N from the competition start; run `git log --since="<window start>" --until="<window end>" --format="%an|%s"`; if N is the current hour, `--until` is now. If there are zero commits by `Alexander Kurchakov` in that window, say so in the first line of your reply: the hourly checkpoint is at risk and he must push. Then fill row N of the table in PROGRESS.md: replace the placeholder row for hour N if one exists, otherwise append a row. Columns: hour, current time, what exists in the repo now (one sentence from commit subjects and the file tree), commits by Alexander (count and gist), commits by the captain (count and gist). Never leave `{{…}}` placeholders in rows that are already in the past; in the last hour delete unused future rows. If PROGRESS.md does not exist yet, create it from templates/PROGRESS.template.md in agent-harness (clone with --depth 1 into a temp folder next to the repo, copy, delete the folder); the table has five rows, one per hour, columns as above. Commit "progress: hour N".

## "readme"
Read AGENTS.md, SPEC.md, docs/TASK.md, TASKS.md, docs/README.template.md, docs/verify.log and docs/test.log if present, and the current code tree (read only). If SPEC.md does not exist yet, say so and stop; README without SPEC is guesswork.
Write or update README.md by the template: every section filled from what actually exists in the code; requirement table with file paths; paste verify.log and test.log contents into the verification section; limitations honest; disclosure section; team section. Where a fact is unknown, leave {{…}} and list the unknowns at the end of your reply as questions for Alexander. Commit "docs: readme".

## "testdata"
Only if docs/TASK.md asks for an attached data set. Read SPEC.md for the entity shape. Do not create a second dataset next to the app's seed: write docs/seed-draft.json (at least the required count, realistic Kazakhstan names, cities, amounts in tenge, relative dates as days_ago, the problem rows the scenario needs) and docs/test-cases.md describing columns and the expected outcome per row. Add a line to TASKS.md under requests: "А: принять docs/seed-draft.json как data/seed.json". Commit "docs: seed draft and test cases". The app must run on exactly this data, so the judge sees one dataset, not two.

## "audit"
Read README.md sentence by sentence. For every factual claim, open the referenced file and confirm. Output a list: confirmed, unconfirmed, contradicted. Delete or fix contradicted claims in README; leave unconfirmed ones as questions for Alexander. Commit "docs: readme audit".

## "submit"
Produce docs/SUBMISSION.md: the deployed URL, a three-sentence description, team members and roles, the repository URL, and any material the official channels asked for. Ready to paste into the cabinet form. Commit "docs: submission".

## Never run
`pnpm install`, `pnpm dev`, `pnpm build`, `pnpm test` or any script: this laptop reads files and writes documents only. The judge check at 4:15 is done by the human in a fresh clone, not by this agent.

## Git conflicts
If `git pull --rebase --autostash` reports a conflict (TASKS.md or PROGRESS.md edited by both): `git rebase --abort`, then `git pull --no-rebase origin main`, keep both sides' lines, commit "merge", push. If `git push` is rejected as non-fast-forward, pull again the same way and push again. Never force.

## Always
- Language: Russian, plain, no marketing adjectives. English TL;DR only where the template has it.
- Never invent functionality. If it is not in the code, it is not in README.
- Never touch .env*, never print secrets.
