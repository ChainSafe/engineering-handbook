---
name: chainsafe-rust-architect
description: Architectural guidance for designing Rust crates and systems at ChainSafe (Forest, Mina-rs, ChainBridge Substrate, PINT, other Rust projects). Use this skill whenever the user is starting a new Rust crate, designing a Rust workspace, choosing an async runtime, picking an error model, deciding `unsafe` usage, structuring a Cargo workspace, deciding `pub` vs `pub(crate)`, picking concurrency primitives, or writing an ADR for Rust work. EVEN IF the user does not explicitly say "architecture" — triggers on "design a Rust crate", "new Rust workspace", "Forest module design", "thiserror or anyhow", "async runtime choice", "Tokio vs async-std", "Arc<Mutex<T>> or channel", "public API surface", "is unsafe justified here", "ADR for Rust", "non_exhaustive enum", "workspace layout". Defers to .invariance for invariants themselves; covers what Rust changes about applying them. Do NOT use for line-level Rust coding (use chainsafe-rust-developer) or Rust PR review (use chainsafe-rust-reviewer).
metadata:
  type: role-workflow
  language: rust
  role: architect
  source: languages/rust/architect.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Rust Architect

Use this when designing Rust systems at ChainSafe — Forest-shaped work or any Rust crate/library/binary. Full reference: [`languages/rust/architect.md`](../../languages/rust/architect.md).

## Key Rust-specific decisions

### Workspace layout

ChainSafe Rust projects use Cargo workspaces (Forest is the canonical example):

- Root `Cargo.toml` declares workspace members.
- Crates split by concern (network, storage, binary, protocol modules).
- A `bin/` crate for the executable; a `lib/` crate for the consumable API.
- Workspace-level dependency hoisting where possible.

### Error model

- **`thiserror` for library crates.** Typed errors callers can match via `#[derive(thiserror::Error)]`.
- **`anyhow` for binary crates.** Pass-through errors with `.context(...)` for ergonomics.
- **No mixing** within a single crate without reason.
- **`?` for propagation.** No `match` arms on trivial pass-through.

### Async runtime

- **Pick one.** Tokio for most ChainSafe work (Forest included). Don't mix tokio and async-std in the same workspace.
- **`#[tokio::main]` only in the binary crate.** Library crates stay runtime-agnostic where possible.
- **Bounded concurrency:** `FuturesUnordered` with limits, `tokio::sync::Semaphore`, `buffer_unordered` on streams. Unbounded futures-spawn is a leak.
- **`Send + Sync + 'static` bounds** — design types so they meet what `tokio::spawn` requires.

### Concurrency primitives

- **`Arc<Mutex<T>>`** for shared mutable state across tasks. `tokio::sync::Mutex` when locks span `.await`; `std::sync::Mutex` when they don't.
- **Channels:** `mpsc` for many-to-one, `broadcast` for one-to-many, `oneshot` for single-response.
- **No `std::thread::spawn` in async code.** Use `tokio::task::spawn` or `tokio::task::spawn_blocking`.

### Public API

- **`pub(crate)` is the default.** `pub` is a versioning commitment.
- **`#[non_exhaustive]`** on enums and structs that may grow.
- **Builder pattern** for complex constructors.
- **No leaking tokio types in library APIs** unless feature-gated.

### Unsafe

- Every `unsafe` block needs a `// SAFETY: ...` comment with the soundness argument.
- Justification beyond "performance."
- `miri` testing path when possible.
- Minimized — wrap the smallest possible code in `unsafe { }`.

## ADR template for Rust work

- Public surface — `pub` vs `pub(crate)` vs private. Justify.
- Error type — `thiserror` or `anyhow`. Justify.
- Async commitments — which runtime, where required, how the API is shaped.
- Unsafe — if any, the soundness argument and safety invariants.
- Invariants impacted — deep links into `.invariance`.

## Anti-patterns at design time

- `unwrap()` in non-test code without `// SAFETY: ...`.
- `Box<dyn Error>` as a function's return type when you could be specific.
- `String` everywhere when `&str` would do.
- Tokio types leaked through public APIs of library crates without feature flags.
- `unsafe` without a soundness comment.

## Forest-specific

Forest carries [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) which sets the security-critical posture for AI-assisted work in a Filecoin client. Architectural decisions on Forest follow that policy — review-time the Rust reviewer skill will enforce.

## Related

- Full reference: [`languages/rust/architect.md`](../../languages/rust/architect.md)
- Sister roles: `chainsafe-rust-developer`, `chainsafe-rust-reviewer`
- Framework: [`invariants/invariance-framework.md`](../../invariants/invariance-framework.md)
- Workflow: `chainsafe-research-plan-implement`
- Upstream: [Effective Rust](https://effective-rust.com/) · [The Rust Book](https://doc.rust-lang.org/book/)
