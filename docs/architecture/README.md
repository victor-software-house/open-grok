# open-grok architecture dossier

This directory documents the published Grok Build architecture before `open-grok` changes it.

## Evidence policy

- Current behavior authority is [`xai-org/grok-build@c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/xai-org/grok-build/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).
- Repository-local Grok evidence links use the identical mirror commit [`open-grok@c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).
- Pi reference claims use [`earendil-works/pi@c6d8371521fc8357958bb21fd43552c15f46c7f4`](https://github.com/earendil-works/pi/tree/c6d8371521fc8357958bb21fd43552c15f46c7f4).
- OMP reference claims use [`can1357/oh-my-pi@d5cd24f39a951bfbd50dc8f50bcf095d59694d6c`](https://github.com/can1357/oh-my-pi/tree/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c).
- models.dev claims use [`anomalyco/models.dev@d7fd1e1eb96339866dc822b901fad7f5896be7ba`](https://github.com/anomalyco/models.dev/tree/d7fd1e1eb96339866dc822b901fad7f5896be7ba).
- Local forks and private research repositories may suggest questions, but they are not authoritative evidence of upstream behavior.
- [`source-ledger.md`](source-ledger.md) owns pin updates and evidence policy.
- Recommendations and proposed architecture are labeled separately from verified current-state facts.

## Dossier structure

| Document | Purpose | Status |
|---|---|---|
| [`current-state.md`](current-state.md) | End-to-end architecture and system boundaries | Draft complete |
| [`crate-map.md`](crate-map.md) | Cargo workspace topology and responsibility map | Draft complete |
| [`runtime.md`](runtime.md) | Startup, TUI, ACP, sessions, actors, tools, and shutdown | Draft complete |
| [`providers-and-auth.md`](providers-and-auth.md) | Models, protocols, credentials, xAI coupling, and custom endpoints | Draft complete |
| [`state-and-execution.md`](state-and-execution.md) | Persistence, compaction, tasks, workspace, sandbox, and subprocesses | Draft complete |
| [`extensibility.md`](extensibility.md) | Plugins, marketplaces, hooks, skills, agents, MCP, LSP, and commands | Draft complete |
| [`documentation-audit.md`](documentation-audit.md) | Existing documentation coverage, freshness, and gaps | Draft complete |
| [`reference-patterns.md`](reference-patterns.md) | Pi-primary and OMP-secondary design laws | Draft complete |
| [`source-ledger.md`](source-ledger.md) | Pinned repositories, commits, and evidence conventions | Draft complete |

The dossier is the prerequisite for provider-platform design. It must describe what exists, not retrofit the desired solution onto the source.
