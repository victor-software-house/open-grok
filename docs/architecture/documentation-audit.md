# Documentation audit

Baseline: [`open-grok/open-grok@c1b5909`](https://github.com/open-grok/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

## Existing documentation inventory

### Root and governance

- `README.md`
- `CONTRIBUTING.md`
- `AGENTS.md`
- `CODING_STANDARDS.md`
- `CHANGELOG.md`
- `SECURITY.md`
- `LICENSE`
- third-party notice files
- `docs/decisions/`
- `docs/upstream/`

The original upstream governance documents were intentionally narrow because the public tree rejected outside contributions. `open-grok` replaced those root policies in commit `7e857c8`.

### User guide

The Pager crate contains **24 numbered chapter files**. Its index and compiled in-app registry cover chapters **1–22**; chapters **23–24** exist on disk and are reachable only through direct paths or cross-links.

The chapter files cover:

- first run and authentication;
- keys, commands, configuration, and themes;
- MCP, skills, plugins, and hooks;
- custom models;
- sessions and memory;
- headless/ACP use;
- sandboxing and permissions;
- dashboard and monitoring.

See the pinned [`user-guide/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/README.md#L7-L52).

### Crate and source-adjacent docs

Useful anchors include:

- Pager Action/Effect architecture and directory map: [`xai-grok-pager/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/README.md#L1-L63)
- Agent definition/discovery model: [`xai-grok-agent/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/README.md#L1-L99)
- Shared test seams: [`xai-grok-test-support/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-test-support/README.md#L1-L37)
- Configuration merge rustdoc: [`xai-grok-config/src/lib.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-config/src/lib.rs#L1-L56)
- MCP module rustdoc: [`xai-grok-mcp/src/lib.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-mcp/src/lib.rs#L1-L38)
- Hook event examples: [`xai-grok-hooks/examples/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-hooks/examples/README.md#L1-L119)
- Vendored Mermaid boundary: [`third_party/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/third_party/README.md#L1-L59)

## What is already strong

- Configuration docs align with the source merge model and file locations. [`05-configuration.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/05-configuration.md#L8-L25)
- Pager has a useful local architecture map.
- Agent and test-support crates document their public conceptual surfaces.
- Hook examples describe concrete JSON contracts.
- User docs cover many operational features that the root README did not expose.

## Missing before this dossier

- **End-to-end architecture:** no document joined binary → Pager → ACP → Shell → Session → Sampler → Tools → Persistence.
- **Workspace dependency map:** the root table named a handful of crates but not the **75-crate** first-party topology.
- **Provider/auth boundary:** no page separated generic seams from xAI assumptions.
- **State model:** session files, canonical history, replay, compaction, rewind, tasks, and subagents were scattered through source.
- **Extensibility ownership:** plugins, trust, hooks, skills, agents, MCP, and LSP lacked one cross-cutting map.
- **Tool lifecycle ownership:** no document mapped provider projection, policy, execution, ACP/UI updates, and model-context reinsertion end to end.
- **Developer onboarding:** no single page explained subsystem ownership, focused validation, test seams, or generated boundaries.
- **Source-to-doc ownership:** no table stated which document owns which subsystem contract.
- **System diagrams:** no repository-owned architecture/data-flow diagram source.

## Verified discovery gap

The filesystem contains chapters **23** and **24**, while both the user-guide index and compiled in-app `USER_GUIDE` registry stop at chapter **22**.

- Index ending at chapter 22: [`user-guide/README.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/README.md#L38-L52)
- Compiled registry ending at chapter 22: [`pager/src/docs.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/docs.rs#L48-L159)
- Dashboard file: [`23-dashboard.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/23-dashboard.md#L1-L19)
- Monitoring file: [`24-monitoring-usage.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/24-monitoring-usage.md#L1-L40)

The configuration guide cross-links chapter 24, so it is partially discoverable from source while remaining absent from the main index and in-app registry. [`05-configuration.md`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/docs/user-guide/05-configuration.md#L547-L572)

## Pi baseline

Pi’s strongest documentation patterns are:

- a task-oriented documentation hub;
- focused provider/auth/session/extension pages;
- package maps next to implementation;
- user contract and implementation references kept together.

Evidence:

- [`packages/coding-agent/docs/index.md`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/docs/index.md#L39-L82)
- [`providers.md`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/docs/providers.md#L1-L23)
- [`extensions.md`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/docs/extensions.md#L3-L16)
- [`sessions.md`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/docs/sessions.md#L1-L20)

## OMP additions

Latest upstream OMP adds useful secondary patterns:

- a source-directory → authoritative-document map;
- explicit anti-duplication guidance;
- deep internals pages for extension loading, session persistence, and auth brokering.

Evidence:

- [`DEVELOPMENT.md`](https://github.com/can1357/oh-my-pi/blob/03c48d073bd4849726cc14750b5aecfa310bdf26/packages/coding-agent/DEVELOPMENT.md#L1-L10)
- [`extension-loading.md`](https://github.com/can1357/oh-my-pi/blob/03c48d073bd4849726cc14750b5aecfa310bdf26/docs/extension-loading.md#L1-L22)
- [`session.md`](https://github.com/can1357/oh-my-pi/blob/03c48d073bd4849726cc14750b5aecfa310bdf26/docs/session.md#L1-L31)
- [`auth-broker-gateway.md`](https://github.com/can1357/oh-my-pi/blob/03c48d073bd4849726cc14750b5aecfa310bdf26/docs/auth-broker-gateway.md#L1-L10)

## open-grok information architecture

```text
AGENTS.md
CODING_STANDARDS.md
CHANGELOG.md
docs/
  index.md
  decisions/
  upstream/
  architecture/
    README.md
    source-ledger.md
    current-state.md
    crate-map.md
    runtime.md
    providers-and-auth.md
    state-and-execution.md
    extensibility.md
    tools.md
    documentation-audit.md
    reference-patterns.md
```

Later user/developer pages should be added only when the fork changes behavior:

- quickstart;
- provider login and account management;
- model/catalog configuration;
- development and focused verification;
- contribution/release workflow.

## Ownership rule

| Contract | Authoritative document |
|---|---|
| Repository guidance and active phase | `AGENTS.md` |
| Coding and verification rules | `CODING_STANDARDS.md` |
| User-visible history | `CHANGELOG.md` |
| Decision records | `docs/decisions/` |
| Upstream imports and evidence-refresh records | `docs/upstream/` |
| Baseline architecture | `architecture/current-state.md` |
| Workspace topology | `architecture/crate-map.md` |
| Runtime and actor flow | `architecture/runtime.md` |
| Provider/auth baseline | `architecture/providers-and-auth.md` |
| Persistence/execution | `architecture/state-and-execution.md` |
| Plugin/extension baseline | `architecture/extensibility.md` |
| Tool lifecycle and policy | `architecture/tools.md` |
| Documentation coverage and gaps | `architecture/documentation-audit.md` |
| Reference extraction | `architecture/reference-patterns.md` |
| Evidence pins | `architecture/source-ledger.md` |

New pages should link these owners instead of duplicating their internals.
