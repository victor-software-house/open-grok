# Reference patterns: Pi first, OMP second

This page extracts reusable design laws from pinned references.

It does **not** select the final `open-grok` architecture.

## Reference order

1. Current Grok Build source defines existing behavior.
2. Latest pinned Pi supplies the primary abstraction patterns.
3. Latest pinned upstream OMP pressure-tests those patterns against broader production behavior.
4. Language/runtime differences remain explicit; TypeScript structures are not copied blindly into Rust.

Exact revisions live in [`source-ledger.md`](source-ledger.md).

---

## Pi: primary patterns

### 1. Provider behavior has one owner

Pi’s `Provider` abstraction owns catalog data, credential methods, optional dynamic model refresh, and request streaming; `Models` resolves the selected model/provider and delegates. [`models.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/ai/src/models.ts#L62-L167)

_**Law:** provider-specific behavior should derive from one definition, not parallel maps for login, environment variables, model lookup, and dispatch._

### 2. Authentication interaction is UI-independent

OAuth implementations emit URLs, device codes, progress, prompts, selections, and manual-code requests through `AuthInteraction`. [`auth/types.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/ai/src/auth/types.ts#L113-L155)

_**Law:** the TUI renders auth interaction; provider auth code does not own terminal UI._

### 3. Credential refresh is serialized and explicit

Pi stores one tagged credential per provider, protects the file and directory, uses an interprocess lock, rechecks expiry inside a serialized modification, and persists one refresh result. [`auth-storage.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/src/core/auth-storage.ts#L14-L46) · [`auth/resolve.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/ai/src/auth/resolve.ts#L78-L117)

_**Law:** refresh is a state transition with cross-process coordination, not an incidental retry callback._

### 4. Model catalogs are generated, not handwritten at runtime

Pi’s generator merges models.dev, OpenRouter, and Vercel data into generated provider model files; runtime provider refresh is separate. [`generate-models.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/ai/scripts/generate-models.ts)

The exact generator path above is intentionally commit-pinned; see the repository if GitHub cannot render the large file anchor.

_**Law:** release-time catalog generation and runtime provider discovery are different authority layers._

### 5. Provider protocols normalize into one event/tool contract

Pi models provider/API identity, modalities, reasoning, cost, limits, headers, and compatibility overrides in a serializable `Model` record. [`types.ts`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/ai/src/types.ts#L703-L729)

_**Law:** product surfaces consume normalized capabilities and stream events; provider wire quirks remain below that boundary._

### 6. Documentation is task-oriented and near the owner

Pi’s coding-agent docs index routes first-run, customization, reference, platform, and development tasks to focused pages. [`docs/index.md`](https://github.com/earendil-works/pi/blob/c6d8371521fc8357958bb21fd43552c15f46c7f4/packages/coding-agent/docs/index.md#L39-L82)

_**Law:** one discoverable hub plus focused owner-adjacent pages beats a monolithic architecture essay._

---

## OMP: secondary pressure tests

### 1. Multiple credentials need durable row identity

Latest OMP stores multiple provider credentials in SQLite and routes by stable credential row identity rather than bearer bytes or array position. Session affinity persists against that ID. [`auth-storage.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/ai/src/auth-storage.ts#L1678-L1799)

_**Pressure test:** Pi’s one-credential-per-provider store is insufficient for account selection, rotation, and failover._

### 2. Selection and failure are provider-account concerns

OMP supports deterministic session affinity, round-robin for non-session callers, temporary credential blocking, and optional usage-aware ranking. [`auth-storage.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/ai/src/auth-storage.ts#L1496-L1538) · [`auth-storage.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/ai/src/auth-storage.ts#L1801-L1897)

_**Pressure test:** retries must distinguish transient request failure from account quota/usage exhaustion._

### 3. Refresh needs in-process and cross-process single-flight

OMP refreshes before expiry, single-flights by durable row ID, and uses SQLite leases for cross-process ownership. [`auth-storage.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/ai/src/auth-storage.ts#L2130-L2339)

_**Pressure test:** a file lock around the whole store may be correct but too coarse once multiple accounts and long-lived refresh flows exist._

### 4. Auth identity and model metadata stay separate

OMP’s auth registry and `pi-catalog` are distinct; compile-time checks connect provider IDs without merging responsibilities. [`registry/types.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/ai/src/registry/types.ts#L1-L55)

_**Pressure test:** a provider may share model metadata with another route while requiring different login, account, or transport behavior._

### 5. Catalog resolution has explicit source precedence

OMP’s model manager resolves:

```text
bundled static → models.dev fallback → cache → dynamic provider discovery
```

Later sources override earlier model IDs; authoritative provider discovery may prune static-only entries. [`model-manager.ts`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/catalog/src/model-manager.ts#L104-L174)

_**Pressure test:** availability, metadata enrichment, and provider-authoritative discovery need different merge semantics._

### 6. YAML is an override and custom-provider surface

`models.yml` / `models.yaml` can define custom providers/models, override built-ins, configure discovery and headers, and express model equivalence. [`docs/models.md`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/docs/models.md#L15-L109)

_**Pressure test:** built-ins should work without YAML, while compatible custom endpoints should not require Rust code._

### 7. Documentation maps source to authority

OMP’s development guide names authoritative subsystem documents rather than duplicating their contents. [`DEVELOPMENT.md`](https://github.com/can1357/oh-my-pi/blob/d5cd24f39a951bfbd50dc8f50bcf095d59694d6c/packages/coding-agent/DEVELOPMENT.md#L1-L10)

_**Pressure test:** an architecture dossier needs explicit document ownership or it will drift into multiple competing explanations._

---

## models.dev: metadata, not transport

models.dev exposes provider/model metadata such as:

- identity and family;
- tool/reasoning/structured-output capabilities;
- modalities;
- context/output limits;
- lifecycle status;
- advisory costs.

It does not eliminate provider-specific auth, transport, or compatibility policy. The schema is authoritative in [`schema.ts`](https://github.com/anomalyco/models.dev/blob/d7fd1e1eb96339866dc822b901fad7f5896be7ba/packages/core/src/schema.ts).

_**Law:** external catalog data can own model facts, while the application still owns safe transport and behavior._

## Patterns to reject

- **Do not embed Pi or OMP’s full agent runtime.** Grok already owns the TUI, sessions, tools, compaction, and ACP loop.
- **Do not introduce a Bun sidecar before proving native Rust seams insufficient.** It adds RPC, credential, packaging, cancellation, and version-skew ownership.
- **Do not maintain a hand-curated model list as the primary catalog.** Generate and cache validated external/provider data.
- **Do not make marketplace installation equivalent to provider-code execution.** Preserve explicit trust gates.
- **Do not freeze a public provider plugin ABI in the first implementation phase.** Exercise built-ins and YAML-compatible providers first.
- **Do not conflate private local OMP research with latest upstream OMP behavior.** Only pinned `can1357/oh-my-pi` evidence establishes the secondary precedent.

## Questions this leaves for design

- Which Grok provider/auth seams can be extracted without disturbing session actor ownership?
- Which provider protocols must be first-class Rust implementations for initial parity?
- What is the smallest safe multi-account schema that supports later brokered or remote storage?
- How should bundled models.dev snapshots, runtime models.dev fallback, and provider discovery divide authority?
- Which current xAI headers/patches belong in a first-party Grok adapter rather than generic sampling code?
- What YAML surface supports custom compatible providers without duplicating the compiled provider registry?

Those questions belong in the reviewed design and goal process, not in the current-state baseline.
