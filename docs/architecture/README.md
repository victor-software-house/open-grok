# open-grok architecture dossier

This directory documents the published Grok Build architecture before `open-grok` changes it.

## Evidence policy

- Current Grok Build claims are pinned to upstream commit [`c1b5909ec707c069f1d21a93917af044e71da0d7`](https://github.com/xai-org/grok-build/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).
- Pi reference claims use a pinned latest [`earendil-works/pi`](https://github.com/earendil-works/pi) revision.
- oh-my-pi reference claims use a pinned latest [`can1357/oh-my-pi`](https://github.com/can1357/oh-my-pi) revision.
- Local forks and private research repositories may suggest questions, but they are not authoritative evidence of upstream behavior.
- Recommendations and proposed architecture are labeled separately from verified current-state facts.

## Dossier structure

| Document | Purpose | Status |
|---|---|---|
| `current-state.md` | End-to-end architecture and system boundaries | Researching |
| `crate-map.md` | Cargo workspace topology and responsibility map | Researching |
| `runtime.md` | Startup, TUI, ACP, sessions, actors, tools, and shutdown | Researching |
| `providers-and-auth.md` | Models, protocols, credentials, xAI coupling, and custom endpoints | Researching |
| `state-and-execution.md` | Persistence, compaction, tasks, workspace, sandbox, and subprocesses | Researching |
| `extensibility.md` | Plugins, marketplaces, hooks, skills, agents, MCP, LSP, and commands | Researching |
| `documentation-audit.md` | Existing documentation coverage, freshness, and gaps | Researching |
| `source-ledger.md` | Pinned repositories, commits, and evidence conventions | Researching |

The dossier is the prerequisite for provider-platform design. It must describe what exists, not retrofit the desired solution onto the source.
