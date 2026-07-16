# Coding standards

Numbered rules for `open-grok` changes and reviews.

## §1 Scope and simplicity

### §1.1 Traceability
Every changed line must serve the active goal, accepted fact, issue, or approved implementation phase.

### §1.2 Minimum mechanism
Use the smallest mechanism that satisfies the requirement. Do not add speculative flexibility, plugin surfaces, services, or abstractions.

### §1.3 Surgical edits
Do not reformat, rename, refactor, or remove unrelated code. Mention unrelated problems separately.

### §1.4 Existing idiom
Match the surrounding crate's naming, module layout, comments, error handling, and test style.

## §2 Rust boundaries

### §2.1 Ownership is architecture
Preserve existing ownership boundaries. Do not replace actor/channel contracts with shared mutable state for convenience.

### §2.2 Thread affinity
`SessionActor`, `MvpAgent`, and other non-`Send` state remain on their owning thread/`LocalSet`. Cross-boundary access uses typed handles and channels.

### §2.3 Explicit contracts
Prefer narrow typed interfaces over maps of loosely related callbacks or configuration fields.

### §2.4 Errors retain context
Propagate or wrap errors with actionable context. Do not silently swallow failures unless the existing contract explicitly treats the operation as best-effort.

## §3 Runtime and sampling

### §3.1 UI isolation
Pager and ACP surfaces consume normalized session updates. Provider wire objects do not enter TUI state.

### §3.2 Stream ordering
Preserve sampling-event ordering and the stream-drainer barrier before post-response tool execution.

### §3.3 Cancellation completeness
Every request path must resolve or cancel its caller-visible completion channel. No failure may leave ACP or session callers waiting indefinitely.

### §3.4 Retry ownership
Retry policy belongs to the layer that understands the failure: transport retry, auth refresh, quota/account failover, and model resampling remain distinct.

## §4 Providers, authentication, and catalogs

### §4.1 Grok-specific policy is explicit
xAI headers, OAuth defaults, proxy patches, chat modes, and remote session services belong behind Grok-specific boundaries.

### §4.2 Existing seams precede new frameworks
Use and test the current `ApiBackend`, `SamplerConfig`, model manager, and credential-provider seams before introducing a new provider framework.

### §4.3 Catalog claims need authority
Do not add or change model metadata without an identified authoritative source and explicit merge precedence.

### §4.4 Credential compatibility is preserved
Changes must preserve current `auth.json`, refresh, and session-token behavior unless an approved migration defines replacement and rollback behavior.

### §4.5 Provider evolution is design-gated
Multiple accounts, rotation, new credential storage, UI-independent auth interaction, YAML provider definitions, and provider plugin APIs remain pending design choices until approved by the goal and phased plan.

### §4.6 Discovery is failure-tolerant
Network failure must retain bundled or last-known-good catalog state. Live provider discovery wins only where its authority is explicit.

### §4.7 Current custom-endpoint boundary is explicit
Configuration may target endpoints compatible with the compiled API backends. A new wire protocol remains a reviewed Rust change unless a later approved design changes that boundary.

## §5 State and persistence

### §5.1 Local truth first
Local session JSONL/JSON remains authoritative unless an approved migration explicitly changes that contract.

### §5.2 Conversation and replay differ
Do not conflate canonical model history with ACP/UI replay history.

### §5.3 Serialized durable mutation
Per-session durable writes pass through the persistence actor or an equivalently serialized owner.

### §5.4 Atomic replacement
Whole-file state replacement uses temporary-file plus rename or an equally durable atomic mechanism.

### §5.5 Backward compatibility
Persisted format changes require versioning, migration or explicit compatibility behavior, and recovery tests.

## §6 Tools, permissions, and extensions

### §6.1 Permission before execution
Plan restrictions, blocking pre-tool hooks, and permission resolution run before tool dispatch.

### §6.2 Same-target writes serialize
Concurrent tool execution must preserve same-path write serialization.

### §6.3 Trust is not installation
Installed or discovered plugins do not execute hooks, MCP, LSP, or scripts without the established trust gate.

### §6.4 Precedence is documented
Config, project, user, plugin, and compatibility-source precedence must be deterministic and tested.

### §6.5 Public extension APIs follow proven internals
Do not freeze a provider/plugin ABI before multiple built-in and configuration-defined integrations validate the boundary.

## §7 Documentation and evidence

### §7.1 Pinned claims
Behavior-sensitive external claims use commit-pinned public permalinks.

### §7.2 Repository-local Grok links
When a mirrored baseline file exists in this fork, link to `open-grok/open-grok` at the pinned revision.

### §7.3 Reference order
Use current Grok source first, Pi primary patterns second, and latest upstream OMP secondary patterns third.

### §7.4 Authority labels
Separate verified facts, local observations, inference, recommendations, proposals, and unresolved questions.

### §7.5 Single document owner
Each subsystem contract has one authoritative document. Other pages link to it rather than restating it.

### §7.6 Upstream provenance is verified
Resolve each named upstream repository, default branch, exact evidence pin, and current head directly; local checkouts do not establish authority or freshness. If upstream rewrites history, preserve the reviewed root and audit the tree-level delta before advancing pins or integrating changes. Never reset or force-replace fork history to follow an unrelated upstream root.

### §7.7 Durable decisions use ADRs and PDRs
Record consequential technical architecture decisions as ADRs and product, project, release, or maintenance-process decisions as PDRs under `docs/decisions/`. Accepted records are superseded by new records rather than rewritten to conceal prior context or trade-offs.

## §8 Tests and verification

### §8.1 Reproduce behavior
Bug fixes require a test or reproducible check that fails before the fix and passes after it.

### §8.2 Focused first
Run focused crate tests/checks before broader suites.

### §8.3 Runtime proof
Product-source changes require an end-to-end exercise of the affected flow when practical.

### §8.4 No warning debt
Completion requires zero new or existing warnings in the changed lint scope.

### §8.5 Failure honesty
Report failed, skipped, unavailable, or inconclusive checks exactly. Do not imply verification that did not run.

## §9 Generated, vendored, and licensed code

### §9.1 Generated ownership
Edit generation inputs, not generated outputs, unless the repository explicitly designates the output as maintained source.

### §9.2 Vendored isolation
Do not casually modify `third_party/`; preserve upstream license and notice requirements.

### §9.3 Apache modification notice
Retain applicable copyright, patent, trademark, attribution, and NOTICE text; mark fork modifications where required.

## §10 Git history

### §10.1 Coherent commits
Each commit should be independently understandable and verified enough to stand on its own.

### §10.2 Conventional subjects
Use Conventional Commit subjects unless superseded by repository policy.

### §10.3 No agent attribution
Do not add AI attribution, generated-by footers, bot co-author trailers, or agent-branded branch/PR metadata.

### §10.4 Upstream clarity
Keep upstream synchronization commits distinguishable from fork-owned product changes.

### §10.5 Upstream change records
Every imported upstream range or reviewed evidence-pin advancement must update the root changelog when user-visible and add an immutable record under `docs/upstream/` with source revisions, comparison status, preserved lineage, included and rejected scope, verification outcomes, integration commit, and follow-ups.

### §10.6 Upstream code synchronizes through isolated pull requests
Prepare code imports on `sync/<source>-<revision>`, include one upstream delta only, require CI and independent review, and merge through protected `main`. Architecture reinterpretation, fork-owned remediation, and unrelated cleanup follow separately.
