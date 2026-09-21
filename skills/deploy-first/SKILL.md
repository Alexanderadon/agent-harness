---
name: deploy-first
description: Deploy the Next.js app to Vercel from the CLI with Turso as the database, verify from a phone, and keep the local zero-config run intact. Use at the 20-minute mark for the empty deploy and again before submission.
---

# Deploy

Vercel, CLI only (the MCP token is known to return 403):

```bash
vercel login            # once, account fistin103
vercel link             # new project, team fistin103-3986s-projects
vercel env add OPENAI_API_KEY production
vercel env add AGENT_MODEL production
vercel env add TURSO_DATABASE_URL production
vercel env add TURSO_AUTH_TOKEN production
vercel --prod --yes
```

The route with the agent exports `export const maxDuration = 60;`.

Turso for the deployed db (local stays file:data/app.db). On Windows without WSL there is no Turso CLI: create the database in the web dashboard app.turso.tech (Create Database, copy URL, Generate Token). With the CLI:

```bash
turso auth login
turso db create hackalem
turso db show hackalem --url
turso db tokens create hackalem
```

lib/db.ts picks TURSO_DATABASE_URL when present, otherwise file:data/app.db, and runs schema.sql plus the seed on first connect if tables are missing.

Smoke after every deploy: open the URL on the phone, press Reset demo, run the scenario, approve, watch the table change. Paste the URL into README only after the smoke passes.

Env matrix: key A in Vercel production; key B as OPENAI_API_KEY_FALLBACK in .env.local only. Hard limit $40 for the day in the OpenAI dashboard.

Deployment Protection: in the Vercel project settings turn off "Vercel Authentication" for production, then open the URL in an incognito window on the phone. A login wall means "does not open" for a judge.
Why the live URL matters: a judge without an OpenAI key can only run the main scenario on the deployed version. Blocks 2 and 7 are therefore not optional.
