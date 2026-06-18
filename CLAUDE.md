# Repository Guide — Awesome LLM Token Optimization

This repo is a **curated Awesome list**; the deliverable is `README.md`. Keep it
high-signal, accurate, and `awesome-lint`-clean. These rules apply to every
session — **especially the scheduled weekly-maintenance runs**.

## Hard rules

1. **Lint must pass before any commit/PR.** Run `npx prettier --write README.md`
   then `npx awesome-lint`; fix every error (0 errors). Key constraints
   `awesome-lint` enforces:
   - **No duplicate links** — a given URL may appear only **once** in the whole
     README. Don't repeat a link between the Quick Wins table, inline lists, and
     the Academic Papers tables. Papers live **only** in the Academic Papers
     tables.
   - **Aligned tables** (prettier handles this), list-item format
     (`[Name](url) - Description.` ending in punctuation), no inline
     `## License` section.
   - **Do NOT add a CI/build badge to the README** (the badge is forbidden by
     sindresorhus/awesome even though CI for linting is fine).

2. **Verify before adding — adversarially. Never add anything unconfirmed.**
   - **Tools:** the repo exists, is **active** (recent commits), **open-source**
     (or has a real free tier), and is specifically about reducing LLM
     **token/cost**. One entry per project. Reject self-promotional clusters and
     low-traction single-author projects (~<a few hundred stars) unless clearly
     seminal.
   - **Papers:** the arXiv ID must resolve to the claimed title — corroborate
     via search / Semantic Scholar / HF if `arxiv.org` blocks automated fetches.
     **Never add unverifiable or future-dated IDs.** Include year + a verified
     one-line key result.
   - **Provider / pricing / caching changes:** confirm the change was actually
     **enacted** — not merely announced, and **not announced-then-reverted**
     (e.g. the June-15 2026 Anthropic Agent-SDK billing change was *paused*, so
     it must not be stated as fact). When unsure, omit. For Anthropic/Claude
     model or pricing specifics, verify against authoritative Anthropic docs,
     not memory.

3. **Dedupe against the current README first.** Read it before proposing
   anything; never add an entry, link, or paper that's already present. (Prior
   maintenance runs repeatedly re-proposed the same items — don't.)

4. **Honor `CONTRIBUTING.md`.** Same quality bar.

## PR hygiene (scheduled maintenance)

- Produce **one consolidated PR per run**. If a previous maintenance PR is still
  open, **update/supersede it** — do not stack another near-duplicate PR.
- Close or supersede stale maintenance PRs so they don't accumulate.
- Branch name `maintenance/YYYY-MM-DD`; **delete the branch after merge/close**.
- The PR body should list what was added **and what was checked but rejected,
  with the reason** (so verification is auditable).

## Weekly maintenance playbook

Sweep → verify → consolidate:

1. **Provider docs/pricing** (Anthropic, OpenAI, Google, DeepSeek, Mistral, xAI):
   caching, batch, and pricing changes **actually in effect**.
2. **New tools/frameworks** (routing, gateways, prompt/output compression,
   KV-cache, inference engines, cost tracking) — verify per Hard Rule 2.
3. **New papers** (compression, KV-cache, routing, context, concise reasoning) —
   verify IDs per Hard Rule 2; add to the Academic Papers tables only.
4. **Link health** on a sample — a 403 from a bot ≠ a dead link; confirm via a
   browser/search before removing anything.
5. Update README → `prettier --write` → `awesome-lint` (0 errors) → open **one**
   PR summarizing the verified changes.
