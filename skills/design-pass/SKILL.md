---
name: design-pass
description: 15-minute visual pass that makes a shadcn default UI look like a finished product using the team's fixed design formula. Use only after the scenario works, never during feature work.
---

# Design pass, 15 minutes, in this order

1. Replace the :root tokens in app/globals.css with templates/globals.tokens.css from agent-harness (background #F2F2F2, card #FFFFFF, border #D1D1D1, foreground #000000, muted-foreground #7A7A7A, primary #000000, radius 8px small, 28px for large cards).
2. Font: Golos Text via next/font/google on body; headings tracking-tight; page title text-3xl; section titles text-lg font-medium.
3. Spacing on an 8px grid: page padding p-6 desktop, p-4 mobile; gap-4 between cards; gap-2 inside.
4. Large containers (table card, agent panel) get rounded-[28px]; buttons, inputs, badges keep rounded-lg.
5. One accent only: black primary buttons, everything else outline or ghost. No colored backgrounds, no gradients, no animation beyond the spinner.
6. Empty, loading and error states show a one-line muted text, never a blank area.
7. Check at 390px width: no horizontal scroll, the panel stacks under the table, buttons full width.
8. Screenshot for README after this pass.

Stop after 15 minutes even if something is imperfect.

## Markup corrector (do this before step 1, 5 minutes)
Open the rendered HTML (view-source or the inspector) and fix what a front-end reviewer would flag first:
- Every card is a `section` with an `h2`; the page has one `h1`, a `header`, a `main` and an `aside` for the agent panel.
- Record lists are `ul/li`, never stacked divs; the data table has `caption`, `thead`, `th scope="col"`, numeric cells `text-right tabular-nums`, units in the header, no clipped columns at 1280px (hide or abbreviate secondary columns with `hidden lg:table-cell`).
- The agent trace is an `ol` of steps; each Approve/Reject is a real `button` with an accessible name.
- Every input has a `label` (`htmlFor`), status badges have text, not colour only; focus rings visible.
- Run `pnpm dlx @axe-core/cli http://localhost:3000` only if it takes under two minutes; otherwise skip, the checklist above is the gate.
