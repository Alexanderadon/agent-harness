---
name: readme-rubric
description: Write the project README so technical experts can deploy, run and score it against the task's OWN criteria (docs/CRITERIA.md) and so it satisfies the mandatory README content of Положение 5.4.15. Use for README.md, PROGRESS.md and the disclosure section.
---

# README for the experts

Who scores: technical experts who deploy and run the repo by the README days after the event, with an AI judge as an auxiliary tool only (Положение 1.17). The event has NO single rubric any more (5.5): criteria and points come from the task's ТЗ, kept verbatim in docs/CRITERIA.md. Two hard rules above any criterion: if the project cannot be started by the README the team is out (5.4.16), and the key functionality must be checkable without any of our accounts or keys (5.6.6). Use templates/README.template.md as the skeleton and fill every section; never leave a heading empty. Order the sections that carry points by the task's weights: the heaviest criterion first after the TL;DR.

Mandatory content, Положение 5.4.15 (each must be findable under a heading): description and purpose; architecture; technologies; installation; running; dependencies; environment variables; the procedure for checking the main scenario.

Must contain:
1. TL;DR in 5 lines: task name, partner, one-sentence solution, live URL, run command. English copy of the TL;DR right below. Directly under it, the one-line check: open URL → Reset → Run → Approve → what changes.
1a. "Соответствие критериям оценки задачи": a table Criterion (verbatim from docs/CRITERIA.md) | Points | What covers it | Where to see or run it. Every criterion of the task is a row, including ones we did not cover (then the third column says so honestly). If docs/CRITERIA.md is missing, ask the captain in TASKS.md requests before writing this section.
2. "Соответствие кейсу и функциональность": a table Requirement | Where implemented (file) | How to verify (steps or command) | Status. Every mandatory requirement of the task is a row. Nothing claimed that does not work.
3. "Техническая реализация": mermaid diagram with three blocks (UI, API, agent + tools + db); list of agent tools with what each reads or writes; model and provider from env; the sentence "No cached or canned model outputs; every run calls the live model."
4. "Воспроизводимость и запуск": system requirements (Node version from .nvmrc, pnpm), exact commands (pnpm i, cp .env.example .env.local, pnpm dev), what works without OPENAI_API_KEY, how to reset the demo. Every env variable from .env.example in the table, including AGENT_REASONING and the run limits; TURSO_* marked as required for the deployed version.
5. "Проверка основного сценария": the live URL is the PRIMARY path, not an addition — it is how an expert without a key checks the key functionality (5.6.6). Numbered steps on the live URL, step 1 is always Reset (the demo database is shared by every visitor), expected result at each step; then the local variant with and without a key; then pasted output of one real `pnpm verify` run and of `pnpm test`. Mention the run limits so a 429 is not mistaken for a failure.
6. "Базовая надёжность и безопасность": input validation, error handling, limits (steps, timeout), behaviour on bad input, no secrets in repo.
7. "Известные ограничения": honest list, 3 to 6 items.
8. "Использованные внешние материалы": the disclosure paragraph from templates/README.template.md (section «Использованные внешние материалы») with the kit hash from the scaffold commit, plus shadcn-generated components/ui, product models actually used, AI tools with their models (Claude Code, Codex, which for what).
9. "Команда": names, roles, who did what.

Language: Russian with an English TL;DR. No marketing adjectives. Every claim points to a file path.

PROGRESS.md: the captain's `progress` fills one row per hour from templates/PROGRESS.template.md (hour, time, what exists, Alexander's commits, captain's commits) at :55, last at 4:35.

Claims audit before submit: for every sentence in README that states a fact about the code, the PM opens the referenced file and confirms it. Anything not confirmed is deleted, not softened. Run commands are given for both shells (bash: cp .env.example .env.local; PowerShell: Copy-Item .env.example .env.local). State Node 22 and pnpm 10 explicitly (`npm i -g pnpm@10`; corepack enable needs an admin shell on Windows). If a task requirement names an artifact ("attach a set of test cases"), that artifact is a file with a path in the table, not a paragraph.
