# Current-state architecture

This document describes Grok Build as published at [`c1b5909`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

It is a **baseline**, not the `open-grok` provider-platform design.

## System shape

```text
xai-grok-pager-bin
  │  CLI dispatch · Tokio runtime · process lifecycle
  ▼
xai-grok-pager
  │  full-screen TUI · Action/Effect state machine · terminal rendering
  ▼
ACP connection
  │  typed request/response channels · streamed session updates
  ▼
xai-grok-shell / MvpAgent
  │  session orchestration · configuration · tools · permissions · subagents
  ▼
SessionActor
  │  one OS thread + current-thread Tokio LocalSet per session
  ├───────────────┬───────────────────┬──────────────────┐
  ▼               ▼                   ▼                  ▼
SamplerActor   Tool bridge        Chat state        Persistence actor
  │               │                   │                  │
  ▼               ▼                   ▼                  ▼
HTTP/SSE       workspace/MCP      conversation       JSONL/JSON + optional
providers      terminal/files     mutation           xAI remote writeback
```

The primary binary is `xai-grok-pager-bin`; it composes Pager, Shell, Workspace, update, telemetry, and crash handling. [`Cargo.toml`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager-bin/Cargo.toml#L7-L31)

## Runtime ownership

| Boundary | Owner | Contract |
|---|---|---|
| **Process and mode dispatch** | `xai-grok-pager-bin` | Interactive TUI, headless prompt, ACP stdio/server, leader, and management commands |
| **Terminal state** | `xai-grok-pager` | `AppView` state plus `Action`/effect dispatch and a thin multiplexing event loop |
| **Agent gateway** | `MvpAgent` through ACP | Typed requests, responses, streamed updates, and reverse permission requests |
| **Session state** | One `SessionActor` thread | Prompt queue, sampler, tools, chat state, permissions, subagents, persistence |
| **Inference request** | `SamplerActor` child task | Backend request, retry/cancel, normalized `SamplingEvent`, completion oneshot |
| **Conversation** | `xai-chat-state` actor | Append/replace/flush through a narrow persistence interface |
| **Durable local state** | Session persistence actor | Serialized JSONL/JSON writes, flush barriers, compaction and rewind rewrites |

Interactive startup resolves configuration, authentication, session intent, and permissions before choosing direct in-process ACP or leader IPC; both present the same `AcpConnection` to Pager. [`app/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/app/mod.rs#L384-L575) · [`acp/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/acp/mod.rs#L148-L367)

## One prompt

1. **Pager sends a prompt over ACP.**
   <br>The TUI loop multiplexes terminal input, ACP updates, effect tasks, timers, hot configuration, and leader state. [`event_loop.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager/src/app/event_loop.rs#L1656-L1735)

2. **`MvpAgent` routes the prompt to a session handle.**
   <br>The handle sends `SessionCommand::Prompt`; callers do not mutate the non-`Send` actor directly. [`spawn.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/spawn.rs#L1573-L1632)

3. **The session actor promotes one foreground task.**
   <br>It builds the conversation request, tools, and the current sampler configuration.

4. **The sampler streams one compiled API dialect.**
   <br>OpenAI Chat Completions, OpenAI Responses, and Anthropic Messages normalize into a shared event stream. [`types.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L1010-L1055)

5. **The session drainer translates sampling events into ACP updates.**
   <br>Text, reasoning, tool-call deltas, retry state, completion, and failures reach Pager without exposing provider wire formats. [`tool_calls.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L2294-L2400)

6. **Tools pass policy before execution.**
   <br>Parsing, plan-mode restrictions, pre-tool hooks, and permission resolution precede concurrent execution; same-path writes serialize. [`tool_calls.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L741-L1199) · [`tool_calls.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L2002-L2231)

7. **Tool results re-enter conversation state.**
   <br>The model loop continues until a final response completes the ACP prompt request.

## Durable state

Local session storage is the primary source of truth under `$GROK_HOME/sessions/`; the default root is `~/.grok`. [`paths.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-config/src/paths.rs#L28-L46)

- `chat_history.jsonl` is the canonical model conversation.
- `updates.jsonl` is the chronological UI/ACP replay stream.
- `summary.json` is the resumability sentinel and session metadata record.
- task, plan-mode, rewind, signal, goal, announcement, feedback, and compaction artifacts are separate files.

The persistence actor serializes all writes and repair behavior. JSONL appends bound torn-write damage to one trailing record; full replacements use temporary files and rename. [`jsonl/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/jsonl/mod.rs#L203-L340)

## Extensibility today

- **Custom model endpoints** can select an arbitrary URL, credentials, headers, and one of the three compiled API dialects.
- **Plugins** add trusted MCP/LSP integrations and non-executable content such as skills and agent definitions.
- **Hooks** intercept lifecycle and tool events.
- **MCP** extends available tools, not model-provider protocols.
- **New wire protocols** require compiled sampler and sampling-type changes.

The provider boundary is therefore partly data-driven and partly closed over Rust protocol implementations. [`config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L3413-L3529) · [`types.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L1010-L1029)

## Critical invariants

- **Actor affinity:** session internals stay on their dedicated thread/`LocalSet`; external code uses channel handles.
- **One foreground prompt:** each session serializes its active foreground turn while preserving queued prompts.
- **Provider normalization:** Pager and tool orchestration consume normalized events, not provider wire objects.
- **Permission before execution:** plan-mode restrictions remain effective even when general permissions auto-approve.
- **Stream ordering:** normal turn completion waits for the stream drainer before post-response tool dispatch.
- **Local durability first:** local persistence is authoritative; xAI remote session sync is optional writeback.
- **Subagent isolation:** a child is a complete session actor and may detach to background rather than be killed with a parent turn.
- **Gateway liveness:** degraded notification relays must not stall sampling or the session loop.

## Current architectural tension

The source already contains reusable seams—protocol selection, sampler configuration, credential-provider traits, arbitrary model endpoints, storage adapters, and normalized events.

It also carries xAI assumptions through embedded catalogs, credential names, URL classification, tracking headers, Responses patches, browser chat modes, OAuth defaults, and remote session services.

That tension is the starting point for `open-grok`; it is not resolved in this baseline document. See [`providers-and-auth.md`](providers-and-auth.md).
