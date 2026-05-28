---
name: chainsafe-rust-developer
description: Idiomatic Rust development at ChainSafe — implementation-level guidance for writing Rust in Forest, Mina-rs, ChainBridge Substrate, and other Rust projects. Use this skill whenever the user is writing Rust, asking how to do something in Rust, debugging Rust, picking between Rust patterns, dealing with errors via thiserror/anyhow, async/Tokio patterns, handling unwrap discipline, writing unsafe with SAFETY comments, testing with proptest or miri, or setting up Rust tooling. EVEN IF the user does not explicitly say "Rust" but the file is .rs. Triggers on "write a Rust function", "implement in Rust", "fix this Rust", "how do I X in Rust", "Tokio async", "Result and ?", "thiserror enum", "anyhow context", "unwrap or expect", "Arc<Mutex>", "spawn_blocking vs spawn", "miri test", "proptest", "cargo clippy", "rustfmt", "cargo.toml". Do NOT use for Rust architectural design (use chainsafe-rust-architect) or Rust PR review (use chainsafe-rust-reviewer).
metadata:
  type: role-workflow
  language: rust
  role: developer
  source: languages/rust/developer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Rust Developer

Idiomatic Rust at ChainSafe. Full reference: [`languages/rust/developer.md`](../../languages/rust/developer.md).

## Tooling baselines

CI gates that must pass:

```sh
cargo fmt --all --check
cargo clippy --all-targets -- -D warnings
cargo build --workspace --all-targets
cargo test --workspace
cargo doc --no-deps
cargo audit
```

For unsafe-heavy crates: also `cargo miri test`.

### Toolchain

Pin with `rust-toolchain.toml`:

```toml
[toolchain]
channel = "1.79.0"
components = ["rustfmt", "clippy"]
```

### Dependencies

- `Cargo.lock` committed for binaries; not for libraries published to crates.io.
- `cargo audit` in CI.
- `cargo deny` for license/source/version policy.
- Workspace-level dependency declarations to keep versions consistent.

## Error handling

```rust
use anyhow::{Context, Result};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum StoreError {
    #[error("key not found: {0}")]
    NotFound(String),
    #[error("backend failure")]
    Backend(#[from] BackendError),
}

pub fn fetch(key: &str) -> Result<Data> {
    let raw = read_backend(key).with_context(|| format!("reading {key}"))?;
    parse(&raw).context("parsing value")
}
```

- **Library crates:** typed `thiserror` errors.
- **Binary crates:** `anyhow::Result<T>`.
- **`?` propagation.** Match only when transforming.

## `unwrap` and `expect`

- **In tests:** fine.
- **In production code:** require a `// SAFETY: ...` comment justifying the invariant.
- **`expect("...")` over `unwrap()`** when you do use it — message helps debugging.

## Async

- `#[tokio::main]` only in binaries.
- `async fn` in trait is stable as of 1.75; older crates use `async-trait`.
- `.await` propagates cancellation — hold no critical invariant across an `.await`.
- `spawn` for async; `spawn_blocking` for CPU-bound. Mixing them up starves the runtime.
- `Send + Sync + 'static` bounds on spawned tasks.

## Unsafe

Every `unsafe` block:

- `// SAFETY: ...` comment immediately above, explaining soundness.
- Justification for choosing `unsafe` over safe alternatives.
- `miri` test where possible.

Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) treats `unsafe` as security-relevant. Expect HARD-FAIL-tier review scrutiny on PRs introducing it.

## Testing

- Unit tests in `#[cfg(test)] mod tests { ... }`.
- Integration tests in `tests/`.
- `#[tokio::test]` for async tests; `flavor = "multi_thread"` for parallel.
- `proptest` for parsers, serializers, math, crypto.
- `cargo nextest` for faster CI runs.
- `miri` for unsafe code.

## Patterns

- **Type-state when the protocol allows it.** Encode "must call A before B" in the type system.
- **Newtypes for domain types.** `pub struct UserId(u64)`.
- **`From` / `TryFrom`** for conversions over inherent `to_*` methods.
- **`Deref` only for smart pointers** — don't fake inheritance.

## Anti-patterns

- `unwrap()` in production paths without `// SAFETY: ...`.
- `Box<dyn Error>` returns when you could be specific.
- `async fn` that doesn't `.await` anything.
- `Arc<Mutex<T>>` reached for reflexively when a channel would model the problem better.
- `unsafe` without a soundness comment.
- Public API leaking tokio types without a feature flag.

## Related

- Full reference: [`languages/rust/developer.md`](../../languages/rust/developer.md)
- Idioms: [`languages/rust/idioms.md`](../../languages/rust/idioms.md)
- Gotchas: [`languages/rust/gotchas.md`](../../languages/rust/gotchas.md)
- Sister roles: `chainsafe-rust-architect`, `chainsafe-rust-reviewer`
- Forest AI policy: https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md
