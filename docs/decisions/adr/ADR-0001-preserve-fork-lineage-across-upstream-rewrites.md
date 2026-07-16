# ADR-0001: Preserve fork lineage across upstream rewrites

- Status: Accepted
- Date: 2026-07-15

## Context

An upstream repository may force-update its default branch, replace a published root commit, or otherwise produce a candidate revision with no common ancestor to the last reviewed source. Resetting a maintained fork to that root would erase the fork's auditable lineage and detach prior review evidence from the code it described.

The first observed case was the `xai-org/grok-build` replacement of parentless root `c1b5909…` with parentless root `b189869…`.

## Decision

`open-grok` preserves its existing lineage when upstream rewrites history.

Before considering the replacement:

1. preserve the last reviewed upstream root on an origin archive branch;
2. lock that branch against force-push and deletion;
3. compare the old and new trees;
4. review the candidate as a content migration;
5. integrate accepted content through normal fork history.

The fork does not reset, force-push, or rebase away established history to match an unrelated upstream root.

## Consequences

- Prior source evidence remains reachable and reproducible.
- Upstream replacements require explicit review rather than automatic synchronization.
- Git history contains fork-owned integration commits instead of preserving an upstream graph relationship that no longer exists.
- Tree and patch identity must be recorded separately from ancestry.

## Alternatives considered

### Reset the fork to the new root

Rejected because it destroys established fork history and invalidates review provenance.

### Ignore all rewritten upstream publications

Rejected because replacement snapshots may contain important correctness, security, compatibility, or documentation changes.

### Merge unrelated roots

Rejected because a synthetic two-root merge misrepresents the publication relationship and makes ordinary history harder to audit.

## Evidence

- [`docs/architecture/source-ledger.md`](../../architecture/source-ledger.md)
- [`docs/upstream/xai-grok-build/2026-07-15-b189869.md`](../../upstream/xai-grok-build/2026-07-15-b189869.md)
- [`docs/upstream/sync-workflow.md`](../../upstream/sync-workflow.md)

## Enforcement

- Current in-tree enforcement is the documented process and [`scripts/upstream/validate-pr.sh`](../../../scripts/upstream/validate-pr.sh) when maintainers run it against a proposed synchronization range.
- The accepted policy calls for planned GitHub synchronization gates, including pull-request-only synchronization and CI validation; those `.github` controls are not evidence of active enforcement until they land.
