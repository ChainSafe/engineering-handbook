# Rust Developer

Idiomatic Rust development at ChainSafe. Tooling, formatting, lint, testing, dependency hygiene, the patterns that show up in review.

> **In one line:** `cargo fmt --check` and `cargo clippy -D warnings` are the floor. `unwrap()` outside tests is a smell. `unsafe` requires a soundness comment.

## Tooling

### Formatting and lint

```sh
cargo fmt --all --check        # must pass without diffs
cargo clippy --all-targets -- -D warnings  # must pass without errors
```

These are CI gates. Failing locally is a sign of a missing pre-commit hook.

Per-project `rustfmt.toml` and `clippy.toml` configure the defaults. The defaults are good; deviate only when there's a real reason.

### Toolchain

Pin the toolchain with `rust-toolchain.toml` at the repo root:

```toml
[toolchain]
channel = "1.79.0"          # or "stable", with a CI-pinned version
components = ["rustfmt", "clippy"]
```

Pinned channels keep CI deterministic. Floating to `stable` is fine for libraries but risky for binaries.

### Dependencies

- `Cargo.lock` committed for binaries; **not** committed for libraries published to crates.io.
- `cargo update` with care; pin minor versions for cryptography / consensus dependencies where a quiet breakage is expensive.
- `cargo audit` in CI for known-vulnerability scanning.
- `cargo deny` for license, source, and version-control policy.
- For workspaces: workspace-level dependency declarations to keep versions consistent across crates.

### IDEs

Whatever you prefer that gives you `rust-analyzer`. The legacy guide enumerates options (CLion, VSCode, Sublime, Lapce, Helix, Vim, Emacs). The choice doesn't matter; the LSP integration does.

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

- **Library crates:** typed errors via `thiserror`. Callers match on variants.
- **Binary crates:** `anyhow::Result<T>` for ergonomics. Add context as errors bubble.
- **`?` for propagation.** Match arms only when you need to inspect or transform.
- **`Result<(), E>` over `bool`** when a function can fail informatively.

## `unwrap` and `expect`

- **In tests:** fine. The test panics; that's the signal.
- **In production code:** require a justification. Pattern:
  ```rust
  // SAFETY: validated by caller; see Foo::new's invariant.
  let value = self.field.as_ref().expect("invariant: field set in Foo::new");
  ```
- **`expect("...")` over `unwrap()`** when you do use it — the message helps debug.

## Async

- **`#[tokio::main]`** only in binaries.
- **`async fn` in trait** is stable as of 1.75; older crates use `async-trait`. Pick one consistently.
- **`.await` propagates cancellation.** Tasks dropped between `await` points run their destructors, not the suspended code. Hold no critical invariant across an `.await`.
- **`spawn` vs `spawn_blocking`.** `spawn` for async work, `spawn_blocking` for CPU-bound or sync-blocking work. Mixing them up starves the runtime.
- **`Send + Sync + 'static`** bounds on spawned tasks — design types that meet them.

## Unsafe

`unsafe { }` is permitted but expensive. Every `unsafe` block needs:

- A `// SAFETY: ...` comment immediately above, explaining why the operation is sound.
- A justification for choosing `unsafe` over a safe alternative.
- A test that exercises the path under `miri` if at all possible.

Forest's reviewer norms (see [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md)) treat `unsafe` as security-relevant. Expect HARD-FAIL-tier scrutiny on PRs introducing it.

## Testing

- **Unit tests** in `#[cfg(test)] mod tests { ... }` at the bottom of the module.
- **Integration tests** in `tests/` at the crate root, exercising the public API.
- **`#[tokio::test]`** for async tests; pick the appropriate flavor (`flavor = "multi_thread"`) for tests that need real parallelism.
- **Property-based tests via `proptest`** for parsers, serializers, math, and crypto.
- **`miri`** in CI for unsafe code; catches UB at the test level.
- **`cargo nextest`** for faster test runs in CI.

## CI

Baseline (extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md)):

- `cargo fmt --all --check`
- `cargo clippy --all-targets -- -D warnings`
- `cargo build --workspace --all-targets`
- `cargo test --workspace`
- `cargo doc --no-deps` (catches broken doc links)
- `cargo audit`
- For unsafe-heavy crates: `cargo miri test`

## Patterns that come up in review

- **Type-state when the protocol allows it.** Encoding "must call A before B" in the type system is better than a runtime check.
- **Newtypes for domain types.** `pub struct UserId(u64)` keeps a `UserId` from being confused with a `OrderId`.
- **`From` / `TryFrom` for conversions** rather than inherent `to_*` methods.
- **`Deref` only for smart pointers.** Don't lean on `Deref` to fake inheritance.
- **No `String` in error variants** unless you genuinely have an open set; `&'static str` or typed payload is usually better.

## Anti-patterns

- **`unwrap()` in production paths** without `// SAFETY: ...`.
- **`Box<dyn Error>` returns** when you could be specific.
- **`async fn` that doesn't `.await` anything.** Probably should be a sync function.
- **`Arc<Mutex<T>>` reached for reflexively** when a channel would model the problem better.
- **`unsafe` without a soundness comment.**
- **Public API leaking tokio types** without a feature flag.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md) — broader testing posture; the Forest/Ghostty pattern lands here.
- Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — Filecoin-specific AI norms.
