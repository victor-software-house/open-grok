# ADR-0002: Import upstream content through normal fork history

- Status: Accepted
- Date: 2026-07-15

## Context

Upstream changes may arrive as a linear commit range or as a rewritten snapshot. The fork needs one integration model that preserves reviewability, separates imported code from fork-owned changes, and supports exact-content verification.

## Decision

Accepted upstream content is applied on a dedicated `sync/*` branch and committed through normal `open-grok` history.

For a linear range, the pull request records the reviewed commit range. For an unrelated root, it records the reviewed tree delta. The prepared patch and working-tree patch receive a stable patch-ID comparison before review.

Upstream-content commits contain only imported paths. Deliberate fork behavior changes, lint migrations, architecture documentation, and remediation discovered during review use separate commits or pull requests.

## Consequences

- Imported content remains distinguishable from fork-owned work.
- Exact patch identity is reproducible.
- Follow-up fixes cannot be mistaken for upstream source.
- Synchronization may require more than one pull request when documentation or fork-specific remediation follows the import.

## Alternatives considered

### Mix imported and fork-owned changes in one commit

Rejected because provenance and future conflict analysis become ambiguous.

### Cherry-pick arbitrary upstream commits after a root rewrite

Rejected when ancestry is unavailable or the publication does not expose the internal commit sequence represented by the new tree.

### Copy changed files without recording patch identity

Rejected because file copying alone cannot prove which source delta was reviewed.

## Evidence

- [`docs/upstream/sync-workflow.md`](../../upstream/sync-workflow.md)
- [`CODING_STANDARDS.md`](../../../CODING_STANDARDS.md)

## Enforcement

- `sync/*` branch convention.
- Required synchronization record and `CHANGELOG.md` update only when it classifies `| User-visible change | yes |`.
- Stable patch-ID check in preparation evidence.
- Independent pull-request review.
