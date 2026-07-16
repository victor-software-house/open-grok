# PDR-0002: Use layered change provenance

- Status: Accepted
- Date: 2026-07-15

## Context

A single changelog cannot efficiently serve users, maintainers, architecture reviewers, and upstream auditors. Mixing every detail into one file makes the user history noisy while still failing to preserve implementation evidence and decision context.

## Decision

`open-grok` uses four complementary records:

1. `CHANGELOG.md` for concise user-visible changes;
2. `docs/upstream/` for source revisions, imported scope, validation, integration provenance, and a machine-checkable `User-visible change` classification that determines whether `CHANGELOG.md` is required;
3. ADRs for durable technical architecture decisions;
4. PDRs for durable product, project, release, and maintenance-process decisions.

Goal fact sheets and plans remain separate review artifacts. They do not replace accepted decision records after implementation policy becomes durable.

## Consequences

- Readers can choose the appropriate level of detail.
- Upstream audits do not overwhelm release notes.
- Decisions remain understandable after their implementation changes.
- Maintainers must update the correct record type as part of each consequential change.

## Alternatives considered

### One comprehensive changelog

Rejected because it becomes unsuitable for both users and engineering audit.

### Commit messages as the only history

Rejected because commits do not consistently preserve alternatives, consequences, evidence, or supersession.

### Mutable wiki or issue threads

Rejected as the authority because they are not versioned with the code and can drift from the repository state.

## Evidence

- [`CHANGELOG.md`](../../../CHANGELOG.md)
- [`docs/upstream/README.md`](../../upstream/README.md)
- [`docs/decisions/README.md`](../README.md)

## Enforcement status

- Current in-tree basis: contribution and coding standards, the upstream workflow, and [`scripts/upstream/validate-pr.sh`](../../../scripts/upstream/validate-pr.sh).
- The accepted policy calls for planned GitHub pull-request templates, Markdown-link gates, and synchronization checks; those `.github` controls are not yet evidence of active enforcement.
