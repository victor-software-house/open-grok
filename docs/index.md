# open-grok documentation

This is the repository-owned documentation hub for `open-grok`.

## Start here

| Need | Document |
|---|---|
| **Understand the published system** | [`architecture/current-state.md`](architecture/current-state.md) |
| **Navigate the Cargo workspace** | [`architecture/crate-map.md`](architecture/crate-map.md) |
| **Trace one prompt end to end** | [`architecture/runtime.md`](architecture/runtime.md) |
| **Understand models, providers, and authentication** | [`architecture/providers-and-auth.md`](architecture/providers-and-auth.md) |
| **Understand sessions, files, tasks, and sandboxing** | [`architecture/state-and-execution.md`](architecture/state-and-execution.md) |
| **Understand plugins, hooks, skills, and MCP** | [`architecture/extensibility.md`](architecture/extensibility.md) |
| **Review existing documentation coverage** | [`architecture/documentation-audit.md`](architecture/documentation-audit.md) |
| **Compare Pi and OMP reference patterns** | [`architecture/reference-patterns.md`](architecture/reference-patterns.md) |
| **Check evidence pins and authority** | [`architecture/source-ledger.md`](architecture/source-ledger.md) |
| **Follow goal discovery and future approved objective** | [`../goals/open-grok-provider-platform/`](../goals/open-grok-provider-platform/) |

## User guide

The upstream user guide remains the current operational reference while the fork preserves upstream behavior:

[`../crates/codegen/xai-grok-pager/docs/user-guide/`](../crates/codegen/xai-grok-pager/docs/user-guide/)

It covers first run, authentication, configuration, keyboard shortcuts, slash commands, custom models, MCP, skills, plugins, hooks, sessions, headless/ACP use, sandboxing, permissions, and monitoring.

## Documentation contract

- **Current-state documents** describe the pinned published source before `open-grok` changes it.
- **Design documents** must label proposals separately from verified behavior.
- **Behavior-sensitive claims** cite commit-pinned public source links.
- **Pi** is the primary pattern reference after current Grok behavior is understood.
- **Latest upstream oh-my-pi** is the secondary reference for broader operational patterns.
- **Private local forks and research repositories** are never upstream authority.

See [`architecture/source-ledger.md`](architecture/source-ledger.md) for exact pins.
