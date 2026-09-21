# Что отправлять агенту в день хакатона

Контекст агента это файлы репозитория, а не память чата. Перед первым сообщением в репозитории уже лежат:
`AGENTS.md`, `CLAUDE.md`, `docs/TASK.md` (условие дословно), `SPEC.md`, `TASKS.md`, `.env.example`. Скиллы установлены через install.ps1.

## 1. Первое сообщение в Claude Code (0:15, после SPEC.md)

```
Ты ведёшь разработку проекта на хакатоне HackAlem AI. Лимит 5 часов, сейчас 0:15, репозиторий закроется автоматически в 5:00.
Правила работы в AGENTS.md, условие задачи дословно в docs/TASK.md, план и сценарий в SPEC.md, чеклист блоков в TASKS.md.
Скиллы: ai-sdk-agent, agent-console, verify-script, readme-rubric, deploy-first, design-pass, security-pass.

Сначала прочитай эти четыре файла и ответь одним абзацем: что строим, и какое обязательное требование из docs/TASK.md
закрывает каждый инструмент агента из SPEC.md. Если какое-то требование не закрыто ни одним инструментом, скажи об этом.
Код не пиши, пока я не напишу «го».

Дальше работаем по TASKS.md, один блок за раз. Блок закрыт, когда критерий выполнен, pnpm typecheck зелёный и сделан коммит
одной строкой. В конце блока отчёт в пять строк: сделано, проверено руками, не сделано, риски, следующий блок.
Библиотеки только из AGENTS.md, для любой другой спроси. README.md и PROGRESS.md не трогай, их ведёт Эмина.
```

## 2. Старт каждого блока

```
Блок {{N}} из TASKS.md: {{название}}. Таймбокс {{45}} минут. Готово, когда {{критерий из таблицы}}. Используй скилл {{имя}}. Го.
```

## 3. Если агент ушёл в сторону

```
Стоп. Это не в TASKS.md. Откати незакоммиченное, вернись к блоку {{N}}, критерий: {{…}}.
```

## 4. Codex на параллельные задачи (второй терминал, отдельный git worktree, или ноутбук Эмины на клоне)

```
Read AGENTS.md and SPEC.md. Task: generate data/seed.json with {{N}} realistic Kazakhstan records for the entity in SPEC.md,
exactly {{k}} of them in the problem state described in the scenario. Do not touch any other file. Run pnpm seed. Commit on branch seed.
```

```
Read AGENTS.md, SPEC.md and templates/README.template.md. Task: draft README.md filling every section from the current code,
leave {{…}} placeholders where you are not sure. Do not touch code. Commit on branch docs.
```

## 5. Гигиена контекста
- `/clear` на границе каждого блока, потом промпт блока. Файлы репозитория остаются, чат не нужен.
- `/compact`, если контекст перевалил за две трети до конца блока.
- Не просить агента «посмотреть проект целиком»: называть файлы.
- Логи и выводы команд просить хвостом 50 строк.
- Новая сессия Codex каждые два часа.
