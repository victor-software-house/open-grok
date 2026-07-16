# Evolve open-grok into an independent provider-open coding agent

## Objective

Evolve `open-grok` into an independently governed, provider-open native-Rust coding agent that preserves or improves the reviewed Grok Build product: its full-screen Pager TUI, ACP and headless surfaces, normalized streaming, actor-owned sessions, tools and permissions, sandbox boundaries, compaction, rewind, subagents, background work, and durable resume.

The finished product must make Grok/xAI subscription access first-class while providing coherent authentication, multi-account routing, catalogs, discovery, protocols, usage, provider-backed tools, model switching, session storage, local/remote attachment, recovery, CI, releases, and selective upstream maintenance across providers.

## Why this work matters

The published baseline has an exceptional interactive product and useful Rust seams, but provider behavior, authentication, model data, session persistence, and remote services remain coupled to xAI assumptions and per-process file-owned state. Traditional agent session listing, search, resume, branching, and corruption handling also degrade noticeably as session counts and histories grow.

open-grok must retain the quality of the existing product while replacing those couplings with explicit provider-neutral contracts, one globally visible session repository, instantaneous thin-client attachment, independently refreshed model data, isolated encrypted credentials, and public delivery systems that the project controls.

## Product instinct and red lines

Ordinary infrastructure is almost invisible. Startup, attachment, search, resume, branching, tool use, and recovery should feel like direct product behavior rather than database, daemon, transport, or operator administration.

After ownership and public-build foundation, implementation pressure goes first to the session experience. An implementation is unacceptable even when its tests pass if it introduces:

- **Perceptible friction** — slow startup, warm/cold attachment, resume, search, interaction, repeated setup, noisy prompts, or routine infrastructure leakage.
- **Destructive ambiguity** — overwritten sessions, silently selected branches, undisclosed context loss, in-place recovery, or certainty claims about pending work.
- **Architectural leakage** — provider shapes in Pager or canonical history, raw database concerns in ordinary clients, duplicated local/remote runtimes, or abstractions without measured need.
- **Operator babysitting** — access questions or routine decisions tools can resolve, repeated review UI, brittle manual steps, or failures without actionable recovery.

Like Pi, ordinary tool operation is permissive/yolo by default and configurable. This default reduces routine interruptions; it never bypasses hard plan-mode, sandbox, trust, or explicit safety boundaries.

## Authority and evidence policy

- Current reviewed Grok source defines the behavior baseline until a newer snapshot passes the repository's provenance process.
- Latest reviewed Pi is the primary external design-pattern reference, especially for immutable single-parent session trees and provider abstraction.
- Latest reviewed upstream OMP is the secondary operational reference for provider breadth, accounts, OAuth, usage, and catalog edge cases.
- OpenAI Codex and provider-owned sources are used where they are the strongest authority, including Rust authentication and app-server transport patterns.
- Source revisions, comparisons, and contradictions live in the repository source ledger and upstream evidence records. Mutable branch names and local checkouts never silently replace reviewed evidence.
- Recommendations, proposals, runtime observations, and verified facts remain distinguishable. Public records contain no credentials, private endpoints, personal data, or conversation/request history.
- The accepted facts in `facts.md` and approved phase order in `plan.md` are the implementation authority. Mutable execution status belongs only in `state.md`.

## Users and operating modes

The product serves individual developers, teams, automation, editors, and other agents through:

- the full-screen Pager TUI;
- headless prompt and management commands;
- ACP stdio and programmatic clients;
- thin local or remote attachments to `open-grokd`;
- optional operator-controlled remote repository placement;
- provider OAuth, API-key, ambient/cloud-identity, keyless, local, and gateway authentication paths.

All modes operate on the same provider, session, account, permission, and recovery contracts rather than maintaining parallel product implementations.

## Non-negotiable product invariants

### Preserve the product boundary

- Pager consumes ACP/session updates and never owns provider wire objects.
- Provider streams normalize into shared sampling events before reaching session or UI logic.
- Session internals preserve actor affinity; clients use handles, channels, and RPC.
- Permission, plan-mode, hooks, and sandbox policy run before tool execution.
- Current hooks, skills, agents, plugins, MCP, LSP, subagents, and trust boundaries remain functional through runtime migration.
- Grok/xAI remains first-class without making xAI behavior the global default.

### Keep provider behavior native and explicit

- Provider identity, auth methods, environment fallbacks, discovery, catalogs, protocol adapter, usage adapter, capabilities, compatibility, and provider-backed tools are compiled Rust definitions.
- Built-ins require no YAML. Reviewed YAML fields may configure compatible providers, models, headers, discovery, tool routing, and equivalence, but do not replace compiled protocol or security logic.
- The initial release covers subscription OAuth, core API-key providers, at least one cloud-identity path, and a compatible local or gateway endpoint. Local-engine support receives focused smoke coverage but never delays hosted-provider correctness, subscription OAuth, cloud identity, or the first release; the remaining provider long tail is tracked parity work, not a blocker.
- The model picker and request path use normalized capability metadata for tools, deferred loading, reasoning, image input, structured output, context/output limits, provider-native tools, and protocol quirks. Unsupported features are disabled or explained before execution rather than failing late or silently changing behavior.
- A public provider plugin ABI remains deferred until built-ins and compatible configuration prove the internal boundaries.

### Isolate and encrypt credentials

- All first-class state lives under `~/.open-grok`.
- Provider credentials use a dedicated SQLite store separate from sessions and shared configuration.
- Secret values are versioned XChaCha20-Poly1305 ciphertext with fresh nonces and authenticated row identity; plaintext secrets never appear in ordinary configuration, database columns, logs, or session payloads.
- Key rotation is resumable and uses per-row key versions, fresh nonces, old-key retention until verification, and no destructive overwrite after decryption or authentication failure.
- The installation key is random and held by the native OS secret vault. Headless Linux requires explicit external key delivery and fails closed without one.
- Multiple credentials per provider have durable IDs, explicit selection, deterministic session affinity, provider-aware quota blocking, healthy-sibling failover, and non-session rotation.
- OAuth refresh is single-flight in process and lease-coordinated across processes. Transient failure preserves credentials; definitive failure disables only the affected credential; refresh never silently falls back to a different auth source.
- Legacy credentials are ignored during startup and may be imported only through an explicit, selected, non-destructive, resumable, rollback-safe command.
- Provider credentials never synchronize through session storage or a remote repository backend.

### Make catalog freshness independent of application releases

- A separate public catalog repository publishes schema-validated, provenance-tagged immutable snapshots with signed manifests and content digests. Snapshot content is derived primarily from reviewed Pi data and supplemented only for Pi-missing OMP-exclusive or OAuth providers.
- Static public delivery is the starting point: immutable release assets plus a small signed mutable pointer. A dedicated catalog service is introduced only after static delivery proves insufficient.
- Resolution precedence is explicit user override, provider-authoritative live discovery, last verified open-grok snapshot, then embedded recovery seed.
- TUI and headless surfaces inspect and force refresh. Normal refresh is conditional, jittered, cached, bounded, offline-capable, and failure-tolerant.
- Activation verifies signer, schema, revision monotonicity, release identity, and content hash and retains the last verified snapshot on failure.

## Canonical provider-neutral request state

- Canonical history contains immutable session nodes, exact attachment cursors, normalized messages and tool results, reasoning, backend-tool interactions, attachments, compaction and rewind boundaries, and versioned effective model, sampling, prompt, and tool-policy inputs.
- The session owns one ordered enabled-tool policy and a provider-neutral per-turn manifest. Adapters project it into provider/model schemas, strictness rules, cache markers, lazy-loading annotations, and hosted-tool shapes; compatible adapters without reviewed lazy loading receive the full enabled tool set.
- xAI request details remain an xAI adapter projection, not shared canonical state.
- Static projection fragments are memoized by definition revision and projection flavor; context-varying descriptions use explicit context revisions.
- Provider continuation or projection state may persist only when it affects deterministic next-request semantics. It is bound to adapter, provider, model, credential affinity, parent node, expiry, and complete canonical-input digests.
- Any mismatch, expiry, or provider rejection invalidates the checkpoint and deterministically rebuilds from canonical history. Transport-only cache hints remain disposable.
- No-op reconstruction preserves a byte-stable serialized prefix so prompt caching and mid-session model switches remain deterministic.

## Session repository and tree model

### One repository, one tree law

- One internal `SessionRepository` owns canonical state and global queries for every session.
- Each session is an immutable single-parent, multi-child tree. Every node has stable identity and at most one parent; one parent may have many children. Multi-parent merge nodes are outside this goal.
- Atomic append batches contain ordered canonical items, parent identity, attachment identity, expected cursor version, idempotency key, digests, and accepted/durable sequence positions.
- Every TUI, CLI, ACP client, agent, or subagent owns an independent durable versioned cursor to an exact node and may append only a child chain from that node.
- Concurrent clients at one parent create sibling branches. Labels, bookmarks, defaults, and presence are mutable metadata, not canonical history.
- `sessionId:nodeId` is first-class across product and repository APIs.
- Bare-session resolution uses a valid caller/device cursor, an explicit default or bookmark, or the sole leaf. Multiple unresolved leaves require a branch picker or structured ambiguity error; the newest timestamp is never selected silently.
- Rewind moves a cursor to an ancestor and never deletes sibling history. Compaction appends a lossy summary/checkpoint with source digests and retains original nodes.

### One efficient daemon architecture

- Thin clients attach to one `open-grokd`, which may run on the same machine or any operator-chosen host.
- The daemon owns repository ordering, bounded memory-hot session actors and contexts, query projections, subscriptions, approvals, tools, and execution coordination instead of starting a full runtime per client.
- Active turns and explicitly backgrounded work continue after a client disconnect while the daemon remains healthy. After restart, the daemon recovers durable state, reports any lost pending tail or non-recoverable external execution honestly, and routes provider-context failure to the two fresh-session recovery choices.
- Independent sessions and tools remain parallel; serialization is limited to the ordering boundaries that require it.
- One transport-neutral, persistent, multiplexed RPC carries requests, streaming events, subscriptions, approvals, overload signals, reconnect cursors, daemon identity, protocol version, and capabilities.
- Local attachment uses Unix-domain sockets or Windows named pipes.
- Framed stdio supports embedding, diagnostics, tests, and SSH execution.
- Secure zero-exposure remote attachment uses an SSH-spawned proxy with connection reuse.
- Persistent remote deployments may expose explicitly configured authenticated encrypted WebSocket/TCP.
- QUIC is a later measured option; raw UDP is not an ordered session-control protocol.
- `open-grokd` may use local SQLite or a reviewed remote database adapter behind `SessionRepository`. Ordinary interactive clients attach through RPC so actors, subscriptions, approvals, ordering, and recovery do not leak into raw SQL clients.
- A second remote session-service architecture is rejected.

### Memory-first progress and bounded durability

- Human-visible interaction does not wait for stable storage.
- The daemon accepts each append into one ordered in-memory queue, assigns its IDs and cursor result, renders it, and may begin inference or tools immediately.
- A dedicated background writer coalesces compatible operations and advances the durable sequence watermark without reordering batches.
- Graceful shutdown drains accepted work. Restart recovers every durable watermark and reports any missing not-yet-durable tail precisely; the system never labels that tail durable.
- SQLite WAL is the initial backend because the workload requires relational integrity, tree traversal, metadata, search, and one sequenced writer with concurrent readers. It remains hidden behind `SessionRepository` and may be replaced only when a maintained alternative wins representative end-to-end gates without recreating a larger custom query and integrity layer.

### Performance is a product contract

Before numeric gates bind, the reference Apple Silicon machine class, dataset generator, session/node distributions, hot/cold cache state, search corpus, daemon configuration, and benchmark procedure are frozen and versioned.

The initial local targets are:

- warm session attachment p95 at or below 10 ms;
- cold attachment of a 1,000-node session p95 at or below 100 ms;
- warm search across 10,000 sessions and 5 million nodes p95 at or below 100 ms;
- visible append at or below 5 ms;
- accepted-to-durable append p95 at or below 20 ms;
- idle daemon RSS target at or below 50 MiB.

Inventory, search, resume, branch traversal, and concurrent attachment must remain imperceptibly fast as repositories grow. Current JSONL data is a migration and benchmark oracle only, never normal authority.

## Session visibility, diagnosis, and recovery

The same repository contract powers TUI, ACP, and headless list, search, filter, sort, tree/child inspection, rename, archive, delete, import, export, sync, diagnose, recover, status, and health operations.

Presence leases and status distinguish active, idle, needs-input, background, dormant, stale, orphaned, failed, completed, pending-persistence, conflict, degraded, and unavailable without treating persisted metadata as proof of live execution.

Invalid state is surfaced without overwriting the original session. Database/application diagnostics check parent existence, cycles, ordering, digests, attachments, checkpoints, and tool-call/result pairing, but the first milestone does not build generalized in-place database surgery.

### Exact and provider-compatible derivation

- Exact derivation creates a fresh session from any `sessionId:nodeId` by materializing its root-to-node provider-neutral chain and preserving messages, reasoning, backend tools, tool-call/result pairing, attachments, effective model, prompt, and tool policy.
- Exact mode records source selector, source path digest, output digest, and transformation version and must produce a semantically equivalent next-request context.
- When a provider rejects otherwise readable context because of generated tool-call IDs, hashes, thinking signatures, continuation references, or related transport values, the product never transforms automatically or in place. It preserves the source tree, explains the incompatibility, and presents exactly two explicit fresh-session recovery choices:
  1. **Sanitized Chain — recommended** — create a new session that preserves ordered messages, reasoning, and tool interactions while regenerating or removing provider-specific generated values.
  2. **Markdown Handoff** — write a readable source-linked handoff file and create a new session whose small initial message only instructs the agent to inspect that path on demand, avoiding one huge injected prompt.
- Both choices preserve the original tree and identify their transformation. Only exact mode claims semantic equivalence; Sanitized Chain and Markdown Handoff optimize provider compatibility and retained context.
- Summarized or compacted derivation remains separately named and explicitly lossy.

### Legacy and interchange boundary

- Normal startup ignores legacy `~/.grok` sessions.
- An optional explicit command imports selected legacy JSON/JSONL sessions non-destructively, resumably, and rollback-safely while leaving originals untouched and reporting malformed records.
- A versioned repository bundle is the normal interchange format.
- JSONL remains only a legacy input or explicitly requested diagnostic export and never becomes a competing authority.

## Provider and account behavior

- A searchable `/login [provider]` and matching headless commands support OAuth, API keys, transient ambient/cloud identity, and keyless providers without provider-specific Pager branches. They report the authenticated account identity and provide login, selection, status, and logout; ambient credentials are never persisted automatically.
- The first provider-platform proof covers Grok/xAI, Anthropic, OpenAI, one cloud-identity request path, and one compatible local or gateway endpoint.
- Provider/model switches reproject canonical history without rewriting it.
- Provider-dependent web and media tools route independently from the chat model with explicit preferred provider and fallback behavior.
- `/usage` and headless usage surfaces provide provider/account quota best-effort and local token/cost data otherwise.
- Usage refresh is on demand when missing or expired, uses configurable jittered TTL, single-flight coalescing, explicit invalidation, and age-labeled last-good fallback.
- Optional background polling is disabled by default. When enabled, it uses capped multiplicative backoff with jitter and suspends itself after a configured failure threshold while preserving manual refresh.
- Usage is never an unconditional per-request quota probe.
- Authoritative provider-reported charges override estimates, and estimated components reconcile to the reported total.

## Independent project and delivery model

- The dedicated `open-grok` GitHub organization is the project home.
- The application, catalog, documentation/site, reusable tooling, and any future SDK or extension repositories remain separate concerns created only when reviewed need exists.
- The project owns public Cargo CI, zero-warning linting, supported-platform builds, tests, security/dependency checks, release automation, changelog, artifacts, signatures, and contribution/security policies.
- Omitted internal xAI Bazel, CI, and release infrastructure is never assumed to validate the public fork.
- Current and future upstream changes never land directly on the default branch. Before independence cutoff, exact snapshots/ranges use isolated reviewed synchronization pull requests. After cutoff, candidates are classified as pick, port, skip, or do-not-port; whole-tree synchronization is no longer the default.
- User-visible changelog, upstream import records, ADRs, PDRs, architecture evidence, and mutable goal state remain distinct.
- One authoritative architecture map documents the complete tool lifecycle: taxonomy, permission ordering, MCP, local versus provider-side execution, web/media routing, browser/computer boundaries, dynamic loading, and test topology. Every tools-relevant phase updates that owner document.
- Accepted decisions are superseded, not silently rewritten.

## Ordered delivery phases

1. **Ownership and preserved foundation** — establish organization identity, protection continuity, and path-by-path classification of dirty work without reset, clean, or bulk stash.
2. **Public Cargo foundation** — make clean-clone Cargo verification, zero-warning linting, CI, provenance, and upstream-sync gates independently reproducible.
3. **Canonical contracts** — define tree nodes, cursors, append/idempotency, provider-neutral context/tools, projection checkpoints, and their decisions/tests.
4. **Memory-first repository** — implement all-session structured state, search, diagnostics, accepted/durable watermarks, frozen benchmarks, and the background writer.
5. **open-grokd** — move actor/execution ownership behind thin local/remote attachments and satisfy the attach/search/append/resource SLOs.
6. **Node-aware product UX** — expose selectors, branches, exact/sanitized/handoff derivation, diagnosis, recovery, and optional explicit import across TUI/headless/ACP.
7. **Provider and credential foundation** — implement compiled providers, encrypted multi-account credentials, vault custody, coordinated refresh, and generic login/account UX.
8. **Catalog, capabilities, tools, and projections** — decouple signed catalog freshness, normalize capabilities, cache projections, and isolate provider-specific request behavior.
9. **Provider vertical slices** — prove Grok/xAI, Anthropic, OpenAI, cloud identity, and local/gateway behavior end to end, including usage and provider-backed tools.
10. **Remote hosting and repository placement** — productionize SSH/TLS attachment and optional remote database adapters without a second service architecture.
11. **Independent release cutover** — ship reproducible artifacts and selective upstream maintenance through open-grok-owned systems.

Each phase follows the concrete file/system work and verification in `plan.md`; a later phase may not weaken an earlier invariant merely to pass its own gate.

## Verification and acceptance gates

The goal is not satisfied by compilation alone. Required evidence includes:

- formatting, supported-platform Cargo builds, targeted tests, and zero-warning clippy;
- clean-clone public CI with no internal infrastructure or credentials;
- property/concurrency tests for single-parent trees, siblings, cursor CAS, ambiguity, and deterministic path materialization;
- visible-append, accepted-to-durable, attach, search, resume, traversal, concurrency, RSS, CPU, and soak benchmarks against frozen fixtures;
- crash tests before acceptance, between acceptance and durability, after durability, graceful drain, restart reconciliation, and pending-tail disclosure;
- exact derivation equivalence plus generated-ID/signature provider-rejection fixtures for sanitized and Markdown-handoff recovery;
- encrypted credential, tamper, rotation, OS-vault, fail-closed, account affinity, quota/failover, and refresh-lease tests;
- catalog signature, rollback, digest, schema, offline, stale-cache, and atomic activation tests;
- request and streaming fixtures for each provider protocol and mid-session model/provider switching;
- local socket/pipe, stdio, SSH proxy, authenticated TLS, reconnect, overload, identity/version negotiation, and remote backend contract tests;
- empirical opt-in TUI/headless provider flows with transient secret injection;
- phase-by-phase verification that the authoritative tool-lifecycle map matches implemented taxonomy, permissions, MCP, local/provider execution, routing, dynamic loading, browser/computer boundaries, and test ownership;
- documentation, provenance, security, artifact signature, install, update, and rollback validation.

Unavailable or blocked checks are reported explicitly. Releases do not require an exhaustive live-provider matrix, but no required contract may be marked verified without evidence.

## First milestone done condition

The first milestone is complete only when:

- the application repository is established under the project organization with preserved lineage and protections;
- public Cargo and CI foundations are reproducible;
- canonical tree/cursor/request contracts are accepted and tested;
- one memory-first all-session repository and `open-grokd` satisfy the frozen Apple Silicon SLOs through thin local clients;
- global list/search/resume/branch traversal is materially better than the JSONL baseline;
- exact node resume, exact derivation, sanitized-chain recovery, Markdown-handoff recovery, diagnosis, and optional explicit legacy import pass their gates;
- no preserved dirty work has been silently discarded or absorbed without classification.

## Broader goal done condition

The goal is complete only when:

- the first milestone remains green;
- Grok/xAI, Anthropic, OpenAI, cloud identity, and a local/gateway path pass end-to-end provider verification;
- encrypted multi-account credentials, signed independent catalogs, normalized capabilities/tools, deterministic projections, usage behavior, and mid-session switching are production-ready;
- the same daemon can be hosted locally or remotely through the supported secure transports and can use a reviewed remote repository adapter without changing client semantics;
- TUI, headless, ACP, hooks, skills, agents, plugins, MCP, LSP, subagents, permissions, sandboxing, and background work meet or exceed baseline behavior;
- the authoritative tool-lifecycle architecture map is complete and current for every tools-relevant phase;
- public releases, artifacts, changelog, governance, security policy, and selective upstream intake are operational through open-grok-owned systems;
- every accepted fact is supported by transcript-visible verification and no required phase remains incomplete.

## Explicit exclusions and deferred decisions

- No multi-parent session DAG or automatic branch merge.
- No automatic legacy state discovery or migration.
- No permanent JSONL authority.
- No per-session database fragmentation.
- No public provider plugin/marketplace ABI in the first provider platform.
- No dedicated catalog service until static signed delivery proves insufficient.
- No second remote Session Service architecture.
- No raw UDP session transport; QUIC waits for measured need.
- No remote multi-primary replication, collaboration roles, client-side session payload encryption, or deployment automation without separate prioritization.
- No generalized first-milestone in-place database repair/salvage machinery.
- No guarantee that arbitrary in-flight external tools replay after daemon or machine failure.
- No provider credentials in session sync or remote repository storage.
- No blind whole-tree upstream synchronization after the independence cutoff.
