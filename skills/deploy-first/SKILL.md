---
name: deploy-first
description: Deploy the Next.js app to Vercel from the CLI with Turso as the database, verify from a phone, and keep the local zero-config run intact. Use at the 20-minute mark for the empty deploy and again before submission.
---

# Deploy

Vercel, CLI only (the MCP token is known to return 403):

```bash
vercel login            # once, account fistin103
vercel link             # new project, team fistin103-3986s-projects
vercel env add OPENAI_API_KEY production       # OUR OWN key, never the perk key: see "Which key" below
vercel env add AGENT_MODEL production          # gpt-6-sol
vercel env add AGENT_REASONING production      # the level measured on the first live run, default low
vercel env add TURSO_DATABASE_URL production   # REQUIRED, see "Turso is not optional"
vercel env add TURSO_AUTH_TOKEN production
vercel --prod --yes
```

The route with the agent exports `export const maxDuration = 60;`. After the first deploy that runs the agent, time the whole scenario on the live URL. If the stream is cut off before 60 s while it works locally, the Vercel plan caps function duration lower: Project Settings → Functions → Max Duration, and lower AGENT_REASONING until the run fits.

Turso is not optional. Without TURSO_DATABASE_URL lib/db.ts falls back to `:memory:` on Vercel, and that is a separate database inside EVERY serverless instance. The write happens in the /api/chat instance, then `router.refresh()` re-renders the page, possibly in another instance that never saw the write: the expert presses Approve and the row does not change. Under Положение 5.4.16 a scenario that cannot be verified is a disqualification, not a lost point. The empty deploy at 0:20 may go out without Turso (the table only reads the seed); the scenario deploy may not. Before `vercel --prod` of any build that includes a write tool: `vercel env ls production` must list TURSO_DATABASE_URL and TURSO_AUTH_TOKEN.

Turso for the deployed db (local stays file:data/app.db). On Windows without WSL there is no Turso CLI: create the database in the web dashboard app.turso.tech (Create Database, copy URL, Generate Token). With the CLI:

```bash
turso auth login
turso db create hackalem
turso db show hackalem --url
turso db tokens create hackalem
```

lib/db.ts picks TURSO_DATABASE_URL when present, otherwise file:data/app.db, and runs schema.sql plus the seed on first connect if tables are missing.

Smoke after every deploy: open the URL on the phone, press Reset demo, run the scenario, approve, watch the table change. Paste the URL into README only after the smoke passes. From the scenario deploy on, repeat this smoke at every `чекпоинт`: the live URL is a gate, not a one-time task.

Which key. Vercel production gets OUR OWN key from platform.openai.com (own organisation, own billing). NEVER the perk key from the event cabinet: perk keys are commonly revoked after the event, and the experts run the live URL on 24–28.09, the finalists again on 29.09. A dead key on the live URL means the key functionality cannot be checked (Положение 5.6.6) and the team is out (5.4.16). The perk key goes only into .env.local for local work that day. Env matrix: own key in Vercel production; perk key as OPENAI_API_KEY in .env.local; the other one as OPENAI_API_KEY_FALLBACK in .env.local only.

Budget until 29.09, not for one day. The OpenAI balance and the monthly spend limit must cover a week of a public URL: with gpt-6-sol a run costs about $0.08, and lib/limits.ts caps runs at AGENT_RUNS_PER_DAY (default 100, so at most about $8 a day). Set the monthly budget in the OpenAI dashboard to cover 7 such days.

Deployment Protection: in the Vercel project settings turn off "Vercel Authentication" for production, then open the URL in an incognito window on the phone. A login wall means "does not open" for a judge.
Why the live URL matters: a judge without an OpenAI key can only run the main scenario on the deployed version, and Положение 5.6.6 requires that the key functionality be checkable without any of our accounts or subscriptions. Blocks 2 and 7 are therefore not optional.

After 18:00 the live URL must survive until 29.09: do not delete or rename the Vercel project, do not rotate the key, do not delete the Turso database. On the morning of 24.09 and again before Demo Day open the URL in incognito and run the scenario once: Reset, Run, Approve, the row changes.
