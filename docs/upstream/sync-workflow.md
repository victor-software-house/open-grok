# Upstream synchronization workflow

This process applies to imported source snapshots and commit ranges from `xai-org/grok-build` or another code upstream. Evidence-only reference updates follow the lighter process in [`README.md`](README.md).

## Invariants

- Existing `open-grok` history is never reset, force-pushed, or rebased away to match upstream.
- Every synchronization is prepared on a `sync/<source>-<revision>` branch and merged through a dedicated pull request.
- The pull request contains one upstream change only. Fork-owned feature work, architecture redesign, and unrelated cleanup use separate pull requests.
- The previous reviewed source remains reachable before a rewritten or disappearing upstream root is integrated.
- Local checkouts do not establish provenance. Repository identity, default branch, old revision, and new revision are verified directly against the named upstream.
- Imported content is reviewed as a tree or commit-range delta. A matching patch ID proves content identity; it does not replace code review or tests.
- Failed, blocked, skipped, and unavailable validation is recorded exactly.

## 1. Discover

1. Resolve the upstream repository and default branch through its hosting API.
2. Verify that the current reviewed revision and candidate revision both exist.
3. Compare the revisions.
4. If the revisions have no common ancestor, compare recursive trees and classify the candidate as a rewritten-root migration.
5. Record timestamps, object IDs, file counts, changed paths, and diff statistics.

No working-tree change occurs during discovery.

## 2. Preserve

For a rewritten or disappearing root:

1. create `archive/<source>-<short-revision>` at the last reviewed revision;
2. push the archive branch to `origin`;
3. lock the branch against force-push and deletion;
4. verify the protected branch through the hosting API.

Linear upstream histories do not require a new archive branch for every commit, but previously created archives remain immutable.

## 3. Prepare

1. Start from current `origin/main`.
2. Create `sync/<source>-<short-revision>`.
3. Fetch the exact upstream objects without moving `main`.
4. Apply the reviewed commit range or tree delta as normal fork history.
5. Compare the expected and applied stable patch IDs.
6. Do not mix generated artifacts unless their owning generation pipeline is understood and included.

A rewritten upstream root is never merged as a second root. Its accepted content is applied on top of the fork lineage.

## 4. Record

The synchronization pull request must update:

- [`CHANGELOG.md`](../../CHANGELOG.md) when the dated upstream record classifies the change as user-visible;
- one immutable record under `docs/upstream/<source>/`;
- applicable license and notice files when upstream changed them.

The record includes:

- a machine-checkable provenance-table classification: `| User-visible change | yes |` or `| User-visible change | no |`;
- old and new immutable revisions;
- graph relationship and default-branch head at review time;
- preserved archive reference;
- exact imported, omitted, and rejected scope;
- behavior, security, compatibility, and documentation effects;
- expected and applied patch IDs;
- validation commands and outcomes;
- follow-up work that must remain outside the synchronization pull request.

Architecture evidence pins advance only after the synchronization merges and affected claims are re-audited in a separate documentation pull request.

## 5. Validate

Accepted pull-request checks:

1. formatting;
2. workspace production compilation on Linux and macOS;
3. zero-warning clippy for production targets;
4. public Cargo library-test compilation and runnable focused tests;
5. Markdown link validation;
6. upstream synchronization contract validation;
7. an empirical smoke test when the delta changes startup, authentication, sessions, tools, terminal behavior, persistence, or sandboxing.

A blocked test target is a release and synchronization concern. It must be repaired or explicitly accepted in the pull request with a separate tracked remediation; it is never reported as passing.

## 6. Review

The pull request receives an independent diff review focused on:

- correctness and regressions;
- security and credential boundaries;
- runtime, persistence, and compatibility changes;
- generated and licensed boundaries;
- divergence from the upstream delta;
- documentation and changelog accuracy.

The synchronization pull request is not merged while a high-confidence blocking finding remains unresolved.

## 7. Merge and follow up

After required checks and review pass:

1. merge through GitHub without bypassing branch protection;
2. record the final merge or integration commit in the upstream record;
3. open separate fork-owned pull requests for deliberate behavior changes or fixes discovered during review;
4. update architecture pins and citations after the reviewed source becomes the repository baseline;
5. run the affected empirical flow against the merged commit.

## Automation status

Currently available in-tree tooling:

- [`scripts/upstream/inspect.sh`](../../scripts/upstream/inspect.sh) produces reproducible local comparison reports;
- [`scripts/upstream/validate-pr.sh`](../../scripts/upstream/validate-pr.sh) enforces the branch, one-record, allowlist, required-heading, and user-visible-changelog contract when run against a proposed synchronization range.

The accepted policy calls for planned GitHub gates to run regular CI, apply the synchronization contract to `sync/*` branches or pull requests labeled `upstream-sync`, validate Markdown links, and provide audit and upstream-drift workflows. Those gates are not evidence of enforcement until their `.github` implementation lands.

Future automation may prepare draft synchronization pull requests, but it must not automatically merge, move protected archive refs, or replace fork history.
