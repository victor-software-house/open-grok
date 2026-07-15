# State and execution architecture

Baseline: [`xai-org/grok-build@c1b5909`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

## State root

`$GROK_HOME` is the application state root; otherwise the canonicalized default is `~/.grok`. The directory is created lazily once per process. [`paths.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-config/src/paths.rs#L28-L46)

Normal session directories use:

```text
$GROK_HOME/sessions/<url-encoded-cwd>/<session-id>/
```

A directory is resumable only when `summary.json` exists. [`jsonl/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/mod.rs#L16-L85)

## Session files

| File | Responsibility |
|---|---|
| **`summary.json`** | Metadata, title, timestamps, model/agent identity, git head, sandbox profile, remote-parent linkage; resumability sentinel |
| **`chat_history.jsonl`** | Canonical model conversation; current format version `1` |
| **`updates.jsonl`** | Chronological ACP/xAI UI updates for replay |
| **`plan.json`** | Todo/task-plan state |
| **`plan_mode.json`** | Plan-mode lifecycle snapshot |
| **`rewind_points.jsonl`** | Per-prompt filesystem snapshots |
| **`signals.json`** | Session signals |
| **`announcement_state.json`** | Announcement de-duplication |
| **`goal/state.json`** | Goal orchestration state |
| **`feedback.jsonl` / `btw_history.jsonl`** | Feedback and side-question history |
| **compaction artifacts** | Checkpoints, requests, recap requests, and segments |

Path definitions live in [`jsonl/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/mod.rs#L78-L112).

## Persistence actor

One actor serializes `PersistenceMsg` traffic for each session.

It owns:

- chat/update appends;
- history rewrites after compaction or rewind;
- summary and task-state updates;
- compaction/checkpoint artifacts;
- flush barriers before archive/copy;
- handoff into optional remote sync.

See the message contract in [`persistence.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/persistence.rs#L306-L391) and actor loop in [`persistence.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/persistence.rs#L1497-L1602).

### Durability behavior

- JSONL append repairs a torn trailing line by inserting a newline before the next record.
- Update replay skips unparsable records.
- Full JSONL replacement uses a temporary file and rename.

This bounds append corruption to one trailing record and preserves the prior complete replacement file until rename. [`jsonl/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/mod.rs#L203-L340)

## Conversation versus replay

`chat_history.jsonl` and `updates.jsonl` have different authority:

- **Chat history** reconstructs model context.
- **Updates** reconstruct the visible UI/session timeline.

Compaction replaces chat history but intentionally preserves updates, so prior visible interaction remains replayable. [`mutations.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-chat-state/src/actor/mutations.rs#L200-L205)

`xai-chat-state` sees only a narrow `ChatPersistence` interface: append, replace, and flush. [`persistence.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-chat-state/src/persistence.rs#L19-L27)

## Compaction and rewind

### Compaction

- Replaces canonical chat history.
- Preserves UI replay.
- Persists exact checkpoint and request/response artifacts through the sequential persistence actor.

### Rewind

Each prompt can record pre/post snapshots for accessed files.

- Relative paths are preferred for portability.
- Absolute paths remain accepted for legacy sessions.
- Add/truncate/merge operations serialize through the persistence actor.

See [`file_state.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-workspace/src/session/file_state.rs#L276-L297) and [`persistence.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/persistence.rs#L1716-L1738).

## Background terminal tasks

The per-session `BackgroundTaskRegistry` is in memory and capped at **10 concurrent tasks**.

Each task snapshot includes:

- command and working directory;
- process result;
- truncated in-memory output;
- full output-log path;
- waiter notification state.

Completed entries are reaped only when capacity is required. [`background_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/terminal/background_task.rs#L28-L267)

Live processes are not reconstructed after resume.

Shutdown persists metadata for still-running tasks in `background_tasks_manifest.json`; resume reads and removes the manifest, then injects a reminder to inspect retained logs. [`background_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/terminal/background_task.rs#L284-L366)

## Subagent state

Subagent coordination uses in-process Tokio channels and oneshot responses; there is no remote backend.

- `pending`, `active`, and `completed` coordinator maps are process memory.
- Foreground children block the parent turn.
- Background children deliberately outlive the parent turn.
- Child session storage lives under the parent:

```text
<parent-session>/subagents/<subagent-id>/
```

See [`backend.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/implementations/grok_build/task/backend.rs#L26-L49), [`coordinator_lifecycle.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/subagent/coordinator_lifecycle.rs#L28-L161), and [`jsonl/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/mod.rs#L50-L58).

## Workspace and VCS

`xai-grok-workspace` owns generic worktree operations; Shell owns session-aware resume and rehydration.

- Worktree creation has a process-local deduplication registry.
- Ignored-file copying runs in the background with parallelism **2**.
- Git status calls the native Git CLI inside a blocking task.
- Status output is capped at **1 MiB**.

See [`worktree/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-workspace/src/worktree/mod.rs#L1-L137) and [`git_status.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-workspace/src/file_system/git_status.rs#L19-L39).

## Sandbox

Startup applies a process-wide, irreversible kernel sandbox through `nono` when supported and enforced.

- macOS uses Seatbelt; Linux uses Landlock where available.
- The sandbox covers the process and children.
- The agent's own network remains available.
- Child network access may be restricted separately.
- Unsupported or failed enforcement logs and continues unsandboxed.

See [`xai-grok-sandbox/src/lib.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sandbox/src/lib.rs#L8-L18) and [`lib.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sandbox/src/lib.rs#L117-L212).

### Sandbox policy sources

Built-ins:

- `workspace`
- `devbox`
- `read-only`
- `strict`
- `off`

Custom definitions merge global `$GROK_HOME/sandbox.toml` with project `.grok/sandbox.toml`; projects may add profiles but cannot override same-named global profiles. [`profiles.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sandbox/src/profiles.rs#L60-L140)

## Permissions

Effective config precedence is:

1. TOML `[ui]` permission mode;
2. remote setting;
3. default `ask`.

Supported values are `always-approve`, `auto`, and `ask`; unknown values fail closed to `ask`. CLI selection is applied above this, while managed policy may disable bypass. [`permissions.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/util/config/permissions.rs#L8-L23) · [`permissions.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/util/config/permissions.rs#L73-L169)

## State invariants

- Local JSONL/JSON is primary truth.
- UI replay and model context are intentionally separate.
- All per-session durable mutation passes through one persistence actor.
- Background process continuity is represented by logs and metadata, not process resurrection.
- Child sessions persist beneath the parent but retain independent session actors.
- Project sandbox definitions cannot weaken same-named global profiles.
- Unknown permission modes fail closed.

## Test anchors

- Chat rewind/restore/compaction: [`xai-chat-state/src/actor/tests.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-chat-state/src/actor/tests.rs)
- JSONL recovery: [`session/storage/jsonl/tests.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/tests.rs)
- Background task lifecycle: [`background_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/terminal/background_task.rs#L386-L500)
- Sandbox integration: [`integration_test.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sandbox/tests/integration_test.rs)
- Denied paths: [`deny_paths_e2e.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sandbox/tests/deny_paths_e2e.rs)
