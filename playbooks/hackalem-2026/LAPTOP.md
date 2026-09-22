# Ноутбук на хакатон · что установить и проверить до 22.09

На ноутбуке нет ничего с основной машины. Всё ставится по этому списку, галочки ставить по факту, а не по памяти.

## Программы, по порядку установки
- [ ] **Node.js 22 LTS** с nodejs.org. Проверка: `node -v` показывает 22.
- [ ] **pnpm 10**: `npm i -g pnpm@10` (без прав администратора). Вариант: `corepack enable` в окне администратора (на Windows без него EPERM), затем `corepack prepare pnpm@10.34.5 --activate`; `pnpm@latest` не брать, это уже pnpm 12. Проверка: `pnpm -v` показывает 10.
- [ ] **Git for Windows** с gitforwindows.org, вместе с Git Credential Manager (он в установщике по умолчанию). Репозиторий команды клонировать в путь без кириллицы и пробелов, например C:\hack.
  `git config --global user.name "Alexander Kurchakov"`, `git config --global user.email "fistin103@gmail.com"`.
- [ ] **Claude** (десктоп-приложение с вкладкой Code) с claude.ai/download, вход в аккаунт с Max. Это основной инструмент.
- [ ] **Codex CLI**: `npm i -g @openai/codex`. Проверка: `codex --version`. Вход в свой аккаунт сейчас, в перк-аккаунт в 12:30 23.09.
- [ ] **Vercel CLI**: `npm i -g vercel`, затем `vercel login` (аккаунт fistin103). Проверка: `vercel whoami`.
- [ ] **VS Code** с code.visualstudio.com: читать SPEC и README, править руками. Cursor не нужен, Blender не нужен.
- [ ] **Браузер** Chrome или Edge: кабинет edu.astanahub.com, Vercel, Turso, GitHub. Проверка живого URL всегда в инкогнито.
- [ ] **Telegram Desktop**: чат и канал хакатона.
- [ ] PowerShell разрешает скрипты: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, иначе install.ps1 и prewarm.ps1 не запустятся.
- [ ] Часы синхронизированы с сетью, часовой пояс Астана: коммиты с неверным временем выглядят как работа до старта.

## Не ставить
Docker, Python, Ollama, Blender, Figma, GUI для баз данных, любые линтеры сверх того, что даёт create-next-app. Ничего из этого не нужно и всё это ест время. Путь запуска у судьи один: `pnpm install`, `pnpm dev`, без образов и альтернатив.

## Комплект и зависимости
- [ ] `git clone https://github.com/Alexanderadon/agent-harness`, потом `pwsh -File C:/hack/agent-harness/install.ps1 -Role alexander` (у Эмины `-Role emina`; для обеих ролей install ставит в `~/.codex/config.toml` `sandbox_mode = "danger-full-access"` и `approval_policy = "never"`). Проверка: в Claude Code набрать `/` и увидеть scaffold, hackathon-day, ai-sdk-agent; написать агенту `Я Александр` и получить короткий ответ: роль, git-имя, ветка, ключ модели, команды (guide/06).
- [ ] `pwsh -File C:/hack/agent-harness/prewarm.ps1`: ставит в кэш pnpm все пакеты дня (Next.js 16, shadcn, ai, @ai-sdk/*, zod, @libsql/client, lucide, vitest, tsx) и проверяет, что скаффолд и сборка проходят. Идёт 5–10 минут, папку после себя удаляет. В день установка пойдёт из кэша за секунды.

## Аккаунты и ключи
- [ ] GitHub Alexanderadon: первый `git push` в любой тестовый репозиторий с ноутбука прошёл (Credential Manager запомнил вход).
- [ ] `git clone https://github.com/BAITC-Hacks/hack-463fe33c-lomra` проходит. Клон читать, ничего не пушить до старта.
- [ ] В папке клона `git push --dry-run origin main` отвечает «Everything up-to-date»: вход в GitHub на этом ноутбуке под нужным аккаунтом и право записи есть. Ничего при этом не отправляется. 403 значит, Credential Manager запомнил чужой аккаунт.
- [ ] platform.openai.com: своя организация, проект **lomra-demo**, предоплата $15–20, автопополнение ВЫКЛ, ключ проекта в менеджере паролей, не в файлах. Этот ключ только для Vercel production (живёт там до 29.09); перк-ключ только в `.env.local`. Новая организация может требовать верификацию для стриминга: проверяется первым живым Run.
- [ ] Turso: вход через GitHub на app.turso.tech (бесплатный план), две базы в веб-дашборде (CLI на Windows нет): **lomra-probe** для утреннего теста и **lomra** для дня. Токен Read & Write с Expiration **Never**. URL и токены в менеджере паролей. `TURSO_*` только в env Vercel, никогда в `.env.local`: verify и seed сбросили бы боевую базу.
- [ ] Vercel: пустой проект создан, env вбиты (ключ lomra-demo в OPENAI_API_KEY, AGENT_MODEL, TURSO_DATABASE_URL, TURSO_AUTH_TOKEN базы lomra), Deployment Protection выключена.
- [ ] build.nvidia.com: аккаунт есть, ключ сохранён, только резерв.
- [ ] Telegram-канал хакатона и почта открыты на телефоне у обоих. Хотспот с телефона проверен.
- [ ] LAN-переходник USB-A → RJ-45 проверен с кабелем, Wi-Fi 5 ГГц виден.

## Эмина
- [ ] Один раз нажала «Edit» и «Commit changes» на тестовом репозитории в браузере.
- [ ] Шаблоны README, SPEC, PROGRESS из комплекта открыты, PICK-TASK.md прочитан.
- [ ] **У Эмины есть право записи в репозиторий команды.** Под её аккаунтом на странице репозитория виден карандаш «Edit» на README и кнопка «Add file». Если нет, до 22-го написать организаторам, чтобы добавили её аккаунт. Запасной путь в день: её текст коммитит Александр с трейлером `Co-authored-by: Эмина <её email>`.
- [ ] **Её агент проверен до старта.** Codex CLI требует ChatGPT Plus или Pro; если у неё нет Plus сейчас, первая проверка в 12:35 23.09 на перк-аккаунте. Запуск только `codex --sandbox danger-full-access --ask-for-approval never`; `Я Эмина` отвечает отдельной строкой «git: pull ок, запись в .git работает», потом `progress` в тестовой папке. На это заложено 20 минут до старта.
- [ ] **Вклад Эмины виден в истории.** Её GitHub-аккаунт привязан к репозиторию команды в кабинете (вкладка «Команды»), и под её аккаунтом страница репозитория открывается. Тестовый коммит на github.com показывает её аватарку и ссылку Emina-An (серое имя без аватарки — почта не привязана). До старта ничего не коммитить. В день у неё свои коммиты через её агента (запасной путь — веб-интерфейс GitHub): docs/TASK.md в ~0:05–0:10, PROGRESS.md в :55 каждого часа и в 4:35, README, docs/JUDGE-CHECK.md, файл тестовых данных, если задача его требует. Итого 8–10 коммитов под её именем, эксперты по п. 5.4.7 проверяют историю и метаданные.
- [ ] Эмина задала в Telegram-чате хакатона вопрос: «Вклад участника документацией и данными через веб-интерфейс GitHub, коммиты под его аккаунтом, засчитывается?» Ответ сохранён скриншотом.
- [ ] **Эмина это судья.** На её ноутбуке стоят Node 22, pnpm 10 и Git, и она один раз до 22-го прошла путь судьи на любом проекте: `git clone`, `pnpm install`, `pnpm dev`, открыть localhost. В день в 2:00 (`судья сборка`) и 4:00 (`судья`) её агент проходит этот путь с репозиторием команды строго по README в чистом клоне, итог в docs/JUDGE-CHECK.md; потом она руками `pnpm start` и живой URL в инкогнито, без подсказок Александра. Что не получилось у неё, не получится у судьи.

## Репозитории, которые можно использовать открыто (Положение 5.4.4–5.4.4.2: разрешены при раскрытии в README)
- `Alexanderadon/agent-harness` — этот комплект.
- `Alexanderadon/neon-tap` — Upstash Redis по REST, серверлесс-функции Vercel, PWA.
- `Alexanderadon/resto-miniapp` — идемпотентные вебхуки, Telegram-бот через fetch, zod-схемы.
- `Alexanderadon/almaty-air` — адаптеры внешних источников, cron-сбор.
- `Alexanderadon/zhk-radar` — скрейперы, MapLibre, статическая генерация.
Правило: копируемый фрагмент называется в README в разделе «Использованные внешние материалы» с именем репозитория.

## Репетиция
- [ ] REHEARSAL.md пройден на ноутбуке, те же инструменты, что будут в день.
- [ ] Замечания по именам API внесены в skills/ai-sdk-agent/SKILL.md и запушены.
