---
name: verify-script
description: Create scripts/verify.ts and the pnpm scripts (verify, smoke, seed) that let a judge prove the main scenario works from a clean checkout. Use after the agent and tools exist.
---

# pnpm verify

scripts/verify.ts (run with tsx):
0. Env. tsx does NOT read .env.local (only `next dev` does): without this step verify never sees the key in .env.local and silently skips the live run. Create scripts/load-env.ts:
   `import { existsSync } from 'node:fs'; for (const file of ['.env.local', '.env']) if (existsSync(file)) process.loadEnvFile(file);`
   (process.loadEnvFile is built into Node 22; no dotenv package) and make `import './load-env';` the FIRST import of scripts/verify.ts and scripts/seed.ts. lib/ reads env lazily inside functions, so import order is enough.
   Guard the production db in BOTH scripts/verify.ts and scripts/seed.ts, before any getDb(): print `db: <dbMode()>` from lib/db.ts; if it is 'turso' and `process.env.VERIFY_REMOTE !== '1'`, print "Refusing to reset the Turso database; set VERIFY_REMOTE=1 if you really mean it" and exit 1 (pnpm smoke runs seed, so smoke is covered too; checked 2026-09-23: an unguarded seed reset whatever TURSO_DATABASE_URL pointed at). TURSO_* never belong in .env.local anyway (deploy-first).
1. Restore the seed first (same code path as POST /api/reset), so a second verify does not trip over orders from the first.
2. Print the ISO timestamp and the model id (AGENT_MODEL or the default) first, then the seed summary (row counts per table).
3. If `hasModelKey()` from lib/model.ts is false: print "No model key (OPENAI_API_KEY or NVIDIA_API_KEY) — skipping live run; pnpm test covers the loop with a mock model; the live run is in docs/verify.log" and exit 0.
4. Run the SPEC.md scenario programmatically: call the same agent from lib/agent.ts with the demo goal, auto-approve write tools for this script only (an override passed by the script, never read by the app), print each step: tool name, input, output summary, ms.
5. Assert the expected state change in the db (from SPEC.md). Print PASS or FAIL with the diff. Exit code 0/1.
6. Restore the seed at the end (same code path as POST /api/reset).

package.json scripts:
- "seed": "tsx scripts/seed.ts"
- "verify": "tsx scripts/verify.ts"
- "smoke": "pnpm typecheck && pnpm test && pnpm seed"
- "typecheck": "next typegen && tsc --noEmit" (same as scaffold; plain tsc fails in a fresh clone)
- "test": "vitest run --passWithNoTests"

Write the exact output of one successful `pnpm verify` run to docs/verify.log and of `pnpm test` to docs/test.log (commit both); run vitest with `--reporter=verbose` so the log lists every test name. The committed docs/verify.log must be a LIVE run with the key: timestamp, model id, every step with ms, PASS. A "skipping live run" log proves nothing and is never the final one. The PM's agent pastes them into README; never edit README yourself.

Tests beyond the scenario (they prove the README's reliability claims without a key, see ai-sdk-agent): tests/limits.test.ts and tests/route.test.ts, next to tools.test.ts and agent.test.ts.

Clean-checkout test: done by the captain's commands «судья сборка» (2:00) and «судья» (4:00) in a separate clone on Emina's laptop. If any step needs a manual action, fix the code, not the README.