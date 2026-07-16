# open-grok provider platform implementation plan

## Authority and approach

This plan implements the final 39 facts in [`facts.md`](facts.md) against the reviewed baseline and source order in [`docs/architecture/source-ledger.md`](../../docs/architecture/source-ledger.md). It preserves the current Pager/ACP normalization and permission boundaries documented in [`docs/architecture/current-state.md`](../../docs/architecture/current-state.md), but replaces per-process file-owned session authority with one provider-neutral all-session repository and an efficient `open-grokd` that may run locally or on an operator-chosen remote host.

The implementation proceeds through independently reviewable phases. Each phase must leave the current product usable, preserve unrelated dirty work, update its owning architecture and decision records, and pass its own exit gate before the next phase begins. No phase may silently broaden into a provider plugin ABI, automatic legacy import, multi-parent history graph, general collaboration platform, multi-primary replication system, or second remote-service architecture.

## Cross-phase invariants

- **Pager remains provider-wire-neutral.** Provider auth, request projection, protocol quirks, catalogs, and hosted tools remain below ACP/session updates.
- **Routine infrastructure is almost invisible.** Daemon, transport, storage, cache, and persistence details stay out of ordinary UX unless explicitly inspected or actionable degradation must be surfaced; warm attachment, resume, search, and interaction are treated as felt product behavior.
- **Permission UX is yolo by default and configurable.** Routine tools proceed without operator babysitting under the default permissive policy, while stricter policies remain selectable and hard plan-mode, sandbox, trust, and explicit safety boundaries still run before execution.
- **Canonical state is provider-neutral.** Immutable session nodes, exact attachment cursors, messages, tool results, attachments, effective request inputs, and semantic checkpoints are authoritative; provider transport objects are adapter-owned projections.
- **The conversation structure is a tree.** Each node has at most one parent and may have many children. No merge node or multi-parent DAG enters this plan.
- **Interaction does not wait for stable storage.** The daemon accepts an append into one ordered in-memory queue, renders it, and may begin inference or tools immediately. Accepted and durable sequence positions remain distinct; a tightly bounded background writer coalesces commits, graceful shutdown drains the queue, and sudden machine failure may lose only the explicitly not-yet-durable tail.
- **Credentials remain separate.** Provider secrets never enter the session repository, daemon session payloads, or remote repository backend and never fall back to plaintext storage.
- **Legacy state is opt-in.** Normal startup does not scan `~/.grok`; any import is an explicit, selected, non-destructive command into `~/.open-grok`.
- **Every engine claim is empirical.** Current JSONL fixtures are migration and benchmark oracles only. SQLite is the initial implementation behind `SessionRepository`, not an eternal public contract.
- **No hidden execution claims.** Durable metadata and leases never masquerade as live actors or successfully resumed external tool execution.
- **Preserved work is classified, not discarded.** The existing staged, unstaged, and untracked foundation remains in place until each path is assigned to a reviewed phase and verified.

## Phase 0 — establish ownership and preserve the foundation

### Outcome

Move the application repository to the dedicated `open-grok` organization as immediate foundation work, preserve the protected xAI publication anchor, and turn the current dirty branch into an explicit path-by-path delivery inventory without resetting, cleaning, or bulk-stashing it.

### Work

1. Record the current local path inventory, staged/unstaged split, branch, `HEAD`, `origin/main`, remotes, and critical remote refs.
2. Classify every existing changed path into:
   - repository identity and public documentation;
   - architecture/provenance/decision records;
   - public Cargo/test-support repairs;
   - CI and upstream-sync automation;
   - goal provenance;
   - unrelated or superseded drafts.
3. Run the transfer preflight from the completed migration audit immediately before the action. Block if destination availability, administrator access, critical SHAs, protected archive continuity, effective default-branch protection, hosted artifacts, or the unchanged dirty local foundation differ from the reviewed expectations.
4. Obtain explicit operator approval for the outward-facing transfer.
5. Transfer only the existing application repository. Do not create speculative catalog, service, SDK, or extension repositories.
6. Verify the destination owner, `main`, `archive/xai-published-c1b5909`, hosted artifacts, redirects, collaborators, and unchanged local dirt.
7. Apply repository-level `main` protection at the destination before normal development resumes; the source organization ruleset does not transfer.
8. Only after successful postflight, update `origin`, public repository links, and the chezmoi-managed Mani source. Preserve `upstream = xai-org/grok-build`.

### Verification

- Compare local `HEAD`, `origin/main`, and both critical remote refs before and after transfer.
- Verify the archive branch remains locked, admin-enforced, non-force-pushable, and non-deletable.
- Verify `main` rejects force pushes and deletion at the destination.
- Verify `git status --porcelain=v1` is byte-equivalent before and after the remote action.
- Run `mani check` and a scoped `mani sync --status` after the managed inventory update.

### Exit gate

The application repository is owned by `open-grok`, critical refs and local work are unchanged, destination branch protection is equivalent, public links and inventory resolve, and no speculative repository has been created.

## Phase 1 — make the public fork independently buildable

### Outcome

Land a reproducible public Cargo verification baseline and the governance/provenance foundation before feature implementation.

### Work

1. Resolve the generated root `Cargo.toml` authority and document the supported way to add or change workspace members; do not hand-edit generated membership without its source.
2. Finish classifying the existing code patches that repair omitted internal Bazel/test-support assumptions. Keep only changes required for the public Cargo build and split them from documentation and workflow changes.
3. Establish focused GitHub Actions workflows for formatting, supported-platform production compilation, public library tests, zero-warning clippy, dependency/security checks, documentation/provenance checks, and upstream-sync validation.
4. Keep workflows modular and cache-aware; do not claim validation for unavailable internal xAI infrastructure.
5. Review the proposed lineage, upstream-import, pull-request, and provenance ADR/PDR records. Accept, revise, reject, or supersede them explicitly rather than treating `Proposed` as authority.
6. Land coherent foundation commits in reviewable order: governance/docs, Cargo/test-support, then CI/upstream-sync automation.
7. Add a user-visible changelog entry only for behavior or delivery changes users can observe.

### Verification

- `cargo fmt --all --check`
- Targeted `cargo check`, `cargo test`, and `cargo clippy -- -D warnings` for every changed crate.
- Public CI from a clean clone with no internal credentials or Bazel-only artifacts.
- Documentation link and provenance checks.
- Workflow fixture tests for rewritten-root detection, exact pinning, and forbidden direct-to-`main` upstream imports.

### Exit gate

A clean public clone can run the supported Cargo gates, clippy emits zero warnings in scope, CI reports blocked checks honestly, and accepted maintenance decisions match the actual workflow.

## Phase 2 — define canonical session and provider-neutral request contracts

### Outcome

Introduce storage- and transport-independent domain types before changing runtime ownership.

### Work

1. Define `SessionId`, `NodeId`, `BatchId`, `AttachmentId`, versioned `SessionSelector`, immutable node payloads, parent links, batch ordinals, content digests, attachment references, semantic inputs, metadata revisions, presence leases, and cursor compare-and-swap.
2. Define the atomic append contract around:
   - attachment identity;
   - expected cursor version;
   - exact parent node;
   - idempotency key;
   - canonical ordered items;
   - created node IDs, final node, context digest, new cursor version, accepted sequence, and durable sequence watermark.
3. Define bare-session resolution: valid caller/device cursor, explicit default/bookmark, sole leaf, otherwise an interactive branch picker or structured headless ambiguity error.
4. Define provider-neutral reconstruction from one exact root-to-node path, including messages, reasoning, backend-tool calls, tool-call/result pairing, attachments, effective model, sampling, prompt, compaction/rewind inputs, and ordered tool policy.
5. Define the canonical enabled-tool policy and per-turn provider-neutral manifest. Make xAI one adapter projection, not the canonical request shape.
6. Define provider projection checkpoints with adapter/provider/model/account affinity, parent node, expiry, and complete projection-input digests. On mismatch or rejection, fall back to deterministic reconstruction.
7. Keep UI replay, viewport state, provider cache hints, and transport continuation details outside canonical history unless a versioned checkpoint is required to reproduce provider semantics.
8. Add decision records for session authority/tree semantics, daemon ownership and accepted-versus-durable append semantics, and provider-neutral projection ownership. The session-tree record must credit Pi's single-parent tree precedent at the pinned Pi revision from the source ledger.
9. Complete the authoritative tool-lifecycle architecture map covering taxonomy, permission ordering, MCP, local versus provider-side execution, web/media routing, browser/computer boundaries, dynamic loading, and test topology. Require every later tools-relevant phase to update this owner document rather than duplicating it.

### Systems touched

- `xai-chat-state` conversation and persistence interfaces.
- `xai-grok-sampling-types` provider-neutral conversation items.
- `xai-grok-shell/src/session/` handles, compaction, rewind, fork/export behavior, and ACP selector types.
- `xai-acp-lib` only where typed selectors or status need protocol exposure.
- A new low-fan-out repository/domain crate, added through the verified workspace-generation path.

### Verification

- Property tests prove one parent per node, stable child ordering, no cycles, deterministic path materialization, sibling preservation, and cursor CAS behavior.
- Concurrent append tests prove two attachments at one parent create siblings and same-attachment races produce one successful cursor advancement.
- Serialization compatibility tests cover versioned IDs/selectors and reject ambiguous short IDs.
- Projection tests prove a no-op rebuild produces the same canonical digest and byte-stable provider prefix.
- The tool-lifecycle map is checked for every required boundary and links its current implementation/test owners.

### Exit gate

The domain model can represent and test all session/tree/projection facts without SQLite, daemon IPC, Pager state, or one provider wire schema becoming authoritative.

## Phase 3 — implement the memory-first all-session repository

### Outcome

Provide one repository for every session under `~/.open-grok`, with global queries, exact node traversal, an ordered memory-first append path, tightly bounded background durability, and non-destructive invariant diagnostics.

### Work

1. Implement `SessionRepository` with an initial SQLite schema for sessions, nodes, batches, attachment cursors, idempotency records, metadata revisions, content-addressed assets, provider projection checkpoints, presence leases, and search projections.
2. Reuse the existing SQLite journal-mode helper and FTS behavior where their contracts fit; do not promote the current search-only index or whole-index remote copying into canonical authority.
3. Configure local WAL with one sequenced writer, bounded read connections, a busy timeout, foreign keys, explicit transaction boundaries, and separately scheduled checkpoints. Use the strongest durability setting that still meets the accepted-to-durable p95 gate; SQLite documents concurrent readers with one serialized writer and the durability/performance trade-off between `FULL` and `NORMAL` ([WAL](https://sqlite.org/wal.html), [isolation](https://sqlite.org/isolation.html)).
4. Accept each append into the daemon's ordered in-memory queue, assign its node IDs/idempotency result/cursor version immediately, and expose both accepted and durable sequence watermarks. Inference and tools may proceed from accepted state without waiting for the writer.
5. Add a dedicated background writer that coalesces compatible queued appends into atomic transactions without reordering batches. Target accepted-to-durable p95 at or below 20 ms on the reference Apple Silicon fixture and drain all pending writes during graceful shutdown.
6. Add global inventory, metadata filters, FTS search, exact path/ancestor/children queries, branch summaries, and health information.
7. Add database and application-level diagnostics: SQLite quick/full/foreign-key checks plus digests, parent existence, cycle detection, batch ordering, tool-call/result pairing, attachment existence, and checkpoint-input validation. Surface and quarantine an invalid session; never overwrite it or attempt generalized in-place surgery in the first milestone.
8. Before numeric SLOs become binding, freeze and version the reference Apple Silicon machine class, generated dataset, session/node distributions, hot/cold cache state, search corpus, append workload, daemon configuration, and benchmark procedure so later tuning cannot move the gate.
9. Benchmark SQLite against current JSONL fixtures and, where useful, a bounded redb/Fjall/heed prototype. A KV engine replaces SQLite only if the complete repository workload—not an isolated key benchmark—wins without introducing a larger unproven indexing, migration, search, and integrity layer. redb itself offers ACID/MVCC/crash-safe storage but still leaves those domain layers to open-grok ([redb](https://github.com/cberner/redb)).

### Verification

- Crash-injection tests before acceptance, between acceptance and durable commit, and after durable commit prove the exact pending-tail behavior.
- Idempotent client reconciliation tests cover retries after an unknown accepted/durable outcome and explicit sequence gaps after restart.
- Graceful shutdown drains every accepted append; sudden process and machine failure recover every durable watermark and report any missing accepted tail honestly.
- A committed benchmark manifest pins the reference machine class, fixture generator/version, generated counts/distributions, cache state, configuration, and command before the aggressive numeric gates are evaluated.
- Aggressive benchmark gates cover visible append, accepted-to-durable p50/p95, throughput, cold/warm inventory, search, exact resume, ancestor/child traversal, concurrent readers, writer contention, and checkpoint tails against that frozen manifest.
- Missing parent, cycle, malformed payload, broken tool pair, missing attachment, and bad checkpoint fixtures surface a non-destructive diagnosis and provider-context recovery choices without overwriting the original session.

### Exit gate

The repository meets the aggressive visible-append and accepted-to-durable gates, materially improves global query/resume/tree operations, recovers every durable watermark, reports any lost pending tail precisely, and surfaces invalid state without silently rewriting the original session.

## Phase 4 — make `open-grokd` the normal local or remote runtime owner

### Outcome

Replace one full runtime per attached client with one efficient daemon endpoint—on the same machine or any operator-chosen host—that owns the repository, bounded memory-hot sessions, execution coordination, and one transport-neutral attachment protocol.

### Work

1. Add an `open-grokd` composition root without pushing daemon concerns into Pager. Define one persistent multiplexed bidirectional RPC with requests, streamed events, subscriptions, approvals, overload signals, reconnect cursors, daemon identity, protocol version, and capability negotiation.
2. Support the protocol over Unix-domain sockets on Unix and named pipes on Windows for the lowest-overhead local path; framed stdio for embedding, diagnostics, tests, and SSH execution; an SSH-spawned proxy for secure zero-exposure remote attachment; and explicitly configured authenticated TLS WebSocket/TCP for persistent remote deployments. Keep QUIC as a measured later transport and reject raw UDP for ordered session control.
3. Implement efficient single-instance ownership per configured endpoint, startup locking, authenticated local-user access, remote daemon identity verification, health, graceful shutdown, bounded queues, and actionable upgrade mismatch errors. Do not restrict internal actor/task parallelism merely to serialize repository ordering.
4. Make TUI, headless, ACP, agent, and subagent entrypoints attach as thin clients over a persistent connection. Preserve the existing typed ACP/update behavior at the Pager boundary, pool/reuse SSH or TLS connections so attach does not repeat setup work, auto-resolve routine startup/access state where tools permit, and keep daemon/backend detail out of the default interface.
5. Move resident `SessionActor` ownership behind the daemon while preserving one actor thread/current-thread runtime/`LocalSet` per hot session, one foreground turn per session, and parallel work across sessions and independent tools.
6. Add bounded hot-session/context and query-projection caches with explicit byte/item limits, LRU-style eviction, pinning for active work, content fingerprints, and deterministic reconstruction from the repository.
7. Let active turns and explicitly backgrounded work continue after client disconnect while the daemon is alive. Persist truthful accepted/durable watermarks and leases; after restart recover durable canonical state, report any pending-tail loss, and do not claim arbitrary external tool execution resumed unless a later checkpoint contract proves it.
8. Integrate per-user supervision and logs using native platform mechanisms where available. Keep a foreground/stdio diagnostic mode and allow the same daemon to be hosted remotely without a second server architecture.
9. Allow `open-grokd` to configure a reviewed remote database adapter behind `SessionRepository` when an operator wants database placement separate from daemon placement. Do not make raw tables the normal client attachment API or duplicate live actor ownership in every client.
10. Retire or adapt `grok agent serve` only after its reconnect behavior is covered by the daemon path; do not leave competing session owners.

### Systems touched

- `xai-grok-pager-bin` mode dispatch and management commands.
- `xai-grok-pager/src/acp/` connection spawning.
- `xai-grok-shell/src/agent/server.rs` and `MvpAgent` ownership.
- `xai-grok-shell/src/session/acp_session_impl/spawn.rs` actor hosting.
- Background-task manifest/status code.
- New daemon RPC and client crates through the verified workspace-generation path.

### Verification

- Attach multiple TUI/headless/ACP clients to one daemon and exact nodes concurrently over local socket/pipe, stdio, SSH proxy, and authenticated TLS network fixtures.
- Prove endpoint single ownership, daemon/user identity verification, protocol negotiation, bounded overload behavior, and no ordinary client dependence on raw repository tables.
- Persistent connection and reconnect tests preserve cursors and streamed state without repeating bootstrap work.
- On the reference Apple Silicon fixture: warm attach p95 ≤10 ms; cold attach of a 1,000-node session p95 ≤100 ms; warm search over 10,000 sessions/5 million nodes p95 ≤100 ms; visible append ≤5 ms; accepted-to-durable append p95 ≤20 ms; idle daemon RSS target ≤50 MiB.
- Hot-cache eviction and cold reconstruction produce identical canonical digests while concurrent warm attachments remain effectively immediate.
- Memory, CPU, scheduler, and file-descriptor soak tests cover many dormant sessions, many hot sessions, and concurrent clients without serializing independent session/tool work.
- Platform-specific supervision, local permissions, SSH bootstrap/PATH, stale endpoint, TLS identity, upgrade, remote reconnect, and recovery tests.
- Focused post-cutover regressions for hooks, MCP tools, LSP, skills/agents loading, subagents, plugin trust decisions, and provider-independent tool permissions.
- Permission-policy tests prove the default permissive/yolo path avoids routine prompts, stricter configured policies still prompt or deny correctly, and hard plan-mode/sandbox/trust boundaries cannot be bypassed by the default.

### Exit gate

Local or remote clients share one daemon endpoint, warm attachment is effectively immediate, cold attachment and global search meet the aggressive SLOs, active sessions remain memory-hot within explicit limits, durable state survives daemon failure, pending-tail loss is surfaced precisely, and Pager behavior remains equivalent through ACP.

## Phase 5 — deliver node-addressable UX, exact derivation, and optional import

### Outcome

Expose the repository model coherently in CLI, TUI, ACP, and management flows without leaking database mechanics.

### Work

1. Support `sessionId` and `sessionId:nodeId` selectors in resume/continue flows, management commands, TUI branch navigation, and ACP APIs.
2. Add branch picker and structured ambiguity errors; never silently choose the newest leaf.
3. Make rewind move an attachment cursor to an ancestor without deleting siblings.
4. Make compaction append a lossy summary/checkpoint with source-range digests while retaining original nodes.
5. Add `sessions derive <sessionId:nodeId> --mode exact` to create a new session from a root-to-node canonical path. Record source selector, source path digest, output digest, and transformation version.
6. When a provider rejects readable context because of generated tool-call IDs, hashes, thinking signatures, continuation references, or related transport values, never transform automatically or in place. Preserve the source session, explain the concrete incompatibility, and present exactly two explicit fresh-session actions:
   - recommended `--mode sanitized`: create a new session with the ordered messages, reasoning, and tool interactions preserved while provider-specific generated values are regenerated or removed;
   - `--mode handoff`: write a readable Markdown handoff and create a new session whose small initial message only instructs the agent to inspect that file path on demand, avoiding one huge injected prompt.
7. Keep summarized/compacted derivation separately named and explicitly lossy. Only exact mode may claim semantic equivalence; sanitized and handoff modes claim compatibility and retained context, not identity.
8. Add explicit `sessions import legacy-grok ...` selection. Do not scan or prompt during startup. Preserve source files, report malformed records, and support resumable rollback-safe import.
9. Add versioned repository bundle export/import; keep JSONL only as an explicitly requested diagnostic export or legacy input.
10. Add shared TUI, headless, and ACP management surfaces for list, search, filter, sort, tree and child inspection, rename, archive, delete, import, export, sync, diagnose, recover, status, and health.

### Verification

- Round-trip tests prove exact derivation produces semantically equivalent next-request context, including reasoning and tool-call/result ordering.
- Provider-rejection fixtures cover invalid/reused tool IDs, hashes, thinking signatures, generated continuation values, and cross-provider projections. Sanitized recovery rebuilds a valid ordered chain and leaves the original tree byte-for-byte untouched.
- Markdown handoff fixtures prove the generated file is readable, source-linked, bounded, and not injected wholesale; the fresh session begins with only the path-oriented inspection instruction.
- Selector tests cover explicit nodes, persisted cursors, bookmarks/defaults, sole leaves, ambiguity, and unambiguous short IDs.
- Rewind and compaction tests preserve siblings and source history.
- Legacy import fixtures cover valid, torn-tail, malformed, compacted, rewound, and attachment-bearing sessions; originals remain byte-identical.
- UX tests prove TUI and headless surfaces show the provider failure, preserve the source session, perform no automatic transformation, recommend Sanitized Chain without preselecting it, present both fresh-session actions, and report the same repository/execution state.

### Exit gate

Users can inspect, filter, sort, rename, archive, delete, resume, branch, derive, import/export, sync, diagnose, recover, and query health through node-aware TUI, headless, and ACP surfaces. Provider-context failure never overwrites the source session and always offers sanitized-chain or Markdown-handoff recovery, with no normal dependency on legacy files.

## Phase 6 — establish provider registry and encrypted multi-account credentials

### Outcome

Create native Rust provider/auth/account foundations without changing Pager into provider-specific UI.

### Work

1. Introduce compiled provider definitions for identity, auth methods, environment fallbacks, catalog/discovery sources, protocol adapter, usage adapter, compatibility policy, normalized capabilities, and provider-backed tools.
2. Add reviewed YAML overrides under `~/.open-grok` for compatible providers/models, headers, discovery, routing, and equivalence. Keep compiled adapters mandatory for new wire protocols or security-sensitive auth.
3. Implement the separate credential SQLite database and encrypted row envelope with XChaCha20-Poly1305, authenticated row identity, key version, fresh nonce, and resumable rotation.
4. Store the installation master key in macOS Keychain, Windows Credential Manager, or Linux Secret Service. Require explicit external key delivery on headless Linux and fail closed without it.
5. Add durable credential IDs, multiple accounts per provider, explicit selection, deterministic session affinity, quota blocking, sibling failover, and non-session rotation.
6. Add in-process single-flight refresh and cross-process durable refresh leases. Distinguish transient from definitive failure and never silently switch auth source.
7. Implement searchable `/login [provider]` and matching headless account login/list/status/select/logout commands. Treat ambient/cloud credentials as transient unless the operator explicitly imports them.
8. Add optional explicit legacy auth import under its own command with selected inputs, resumable rollback-safe verification, and originals left untouched; never auto-detect by reading legacy state during normal startup.

### Verification

- No plaintext secret appears in configuration, ordinary database columns, logs, errors, crash reports, or session sync payloads.
- Known-answer encryption, tamper, wrong-key, rotation interruption/resume, and old-key retention tests.
- OS vault integration tests plus fail-closed headless Linux fixtures.
- Multi-process refresh lease, account-affinity, quota-block, failover, and definitive-revocation tests.
- Pager snapshots prove provider additions do not require provider-specific TUI branches.

### Exit gate

Grok/xAI and test providers can authenticate through the generic account model, secrets remain isolated, refresh is coordinated, and all UI/headless account operations use the same contracts.

## Phase 7 — decouple model catalogs, capabilities, tools, and request projections

### Outcome

Make model freshness independent of application releases and make adapter projection deterministic, efficient, and invalidatable.

### Work

1. Define the schema-validated catalog snapshot, provenance, monotonic revision, signer identity, content digest, release identity, compatibility bounds, and embedded recovery seed.
2. Create the catalog repository only when this phase starts. Publish immutable signed snapshots as GitHub Release assets and a small signed latest pointer through GitHub Pages or equivalent static hosting. Pi already operates a remote provider-catalog overlay at `pi.dev`; open-grok begins with static delivery and defers a dedicated service until measured need.
3. Implement precedence: explicit user overrides, provider-authoritative live discovery, last verified open-grok snapshot, then embedded seed.
4. Add conditional/jittered refresh, bounded caching, force/inspect commands, offline fallback, atomic activation, and rollback on verification failure.
5. Normalize tools, deferred loading, reasoning, images, structured output, context/output limits, provider-native tools, and protocol quirks into capability metadata.
6. Build provider/model adapter projections from the canonical request context and tool manifest. Cache immutable fragments by tool-definition revision and projection flavor; include explicit context revisions for dynamic descriptions.
7. Persist only semantic provider checkpoints defined in Phase 2. Invalidate on adapter/model/account/input mismatch, expiry, or provider stale-state rejection and rebuild from canonical state.
8. Preserve xAI-specific headers, patches, hosted tools, OAuth behavior, and continuation state inside the xAI adapter.
9. Update the authoritative tool-lifecycle map with the final provider-side/local routing, dynamic-loading, projection-cache, and capability-test ownership introduced by this phase.

### Verification

- Signature, wrong signer, rollback revision, digest mismatch, schema mismatch, partial download, stale cache, offline, and embedded-seed tests.
- Request golden fixtures for OpenAI Chat Completions, OpenAI Responses, Anthropic Messages, and xAI-specific projections.
- Model switch tests reproject the same canonical state without rewriting history.
- Cache tests prove exact invalidation and byte-stable no-op prefixes.
- Unsupported capability tests fail early with explicit product errors.
- Documentation verification proves the tool-lifecycle map reflects the implemented routing, projection, permission, dynamic-loading, and test boundaries.

### Exit gate

Catalog updates ship independently, verified snapshots activate atomically, provider switches preserve canonical context, and no provider wire object becomes shared session authority.

## Phase 8 — prove provider vertical slices and usage behavior

### Outcome

Ship end-to-end provider behavior for Grok/xAI, Anthropic, OpenAI, and one compatible local/gateway endpoint through the new foundations, plus at least one cloud-identity provider request path required for first-release family coverage.

### Work

1. Preserve and migrate Grok/xAI subscription OAuth, inference, reasoning, tool streaming, session affinity, request patches, hosted tools, and provider-side behavior first.
2. Implement Anthropic and OpenAI auth/protocol adapters using current provider APIs and the strongest reviewed Codex/OMP precedent where applicable.
3. Add one compatible local or gateway path without delaying hosted-provider correctness.
4. Prove at least one cloud-identity provider path end to end, including ambient identity discovery, account/role selection where applicable, signed request authentication, streaming inference, expiry/refresh behavior, and isolation from stored API-key/OAuth credentials.
5. Normalize streaming text, reasoning, tool calls/results, retries, usage, errors, cancellation, and completion into existing sampling/session events.
6. Implement provider-dependent web/media tool routing separately from the chat-model provider, with explicit fallback and capability errors.
7. Add best-effort `/usage` and headless usage surfaces. Refresh missing/expired data on demand with configurable jittered TTL, single-flight coalescing, explicit invalidation, and labeled last-good stale fallback.
8. Keep optional background quota polling disabled by default. When enabled, use capped multiplicative backoff with jitter and suspend automatically after a configured failure threshold while preserving manual refresh.
9. Reconcile authoritative provider-reported response charges over local estimates.
10. Update the authoritative tool-lifecycle map with the implemented hosted-tool routes, local fallbacks, provider capability gates, permission flow, and vertical-slice test ownership.

### Verification

- Deterministic mock-server fixtures for login, refresh, streaming, reasoning, tools, cancellation, retry, quota, charge reconciliation, and stale continuation fallback.
- Empirical opt-in TUI and headless smoke flows for each named vertical slice and the cloud-identity path, with secrets injected transiently and no exhaustive live matrix as a release gate.
- Cloud-identity fixtures cover ambient discovery, account/role selection, signing, expiry/refresh, and isolation from persisted provider credentials.
- Mid-session provider/model switching across tool and no-tool turns.
- Prompt-cache prefix and projection-checkpoint reuse/invalidation measurements.
- Failure tests prove one provider/account does not corrupt another or mutate canonical history.
- Documentation verification proves the tool-lifecycle map matches the shipped hosted/local routes, permissions, dynamic loading, and provider test topology.

### Exit gate

The four named vertical slices complete login, model selection, streaming, reasoning, tools, persistence, resume, catalog refresh, usage, and failure handling through shared contracts; at least one cloud-identity provider path additionally passes its end-to-end auth and inference gate, and Grok behavior remains first-class.

## Phase 9 — harden remote daemon hosting and repository placement

### Outcome

Let operators host the same `open-grokd` anywhere and choose local or remote repository placement without inventing a second session service, exposing unauthenticated listeners, or coupling ordinary clients to raw SQL.

### Work

1. Productionize the Phase 4 transport matrix around the same domain RPC: local socket/pipe, framed stdio, SSH-spawned proxy, and authenticated TLS WebSocket/TCP. Codex app-server validates the separation of protocol from stdio, Unix-socket WebSocket, and proxy transports, while its experimental unauthenticated TCP WebSocket is explicitly not the security model to copy ([Codex app-server](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md), [authentication request](https://github.com/openai/codex/issues/15141)).
2. Add persistent connection pooling, SSH control-connection reuse, reconnect cursors, monotonic event sequences, backpressure, bounded queues, retryable overload errors, and clear failure attribution across SSH bootstrap, daemon startup, authentication, version mismatch, stale endpoint, and repository failure.
3. Allow the daemon to configure a reviewed remote database adapter behind `SessionRepository` when database placement must differ from daemon placement. The adapter must preserve immutable sibling branches, cursor CAS, idempotency, accepted/durable watermarks, and global query semantics; Turso Sync's last-push-wins behavior is not sufficient for the session conflict model ([Turso](https://docs.turso.tech/sync/conflict-resolution)).
4. Keep provider credentials local to the daemon host and outside every session payload and remote repository row.
5. Keep live actors, approvals, subscriptions, tool execution, and provider-context recovery in the daemon even when the repository backend is remote. Direct database access may exist for operator diagnostics or a separately reviewed compatibility mode, but it is not the normal interactive client protocol.
6. Defer QUIC, offline multi-primary replication, E2EE payloads, collaboration roles, and deployment automation until measurements or product priorities justify them.

### Verification

- The same domain contract suite runs over every transport and against local SQLite plus any selected remote repository adapter.
- Warm remote reconnect over pooled SSH/TLS avoids daemon/session rehydration and meets separately recorded network-adjusted overhead budgets.
- Network loss, timeout during accepted-to-durable transition, duplicate retry, stale cursor, metadata CAS, asset mismatch, identity/version negotiation, and recovery tests.
- Concurrent clients appending from one parent create siblings, not overwritten state.
- Credentials and local secret references never cross the protocol or repository boundary.
- Remote daemon and remote-backend restarts recover durable watermarks, surface pending-tail uncertainty, and preserve both context recovery actions.

### Exit gate

An operator can host `open-grokd` locally or remotely, attach through the most efficient secure transport for the deployment, optionally place its repository in a reviewed remote database backend, and retain the same hot-session, branch, recovery, and provider behavior without a parallel service architecture.

## Phase 10 — independent release and maintenance cutover

### Outcome

Release open-grok as an independently governed product with selective upstream intake and verifiable public artifacts.

### Work

1. Finalize naming, versioning, artifact identity, release notes, contribution policy, security policy, support matrix, and installer/update channels.
2. Keep user changelog, upstream import records, ADR/PDR decisions, architecture evidence, and mutable goal state separate.
3. Before the independence cutoff, isolate exact upstream snapshots/ranges in reviewed sync pull requests. After cutoff, classify candidates as pick, port, skip, or do-not-port; stop treating whole-tree sync as the default.
4. Produce signed release artifacts through public CI and verify install/upgrade/rollback on supported platforms.
5. Run the full product acceptance matrix across TUI, headless, ACP, local/remote daemon lifecycle, local and reviewed remote repository backends, providers, catalog, credentials, session derivation, and both context recovery paths.
6. Update the final self-contained goal and state only after transcript-visible evidence satisfies every done condition.

### Verification

- Clean-clone release rehearsal.
- Artifact checksum/signature and provenance verification.
- Supported-platform install, first run, login, session create/resume/branch/derive, update, and rollback flows.
- Upstream intake dry run against a new candidate proves the classified workflow.
- Documentation audit contains no credentials, personal data, private endpoints, request history, or unsupported absolute claims.

### Exit gate

A public release is reproducible from open-grok-owned systems, the full accepted product behavior is verified, selective upstream maintenance is operational, and no goal fact remains dependent on an unapproved future phase.

## Milestone boundaries

### Foundation milestone

- Application repository transferred with protection continuity.
- Public Cargo/CI foundation green.
- Canonical session contracts accepted.
- Memory-first all-session repository and local/remote-capable `open-grokd` proven through thin clients under the aggressive Apple Silicon SLOs.
- Node-addressable resume, exact derivation, sanitized-chain recovery, Markdown-handoff recovery, invariant diagnostics, and optional explicit import pass their gates.

### Provider-platform milestone

- Provider registry, encrypted multi-account credentials, independent signed catalog, normalized capabilities/tools, the four named vertical slices, and at least one cloud-identity request path pass end-to-end verification.
- Grok/xAI behavior remains first-class.
- Mid-session model/provider switching is deterministic and cache-safe.

### Remote deployment milestone

- The same `open-grokd` runs locally or remotely over local socket/pipe, stdio, SSH proxy, or authenticated TLS transport and passes one protocol contract suite.
- A reviewed remote repository adapter may sit behind the daemon without becoming the client control protocol.
- QUIC, collaboration, multi-primary replication, and deployment automation remain deferred unless separately justified.

## Principal risks and controls

| Risk | Control |
|---|---|
| Repository transfer temporarily weakens `main` protection | Preflight current rules; apply destination repository protection immediately; block normal development until verified. |
| Dirty foundation mixes unrelated code and documentation | Path-by-path classification and coherent commits; no reset, clean, or bulk stash. |
| Daemon migration regresses Pager or actor affinity | Keep ACP boundary; move ownership behind handles; parity and reconnect tests before removing old paths. |
| Background persistence loses a sudden-failure tail | Distinguish accepted and durable watermarks, target ≤20 ms accepted-to-durable p95, drain on graceful shutdown, reconcile idempotently, and surface any missing pending tail without claiming it was durable. |
| SQLite becomes accidental permanent ABI | Hide it behind `SessionRepository`; benchmark full workloads; keep schemas internal and versioned. |
| Hot state grows without bound or limits parallelism | Explicit cache budgets, active pinning, eviction, cold reconstruction, multi-session/tool concurrency tests, and Apple Silicon CPU/RSS/attach SLOs. |
| Provider checkpoints become competing history | Bind them to complete canonical digests and adapter identity; invalidate and rebuild on any mismatch. |
| Legacy import expands into permanent dual authority | Explicit command only, selected inputs, originals untouched, repository bundle as normal interchange. |
| Remote flexibility becomes a second platform | Reuse one daemon and one domain protocol across transports; keep remote database placement behind the repository adapter; defer QUIC, replication, collaboration, and deployment automation. |
| Provider breadth delays a usable release | Four mandatory vertical slices; track the remaining long tail without blocking the first provider-platform release. |

## Decisions intentionally deferred

- Replacing SQLite with redb, Fjall, heed/LMDB, or another engine unless end-to-end benchmark and integrity gates justify it.
- Multi-parent merge nodes or a general conversation DAG.
- Automatic legacy state discovery or migration.
- A public provider plugin/marketplace ABI.
- A dedicated catalog service beyond static signed distribution.
- QUIC transport until SSH/TLS measurements show a real gap; raw UDP remains rejected for ordered session control.
- Remote multi-primary replication, collaboration roles, client-side session payload encryption, and deployment automation.
- Guaranteed replay of arbitrary in-flight external tools after daemon or machine failure.
