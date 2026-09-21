---
name: verify-script
description: Create scripts/verify.ts and the pnpm scripts (verify, smoke, seed) that let a judge prove the main scenario works from a clean checkout. Use after the agent and tools exist.
---

# pnpm verify

scripts/verify.ts (run with tsx):
1. Ensure data/app.db exists; if not, run the seed.
2. Print the seed summary (row counts per table).
3. If OPENAI_API_KEY is missing: print "OPENAI_API_KEY not set — skipping live run; pnpm test covers the loop with a mock model" and exit 0.
4. Run the SPEC.md scenario programmatically: call the same agent from lib/agent.ts with the demo goal, auto-approve write tools for this script only (an override passed by the script, never read by the app), print each step: tool name, input, output summary, ms.
5. Assert the expected state change in the db (from SPEC.md). Print PASS or FAIL with the diff. Exit code 0/1.
6. Restore the seed at the end (same code path as POST /api/reset).

package.json scripts:
- "seed": "tsx scripts/seed.ts"
- "verify": "tsx scripts/verify.ts"
- "smoke": "pnpm typecheck && pnpm test && pnpm seed"
- "typecheck": "tsc --noEmit"
- "test": "vitest run"

README gets the exact output of one successful `pnpm verify` run pasted into a code block.

Clean-checkout test (block 10): `git clone <repo> ../fresh && cd ../fresh && corepack enable && pnpm i --frozen-lockfile && pnpm typecheck && pnpm test && pnpm dev`. Open localhost, see the seeded table without running anything else. If any step needs a manual action, fix the code, not the README.

Optional Docker path (block 10, only if docker build was proven in rehearsal): copy templates/Dockerfile and compose.yaml from agent-harness, set `output: "standalone"` in next.config, run `docker compose up --build`, open localhost:3000, see the seeded table. Add the two commands to README under "Запуск" as an alternative. If the build fails, remove both files rather than leaving them.
