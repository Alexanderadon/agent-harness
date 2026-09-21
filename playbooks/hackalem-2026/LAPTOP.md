# Ноутбук на хакатон · что установить и проверить до 22.09

На ноутбуке нет ничего с основной машины. Всё ставится по этому списку, галочки ставить по факту, а не по памяти.

## Программы, по порядку установки
- [ ] **Node.js 22 LTS** с nodejs.org. Проверка: `node -v` показывает 22.
- [ ] **pnpm 10**: `corepack enable`, затем `corepack prepare pnpm@latest --activate`. Проверка: `pnpm -v` показывает 10.
- [ ] **Git for Windows** с gitforwindows.org, вместе с Git Credential Manager (он в установщике по умолчанию).
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
Docker, Python, Ollama, Blender, Figma, GUI для баз данных, любые линтеры сверх того, что даёт create-next-app. Ничего из этого не нужно и всё это ест время.

## Комплект и зависимости
- [ ] `git clone https://github.com/Alexanderadon/agent-harness`, в папке `.\install.ps1`. Проверка: в Claude Code набрать `/` и увидеть scaffold, hackathon-day, ai-sdk-agent.
- [ ] `.\prewarm.ps1` из той же папки: ставит в кэш pnpm все пакеты дня (Next.js 16, shadcn, ai, @ai-sdk/*, zod, @libsql/client, lucide, vitest, tsx) и проверяет, что скаффолд и сборка проходят. Идёт 5–10 минут, папку после себя удаляет. В день установка пойдёт из кэша за секунды.

## Аккаунты и ключи
- [ ] GitHub Alexanderadon: первый `git push` в любой тестовый репозиторий с ноутбука прошёл (Credential Manager запомнил вход).
- [ ] `git clone https://github.com/BAITC-Hacks/hack-463fe33c-lomra` проходит. Клон читать, ничего не пушить до старта.
- [ ] platform.openai.com: своя организация, $5 на балансе, ключ в менеджере паролей, не в файлах. Лимит расходов $40 в день на 23–29.09.
- [ ] Turso: вход через GitHub на app.turso.tech, база создана в веб-дашборде (CLI на Windows нет), URL и токен в менеджере паролей.
- [ ] Vercel: пустой проект создан, env вбиты (OPENAI_API_KEY, AGENT_MODEL, TURSO_DATABASE_URL, TURSO_AUTH_TOKEN), Deployment Protection выключена.
- [ ] build.nvidia.com: аккаунт есть, ключ сохранён, только резерв.
- [ ] Telegram-канал хакатона и почта открыты на телефоне у обоих. Хотспот с телефона проверен.
- [ ] LAN-переходник USB-A → RJ-45 проверен с кабелем, Wi-Fi 5 ГГц виден.

## Эмина
- [ ] Один раз нажала «Edit» и «Commit changes» на тестовом репозитории в браузере.
- [ ] Шаблоны README, SPEC, PROGRESS из комплекта открыты, PICK-TASK.md прочитан.

## Репозитории, которые можно использовать открыто (Положение 6.4: раскрыть в README)
- `Alexanderadon/agent-harness` — этот комплект.
- `Alexanderadon/neon-tap` — Upstash Redis по REST, серверлесс-функции Vercel, PWA.
- `Alexanderadon/resto-miniapp` — идемпотентные вебхуки, Telegram-бот через fetch, zod-схемы.
- `Alexanderadon/almaty-air` — адаптеры внешних источников, cron-сбор.
- `Alexanderadon/zhk-radar` — скрейперы, MapLibre, статическая генерация.
Правило: копируемый фрагмент называется в README в разделе «Использованные внешние материалы» с именем репозитория.

## Репетиция
- [ ] REHEARSAL.md пройден на ноутбуке, те же инструменты, что будут в день.
- [ ] Замечания по именам API внесены в skills/ai-sdk-agent/SKILL.md и запушены.
