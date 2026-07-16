# PDR-0001: Require isolated reviewed upstream synchronization pull requests

- Status: Accepted
- Date: 2026-07-15

## Context

Upstream imports can alter large portions of runtime, authentication, persistence, tools, sandboxing, and documentation at once. Direct integration into the default branch prevents required checks and focused review from acting as merge gates.

## Decision

Every upstream code synchronization uses a dedicated pull request from `sync/<source>-<revision>`.

The pull request:

- contains one upstream delta only;
- carries the `upstream-sync` classification;
- updates one dated upstream record;
- classifies user-visible impact with `| User-visible change | yes |` or `| User-visible change | no |` in the dated record, and updates the changelog when the classification is `yes`;
- satisfies the accepted required checks;
- receives independent diff review;
- merges without bypassing branch protection.

Evidence-pin-only updates may use a normal documentation pull request when no source is imported.

## Consequences

- Synchronization quality is visible before merge.
- Review discussions remain scoped to one source delta.
- Maintenance takes longer than direct pushes but avoids ambiguous or unverified imports.
- Emergency exceptions require a separate documented decision; they are not implicit administrator discretion.

## Alternatives considered

### Direct synchronization commits to `main`

Rejected because validation and review occur after the state has already become authoritative.

### Combine synchronization with architecture updates

Rejected because source import correctness and interpretation of the new architecture require different review questions.

### Allow unreviewed automated merges

Rejected because upstream source remains external input and may include incompatible or unsafe changes.

## Evidence

- [`docs/upstream/sync-workflow.md`](../../upstream/sync-workflow.md)
- [`scripts/upstream/validate-pr.sh`](../../../scripts/upstream/validate-pr.sh)

## Enforcement status

- Current in-tree enforcement is the documented process and `validate-pr.sh` when maintainers run it against a proposed synchronization range.
- The accepted policy calls for planned GitHub branch protection, synchronization gates, and a pull-request template; those `.github` controls are not yet evidence of active enforcement.
