---
title: Rust Architect
status: draft (v2)
authors:
  - "@kalambet"
language: rust
role: architect
last_updated: 2026-05-27
---

# Rust Architect

Architectural guidance for Rust projects at ChainSafe — notably [Forest](https://github.com/ChainSafe/forest) (Filecoin), [Mina-rs](https://github.com/ChainSafe/mina-rs), [ChainBridge Substrate](https://github.com/ChainSafe/chainbridge-substrate), and others. The architectural framework lives in `.invariance` (see the [pointer page](../../10-invariants/invariance-framework.md)); this page covers Rust-specific shaping.

> **In one line:** Errors are typed. Ownership is explicit. Async runtime is a library choice, not a default. Use the type system instead of comments.

## Defer to `.invariance` for

| Decision | `.invariance` section |
|---|---|
| Service boundaries and contracts | Component contracts *[anchor pending]* |
| Invariant naming and testability | Invariant lifecycle *[anchor pending]* |
| Cross-component failure modes | Failure-mode invariants *[anchor pending]* |
| Memory and ownership invariants | Ownership/lifetime invariants *[anchor pending]* |

## Rust-specific architectural choices

### Project layout

ChainSafe Rust projects use Cargo workspaces for multi-crate projects (Forest is the canonical example):

- `Cargo.toml` at the root declares workspace members.
- Crates split by concern: one for the network layer, one for storage, one for the binary, one per protocol module.
- A `bin/` crate for the executable, a `lib/` crate for the consumable API, others for internals.
- Workspace-level dependency hoisting where possible to keep versions consistent.

### Error model

- **`thiserror` for libraries, `anyhow` for binaries.** Library crates expose typed errors (`#[derive(thiserror::Error)]`) so callers can match; binaries that just need to propagate use `anyhow::Result`.
- **No `unwrap()` / `expect()` in production paths.** Either handle the error or document the invariant that makes it impossible. Tests are an exception.
- **`?` for propagation.** Don't write match arms for the trivial pass-through case.
- **Error context.** Use `anyhow::Context` or a typed `.with_context(...)` extension to add context as errors bubble.

### Async runtime

- **Pick one.** Tokio for most ChainSafe projects (including Forest). Don't mix tokio and async-std in the same workspace.
- **`#[tokio::main]` only in the binary crate.** Library crates stay runtime-agnostic where possible — they take a runtime handle or are runtime-generic via traits.
- **Bounded concurrency.** `FuturesUnordered` with limits, `tokio::sync::Semaphore`, or `buffer_unordered` on streams. Unbounded futures spawning is a leak.
- **`Send + Sync` and `'static` bounds** — design types so they meet the bounds Tokio's `spawn` requires.

### Concurrency primitives

- **`Arc<Mutex<T>>`** for shared mutable state across tasks. `Arc` for shared ownership, `Mutex` for synchronization.
- **`tokio::sync::Mutex` vs `std::sync::Mutex`.** Tokio mutex when locks span `await` points; std mutex when they don't.
- **Channels:** `tokio::sync::mpsc` for many-to-one, `broadcast` for one-to-many, `oneshot` for single-response.
- **No `std::thread::spawn` in async code.** Use `tokio::task::spawn` or `tokio::task::spawn_blocking` for genuinely-CPU-bound work.

### Public API

- **`pub(crate)` is the default visibility for new items.** `pub` is a contract.
- **`#[non_exhaustive]`** on enums and structs you want to be able to extend without semver breakage.
- **Builder pattern** for complex constructors. The standard library's `std::process::Command` is a model.
- **No leaking `tokio::` types in library APIs.** Use abstract bounds or feature-gate.

## ADR shape for Rust crates

When opening an ADR for a Rust crate, the template should cover:

- **Public surface.** What's `pub`, what's `pub(crate)`, what's private. Why.
- **Error type.** Typed (`thiserror`) or pass-through (`anyhow`). Justify.
- **Async commitments.** Which runtime, where the runtime is required, how the crate's API is shaped around async.
- **Unsafe code.** If any `unsafe { }` is involved, justify the soundness argument and the safety invariants the caller must uphold.
- **Invariants impacted.** Deep links into `.invariance`.

## Anti-patterns

- **`unwrap()` in non-test code** without an `// SAFETY: ...` style comment justifying why the invariant holds.
- **`Box<dyn Error>` as a function's return type** when you could be specific. Use it only at boundaries.
- **`String` everywhere when `&str` would do.** Allocations have a cost; types tell the caller about ownership.
- **`tokio` types leaked through public APIs of library crates** without feature flags.
- **`unsafe` without a soundness comment.** Every `unsafe` block needs a justification.

## Related

- [`developer.md`](./developer.md) — implementation-level Rust practice.
- [`reviewer.md`](./reviewer.md) — what to look for in a Rust PR.
- [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — Filecoin/Forest-specific AI norms; informs Rust review at ChainSafe.
- [`../../10-invariants/invariance-framework.md`](../../10-invariants/invariance-framework.md) — architectural framework this page defers to.
