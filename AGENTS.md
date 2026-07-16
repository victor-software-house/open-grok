# AGENTS.md

Guidance for humans and coding agents working in `open-grok`.

## What this repository is

`open-grok` is an independent community fork of [`xai-org/grok-build`](https://github.com/xai-org/grok-build), owned by the open-grok organization.

The project preserves Grok Build's exceptional Rust TUI and agent runtime while opening provider choice, authentication, model discovery, and account management.

It is not affiliated with, endorsed by, or supported by xAI.

## Current phase

The source-pinned architecture dossier and provider-platform goal and plan are accepted. Foundation and session implementation proceeds through the active approved checkpoints. Code outside the active phase is forbidden.

## Sources of truth

| Question | Authority |
|---|---|
| Current Grok behavior | Pinned `xai-org/grok-build` source mirrored in this fork |
| Repository architecture | [`docs/architecture/`](docs/architecture/) |
| Evidence revisions | [`docs/architecture/source-ledger.md`](docs/architecture/source-ledger.md) |
| Accepted decisions | [`docs/decisions/`](docs/decisions/) |
| Upstream imports | [`docs/upstream/`](docs/upstream/) |
| User-visible history | [`CHANGELOG.md`](CHANGELOG.md) |
| Design patterns | Pi first, latest upstream OMP second |
| Long-running objective | [`goals/open-grok-provider-platform/goal.md`](goals/open-grok-provider-platform/goal.md), governed by the accepted facts, approved plan, invariant controller, and mutable execution state in that directory |
| Coding rules | [`CODING_STANDARDS.md`](CODING_STANDARDS.md) |

Private local forks and research repositories may suggest questions, but they are not authoritative evidence of upstream Pi or OMP behavior.

## Architecture orientation

```text
xai-grok-pager-bin
  → xai-grok-pager
    → ACP
      → xai-grok-shell / MvpAgent
        → one SessionActor thread per session
          ├─ SamplerActor
          ├─ tool bridge and permissions
          ├─ chat-state actor
          ├─ persistence actor
          └─ subagent coordinator
```

Start with:

- [`docs/architecture/current-state.md`](docs/architecture/current-state.md)
- [`docs/architecture/crate-map.md`](docs/architecture/crate-map.md)
- [`docs/architecture/runtime.md`](docs/architecture/runtime.md)
- [`docs/architecture/providers-and-auth.md`](docs/architecture/providers-and-auth.md)
- [`docs/architecture/state-and-execution.md`](docs/architecture/state-and-execution.md)
- [`docs/architecture/extensibility.md`](docs/architecture/extensibility.md)

## Critical invariants

- **Preserve the TUI boundary.** Pager consumes ACP/session updates; provider wire details stay below it.
- **Preserve actor affinity.** Session internals remain on their dedicated thread/`LocalSet`; external code uses handles and channels.
- **Preserve normalized sampling.** Provider streams become shared sampling events before reaching session/UI logic.
- **Permission precedes execution.** Plan-mode restrictions, hooks, and permission resolution run before tools.
- **Local state remains durable.** Session persistence serializes writes; model context and UI replay remain distinct.
- **Trust remains explicit.** Marketplace installation does not imply executable-plugin trust.
- **Grok remains first-party, not global.** xAI-specific headers, patches, OAuth, catalogs, and remote services must not leak into generic provider behavior.
- **Catalog data is not transport policy.** External model metadata cannot replace provider-specific auth, protocol, and compatibility logic.
- **Upstream rewrites are migrations.** Verify named upstream heads directly, preserve reviewed roots, and audit unrelated replacement histories before integrating them; never reset this fork to follow a rewritten root.

## Reference hierarchy

Extract patterns in this order:

1. current Grok Build constraints;
2. latest pinned Pi abstractions;
3. latest pinned upstream OMP operational behavior;
4. models.dev and provider-owned APIs for model metadata and live availability.

Do not copy TypeScript application structure blindly into Rust. Extract laws, contracts, and test cases.

## Generated and vendored boundaries

- The root `Cargo.toml` is generated upstream. Treat it as read-only unless the generation source and sync process are understood.
- Generated protobuf Rust belongs to the owning build pipeline.
- `third_party/` retains its own licenses and notices.
- Preserve `LICENSE`, `THIRD-PARTY-NOTICES`, crate-local notices, and `third_party/NOTICE`.
- Mark modified upstream files where Apache-2.0 requires it.

## Change discipline

- Make the smallest change that satisfies the active requirement.
- Every changed line must trace to the goal, accepted fact, issue, or approved phase.
- Do not refactor adjacent code without a demonstrated need.
- Follow existing Rust naming, module, error, and test patterns.
- Remove only orphans created by your own change.
- Keep provider-specific policy behind an explicit provider/adapter boundary.
- Do not add a sidecar, plugin ABI, catalog service, or abstraction merely because it may be useful later.

## Documentation contract

- Current-state claims use commit-pinned public links.
- Mirrored Grok source links should stay inside `open-grok/open-grok`.
- Pi/OMP/models.dev links point to their pinned upstream repositories.
- Label facts, inference, recommendations, proposals, and unresolved questions distinctly.
- Update the authoritative owner document instead of duplicating architecture prose.
- Update [`docs/architecture/source-ledger.md`](docs/architecture/source-ledger.md) when evidence pins move.

## Validation

Target the crates and behavior changed; full-workspace builds are expensive.

```sh
cargo fmt --all --check
cargo check -p <crate>
cargo test -p <crate>
cargo clippy -p <crate> -- -D warnings
```

For runtime changes, exercise the affected flow end to end in addition to static checks.

Completion requires:

- relevant tests pass;
- clippy has **zero warnings** for the changed scope;
- formatting passes;
- documentation links remain valid;
- the working tree contains no unexplained changes.

## Git and delivery

- `origin` is `open-grok/open-grok`.
- `upstream` is `xai-org/grok-build`.
- Keep fork changes auditable and separate from upstream sync commits.
- Every upstream import or evidence-pin advancement updates [`docs/upstream/`](docs/upstream/) and the root [`CHANGELOG.md`](CHANGELOG.md) when user-visible.
- Every code synchronization uses an isolated `sync/*` pull request, required CI, and independent review; never push imported code directly to `main`.
- Consequential technical and product/process choices receive ADRs or PDRs under [`docs/decisions/`](docs/decisions/); supersede accepted records instead of rewriting their rationale.
- Use Conventional Commits unless the repository later adopts a stricter convention.
- No AI attribution, generated-by footer, or bot co-author trailer.
- Commit and push coherent verified changes; do not leave completed work local-only.

## Security

Never commit credentials, OAuth tokens, private endpoints, captured secrets, or account identifiers.

Report vulnerabilities through GitHub private vulnerability reporting as described in [`SECURITY.md`](SECURITY.md).
