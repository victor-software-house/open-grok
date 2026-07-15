# Architecture source ledger

This ledger defines the evidence boundary for the initial `open-grok` architecture dossier.

## Pinned sources

| Source | Role | Pinned revision |
|---|---|---|
| [`xai-org/grok-build`](https://github.com/xai-org/grok-build) | **Current system authority and provenance** | [`c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/xai-org/grok-build/tree/c1b5909ec707c069f1d21a93917af044e71da0d7) |
| [`victor-software-house/open-grok`](https://github.com/victor-software-house/open-grok) | **Repository-local evidence mirror** | [`c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7) |
| [`earendil-works/pi`](https://github.com/earendil-works/pi) | **Primary architecture-pattern reference** | [`c6d8371521fc8357958bb21fd43552c15f46c7f4`](https://github.com/earendil-works/pi/tree/c6d8371521fc8357958bb21fd43552c15f46c7f4) |
| [`can1357/oh-my-pi`](https://github.com/can1357/oh-my-pi) | **Secondary operational-pattern reference** | [`d5cd24f39a951bfbd50dc8f50bcf095d59694d6c`](https://github.com/can1357/oh-my-pi/tree/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c) |
| [`anomalyco/models.dev`](https://github.com/anomalyco/models.dev) | **External model-metadata reference** | [`d7fd1e1eb96339866dc822b901fad7f5896be7ba`](https://github.com/anomalyco/models.dev/tree/d7fd1e1eb96339866dc822b901fad7f5896be7ba) |

Research snapshot date: **2026-07-15**.

## Authority order

1. **Pinned Grok Build source** defines what exists.
2. **Tests and source-adjacent rustdoc** clarify contracts and failure behavior.
3. **Tracked Grok Build user/crate documentation** explains intended usage; contradictions are recorded rather than silently resolved.
4. **Pinned Pi source/docs** supply the first external design comparison.
5. **Pinned upstream OMP source/docs** pressure-test the comparison against broader provider and account behavior.
6. **models.dev and provider APIs** inform model metadata and live-discovery strategy.

## Evidence rules

- Public commit-pinned permalinks are the durable citation.
- Repository-relative paths help local navigation but do not replace public evidence.
- Recommendations are marked as recommendations; sources prove premises, not conclusions.
- Runtime observations require a committed evidence artifact with the exact command, version, and result.
- Mutable `main` branches, live API payloads, and unpinned documentation are discovery inputs only.
- Private repositories may suggest questions but cannot establish current Pi or OMP behavior.

## Updating pins

A source-pin update must:

1. record the old and new revisions;
2. identify behavior-sensitive documents affected by the change;
3. rerun the focused source audit for those documents;
4. update citations and contradictions;
5. commit the pin and documentation changes together.

The project goal may remain invariant while these evidence references evolve through explicit reviewed updates.
