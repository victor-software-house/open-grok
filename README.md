<div align="center">

# open-grok

**The Grok Build TUI, opened to every provider.**

A community-owned fork of [`xai-org/grok-build`](https://github.com/xai-org/grok-build) focused on preserving its exceptional Rust terminal experience while making provider choice, authentication, model discovery, and account management first-class.

[Status](#status) · [Direction](#direction) · [Build from source](#build-from-source) · [Documentation](#documentation) · [Upstream](#upstream-and-provenance) · [Contributing](#contributing)

</div>

> [!IMPORTANT]
> `open-grok` is an independent community derivative. It is not affiliated with, endorsed by, or supported by xAI. Grok and xAI names remain the property of their respective owners and are used only to identify upstream provenance and compatibility.

## Status

`open-grok` is in its architecture and foundation phase.

The fork currently preserves the upstream Grok Build source and behavior. Upstream already includes a native Rust TUI, agent runtime, tools, ACP integration, xAI subscription authentication, and configurable OpenAI Chat Completions, OpenAI Responses, and Anthropic Messages endpoints.

Before changing those systems, we are documenting how the published code actually works. The source-pinned architecture dossier lives under [`docs/architecture/`](docs/architecture/). Goal discovery is underway under [`goals/open-grok-provider-platform/`](goals/open-grok-provider-platform/); no invariant objective or implementation plan is approved yet.

Do not treat the multi-provider roadmap as implemented yet.

## Direction

The project is being shaped around these invariants:

- Preserve the full-screen Rust TUI and the capabilities available through vanilla Grok Build.
- Keep Grok/xAI subscription OAuth as a first-party provider path.
- Support most Pi and oh-my-pi providers through a coherent `/login` experience, including API keys, OAuth, safe credential persistence, multiple accounts, refresh, and controlled rotation.
- Avoid maintaining a handwritten model list. External catalog data such as [`models.dev`](https://models.dev/) and authenticated provider discovery should supply model metadata and availability.
- Allow built-in and custom providers to inherit shared behavior and override only what differs.
- Support custom providers and models through YAML configuration early, before a broader provider-extension API.
- Design internal boundaries that can later support provider registration, hooks, and marketplace extensions without freezing a speculative plugin ABI now.
- Keep architecture claims tied to pinned source evidence. Latest Pi is the primary reference for modular provider abstractions; latest upstream oh-my-pi is a secondary reference for broader auth, account, catalog, and discovery behavior.

These are direction-setting constraints, not an approved implementation design. The current codebase analysis comes first.

## Build from source

Requirements:

- **Rust** — pinned by [`rust-toolchain.toml`](rust-toolchain.toml)
- **protoc** — resolved through [`bin/protoc`](bin/protoc) or `$PROTOC`
- macOS or Linux; Windows remains best-effort in the published upstream tree

```sh
cargo run -p xai-grok-pager-bin
cargo check -p xai-grok-pager-bin
```

The current artifact is still named `xai-grok-pager`; upstream releases install it as `grok`. Independent package, executable, data-directory, and visual branding are pre-release work for this fork.

## Documentation

### open-grok documentation

- [`docs/index.md`](docs/index.md) — complete documentation hub
- [`docs/architecture/`](docs/architecture/) — current-state architecture dossier, source ledger, and documentation audit
- [`goals/open-grok-provider-platform/`](goals/open-grok-provider-platform/) — goal discovery placeholder and future reviewed provenance package

### Upstream user documentation

The published upstream user guide remains available in:

[`crates/codegen/xai-grok-pager/docs/user-guide/`](crates/codegen/xai-grok-pager/docs/user-guide/)

It covers authentication, configuration, keyboard shortcuts, slash commands, themes, MCP, skills, plugins, hooks, headless mode, sandboxing, and sessions. [`docs/architecture/documentation-audit.md`](docs/architecture/documentation-audit.md) records where those documents match the source, where discovery is incomplete, and which developer documentation was missing.

## Repository layout

| Path | Responsibility |
|---|---|
| `crates/codegen/xai-grok-pager-bin` | Binary composition root |
| `crates/codegen/xai-grok-pager` | Full-screen TUI and rendering |
| `crates/codegen/xai-grok-shell` | Agent runtime, sessions, ACP, and headless entry points |
| `crates/codegen/xai-grok-sampler` | Provider protocol requests and normalized sampling events |
| `crates/codegen/xai-grok-tools` | Tool implementations |
| `crates/codegen/xai-grok-workspace` | Filesystem, VCS, execution, and checkpoints |
| `docs/architecture` | open-grok current-state architecture documentation |
| `goals/open-grok-provider-platform` | Goal discovery placeholder; future facts, plan, and invariant objective |
| `third_party` | Vendored source and its license notices |

The root [`Cargo.toml`](Cargo.toml) is generated upstream. Treat it as read-only unless the generation source and synchronization model are understood.

## Upstream and provenance

This repository is a public GitHub fork of [`xai-org/grok-build`](https://github.com/xai-org/grok-build). The `upstream` Git remote tracks that source; `origin` tracks [`victor-software-house/open-grok`](https://github.com/victor-software-house/open-grok).

Upstream periodically publishes from an internal monorepo. We will preserve an auditable upstream baseline, keep fork changes clearly separated, and retain all required Apache and third-party notices.

## Contributing

The project is opening its architecture before opening implementation broadly. Issues, source corrections, architecture evidence, and documentation improvements are welcome now. Provider implementation work should follow an approved repository goal and phased plan so the fork does not accumulate incompatible one-off integrations.

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Security

Report vulnerabilities privately through GitHub's private vulnerability reporting for this repository. See [`SECURITY.md`](SECURITY.md).

## License

First-party upstream code is licensed under the **Apache License, Version 2.0**. See [`LICENSE`](LICENSE).

Third-party and vendored code remains under its original licenses. Preserve:

- [`THIRD-PARTY-NOTICES`](THIRD-PARTY-NOTICES)
- [`crates/codegen/xai-grok-tools/THIRD_PARTY_NOTICES.md`](crates/codegen/xai-grok-tools/THIRD_PARTY_NOTICES.md)
- [`third_party/NOTICE`](third_party/NOTICE)

Fork modifications will be marked and documented as required by Apache-2.0.
