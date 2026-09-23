---
name: deploy-first
description: Deploy the Next.js app to Vercel from the CLI with Turso as the database, verify it through /api/health and a phone smoke, and keep the live URL alive until Demo Day. Use for the empty deploy at ~0:25, the hourly deploys after each checkpoint, the final deploy at 4:00, and for key rotation after the event.
---

# Deploy

Vercel, CLI only (the MCP token is known to return 403). The project is prepared in the morning (account fistin103, project lomra, Deployment Protection off, env set), so in the day only `vercel link` and `vercel --prod --yes` remain.

```bash
vercel login                                   # once, account fistin103
vercel link --yes --project lomra              # team fistin103-3986s-projects
vercel env add OPENAI_API_KEY production       # OUR OWN key of the OpenAI project lomra-demo, never the perk key ("Which key")
vercel env add AGENT_MODEL production          # always set explicitly; fixed at the 2:50 deploy ("Which model")
vercel env add AGENT_REASONING production      # the level measured on the first live run, default low
vercel env add TURSO_DATABASE_URL production   # REQUIRED ("Turso is not optional"); skip both when the Turso Cloud integration already connected them
vercel env add TURSO_AUTH_TOKEN production
vercel --prod --yes
```

## When to deploy

- Empty deploy at ~0:25 (block 2): the scaffold page (block 1 is still in progress, the seed arrives with the 0:50 deploy). There is no /api/health yet; the check is only that the URL opens on the phone in incognito without a Vercel login wall.
- Hourly, right after each checkpoint push (0:50, 1:50, 2:50), the release candidate of block 7 at 3:15 (after block 6 is pushed, before `блок 9`), and the final one at 4:00: ONLY when `git status --short` is empty and `git rev-parse HEAD` equals `git rev-parse origin/main`. `vercel` uploads the working folder, not the commit: deploying mid-block ships code that is not in the repository. If the tree is dirty, skip that hour's deploy.
- From 4:30 (17:30) never run `vercel --prod`. A broken URL after that gets `vercel rollback` to the last good deployment, nothing else.

## Gate after every deploy

The README and the smoke use the production alias that `vercel --prod` prints (line "Aliased") or that Vercel → Domains shows. Never construct the address by hand: `lomra.vercel.app` may belong to someone else.

1. From the deploy that contains block 1 on: `curl -s <URL>/api/health` shows `"db":"turso","db_ok":true`. Anything else means the deploy is not done.
2. Smoke on the phone in incognito: Reset demo (it also applies the current schema, see ai-sdk-agent), Run, Approve, the row changes; reload twice and open the same URL in a second browser: the row is still changed. That is the only check that catches a per-instance database. End with Reset, so the next visitor starts from the seed.
3. Paste the URL into README only after the smoke passes.

The route with the agent exports `export const maxDuration = 60;`. On the first deploy that runs the agent, time the whole scenario on the live URL. If the stream is cut off before 60 s while it works locally, the Vercel plan caps function duration lower: Project Settings → Functions → Max Duration, and lower AGENT_REASONING until the run fits.

## Turso is not optional

Without TURSO_DATABASE_URL lib/db.ts falls back to `:memory:` on Vercel, and that is a separate database inside EVERY serverless instance. The write happens in the /api/chat instance, then `router.refresh()` re-renders the page, possibly in another instance that never saw the write: the expert presses Approve and the row does not change. Under Положение 5.4.16 a scenario that cannot be verified is a disqualification, not a lost point. The fallback only keeps the page alive and shows a red line; a deployment in that mode is never submitted.

The rules do not name Turso; they need one persistent database shared by every instance. Turso is the only one that needs no code change: it is hosted libSQL, the same SQLite dialect and @libsql/client the app, the tests and the local file database use. Postgres (Neon, Supabase) means rewriting lib/db.ts, the SQL dialect, FTS5, the in-memory test database and the verify/seed scripts on the day; Redis, Blob and Global Config are not consistent databases.

Two databases are created in the morning: `lomra-probe` for the morning test and `lomra` for the day, untouched until 13:00. Two ways, checked against the docs on 23.09; pick ONE per Vercel project and never mix them in the same project (a connected integration fails on env names that already exist):

A. Recommended, no separate account: Vercel dashboard → Marketplace (Storage) → **Turso Cloud** → Install (the person accepts the terms, free plan $0, billed through the Vercel team fistin103) → create database → Connect Project: the right project, **Production only**, and the **Custom Prefix field empty** (it may come prefilled, e.g. STORAGE; any prefix renames the variables and lib/db.ts silently falls back to `:memory:`). CLI equivalent, run by the person in an interactive terminal inside the linked folder: `vercel integration add tursocloud/database --name lomra -e production --no-env-pull` (`--no-env-pull` keeps TURSO_* out of .env.local and does not overwrite the local keys). Then `vercel env ls production` must list exactly `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN`, then `vercel --prod` (existing deployments do not get new env). The lifetime of the integration's token is not documented: the daily /api/health check below covers it.
B. Direct: app.turso.tech → Sign in with GitHub (not a passkey) → Create Database → copy the URL (`libsql://…`) → Generate Token with Expiration **Never** (a 7-day token dies before Demo Day), then `vercel env add` as above. There is no Turso CLI on Windows without WSL.

Either way: engine **libSQL**, not the new Turso engine ("early preview": its full-text search is not FTS5, and @libsql/client targets libSQL); location **AWS US East (Virginia), aws-us-east-1**, next to the Vercel function region iad1 (check Project Settings → Functions); never run `turso db tokens invalidate` (it kills every token of the group, both databases). The free plan archives a database after 10 days without activity and it does not wake up by itself: the daily 10:00 check on 24–29.09 keeps it active. URL and token go to the password manager and then only into Vercel env. TURSO_* never go into .env.local: `pnpm verify` and `pnpm seed` reset whatever database they connect to, and verify refuses Turso without VERIFY_REMOTE=1 for that reason. FTS5 (form B) was tested only on the local file: when the task is form B, the smoke of the first deploy with block 1 includes one search on the live URL.

lib/db.ts picks TURSO_DATABASE_URL when present, otherwise file:data/app.db (or `:memory:` on Vercel), and runs schema.sql plus the seed on first connect if tables are missing.

## Which key

Vercel production gets OUR OWN key: a separate OpenAI project `lomra-demo` in our organisation, prepaid balance $15–20, auto-recharge OFF. That prepaid balance is the only hard stop on spend for a public URL. NEVER the perk key from the event cabinet: perk keys are commonly revoked after the event, and the experts run the live URL on 24–28.09, the finalists again on 29.09. A dead key means the key functionality cannot be checked (Положение 5.6.6) and the team is out (5.4.16). The perk key lives only in .env.local for local work that day. No own OpenAI key at all: our own NVIDIA_API_KEY plus an AGENT_MODEL with function calling.

A new OpenAI organisation may be required to verify itself before it can stream some models. The first live Run shows it: an error mentioning organisation verification means verify the organisation on platform.openai.com (Settings → Organization) or switch to another key or model. Check this in the morning on lomra-probe, not at 1:50.

## Which model

Locally all day `AGENT_MODEL=gpt-6-luna`. In Vercel production the model is fixed at the 2:50 deploy and never changed after 3:15: `gpt-6-sol` if three Runs on the live URL each finish under 30 s with the Approve card and the prepaid balance is at least $10; otherwise `gpt-6-luna`; otherwise `gpt-5.6-terra`. Changing it means `vercel env rm AGENT_MODEL production --yes`, `vercel env add AGENT_MODEL production`, then `vercel redeploy <URL of the current production deployment> --target production` (same source, new env; the working tree is not involved, so it works mid-block). Cost: about $0.08 per run on gpt-6-sol, $0.004 on gpt-6-luna; lib/limits.ts allows 10 runs an hour per address and has a daily breaker at 300 runs.

## Deployment Protection

In the Vercel project settings turn off "Vercel Authentication" for production (done in the morning), then open the URL in an incognito window on the phone. A login wall means "does not open" for a judge. Why the live URL matters: a judge without an OpenAI key can only run the main scenario on the deployed version, and Положение 5.6.6 requires that the key functionality be checkable without any of our accounts or subscriptions. Blocks 2 and 7 are therefore not optional.

## After 18:00, until 29.09

The repository is frozen at 18:00 (5.4.13–5.4.14): never deploy changed code again. Keep the Vercel project, its env and the Turso database; do not delete or rename them. Every morning 24–29.09 at 10:00: `<URL>/api/health` shows turso, db_ok and a model, then Reset, Run, Approve, Reset on the phone; check the prepaid balance of lomra-demo.

Key rotation, only if the key dies (revoked, out of balance), and only infrastructure: `vercel env rm OPENAI_API_KEY production --yes` (a dead key left in env still wins in lib/model.ts), `vercel env add OPENAI_API_KEY production` with a working key (or NVIDIA_API_KEY plus AGENT_MODEL), then Dashboard → Deployments → the current production deployment → Redeploy (the same commit). Before the first such change after 18:00, ask the organizers in the official chat whether an env change counts as a change of the project.
