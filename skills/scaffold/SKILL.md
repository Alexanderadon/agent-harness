---
name: scaffold
description: Minute-zero setup of a hackathon or new project repo - create the Next.js 16 + shadcn + AI SDK skeleton non-interactively inside a repository that already contains files, then bring in the team kit (AGENTS.md, templates, docs) from the public agent-harness repository and commit. Use when the user says "scaffold" in a fresh repo.
---

# Scaffold, non-interactive, into a non-empty repo, then the team kit

The current folder is the team repository (already has .git, README.md from the platform, maybe .gitignore). Do everything below without asking questions. Budget: 12 minutes (package download alone is 3–4 min). Rehearsed 2026-09-21 on Windows / pnpm 10.33 / Next 16.3.5 / shadcn 4.21: every step below reflects what actually worked.

## 1. Next.js skeleton

create-next-app refuses a directory with files it does not know, so scaffold next to the repo and move the result in.

```bash
cd ..
pnpm create next-app@latest scaffold-tmp --ts --tailwind --eslint --app --no-src-dir --import-alias "@/*" --use-pnpm --yes
```

Move everything EXCEPT `node_modules`, `.git`, `.next` and the generated `README.md` into the repo (pnpm's node_modules use absolute junctions on Windows and die after a move; README.md belongs to the captain). PowerShell:

```powershell
Remove-Item -Recurse -Force scaffold-tmp\.git, scaffold-tmp\node_modules, scaffold-tmp\.next -ErrorAction SilentlyContinue
Remove-Item scaffold-tmp\README.md
Get-ChildItem -Force scaffold-tmp | Move-Item -Destination <repo> -Force
Remove-Item -Recurse -Force scaffold-tmp
```

Then in the repo: `pnpm install` (fast, from the store).

create-next-app 16 writes its own `AGENTS.md` and `CLAUDE.md` with a `<!-- BEGIN:nextjs-agent-rules -->` block that `next dev` re-adds on every run. Keep that block: when the team AGENTS.md arrives in step 3, put the block at the top of it, otherwise both laptops get a dirty tree after every dev run.

## 2. UI kit and dependencies

```bash
pnpm dlx shadcn@latest init -y -d
pnpm dlx shadcn@latest add -y button card badge table skeleton input textarea scroll-area separator
pnpm add ai @ai-sdk/openai @ai-sdk/react zod @libsql/client lucide-react
pnpm add -D vitest tsx "@types/node@^22"
```

`@types/node` must be ^22: create-next-app pins ^20 and vitest 5 refuses it. shadcn 4 uses `@base-ui/react` and a separate `cn` package; that is fine, do not fight it.

## 3. Repo hygiene (now, not later)

- `.nvmrc`: write the file with a tool that writes UTF-8, or `[IO.File]::WriteAllText("$PWD\.nvmrc", "22`n")`. Never `echo 22 > .nvmrc` in PowerShell 5: that writes UTF-16 with a BOM and Node ignores it.
- `.gitignore`: keep the generated `.env*` line and add `!.env.example` right after it, otherwise the kit's `.env.example` is never committed. Add `data/app.db`.
- `.gitattributes` with one line `* text=auto eol=lf`, then `git add --renormalize .` (two Windows laptops otherwise fight over CRLF).
- `next.config.ts`: `serverExternalPackages: ['@libsql/client', 'libsql']` so Turbopack leaves native bindings alone.
- `pnpm-workspace.yaml` (generated) lists `ignoredBuiltDependencies`; remove `sharp` from that list if present, it conflicts with the next line.
- package.json: `"engines": { "node": ">=22" }`, `"pnpm": { "onlyBuiltDependencies": ["@libsql/client", "libsql", "esbuild", "sharp"] }`.
- package.json scripts: `"typecheck": "next typegen && tsc --noEmit"` (Next 16 generates route types into .next/types; a fresh clone has none and plain tsc fails on `LayoutProps`), `"test": "vitest run --passWithNoTests"`, `"seed": "tsx scripts/seed.ts"`, `"verify": "tsx scripts/verify.ts"`, `"smoke": "pnpm typecheck && pnpm test && pnpm seed"`.
- Never start `pnpm dev` in the foreground of this agent: it never returns. Verify with `pnpm build`.

## 4. Team kit (disclosed prior material)

```bash
git clone --depth 1 https://github.com/Alexanderadon/agent-harness ../kit-tmp
```

Copy `AGENTS.md` and `CLAUDE.md` to the root (prepend the nextjs-agent-rules block to AGENTS.md as said above), `templates/TASKS.template.md` as `TASKS.md`, `templates/env.example` as `.env.example`, `templates/PROGRESS.template.md` as `PROGRESS.md` only if PROGRESS.md does not exist yet (the captain may have created it), and into `docs/`: `playbooks/hackalem-2026/WINNING-SHAPE.md`, `templates/SPEC.template.md`, `templates/README.template.md`, `templates/TASK.template.md`. Never overwrite `docs/TASK.md`, `README.md` or `PROGRESS.md` if they exist. Delete `../kit-tmp`.

## 5. Finish

`pnpm typecheck` and `pnpm build` must pass. `git pull --rebase --autostash origin main` (the captain has probably pushed docs/TASK.md by now), commit "scaffold + conventions (disclosed)", push. If push is rejected as non-fast-forward, pull the same way and push again; never force.
Mark block 0 in TASKS.md as ✅ in the same commit.
Report in three lines: what was created, typecheck and build result, anything that asked a question or failed. Then stop.
