# Upstream change ledger

This directory records every reviewed import or evidence-pin advancement from an external authority.

The root [`CHANGELOG.md`](../../CHANGELOG.md) summarizes user-visible project changes. This ledger preserves the engineering provenance needed to reproduce and audit each upstream decision. Code imports follow the mandatory [`synchronization workflow`](sync-workflow.md) and related [`decision records`](../decisions/README.md).

## Required record

Every upstream change record states:

1. the named upstream repository and immutable old/new revisions;
2. default-branch identity and comparison status at review time;
3. whether histories are linear, diverged, or unrelated;
4. any preserved branch or tag created before integration;
5. the exact scope imported, omitted, or rejected;
6. behavior, security, compatibility, and documentation effects;
7. verification commands and outcomes;
8. the fork commit that carries the integration;
9. unresolved follow-ups.

A local checkout is never sufficient provenance. Verify the named upstream repository and exact objects directly before writing or updating a record.

## Integration policy

- **Linear upstream change:** review the commit range, then import it through normal fork history.
- **Rewritten or unrelated history:** stop automatic synchronization, preserve the last reviewed root, compare trees, and integrate accepted content as a normal fork-owned commit.
- **Evidence-only reference update:** record why the new pin changes or does not change the claim for which the reference is used.
- **Partial import:** list every omitted or rejected behavior and the reason.
- **No history replacement:** never reset, rebase away, or force-push established `open-grok` history to match an upstream rewrite.

## Records

| Source | Date | Old revision | New revision | Result |
|---|---|---|---|---|
| [`xai-org/grok-build`](xai-grok-build/2026-07-15-b189869.md) | 2026-07-15 | `c1b5909…` | `b189869…` | Audited candidate; isolated synchronization PR required; original root preserved |
| [`openai/codex`](openai-codex/2026-07-16-2edad72.md) | 2026-07-16 | `78d4a56…` | `2edad72…` | Evidence-pin advancement; no code import |
| [`can1357/oh-my-pi`](oh-my-pi/2026-07-16-03c48d0.md) | 2026-07-16 | `d5cd24f…` | `03c48d0…` | Evidence-pin advancement; usage fact clarified; no code import |

Pi and models.dev matched their recorded default-branch heads during the provenance verification and therefore required no change record.
