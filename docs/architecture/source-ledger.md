# Architecture source ledger

This ledger defines the evidence boundary for the initial `open-grok` architecture dossier.

## Pinned sources

| Source | Role | Pinned revision |
|---|---|---|
| [`xai-org/grok-build`](https://github.com/xai-org/grok-build) | **Reviewed published baseline and provenance** | [`c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/xai-org/grok-build/tree/c1b5909ec707c069f1d21a93917af044e71da0d7) |
| [`open-grok/open-grok`](https://github.com/open-grok/open-grok) | **Repository-local evidence mirror and preserved lineage** | [`c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/open-grok/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7) |
| [`earendil-works/pi`](https://github.com/earendil-works/pi) | **Primary architecture-pattern reference** | [`c6d8371521fc8357958bb21fd43552c15f46c7f4`](https://github.com/earendil-works/pi/tree/c6d8371521fc8357958bb21fd43552c15f46c7f4) |
| [`openai/codex`](https://github.com/openai/codex) | **Rust reference for Codex authentication** | [`2edad72de3e4fb12a7519027d5eb3cbda45eea6c`](https://github.com/openai/codex/tree/2edad72de3e4fb12a7519027d5eb3cbda45eea6c) |
| [`can1357/oh-my-pi`](https://github.com/can1357/oh-my-pi) | **Secondary operational-pattern reference** | [`03c48d073bd4849726cc14750b5aecfa310bdf26`](https://github.com/can1357/oh-my-pi/tree/03c48d073bd4849726cc14750b5aecfa310bdf26) |
| [`anomalyco/models.dev`](https://github.com/anomalyco/models.dev) | **External model-metadata reference** | [`d7fd1e1eb96339866dc822b901fad7f5896be7ba`](https://github.com/anomalyco/models.dev/tree/d7fd1e1eb96339866dc822b901fad7f5896be7ba) |

Research snapshot date: **2026-07-16**.

## Provenance status

Evidence pins are reviewed snapshots, not claims that a local checkout or mutable branch is current.

On **2026-07-15**, xAI replaced `grok-build` `main` with a second parentless root, [`b189869b7755d2b482969acf6c92da3ecfeffd36`](https://github.com/xai-org/grok-build/tree/b189869b7755d2b482969acf6c92da3ecfeffd36), **2 hours 36 minutes 37 seconds** after the reviewed root. The two snapshots contain the same **2,715 file paths** and differ in **27 files**. Because they have no common ancestor, the replacement is an integration candidate rather than a normal upstream synchronization.

The reviewed original is preserved at [`archive/xai-published-c1b5909`](https://github.com/open-grok/open-grok/tree/archive/xai-published-c1b5909), locked against force-push and deletion. The complete comparison and integration decision are recorded in [`docs/upstream/xai-grok-build/2026-07-15-b189869.md`](../upstream/xai-grok-build/2026-07-15-b189869.md). The dossier keeps `c1b5909…` as its baseline until the replacement's behavior-sensitive changes and affected citations pass a focused audit. `open-grok` history must not be reset, rebased away, or force-replaced to follow a rewritten upstream root.

At the same verification point:

- Pi `main` equals the recorded Pi pin.
- Upstream OMP `main` equals the advanced OMP pin after review of the one-commit OpenRouter cost-reconciliation and catalog-data delta; the behavior-sensitive finding is recorded in [`docs/upstream/oh-my-pi/2026-07-16-03c48d0.md`](../upstream/oh-my-pi/2026-07-16-03c48d0.md).
- models.dev `dev` equals the recorded models.dev pin.
- Codex `main` equals the recorded Codex pin after review of the one-commit cache-write token-accounting delta; it did not change the authentication behavior for which Codex is cited.

## Authority order

1. **Latest reviewed Grok Build snapshot** defines the documented baseline; an unreviewed replacement head does not silently supersede it.
2. **Tests and source-adjacent rustdoc** clarify contracts and failure behavior.
3. **Tracked Grok Build user/crate documentation** explains intended usage; contradictions are recorded rather than silently resolved.
4. **Pinned Pi source/docs** supply the first external design comparison.
5. **Pinned upstream OMP source/docs** pressure-test the comparison against broader provider and account behavior.
6. **models.dev and provider APIs** inform model metadata and live-discovery strategy.

## Evidence rules

- Public commit-pinned permalinks are the durable citation.
- Resolve the named upstream repository, default branch, exact pin, and current head directly before research; a local checkout never proves upstream identity or freshness.
- Repository-relative paths help local navigation but do not replace public evidence.
- Recommendations are marked as recommendations; sources prove premises, not conclusions.
- Runtime observations require a committed evidence artifact with the exact command, version, and result.
- Mutable `main` branches, live API payloads, and unpinned documentation are discovery inputs only.
- Private repositories may suggest questions but cannot establish current Pi or OMP behavior.

## Updating pins

A source-pin update must:

1. resolve the named upstream repository and default-branch head directly;
2. verify that the old and new revisions exist and record their comparison status;
3. stop automatic advancement when histories diverge or have no common ancestor;
4. preserve a rewritten or disappearing reviewed root on an origin archive branch;
5. identify behavior-sensitive documents affected by the change;
6. rerun the focused source audit for those documents;
7. decide which upstream changes belong in the fork instead of replacing history blindly;
8. update citations, contradictions, and provenance status;
9. commit the pin and documentation changes together.

The project goal may remain invariant while these evidence references evolve through explicit reviewed updates.
