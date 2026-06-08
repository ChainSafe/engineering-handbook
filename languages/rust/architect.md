# Rust Architect

Architectural guidance for Rust projects at ChainSafe — notably [Forest](https://github.com/ChainSafe/forest) (Filecoin), [Mina-rs](https://github.com/ChainSafe/mina-rs), [ChainBridge Substrate](https://github.com/ChainSafe/chainbridge-substrate), and others. The architectural framework lives in `.invariants` (see the [pointer page](../../invariants/invariants-framework.md)); this page covers Rust-specific shaping.

> **In one line:** Errors are typed. Ownership is explicit. Async runtime is a library choice, not a default. Use the type system instead of comments.

## Defer to `.invariants` for

| Decision | `.invariants` section |
|---|---|
| Service boundaries and contracts | Component contracts |
| Invariant naming and testability | Invariant lifecycle |
| Cross-component failure modes | Failure-mode invariants |
| Memory and ownership invariants | Ownership/lifetime invariants |

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

### Static vs. dynamic dispatch

Generics versus trait objects is an architectural choice, not a style one ([Effective Rust Item 12](https://effective-rust.com/generics.html)):

- **Generics / `impl Trait` — static dispatch.** Monomorphized: fastest at runtime, no indirection. The default, and the right call on hot paths (consensus, crypto, serialization). The cost is code bloat and compile time when over-used.
- **`dyn Trait` — dynamic dispatch.** One vtable, smaller binary, a pointer indirection per call. Reach for it at plugin boundaries, for heterogeneous collections (`Vec<Box<dyn Trait>>`), or to cut monomorphization bloat. Needs an object-safe trait.

Default to generics; choose `dyn` deliberately, not reflexively.

### API stability and evolution

A `pub` item is a versioning contract; treat the public surface as SemVer-governed ([Effective Rust Items 21–24](https://effective-rust.com/semver.html)):

- **Know what breaks.** Removing or renaming a `pub` item, or adding a field to a struct callers construct, is a breaking change; adding a method or a `#[non_exhaustive]` variant is not.
- **`#[non_exhaustive]`** on public enums and structs you expect to grow.
- **Re-export dependency types that appear in your public API** (`pub use dep::Handle`) — otherwise callers can't name the type without pinning the same dependency version (Item 24).
- **Seal traits** you don't want implemented downstream (a private supertrait), so methods can be added later without breaking implementors.
- **Boundaries.** Crates targeting WASM or embedded stay `no_std`-compatible where practical; FFI surfaces stay narrow and are generated with `bindgen` / `cbindgen`, not hand-mapped (Items 33–35).

## ADR shape for Rust crates

When opening an ADR for a Rust crate, the template should cover:

- **Public surface.** What's `pub`, what's `pub(crate)`, what's private. Why.
- **Public-API stability.** The SemVer guarantees the crate makes; `#[non_exhaustive]` use; which dependency types are re-exported.
- **Dispatch strategy.** Where the crate uses generics vs. `dyn Trait`, and why.
- **Error type.** Typed (`thiserror`) or pass-through (`anyhow`). Justify.
- **Async commitments.** Which runtime, where the runtime is required, how the crate's API is shaped around async.
- **Unsafe code.** If any `unsafe { }` is involved, justify the soundness argument and the safety invariants the caller must uphold.
- **Invariants impacted.** Deep links into `.invariants`.

## Anti-patterns

- **`unwrap()` in non-test code** without an `// SAFETY: ...` style comment justifying why the invariant holds.
- **`Box<dyn Error>` as a function's return type** when you could be specific. Use it only at boundaries.
- **`String` everywhere when `&str` would do.** Allocations have a cost; types tell the caller about ownership.
- **`tokio` types leaked through public APIs of library crates** without feature flags.
- **`unsafe` without a soundness comment.** Every `unsafe` block needs a justification.
- **Undocumented public items.** A `pub` item with no `///` doc comment ships an unexplained contract.
- **`dyn Trait` in a hot-path signature** chosen by default rather than measured.
- **Overengineering.** Reaching for a trait, macro, generic, or `unsafe` before a plain function would do, or optimizing before profiling — the "four horsemen" of bad Rust. Prefer the simplest construct that *still honors the idioms in this guide* — simple, not simplistic. Simplicity is never a license to erase intent: a named enum or newtype still beats a fistful of `bool`/`String` parameters ([`idioms.md`](./idioms.md)).

## Related

- [`developer.md`](./developer.md) — implementation-level Rust practice.
- [`reviewer.md`](./reviewer.md) — what to look for in a Rust PR.
- [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — Filecoin/Forest-specific AI norms; informs Rust review at ChainSafe.
- [`../../invariants/invariants-framework.md`](../../invariants/invariants-framework.md) — architectural framework this page defers to.
- [Effective Rust](https://effective-rust.com/) (Drysdale) and [The Rust Book](https://doc.rust-lang.org/book/) — the canonical practice references this section builds on; cataloged in [`sources.md`](../../references/sources.md).
- [Idiomatic Rust](https://github.com/mre/idiomatic-rust) (peer-reviewed corpus) and the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) — idiomatic-Rust principles and API conventions.
