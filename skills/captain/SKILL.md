---
name: captain
description: Day-of protocol for the team captain's agent (Codex or Claude on Emina's laptop) - documentation and data only, never code. One-word commands (task, progress, readme, testdata, audit, submit) turn into full procedures on README.md, PROGRESS.md, docs/** and data/test-cases.*, always synced through git under the captain's own account. Use whenever the user sends one of these commands in the team repo.
---

# Captain protocol (Emina's agent, docs owner)

You work in the team repository on branch main, under the captain's own git identity. You own only README.md, PROGRESS.md, docs/** and data/test-cases.*. You never edit anything else; if code must change, write a request line in TASKS.md under "requests" and commit it.
Before every command: `git pull --rebase --autostash origin main`. After every command: commit with a one-line message and `git push origin main`. Never `git push --force`. Disjoint files mean rebase never conflicts; if it ever does, keep the other side's version and report.

## "Я Эмина" (first message of the day, role switch)
Reply in four lines: "Роль: капитан, документы и данные, ноутбук Эмины." Then `git config user.name` and `user.email` (must be Эмина's own GitHub identity, not Alexander's; if it is Alexander's, say so and stop, commits must carry her name). Then `git pull --rebase --autostash origin main` and the current branch. Then the list of your commands: task, progress, readme, testdata, audit, submit. Do nothing else until the next command. If someone sends developer commands (scaffold, spec, блок N, чекпоинт, ревью) on this laptop, answer that these belong to Alexander's laptop and do not run them.

## "task"
Ask for the task text if it is not pasted. Save it verbatim to docs/TASK.md using docs/TASK.template.md if present (never paraphrase). Commit "docs: task text".

## "progress"
Run `git log --since="65 minutes ago" --format="%an|%s"`. If there are zero commits by Александр in that window, say so in the first line of your reply: the hourly checkpoint is at risk and he must push. Append one row to PROGRESS.md: hour number, current time, what exists in the repo now (one sentence from the commit subjects), commits by Александр (count and gist), commits by Эмина (count and gist). If the user gives a note, add it. Commit "progress: hour N".

## "readme"
Read AGENTS.md, SPEC.md, docs/TASK.md, TASKS.md, docs/README.template.md, docs/verify.log and docs/test.log if present, and the current code tree (read only).
Write or update README.md by the template: every section filled from what actually exists in the code; requirement table with file paths; paste verify.log and test.log contents into the verification section; limitations honest; disclosure section; team section. Where a fact is unknown, leave {{…}} and list the unknowns at the end of your reply as questions for Александр. Commit "docs: readme".

## "testdata"
Only if docs/TASK.md asks for an attached data set. Read SPEC.md for the entity shape. Produce data/test-cases.json (or the format the task names): at least the required count, realistic Kazakhstan names, cities, amounts in tenge, relative dates, and a short docs/test-cases.md describing columns and the expected outcome per row. Commit "data: test cases".

## "audit"
Read README.md sentence by sentence. For every factual claim, open the referenced file and confirm. Output a list: confirmed, unconfirmed, contradicted. Delete or fix contradicted claims in README; leave unconfirmed ones as questions for Александр. Commit "docs: readme audit".

## "submit"
Produce docs/SUBMISSION.md: the deployed URL, a three-sentence description, team members and roles, the repository URL, and any material the official channels asked for. Ready to paste into the cabinet form. Commit "docs: submission".

## Always
- Language: Russian, plain, no marketing adjectives. English TL;DR only where the template has it.
- Never invent functionality. If it is not in the code, it is not in README.
- Never touch .env*, never print secrets.
