# Providers, models, and authentication

Baseline: [`xai-org/grok-build@c1b5909`](https://github.com/victor-software-house/open-grok/tree/c1b5909ec707c069f1d21a93917af044e71da0d7).

This page separates the reusable provider seams from the xAI product assumptions currently carried through them.

## Current provider model

### Protocol and authentication are separate choices

`ApiBackend` selects one compiled wire dialect:

- `chat_completions` → OpenAI Chat Completions;
- `responses` → OpenAI Responses;
- `messages` → Anthropic Messages.

See [`sampling-types/types.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampling-types/src/types.rs#L1010-L1021).

`AuthScheme` separately selects bearer or `x-api-key` request authentication. [`sampler/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/config.rs#L18-L24)

`SamplerConfig` carries:

- base URL and model;
- auth scheme and credentials;
- arbitrary headers;
- API backend;
- retry and timeout controls;
- tool-streaming behavior;
- live bearer resolution.

See [`sampler/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/config.rs#L18-L127).

## Model configuration

A model entry can define:

- routing model ID and display metadata;
- inference and API base URLs;
- literal or environment-resolved credentials;
- auth scheme and API backend;
- context/output limits;
- arbitrary headers;
- retry/idle behavior;
- capability flags and streaming-tool behavior.

This makes arbitrary BYOK endpoints possible when they speak one of the compiled dialects. [`agent/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L3413-L3529)

## Catalog composition

Current precedence is:

1. user `[model.*]` configuration;
2. fetched/remote catalog;
3. embedded defaults.

Global model/header defaults fill missing fields without replacing model-specific values. A configured custom endpoint can suppress bundled defaults. [`agent/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L3105-L3289)

The embedded default catalog is xAI-oriented and derives proxy/API-key base URLs from xAI defaults. [`agent/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L3349-L3410)

## Model selection

`ModelsManager` centralizes:

- allowed/disabled/hidden filters;
- fetched-catalog validation;
- auth-mode availability;
- current/default selection;
- catalog replacement and re-selection.

Default selection priority is:

1. CLI override;
2. `GROK_DEFAULT_MODEL`;
3. config default;
4. remote-settings hint;
5. first visible/bundled fallback.

See [`agent/models.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/models.rs#L1671-L1897).

## Remote discovery

Model discovery can use a custom endpoint, cached session credentials, deployment keys, or `XAI_API_KEY`.

- Custom/API-key discovery calls a configured `/models` endpoint with bearer authentication.
- Session discovery targets the CLI proxy and adds xAI identity headers.
- The parser accepts multiple server field spellings and all three API backends.

See [`remote/client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/remote/client.rs#L675-L852).

Catalog behavior is cache-first and failure-tolerant: failed refresh leaves the existing catalog in place. [`agent/models.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/models.rs#L213-L267) · [`agent/models.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/models.rs#L1052-L1136)

## Credential resolution

For inference, the current model-centric priority is:

1. literal model key or configured environment keys;
2. browser/session token;
3. ambient `XAI_API_KEY`.

A separate API base URL may be chosen for API-key mode. The xAI API-key disable switch can replace an xAI key with the session token while preserving non-xAI/BYOK behavior. [`agent/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L4256-L4361)

## Authentication abstraction

`AuthCredentialProvider` exposes:

- current credential snapshot;
- refresh after `401`;
- header behavior;
- identity metadata.

Static implementations support raw keys and tests. [`auth_provider.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-auth/src/auth_provider.rs#L1-L118)

`AuthManager` owns an in-memory bearer and scoped `auth.json`; refresh is serialized and can adopt a token written by another process. [`auth/manager.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/auth/manager.rs#L120-L202)

## Browser OAuth/OIDC

The login engine is configurable OIDC/OAuth2 with xAI defaults.

- configurable issuer, client ID, and scopes;
- PKCE;
- browser launch;
- loopback callback or pasted-code fallback;
- token exchange and principal enforcement;
- persisted credentials;
- transient refresh retry.

Absent configuration, it defaults to `https://auth.x.ai` and an embedded client ID. [`auth/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/auth/config.rs#L45-L90) · [`oidc/login.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/auth/oidc/login.rs#L347-L501)

## Request construction

The Shell converts model/auth configuration into one homogeneous `SamplerConfig` and injects CLI-proxy-specific headers only for recognized proxy URLs. [`agent/config.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/agent/config.rs#L4591-L4672)

`SamplingClient` then:

- applies generic auth and arbitrary headers;
- resolves a live bearer per request;
- posts to `/chat/completions`, `/responses`, or `/messages`;
- maps provider-specific SSE into normalized events.

See [`sampler/client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/client.rs#L394-L541).

## Generic seams versus xAI coupling

| Reusable seam | Current xAI assumption |
|---|---|
| `ApiBackend` and normalized events | Only three compiled dialects |
| `SamplerConfig`, `AuthScheme`, headers, live bearer | URL classification and proxy-specific header injection |
| Arbitrary model endpoints and catalog merge | Embedded xAI catalog and environment naming |
| `AuthCredentialProvider` and configurable OIDC | xAI issuer/client defaults and first-party restrictions |
| `StorageAdapter` and local JSONL | xAI remote session backend and identity headers |

### Inference coupling inside the sampler

Every request currently applies `x-grok-*` identity/tracking headers.

The Responses path also contains xAI-specific request and response behavior:

| Direction | Behavior |
|---|---|
| **Request** | inject `stream_tool_calls`, raw tools such as `x_search`, and optional doom-loop control headers |
| **Response** | strip tools that the typed decoder cannot parse after deserialization fails, override `usage.total_tokens` from `context_details`, and intercept non-standard doom-loop events |

See [`sampler/client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/client.rs#L81-L113) and [`sampler/client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/client.rs#L1271-L1442).

### Product services outside inference

- Browser/chat modes call xAI-specific `grok.com/rest/modes`. [`chat_models_client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/remote/chat_models_client.rs#L1-L155)
- Optional remote session sync uses xAI `/sessions` endpoints and identity headers. [`remote/client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/remote/client.rs#L278-L549)
- Local JSONL remains authoritative; remote sync is optional writeback. [`storage/mod.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/src/session/storage/mod.rs#L584-L612)

## Retry layers

- Inference retries live in the sampler request task.
- Non-inference HTTP middleware refreshes credentials after `401` and retries cloneable requests.

See [`request_task.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-sampler/src/actor/request_task.rs#L80-L408) and [`retry_middleware.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-auth/src/retry_middleware.rs#L1-L78).

## Current limits

- One active Grok-oriented browser credential store, not a provider/account collection.
- No built-in multi-account selection, rotation, or quota blocking.
- No external model-catalog authority such as models.dev.
- No dynamic provider protocol registration.
- Provider capability metadata is narrower than Pi/OMP references.
- Custom providers are practical only when compatible with an existing wire dialect.

These are verified baseline limits, not yet an approved `open-grok` design.

## Test anchors

- Multi-dialect mocked SSE integration: [`test_sampling_client.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-shell/tests/test_sampling_client.rs#L218-L326)
- Bounded `401` retry: [`retry_middleware.rs`](https://github.com/victor-software-house/open-grok/blob/c1b5909ec707c069f1d21a93917af044e71da0d7/crates/codegen/xai-grok-auth/src/retry_middleware.rs#L81-L272)
- Model/catalog/config tests are colocated in `agent/models.rs`, `agent/config.rs`, and `remote/client.rs`.
