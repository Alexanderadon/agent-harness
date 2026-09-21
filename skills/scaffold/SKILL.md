---
name: scaffold
description: Minute-zero setup of a hackathon or new project repo - create the Next.js 16 + shadcn + AI SDK skeleton non-interactively inside a repository that already contains files, then bring in the team kit (AGENTS.md, templates, docs) from the public agent-harness repository and commit. Use when the user says "scaffold" in a fresh repo.
---

# Scaffold, non-interactive, into a non-empty repo, then the team kit

The current folder is the team repository (already has .git, README.md from the platform, maybe .gitignore). Do everything below without asking questions.

## 1. Next.js skeleton

create-next-app refuses a directory with files it does not know, so scaffold next to the repo and move the result in.

```bash
cd ..
pnpm create next-app@latest scaffold-tmp --ts --tailwind --eslint --app --no-src-dir --import-alias "@/*" --use-pnpm --yes
cd scaffold-tmp && rm -rf .git && cp -r . ../<repo>/ && cd .. && rm -rf scaffold-tmp && cd <repo>
```

PowerShell equivalent for the move: delete `scaffold-tmp\.git`, then `Get-ChildItem -Force scaffold-tmp | Move-Item -Destination <repo> -Force`.
Keep the platform README.md content at the top of the generated README. Merge .gitignore and add `data/app.db` and `.env*`.

## 2. UI kit and dependencies

```bash
pnpm dlx shadcn@latest init -y -d
pnpm dlx shadcn@latest add -y button card badge table skeleton input textarea scroll-area separator
pnpm add ai @ai-sdk/openai @ai-sdk/react zod @libsql/client lucide-react
pnpm add -D vitest tsx @types/node
echo 22 > .nvmrc
```

Repo hygiene (do it now, not later):
- `.gitattributes` with one line `* text=auto eol=lf`, then `git add --renormalize .` (two Windows laptops otherwise fight over CRLF).
- `next.config.ts`: `serverExternalPackages: ['@libsql/client', 'libsql']` so Turbopack leaves native bindings alone.
- Never start `pnpm dev` in the foreground of this agent: it never returns. Verify with `pnpm build`, or start dev in the background and curl it.
- On Windows the agent shell is PowerShell: use Remove-Item -Recurse -Force, Copy-Item -Recurse, Move-Item instead of rm/cp/mv.

package.json: `"engines": { "node": ">=22" }`, `"pnpm": { "onlyBuiltDependencies": ["@libsql/client", "libsql", "esbuild", "sharp"] }`,
scripts `"typecheck": "tsc --noEmit"`, `"test": "vitest run"`, `"seed": "tsx scripts/seed.ts"`, `"verify": "tsx scripts/verify.ts"`, `"smoke": "pnpm typecheck && pnpm test && pnpm seed"`.

## 3. Team kit (disclosed prior material)

```bash
git clone --depth 1 https://github.com/Alexanderadon/agent-harness ../kit-tmp
cp ../kit-tmp/AGENTS.md ../kit-tmp/CLAUDE.md .
cp ../kit-tmp/templates/TASKS.template.md TASKS.md
cp ../kit-tmp/templates/env.example .env.example
cp ../kit-tmp/templates/PROGRESS.template.md PROGRESS.md
mkdir -p docs
cp ../kit-tmp/playbooks/hackalem-2026/WINNING-SHAPE.md ../kit-tmp/templates/SPEC.template.md ../kit-tmp/templates/README.template.md ../kit-tmp/templates/TASK.template.md docs/
rm -rf ../kit-tmp
```

Do not overwrite docs/TASK.md if it already exists.

## 4. Finish

`pnpm typecheck` must pass and `pnpm dev` must show the default page. Commit "scaffold + conventions (disclosed)". Push if a remote exists.
Report in three lines: what was created, typecheck result, anything that asked a question or failed. Then stop.
