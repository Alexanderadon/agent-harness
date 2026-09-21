---
name: scaffold
description: Create the Next.js 16 + shadcn + AI SDK project skeleton non-interactively inside a repository that already contains files (README, .gitignore). Use once at minute 0 of a hackathon or at the start of any new project on this stack.
---

# Scaffold, non-interactive, into a non-empty repo

create-next-app refuses a directory that contains files it does not know (README.md from the platform, AGENTS.md, docs/). Scaffold in a sibling folder and move the result in.

```bash
# 1. scaffold next to the repo, no prompts
cd ..
pnpm create next-app@latest scaffold-tmp --ts --tailwind --eslint --app --no-src-dir --import-alias "@/*" --use-pnpm --yes
# 2. move everything (including dotfiles) into the repo root, keep the repo's .git
cd scaffold-tmp && rm -rf .git && cp -r . ../<repo>/ && cd .. && rm -rf scaffold-tmp && cd <repo>
# 3. merge: keep the platform README.md content on top of the generated one; merge .gitignore lines (add data/app.db, .env*)
# 4. shadcn, no prompts, default style
pnpm dlx shadcn@latest init -y -d
pnpm dlx shadcn@latest add -y button card badge table skeleton input textarea scroll-area separator
# 5. runtime deps
pnpm add ai @ai-sdk/openai @ai-sdk/react zod @libsql/client lucide-react
pnpm add -D vitest tsx @types/node
# 6. repo basics
echo 22 > .nvmrc
```

package.json additions (do them now, not later):
- "engines": { "node": ">=22" }
- "pnpm": { "onlyBuiltDependencies": ["@libsql/client", "libsql", "esbuild", "sharp"] }
- scripts: "typecheck": "tsc --noEmit", "test": "vitest run", "seed": "tsx scripts/seed.ts", "verify": "tsx scripts/verify.ts", "smoke": "pnpm typecheck && pnpm test && pnpm seed"

Windows note: the move step in PowerShell is `Get-ChildItem -Force scaffold-tmp | Move-Item -Destination <repo> -Force` after deleting scaffold-tmp\.git. If any command asks a question, it was run without its flag; stop and re-run with the flag.

Done when `pnpm typecheck` passes and `pnpm dev` shows the default page. Commit "scaffold" immediately.
