# open-grok provider platform goal

Goal setup is complete: `facts.md` and `facts.meta.json` contain the final 39-fact authority, `plan.md` is approved after direct interview amendments and focused review, and `goal.md` is the self-contained invariant objective. `facts-history/` preserves the earlier completed 31-fact review.

This directory will contain the reviewed provenance package:

- `interview.json` and `interview-result.json` — public-safe structured decisions without verbatim request history
- `facts-review.json`, `facts-result.json`, `facts.md`, and `facts.meta.json`
- `facts-history/` — public-safe completed review bundles before material amendments
- `plan.md`
- `goal.md`
- `goal-condition.md` — invariant controller copied into the active goal system
- `state.md` — mutable execution progress, never objective authority

The final goal must be self-contained and invariant while its underlying evidence references can evolve through explicit pinned updates. The active controller rereads the live goal, facts, plan, state, evidence ledger, and decisions before resuming the first incomplete gate; mutable state never replaces reviewed authority.

Prerequisite: complete and review [`../../docs/architecture/`](../../docs/architecture/).
