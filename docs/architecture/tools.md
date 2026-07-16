# Tool lifecycle architecture

Baseline: [`xai-org/grok-build@c1b5909`](https://github.com/open-grok/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

This document maps the reviewed current tool lifecycle from model-facing definitions through request projection, streamed calls, policy, execution, ACP/UI updates, and model-context reinsertion. It also separates local tools, MCP tools, provider-hosted tools, and subagents, then records the current provider-coupling gaps that open-grok must remove.

This is a **current-state architecture document**. The final section labels accepted open-grok direction separately from behavior present in the reviewed baseline.

## End-to-end shape

```text
Tool registry / MCP metadata / hosted-tool configuration
  │
  ├─ local function definitions ───────────────┐
  ├─ dynamic MCP search index                  │
  └─ Responses-native hosted tools             │
                                               ▼
Session turn construction
  │  plan-mode filtering · backend-search choice · structured-output tool
  ▼
ConversationRequest
  │  tools · tool_choice · hosted_tools
  ▼
Compiled provider adapter
  │  Chat Completions · Responses/xAI · Anthropic Messages
  ▼
Normalized SamplingEvent::ToolCallDelta
  │
  ▼
Session tool-call pipeline
  │  parse → validate → plan gate → hooks → permission → dispatch
  ▼
ToolBridge / workspace / MCP / subagent execution
  │
  ├─ ACP/UI ToolCallUpdate
  └─ ConversationItem::tool_result
       │
       └─ next sampling iteration
```

Pager sees ACP session updates. It does not parse provider tool-call wire formats or execute tools directly.

## Tool identity and taxonomy

The current canonical classification is `ToolKind`. It covers read/edit/write/delete/move, filesystem and code search, LSP, command execution, planning, web operations, task/subagent operations, skills, memory, media/deploy operations, dynamic search/use-tool operations, and lifecycle tools. It also defines display labels and which categories are read-only. [`tool_taxonomy.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/tool_taxonomy.rs#L31-L113)

Executed calls may carry a canonical `_meta["x.ai/tool"]` envelope containing the metadata version, wire name, kind, namespace, label, read-only status, and canonical input projection. Consumers merge updates by tool-call ID rather than treating every update as a new call. [`tool_taxonomy.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/tool_taxonomy.rs#L147-L234)

The model-facing local definition is not yet provider-neutral. It is an OpenAI-style function object with a name, optional description, and JSON `parameters`. [`definition.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/types/definition.rs#L1-L45)

## Stage 1 — assembly and enabled-tool selection

`Agent` owns a session-bound `ToolBridge`. It exposes all registered definitions and a built-ins-only definition set; backend-hosted tools are stored separately from local function definitions. [`agent.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/agent.rs#L14-L50) · [`agent.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/agent.rs#L172-L195)

Before a normal turn, the session:

1. waits for MCP initialization only when the selected strategy is blocking;
2. resolves the built-ins-only definition set;
3. filters cursor tools according to plan mode;
4. removes the local `web_search` function when backend-hosted search is enabled.

[`sampler_turn.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/sampler_turn.rs#L111-L151)

Turn construction converts definitions into `ToolSpec`, optionally appends a synthetic structured-output tool, builds the conversation request, and attaches hosted tools only when both agent configuration and the selected model's backend-search capability permit them. [`turn.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/turn.rs#L1732-L1895)

`ConversationRequest` keeps local `tools`, `tool_choice`, and `hosted_tools` separate. The Chat Completions request type serializes `tools` and `tool_choice` explicitly. [`types.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L63-L112) · [`types.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L167-L190)

## Stage 2 — compiled provider projection

Three provider dialects are compiled into the sampler:

- OpenAI Chat Completions;
- OpenAI Responses, including xAI behavior;
- Anthropic Messages.

They are selected by `ApiBackend`; plugins do not add a new wire protocol. See [`providers-and-auth.md`](providers-and-auth.md#current-provider-model) and [`extensibility.md`](extensibility.md#model-provider-boundary).

### Chat Completions

The stream transform accumulates positional tool-call deltas containing ID, function name, and arguments. It emits the shared `SamplingEvent::ToolCallDelta`; completed calls force the normalized stop reason to `ToolCalls`. [`chat_completions.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/chat_completions.rs#L70-L84) · [`chat_completions.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/chat_completions.rs#L197-L278)

### Responses / xAI

The Responses transform maps each output item to a tool index, then emits function argument deltas through the same normalized event. It also recognizes hosted MCP, code-interpreter, web-search, image-generation, and custom-tool response events. [`responses.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/responses.rs#L21-L78) · [`responses.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/responses.rs#L119-L131) · [`responses.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/responses.rs#L245-L278)

### Anthropic Messages

The Messages transform accumulates indexed content blocks. A `tool_use` block supplies ID and name; `InputJsonDelta` fragments append and emit argument deltas. [`messages.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/messages.rs#L37-L56) · [`messages.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/messages.rs#L161-L280)

The sampler request task owns transform selection, timeout, retry, cancellation, and the single final normalized `Completed` or `Failed` event. [`request_task.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/request_task.rs#L1-L36) · [`request_task.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/request_task.rs#L73-L177)

## Stage 3 — parse and canonicalize the call

The session emits a pending ACP tool-call update before parsing. It then:

1. parses streamed argument text;
2. attempts recovery for concatenated JSON objects;
3. validates the call through `ToolBridge`;
4. stamps the canonical taxonomy metadata.

[`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L741-L890)

The tool-call ID remains the correlation key across provider deltas, ACP updates, execution, and the final model-visible result.

## Stage 4 — plan, hooks, permission, and approval

The policy order is load-bearing:

```text
plan-mode gate
  → display/update construction
  → PreToolUse hooks
  → permission resolution
  → exit-plan approval when applicable
  → dispatch
```

A hook denial prevents permission resolution and execution. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L893-L1199)

Plan mode is enforced independently of the always-approve path. Edit operations are restricted to the plan file, apart from a compatibility-toolset Markdown carve-out; non-edit tools continue into ordinary permission handling. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L133-L180)

Exit-plan requests inspect the plan file and ask the client for approval. Unknown response outcomes fail closed. A disconnected client retains the gate for reconnect, while the no-client case permits execution. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L182-L255) · [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L1201-L1317)

Permission configuration merges native `.grok`, managed/enterprise, and `.claude` settings. `bypassPermissions` becomes a synthetic allow-all only when managed policy permits it; unknown default modes fail safe. [`resolution.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-workspace/src/permission/resolution.rs#L1-L94)

## Stage 5 — dispatch and execution

Approved calls execute concurrently. Mutating calls that target the same path serialize through a per-path mutex rather than globally serializing all tools. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L387-L495)

`ToolBridge` is finalized with session-local execution dependencies: terminal backend, async filesystem, working directory, session folder and environment, notification handle, skills, persisted tool-state path, optional memory backend, and web search/fetch configuration. [`registry/types.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/registry/types.rs#L204-L260)

The bridge parses before dispatch, routes calls into the finalized registry, and supports runtime MCP tool registration and unregistration. [`bridge.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/bridge.rs#L65-L99) · [`bridge.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/bridge.rs#L157-L211)

## Stage 6 — ACP/UI output and context reinsertion

Tool execution produces both clean structured output for ACP/UI and prompt-ready text for model context. [`bridge.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/bridge.rs#L26-L45)

Successful output triggers post-tool hooks and telemetry, then delegates result handling. Failure becomes a model-visible tool error and invokes the failure hook. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L492-L633)

Result handling emits ACP `ToolCallUpdate` records and pushes a correlated `ConversationItem::tool_result` into chat state for the next sampling iteration. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L2002-L2190)

## MCP and runtime dynamic discovery

MCP configuration merges sources in this order:

1. TOML configuration;
2. trusted active plugins;
3. Claude JSON;
4. Cursor JSON;
5. project `.mcp.json`.

Executable plugin MCP requires both enablement and trust. See [`extensibility.md`](extensibility.md#mcp-precedence) and [`extensibility.md`](extensibility.md#trust-boundary).

The baseline's dynamic tool path is the local `search_tool`, not demonstrated provider-native deferred loading. It performs BM25 search over a `ToolIndex` of MCP tools and returns descriptions and input schemas. [`search_tool/mod.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/implementations/search_tool/mod.rs#L1-L16) · [`search_tool/mod.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-tools/src/implementations/search_tool/mod.rs#L207-L325)

MCP metadata snapshots use all bridge definitions, filter qualified names containing `__`, record server/tool schemas, and mark initialization state. [`mcp_snapshot.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/mcp_snapshot.rs#L35-L69) · [`mcp_snapshot.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/mcp_snapshot.rs#L126-L159)

The normal request path uses built-ins-only definitions, while MCP snapshot/search uses all definitions. The reviewed evidence proves local discovery and dispatch, but does not prove that a searched MCP schema is re-advertised to every provider request. This must not be described as Anthropic-style deferred loading without a focused protocol audit.

## Local tools versus provider-hosted tools

### Local execution

Filesystem, code search, LSP, terminal, worktree, planning, skill, memory, task/subagent, and configured web/fetch tools execute through `ToolBridge` against session-local workspace services. They pass the same plan, hook, permission, dispatch, ACP, and context-reinsertion pipeline.

### Provider-hosted execution

Hosted search is not a local function call. `AgentBuilder` creates Responses-native `WebSearch` and `XSearch`; a normal turn removes the local `web_search` function when that hosted path is active. [`builder.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/builder.rs#L1173-L1195) · [`sampler_turn.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/sampler_turn.rs#L131-L145)

The Responses stream recognizes provider-side web search, code interpreter, MCP, image generation, and custom-tool events. The reviewed baseline does not establish a complete provider-hosted computer-use lifecycle. [`responses.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/responses.rs#L42-L77)

### Browser and computer boundary

The source proves local workspace/terminal/filesystem execution and Responses-native hosted event handling. It does not prove that browser or computer automation is one portable provider-neutral capability. Any future browser/computer integration must identify whether execution is:

- local through an open-grok tool and permission boundary;
- delegated to MCP or another trusted extension;
- provider-hosted and represented through an adapter-specific event stream.

Those modes must not be conflated.

## Subagents as tool-driven child sessions

Subagents are local child sessions rather than provider-hosted tools. Foreground children block the parent turn; background children may survive it; coordination maps and channels are process-local; child storage is nested under the parent session. See [`state-and-execution.md`](state-and-execution.md#subagent-state).

Task/spawn aliases are recognized during tool-call handling, and background intent is recorded in ACP metadata before dispatch. [`tool_calls.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_impl/tool_calls.rs#L755-L785)

## Focused test topology

| Contract | Current test anchor |
|---|---|
| Anthropic streamed tool deltas | [`messages_tests.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/stream/messages_tests.rs) |
| Multi-dialect mocked SSE | [`test_sampling_client.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/tests/test_sampling_client.rs#L218-L326) |
| Plan-mode edit restrictions | [`plan_mode_edit_gate_tests.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_tests/plan_mode_edit_gate_tests.rs) |
| Exit-plan approval and reconnect | [`plan_approval_resume_tests.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_tests/plan_approval_resume_tests.rs) · [`PTY test`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-pager-pty-harness/tests/plan_approval_resume.rs) |
| Parallel dispatch and same-path serialization | [`parallel_dispatch_tests.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/acp_session_tests/parallel_dispatch_tests.rs) |
| Built-in/hosted filtering | [`builder.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-agent/src/builder.rs#L2324-L2394) |

The test map is incomplete for provider-neutral tool projection because that abstraction does not exist in the reviewed baseline. Future adapter work must add request goldens, capability gating, deferred-loading fallback, provider-hosted event fixtures, and mid-session model-switch coverage.

## Current coupling and contradictions

### OpenAI-shaped local definition is treated as generic

The shared local tool definition uses OpenAI function fields. Anthropic and Responses transforms adapt around it rather than consuming a truly provider-neutral manifest.

### Hosted tools are Responses/xAI-specific

"Backend-hosted" currently means Responses-native tool variants selected by builder and turn logic. It is not a provider-neutral hosted-tool contract.

### Shared sampler paths still carry xAI behavior

Current request logic attaches `x-grok-*` identity headers broadly and contains Responses-only streaming and recovery behavior in shared sampler paths. See [`providers-and-auth.md`](providers-and-auth.md#generic-seams-versus-xai-coupling) and [`client.rs`](https://github.com/open-grok/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/client.rs#L36-L70).

### Compatible endpoints are not provider-neutral protocols

Custom endpoints may select one compiled dialect, but xAI tracking, patches, and tolerance behavior mean dialect compatibility is not equivalent to independent provider support.

### Dynamic MCP discovery is not proven provider deferred loading

`search_tool` and MCP snapshots establish local discovery. The baseline does not prove provider-native schema activation after search, so the distinction remains explicit.

## Accepted open-grok change boundary

The reviewed goal and facts require this owner document to evolve with each tools-relevant phase. The accepted direction is:

- canonical session state owns one ordered enabled-tool policy and a provider-neutral per-turn manifest;
- provider/model adapters own wire projection, schema dialect, strictness, cache markers, lazy-loading annotations, and provider-hosted variants;
- adapters without reviewed lazy loading receive the complete enabled tool set;
- xAI headers, patches, hosted tools, OAuth, and continuation state remain inside the xAI adapter;
- normalized capability metadata gates tools, deferred loading, reasoning, image input, structured output, limits, provider-native tools, and protocol quirks before request execution;
- unsupported features are disabled or explained explicitly rather than failing late;
- ordinary permissions are permissive/yolo by default but configurable, while hard plan-mode, hooks, sandbox, trust, and explicit safety boundaries continue to precede execution;
- provider-dependent web and media tools route independently from the chat model;
- local, MCP, and provider-hosted browser/computer execution remain distinct trust and execution modes;
- request projections are cached by complete revision/digest inputs and invalidated deterministically on mismatch or provider rejection.

Implementation detail and verification remain in [`goals/open-grok-provider-platform/plan.md`](../../goals/open-grok-provider-platform/plan.md); the invariant behavior is in [`goal.md`](../../goals/open-grok-provider-platform/goal.md).
