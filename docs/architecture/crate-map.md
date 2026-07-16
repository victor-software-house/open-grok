# Cargo workspace map

Baseline: [`xai-org/grok-build@c1b5909`](https://github.com/open-grok/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

## Scale and editing authority

- The workspace declares **79 members**.
- **75 crates** are first-party.
- **4 workspace members** live under `third_party/`.
- The root [`Cargo.toml`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/Cargo.toml#L1-L85) is explicitly generated.
- Per-crate manifests and source modules are the editing authority.

## Layer map

### Product surfaces and composition roots

| Crate | Responsibility |
|---|---|
| **`xai-grok-pager-bin`** | Primary `xai-grok-pager` binary; composes Pager, Shell, Workspace, update, telemetry, and crash handling |
| **`xai-grok-pager`** | Full-screen TUI, interaction state, ACP handling, terminal event loop |
| **`xai-grok-pager-minimal`** | Reduced Pager surface |
| **`xai-grok-shell`** | Agent/session orchestration and headless/ACP application modes |
| **`xai-grok-workspace`** | Filesystem, VCS, execution, worktrees, checkpoints, host workspace service |
| **`ptyctl-cli` / `xai-grok-pager-pty-harness`** | Terminal and PTY diagnostics/testing |

The main binary composition is visible in [`xai-grok-pager-bin/Cargo.toml`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager-bin/Cargo.toml#L7-L31).

### Agent, conversation, and product domain

- `xai-acp-lib` · typed ACP gateway and normalization
- `xai-agent-lifecycle` · lifecycle contracts
- `xai-chat-state` · actor-owned conversation mutation and persistence boundary
- `xai-grok-agent` · agents, plugins, skills, prompts, and discovery
- `xai-grok-auth` · credential-provider abstraction and HTTP retry middleware
- `xai-grok-config` / `xai-grok-config-types` · merged configuration and paths
- `xai-grok-models` · embedded model data
- `xai-grok-sampler` / `xai-grok-sampling-types` · inference protocols and normalized events
- `xai-grok-memory` · session memory behavior
- `xai-grok-subagent-resolution` · subagent resolution contracts
- `xai-prompt-queue` · prompt sequencing
- `xai-grok-version`, `xai-grok-update`, `xai-grok-announcements`, `xai-grok-shared`, `xai-grok-secrets`

### Tools, protocols, and extensions

- `xai-grok-tools` · concrete tool implementations
- `xai-grok-tools-api` · generated protobuf API
- `xai-grok-tools-api` consumers rely on Rust generated into `OUT_DIR`; [`build.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools-api/build.rs#L1-L34) delegates to [`xai-proto-build`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/build/xai-proto-build/src/lib.rs#L176-L214).
- `xai-tool-types`, `xai-tool-protocol`, `xai-tool-runtime` · shared tool contracts
- `xai-grok-hooks`, `xai-hooks-plugins-types` · lifecycle hooks and plugin hook types
- `xai-grok-mcp` · MCP integration
- `xai-grok-plugin-marketplace` · marketplace management
- `xai-computer-hub-core`, `xai-computer-hub-sdk`, `xai-computer-hub-mcp-adapter` · Computer Hub core, SDK, and MCP adapter
- `xai-interjection-core` · user-interjection support
- `prod-mc-cli-chat-proxy-types` · proxy product types

### Host-local infrastructure

- filesystem/VCS: `xai-file-utils`, `xai-gix-status`, `xai-fast-worktree`, `xai-hunk-tracker`
- execution/session: `xai-grok-shell-base`, `xai-grok-shell-session-support`, `xai-grok-workspace-client`, `xai-grok-workspace-types`
- environment/network: `xai-grok-env`, `xai-grok-http`, `xai-grok-paths`, `xai-fsnotify`
- policy/reliability: `xai-grok-sandbox`, `xai-circuit-breaker`, `xai-sqlite-journal`
- observability/system: `xai-grok-telemetry`, `xai-mixpanel`, `xai-system-power`, `xai-crash-handler`
- utility: `xai-token-estimation`, `xai-tty-utils`, `xai-codebase-graph`

### TUI and rendering

- `xai-grok-pager-render` · rendering helpers
- `xai-grok-markdown` / `xai-grok-markdown-core` · Markdown pipeline
- `xai-grok-mermaid` · Mermaid rendering integration
- `xai-ratatui-inline`, `xai-ratatui-textarea` · terminal UI foundations
- `xai-grok-voice` · voice integration
- `ptyctl` · PTY control

### Build, observability, and test support

- `xai-proto-build` · protobuf build helper
- `xai-grok-compaction` · compaction logic
- `xai-tracing`, `xai-tracing-macros` · tracing infrastructure
- `xai-test-utils`, `xai-grok-test-support` · shared test seams and harnesses

## Dependency direction

```text
runnable binaries
  → Pager / Shell / Workspace
    → agent orchestration / tools / extensions / host infrastructure
      → protocol types / configuration / shared utilities
```

### High fan-out hubs

| Crate | Direct first-party dependencies | Meaning |
|---|---:|---|
| **`xai-grok-shell`** | **45** | Primary application-orchestration concentration |
| **`xai-grok-workspace`** | **29** | Host workspace and execution concentration |
| **`xai-grok-pager`** | **25** | TUI/product integration concentration |
| **`xai-grok-tools`** | **15** | Tool implementation hub |
| **`xai-grok-pager-bin`** | **12** | Product composition root |

The Shell dependency surface is visible in [`xai-grok-shell/Cargo.toml`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/Cargo.toml#L13-L173).

### High fan-in contracts

- `xai-grok-version` — **15** first-party consumers
- `xai-grok-config` — **14**
- `xai-grok-tools` and `xai-tty-utils` — **13** each
- `xai-tool-types` — **11**
- `xai-tool-protocol` — **10**
- `xai-grok-telemetry` and `xai-tool-runtime` — **8** each

These crates deserve compatibility-focused review because a small contract change propagates broadly.

## Generated and vendored boundaries

- Root workspace membership and dependency versions are generated.
- Protobuf Rust is generated for `xai-grok-tools-api`.
- `third_party/{dagre_rust,graphlib_rust,mermaid-to-svg,ordered_hashmap}` remain separate license and ownership domains. [`Cargo.toml`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/Cargo.toml#L80-L84)

## Practical navigation

| Change | Start here |
|---|---|
| TUI interaction/rendering | `xai-grok-pager`, then `xai-grok-pager-render` |
| Prompt/session lifecycle | `xai-grok-shell/src/session/` |
| Provider request/stream behavior | `xai-grok-sampler`, `xai-grok-sampling-types` |
| Model selection/config | `xai-grok-shell/src/agent/models.rs` and `config.rs` |
| Auth | `xai-grok-auth`, `xai-grok-shell/src/auth/` |
| Tools | `xai-grok-tools` plus `xai-tool-*` contracts |
| Files/worktrees/sandbox | `xai-grok-workspace`, `xai-grok-sandbox` |
| Plugins/skills/agents | `xai-grok-agent` |

## Architectural consequence

Provider-platform work should not begin in Pager.

The highest-leverage seams are the Shell model/auth orchestration and the Sampler protocol contracts; Pager already consumes normalized ACP/session updates and should remain insulated from provider wire details.
