# Contributing to open-grok

`open-grok` is an independent community fork of [`xai-org/grok-build`](https://github.com/xai-org/grok-build). It is not affiliated with or supported by xAI.

## Current contribution phase

The project has completed its reviewed provider-platform goal and is implementing the public foundation and session experience in ordered checkpoints. Contributions are welcome when they improve the active phase:

- corrections backed by pinned source evidence
- architecture and data-flow documentation
- reproducible build or test fixes
- provider, authentication, catalog, and compatibility research
- narrowly scoped fixes that preserve upstream behavior

Large provider implementations, plugin systems, broad refactors, and product renaming must follow the relevant active phase in [`goals/open-grok-provider-platform/plan.md`](goals/open-grok-provider-platform/plan.md).

## Before opening a pull request

1. Read [`README.md`](README.md) and [`docs/architecture/`](docs/architecture/).
2. Keep each change narrow and traceable to an issue, accepted fact, or approved plan step.
3. Preserve upstream and third-party license notices.
4. Mark modified upstream files where Apache-2.0 requires it.
5. Run focused checks for the crates you changed before relying on repository CI.
6. State the exact verification performed and any checks you could not run.
7. Add or reference an ADR/PDR when the change establishes a durable architecture, product, release, or maintenance decision.
8. Update `CHANGELOG.md` when behavior is user-visible.

Typical commands:

```sh
cargo fmt --all --check
cargo check -p <crate>
cargo test -p <crate>
cargo clippy -p <crate> -- -D warnings
```

The root `Cargo.toml` is generated upstream. Do not edit it casually.

## Architecture evidence

Claims about current behavior must cite the exact source revision and strongest available source location. Public upstream permalinks are preferred; local file paths are navigation aids, not durable proof.

Pi references must use a pinned latest [`earendil-works/pi`](https://github.com/earendil-works/pi) revision. oh-my-pi references must use a pinned latest [`can1357/oh-my-pi`](https://github.com/can1357/oh-my-pi) revision. Private local research repositories are never authoritative upstream evidence.

## Security reports

Do not open public issues for vulnerabilities. Follow [`SECURITY.md`](SECURITY.md).
