# Extensibility architecture

Baseline: [`open-grok/open-grok@c1b5909`](https://github.com/open-grok/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

The published system has broad **content and tool extensibility**, but model-provider protocols remain compiled Rust behavior.

## Plugin bundle contract

A plugin may use conventional directories or an optional `plugin.json` manifest.

Supported components include:

- skills;
- commands;
- agent definitions;
- hooks;
- MCP servers;
- LSP servers.

The manifest supports both paths and inline definitions. [`manifest.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/manifest.rs#L132-L245)

Themes and model-protocol adapters are not plugin manifest components.

## Discovery scopes

Plugin discovery covers:

1. CLI/session-provided directories;
2. project `.grok` and `.claude` roots;
3. user Grok and Claude roots;
4. installed marketplaces;
5. configured `[plugins].paths`.

Canonical paths deduplicate repeated discoveries; scope precedence resolves name conflicts. [`discovery.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/discovery.rs#L267-L485)

## Trust boundary

A plugin must be both **enabled** and **trusted** before executable components run.

- Untrusted project plugins may still expose skill and agent metadata.
- Hooks, MCP, scripts, and other executable components remain blocked.
- Trusted canonical plugin roots are stored in `~/.grok/trusted-plugins`.
- Config-path plugins under the user home may be automatically trusted.

See [`trust.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/trust.rs#L1-L17) and [`trust.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/trust.rs#L60-L177).

## Marketplace

Marketplace configuration distributes plugin bundles; it does not introduce new runtime type systems.

Supported sources include:

- `[[marketplace.sources]]`;
- Claude-compatible `extraKnownMarketplaces`;
- project `.claude/settings.json` enabled-plugin declarations.

See [`hooks-and-plugins.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/hooks-and-plugins.md#L75-L129) and [`marketplace.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/marketplace.rs#L1-L93).

## Hooks

The shared hook engine exposes events across:

- session start/end and stop;
- prompt submission and turn completion;
- pre/post tool use and tool failure;
- permission requests;
- notifications;
- subagent lifecycle;
- compaction.

`PreToolUse` is the only blocking hook event. `SubagentEnd` aliases `SubagentStop`. [`event.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-hooks/src/event.rs#L6-L149)

Plugin hooks feed the common engine through an adapter that:

- filters a bounded plugin-supported event set;
- namespaces hook specs;
- injects protected `GROK_PLUGIN_*` values and compatibility aliases;
- resolves plugin-root/data substitutions.

See [`hooks_adapter.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/plugins/hooks_adapter.rs#L18-L195).

## Skills and commands

Skills are dynamic filesystem content.

- Plugin skills and `commands/*.md` parse through the skill loader.
- Plugin provenance is retained.
- Duplicates merge according to source precedence.
- User documentation defines CWD → repository → user priority plus vendor-compatible roots and configured directories.

See [`skills.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/prompt/skills.rs#L534-L616) and [`08-skills.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/08-skills.md#L15-L48).

Slash commands are:

1. compiled built-ins;
2. enabled, user-invocable skills.

Built-ins win collisions; plugin `commands/*.md` therefore become skill-backed commands rather than independent executable code. [`slash_commands.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/slash_commands.rs#L301-L358)

## Agent definitions

Markdown/YAML agent definitions load from:

- project `.grok/agents` and `.claude/agents` roots;
- user roots;
- enabled plugins.

Project definitions may shadow built-in subagents.

An agent definition can constrain:

- prompt;
- tools;
- model;
- MCP;
- hooks;
- subagents.

See [`discovery.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/discovery.rs#L1-L112) and [`config.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/config.rs#L713-L816).

## MCP precedence

The effective MCP set merges:

1. TOML-defined MCP servers;
2. active plugin MCP servers without replacing TOML names;
3. Claude JSON;
4. Cursor JSON;
5. project `.mcp.json`.

Plugin MCP requires an enabled and trusted plugin. [`managed_mcp.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/managed_mcp.rs#L240-L349)

## LSP precedence

- User configuration loads first.
- Project configuration overrides user names.
- Plugin definitions fill only unclaimed names.
- Untrusted plugin LSP definitions are excluded.

See [`lsp/config.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/implementations/lsp/config.rs#L12-L104).

## Themes

Themes are compiled and selected through `[ui]` configuration.

The user guide documents five built-ins plus `auto`; no dynamic theme loader exists in the plugin surfaces inspected. [`06-theming.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/06-theming.md#L1-L68)

## Model-provider boundary

Custom model configuration can provide:

- endpoint URL;
- key/environment resolver;
- auth scheme;
- headers;
- one of the compiled API backends.

It cannot register an arbitrary protocol implementation.

The protocol boundary is the closed `ApiBackend` enum plus Sampler request/stream translation. [`sampling-types/types.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L1010-L1029)

Therefore:

- a compatible custom endpoint is data/config extensibility;
- a genuinely new wire protocol is a compiled Rust change;
- current plugins cannot supply that protocol implementation.

## Existing tests and docs

Tests cover:

- convention-based discovery;
- scope and de-duplication precedence;
- trust and path-escape checks;
- inline manifest components;
- MCP ownership;
- untrusted LSP filtering.

User-facing documentation exists in:

- `07-mcp-servers.md`;
- `08-skills.md`;
- `09-plugins.md`;
- `10-hooks.md`;
- `hooks-and-plugins.md`.

## Invariants for later provider extensions

- Preserve the current trust distinction between metadata and executable components.
- Do not make marketplace installation equivalent to implicit execution permission.
- Keep built-in/config/plugin precedence explicit and testable.
- Reuse the existing content and lifecycle surfaces where they fit.
- Do not pretend the present plugin system already supports provider protocols.
- Delay a public provider-plugin ABI until the native provider boundaries have been exercised by built-ins and YAML-defined compatible providers.
