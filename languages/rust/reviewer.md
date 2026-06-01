# Rust Reviewer

Language-specific checklist when reviewing a Rust PR. Operates under the [universal review principles](../../workflows/code-review.md#universal-principles).

> **In one line:** Lint clean, no `unwrap()` outside tests, no `unsafe` without soundness, no `tokio` leaking into library APIs. SOFT WARNING in general; `unsafe` gets near-HARD scrutiny.

## Severity tier

Per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27), Rust reviewer findings emit as **SOFT WARNING** by default. **`unsafe` blocks promote to near-HARD-FAIL scrutiny** per Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — security-critical, requires explicit operator review beyond the agent reviewer.

## What to look for

### Errors and panics

- **No `unwrap()` / `expect()` in production paths** without a `// SAFETY: ...` comment justifying the invariant. Test code is exempt.
- **Typed errors via `thiserror`** in library crates; `anyhow::Result` in binaries. Mixing the patterns in one crate is a smell.
- **`?` propagation** instead of match-on-trivial-pass-through.
- **Errors carry context.** `.context(...)` / `.with_context(...)` calls preserve the chain.
- **No `unimplemented!()` / `todo!()` / `panic!()` in production paths.** If the work isn't done, the PR isn't ready.

### Unsafe

- **Every `unsafe` block has a `// SAFETY: ...` comment.** Missing → HARD-FAIL-equivalent; the reviewer refuses to approve.
- **The justification is real.** "Performance" alone is not a soundness argument; cite the invariants and what makes them hold.
- **`miri` testing path exists** for the unsafe code (if the project's CI supports it). If not, flag as a risk.
- **The unsafe is minimized.** Wrap the smallest possible code in `unsafe { }`; the safe wrapper should be obvious.

### Async

- **`async fn` actually awaits.** A function declared async that doesn't `.await` is probably sync in disguise.
- **No `Send`/`Sync` violations in spawn boundaries.** `tokio::spawn(future)` requires `Send + 'static`; verify.
- **`.await` does not span a critical invariant.** Holding a non-cancellation-safe state across an `.await` is a bug.
- **`spawn` vs `spawn_blocking`.** CPU-bound work in `spawn` starves the runtime; flag.
- **No unbounded `FuturesUnordered` / `JoinSet`** for inputs of unknown size. Use `buffer_unordered` or a semaphore.

### API design

- **`pub(crate)` is the default.** New `pub` items should be justified. Public API is a versioning commitment.
- **`#[non_exhaustive]`** on enums and structs that may grow. Forgetting this locks the crate into a breaking-change cycle.
- **No `tokio::` types in public library APIs** unless feature-gated.
- **Newtypes for domain values.** Bare `u64` or `String` crossing module boundaries is a smell if a newtype would communicate intent.

### Concurrency primitives

- **`Arc<Mutex<T>>` reflex check.** Could a channel model this? An immutable type? An `Arc<T>` without the mutex? Often yes.
- **`std::sync::Mutex` vs. `tokio::sync::Mutex`.** Locks that span `await` need the tokio mutex.
- **No `.lock().unwrap()` chains** without a comment on why poisoning is impossible (or how it's handled).

### Tests

- **Tests exist for the change.** The legacy guide and the [testing-and-qa](../../workflows/testing-and-qa.md) page apply: agent-authored tests need the same scrutiny as agent-authored code.
- **Mocks are minimal.** Mock-heavy unit tests asserting "was called" rather than behavior are theatre.
- **Property tests via `proptest`** for code with formal invariants (parsing, serialization, math, crypto).
- **`miri` tests for unsafe.** Where applicable.

### Lint and formatting

- **`cargo fmt --check`** clean.
- **`cargo clippy -D warnings`** clean.
- **No `#[allow(...)]`** without a comment explaining why.
- **`cargo doc --no-deps`** builds (no broken doc links).

### Dependencies

- **No new unjustified dependencies.** Each new crate in `Cargo.toml` is a supply-chain decision.
- **License compatibility.** GPL incursions into Apache 2.0–licensed crates are blocking.
- **`cargo audit` clean.** No known vulnerabilities introduced.

## What to flag vs. fix in place

- **Flag**: `unsafe` soundness, panic-vs-error decisions, async design, public API extensions, dependency additions, lint suppressions.
- **Suggest with code suggestion**: trivial fmt-clippy issues that CI didn't catch, doc-link typos.
- **Don't fix and push** unless the operator has authorized co-authorship.

## When the reviewer skill refuses to review

- Diff contains code in a language other than Rust.
- PR description is empty.
- Diff touches code out of session scope.
- **Diff introduces `unsafe` and the PR description doesn't justify it.** Refuse and escalate to the CODEOWNER.

## Phrasing

- Lead with the concern: "This `unsafe` block transmutes between repr-C and a Rust struct; the SAFETY comment cites layout, but the layout is `repr(Rust)` and not guaranteed. What's the actual soundness argument?"
- Cite Forest's AI policy when relevant.
- `nit:` for taste-level.

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md) — universal review framework.
- [`../../invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings) — HARD FAIL semantics; `unsafe` promotes here.
- Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) — the Filecoin-specific extension.
