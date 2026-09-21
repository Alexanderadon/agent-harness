# Что писать агенту в день хакатона

Длинный текст живёт в скиллах `scaffold` и `hackathon-day`, которые стоят на ноутбуке через install.ps1. Твои сообщения это команды в одно слово.

## Команды дня

| Когда | Что пишешь | Что делает агент |
|---|---|---|
| 0:00, первое сообщение | `Я Александр` | включает роль: проверяет git-имя, делает pull, показывает список команд, ждёт |
| 0:00 | `scaffold` | 10–12 минут: создаёт Next.js-проект, ставит shadcn и зависимости, клонирует agent-harness и раскладывает комплект, коммитит, пушит |
| 0:05, когда Эмина положила условие в docs/TASK.md | `spec` | пишет SPEC.md по шаблону, привязывает каждое требование к инструменту, код не пишет |
| после твоих правок SPEC | `старт` | пересказывает план одним абзацем, называет незакрытые требования, ждёт |
| 0:15 | `го` | начинает блок 1 |
| дальше | `блок 3`, `блок 4`, … (можно `блок 3, 45 минут`) | делает только этот блок, коммит, отчёт в пять строк, останавливается |
| ушёл в сторону | `стоп` | откатывает лишнее, возвращается к блоку |
| конец блока 4, начало блока 10 | `ревью` | субагент только для чтения: нарушения требований и правил списком, группы 1–2 чинятся одним коммитом |
| :50–:55 | `чекпоинт` | пушит что есть, даже если typecheck красный; ничего не удаляет |

Между блоками ты сам делаешь `/clear` и отправляешь следующий `блок N`. Файлы репозитория остаются, чат не нужен.

## Команды Эмины её агенту (скилл `captain`, её ноутбук, её аккаунт)

| Когда | Пишет | Что делает агент |
|---|---|---|
| 0:00, первое сообщение | `Я Эмина` | включает роль: проверяет, что git-имя её, делает pull, показывает список команд, ждёт |
| 0:05 | `task` + текст условия | docs/TASK.md дословно, коммит |
| :55 | `progress` | строка в PROGRESS.md из коммитов обоих за час |
| 0:40 | `testdata` | data/test-cases.json, если условие требует набор данных |
| 1:30, 3:15 | `readme` | README по шаблону из реального кода, вопросы Александру списком |
| 3:40 | `audit` | каждое утверждение README сверено с файлами |
| 4:20 | `submit` | docs/SUBMISSION.md для анкеты |

Два агента не конфликтуют, потому что владеют разными файлами (см. Team protocol в AGENTS.md) и оба делают `git pull --rebase` перед каждой командой. Общая доска это TASKS.md: статусы блоков и раздел requests.

## Codex на параллельные задачи (второй терминал в отдельном git worktree, или ноутбук Эмины на клоне)

```
Read AGENTS.md and SPEC.md. Task: generate data/seed.json with {{N}} realistic Kazakhstan records for the entity in SPEC.md,
exactly {{k}} of them in the problem state described in the scenario; dates relative (days_ago). Do not touch any other file.
Run pnpm seed. Commit on branch seed.
```

```
Read AGENTS.md, SPEC.md and docs/README.template.md. Task: draft README.md filling every section from the current code,
leave {{…}} placeholders where you are not sure. Do not touch code. Commit on branch docs.
```

## Если скиллы не установились (запасной вариант, полный текст)

Скаффолд:
```
Используй скилл scaffold. Если скилла нет: создай Next.js 16 проект через временную папку рядом (create-next-app с флагами --ts --tailwind --eslint --app --no-src-dir --use-pnpm --yes), перенеси в этот репозиторий, shadcn init -y -d и компоненты button card badge table skeleton input textarea scroll-area separator, зависимости ai @ai-sdk/openai @ai-sdk/react zod @libsql/client lucide-react и dev vitest tsx, .nvmrc 22, engines, onlyBuiltDependencies для @libsql/client libsql esbuild sharp, скрипты typecheck/test/seed/verify/smoke. Затем склонируй https://github.com/Alexanderadon/agent-harness во временную папку, скопируй AGENTS.md и CLAUDE.md в корень, templates/TASKS.template.md как TASKS.md, templates/env.example как .env.example, templates/PROGRESS.template.md как PROGRESS.md, в docs/ положи playbooks/hackalem-2026/WINNING-SHAPE.md, templates/SPEC.template.md и templates/README.template.md. Временные папки удали. pnpm typecheck зелёный, коммит «scaffold + conventions (disclosed)», пуш.
```

SPEC:
```
Прочитай AGENTS.md, docs/WINNING-SHAPE.md, docs/TASK.md и docs/SPEC.template.md. Заполни SPEC.md по шаблону: одна сущность, два инструмента чтения, один или два записи, сценарий из шести шагов, ожидаемое состояние для verify, раздел «Не делаем». Каждое обязательное требование из docs/TASK.md привяжи к инструменту или экрану; что не ложится, отметь строкой «НЕ ЗАКРЫТО». Библиотеки вне AGENTS.md назови, но не добавляй. Код не пиши.
```

Старт:
```
Прочитай AGENTS.md, docs/TASK.md, SPEC.md и TASKS.md. Ответь одним абзацем: что строим и какое требование закрывает каждый инструмент; назови незакрытые. Код не пиши до слова «го». Дальше работаем по TASKS.md по одному блоку: критерий выполнен, pnpm typecheck зелёный, коммит одной строкой, отчёт в пять строк, следующий блок не начинать. Библиотеки только из AGENTS.md. README.md и PROGRESS.md не трогать.
```
