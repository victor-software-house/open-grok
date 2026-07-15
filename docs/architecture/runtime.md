# Runtime architecture

Baseline: [`xai-org/grok-build@c1b5909`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

## Runtime modes

`xai-grok-pager-bin` creates a multithread Tokio runtime, parses `PagerArgs`, dispatches the selected mode, and force-shuts the runtime down after a **two-second** grace period. [`main.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager-bin/src/main.rs#L1456-L1528)

Supported surfaces include:

- interactive full-screen TUI;
- single-turn/headless prompts;
- ACP `stdio` and headless agent modes;
- websocket server mode;
- shared leader mode;
- management subcommands.

The CLI also owns session/worktree choices, permission seeds, subagent settings, and background-wait behavior. [`cli.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/app/cli.rs#L383-L726)

## Execution ownership

| Unit | Execution model | Owns |
|---|---|---|
| **Pager process** | Multithread Tokio runtime | CLI, terminal lifecycle, application startup |
| **TUI state machine** | Main async loop plus effect tasks | `AppView`, input routing, rendering, ACP update handling |
| **Direct ACP agent** | Dedicated OS thread + current-thread Tokio `LocalSet` | Non-`Send` `MvpAgent` |
| **Session** | Dedicated OS thread + current-thread Tokio `LocalSet` | `SessionActor`, prompt queue, sampler, tools, chat state, persistence |
| **Inference request** | Child Tokio task owned by `SamplerActor` | HTTP stream, retry, cancellation, normalized events |
| **Tool set** | Concurrent futures inside session | Permissioned tool calls and results |
| **Subagent** | Independent child session thread | Child conversation, tools, persistence, optional worktree |

Direct ACP mode deliberately isolates `MvpAgent` on `acp-agent-worker`; callers communicate through the typed gateway. [`spawn.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/acp/spawn.rs#L33-L129)

## ACP boundary

- Outbound method requests use unbounded MPSC channels.
- Each request receives a oneshot response channel.
- Incoming methods dispatch into local tasks.
- Session notifications are fire-and-forget so a degraded relay cannot stall sampling or the session actor.

See [`xai-acp-lib/src/gateway.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-acp-lib/src/gateway.rs#L171-L230) and its notification path at [`gateway.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-acp-lib/src/gateway.rs#L447-L469).

## Turn sequence

```text
terminal input
  → AppView action/effect
  → ACP PromptRequest
  → MvpAgent resolves SessionHandle
  → SessionCommand::Prompt
  → SessionActor promotes one foreground task
  → build conversation + tools + sampler config
  → SamplerActor submits request
  → protocol stream becomes SamplingEvent
  → session drainer emits ACP updates
  → tool calls pass hooks + permissions
  → approved tools run concurrently
  → tool results append to conversation
  → next sampling iteration or final PromptResponse
```

The TUI loop remains thin: it multiplexes terminal input, ACP messages, spawned task results, timers, progress, hot configuration, and leader state. It batches up to **32 ACP messages** and avoids draining ACP while terminal input is buffered. [`event_loop.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/app/event_loop.rs#L1656-L1735)

## Session isolation

A `SessionActor` owns:

- the active foreground task and prompt queue;
- sampler handle and event drainer;
- tool bridge and permission manager;
- chat-state actor handle;
- persistence handle;
- subagent coordination;
- session-scoped MCP and execution state.

The external `SessionHandle` is cloneable; the actor remains thread-affine and non-`Send`. [`spawn.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/spawn.rs#L1573-L1664)

## Sampling lifecycle

`SamplerActor` serializes commands but spawns one task per request.

- Duplicate request IDs cancel and replace the prior task.
- Dropping all handles cancels and drains active requests.
- Each request owns an event stream and completion oneshot.
- The turn waits up to **five seconds** for the event-drainer barrier before processing post-response tool calls.

See [`actor/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/mod.rs#L60-L143) and [`sampler_turn.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/sampler_turn.rs#L848-L913).

### Retry and recovery

The request task can:

- back off transient failures;
- resample empty responses under a separate budget;
- resample provider doom-loop events under another budget;
- strip images after probable body rejection;
- rebuild the client for HTTP/1.1 after connection failures;
- terminate with a normalized `Failed` event.

Cancellation is checked before and during each attempt. [`request_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/request_task.rs#L73-L408)

## Tool execution

Tool calls move through a fixed gate:

1. emit pending ACP state;
2. parse and normalize input;
3. enforce plan-mode edit restrictions;
4. run blocking `PreToolUse` hooks;
5. resolve permission policy or user choice;
6. execute approved calls;
7. emit status/output and post-tool hooks;
8. append a model-visible tool result.

Plan-mode restrictions apply before the general permission path, including in otherwise auto-approved modes. [`tool_calls.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L741-L1199)

Approved calls use `FuturesUnordered`; writes to the same target path serialize through a per-path Tokio mutex. Interruptible wait tools race pending user interjection. [`tool_calls.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L387-L739)

## Cancellation

ACP cancellation becomes `SessionCommand::Cancel`.

- The active prompt task and foreground processes are aborted.
- Later queued user prompts remain queued in the normal interactive path.
- Subagent cancellation is policy-controlled.
- Background terminal tasks are not automatically killed by this path.
- The cancelled ACP prompt is resolved so the caller cannot hang.

See [`tasks_cancel.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tasks_cancel.rs#L222-L400).

## Subagents

A subagent is a **complete child session**, not a lightweight future.

- It receives a distinct session ID.
- It may receive an isolated worktree.
- It inherits selected parent facilities such as permissions, terminal backend, scheduler, MCP pool, and trace context.
- Foreground children hold a parent wait guard.
- Expired or orphaned foreground waits detach the child to background rather than killing it.

See [`handle_request.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/subagent/handle_request.rs#L1049-L1385).

## Shutdown

Pager exits on connection cancellation, terminal-reader closure, or quit/signal handling.

After the loop:

- logs flush;
- terminal state restores;
- ACP cancels;
- process-scoped children are killed.

Session shutdown separately flushes replay state, runs `SessionEnd`/`Stop` hooks, persists memory/background-task state, cancels feedback sync, and ends the actor loop. [`run_loop.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/run_loop.rs#L772-L817)

## Invariants for future work

- Provider changes must preserve normalized event delivery into ACP.
- Authentication refresh must not break session-thread affinity.
- Retry/cancel behavior belongs below Pager.
- Provider-specific tool streaming must still respect stream-drainer ordering.
- New account rotation must not create concurrent refresh races across sessions/processes.
- A provider failure must resolve the active prompt; it must not leave ACP callers waiting indefinitely.

## Test anchors

- CLI modes: [`cli.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/app/cli.rs#L880-L1180)
- ACP ordering/replay: [`gateway.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-acp-lib/src/gateway.rs#L563-L694)
- Sampler error conversion: [`request_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/request_task.rs#L747-L861)
- Cancellation slots: [`tasks_cancel.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tasks_cancel.rs#L618-L689)
