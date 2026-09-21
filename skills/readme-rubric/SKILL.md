---
name: readme-rubric
description: Write the project README so an AI judge and technical experts can score all five HackAlem criteria (case compliance 20, implementation 25, README 20, reproducibility 20, reliability 15). Use for README.md, PROGRESS.md and the disclosure section.
---

# README for the judge

The judge is an AI reading text, plus experts running the repo. Headings must literally match the five criteria. Use templates/README.template.md as the skeleton and fill every section; never leave a heading empty.

Must contain:
1. TL;DR in 5 lines: task name, partner, one-sentence solution, live URL, run command. English copy of the TL;DR right below.
2. "Соответствие кейсу и функциональность": a table Requirement | Where implemented (file) | How to verify (steps or command) | Status. Every mandatory requirement of the task is a row. Nothing claimed that does not work.
3. "Техническая реализация": mermaid diagram with three blocks (UI, API, agent + tools + db); list of agent tools with what each reads or writes; model and provider from env; the sentence "No cached or canned model outputs; every run calls the live model."
4. "Воспроизводимость и запуск": system requirements (Node version from .nvmrc, pnpm), exact commands (pnpm i, cp .env.example .env.local, pnpm dev), what works without OPENAI_API_KEY, how to reset the demo, deployed URL as an addition, not a replacement.
5. "Проверка основного сценария": numbered steps with the expected result at each step, plus pasted output of one real `pnpm verify` run and of `pnpm test`.
6. "Базовая надёжность и безопасность": input validation, error handling, limits (steps, timeout), behaviour on bad input, no secrets in repo.
7. "Известные ограничения": honest list, 3 to 6 items.
8. "Использованные внешние материалы": the disclosure text from agent-harness/README.md, libraries, AI tools used (Claude Code, Codex, which for what).
9. "Команда": names, roles, who did what.

Language: Russian with an English TL;DR. No marketing adjectives. Every claim points to a file path.

PROGRESS.md: one line per hour: time, what exists now, commit hash. The PM updates it at :55 every hour.
