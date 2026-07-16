# Decision records

Decision records preserve the context and consequences of choices that should remain understandable after code, maintainers, and upstream sources change.

## Record types

| Type | Scope | Directory |
|---|---|---|
| **ADR** | Technical architecture, data ownership, interfaces, security boundaries, persistence, runtime, and migration strategy | [`adr/`](adr/) |
| **PDR** | Product, project, release, maintenance, contribution, and operational process decisions | [`pdr/`](pdr/) |

A change may require both records when product policy and technical architecture are independently consequential.

## Lifecycle

Records use these statuses:

- **Proposed** — available for review; not authoritative.
- **Accepted** — current decision and required context.
- **Deprecated** — retained for history but no longer recommended.
- **Superseded by ADR/PDR-NNNN** — replaced by a later record.
- **Rejected** — considered and deliberately not adopted.

Accepted records are immutable except for factual corrections, link repair, and an explicit status transition. A changed decision receives a new record that links to and supersedes the old one.

## Required structure

Each record contains:

1. title, status, and date;
2. context and problem;
3. decision;
4. consequences and trade-offs;
5. alternatives considered;
6. evidence and related records;
7. verification or enforcement where applicable.

Do not include credentials, private endpoints, personal data, conversation history, or subjective request provenance. State the technical or product rationale directly.

## Naming

```text
ADR-NNNN-short-kebab-title.md
PDR-NNNN-short-kebab-title.md
```

Numbers are monotonically increasing within each record type and are never reused.

## Current records

### Architecture decisions

- [`ADR-0001-preserve-fork-lineage-across-upstream-rewrites.md`](adr/ADR-0001-preserve-fork-lineage-across-upstream-rewrites.md)
- [`ADR-0002-import-upstream-content-through-normal-fork-history.md`](adr/ADR-0002-import-upstream-content-through-normal-fork-history.md)

### Product and process decisions

- [`PDR-0001-require-isolated-reviewed-upstream-sync-pull-requests.md`](pdr/PDR-0001-require-isolated-reviewed-upstream-sync-pull-requests.md)
- [`PDR-0002-use-layered-change-provenance.md`](pdr/PDR-0002-use-layered-change-provenance.md)
