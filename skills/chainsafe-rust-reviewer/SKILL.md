---
name: chainsafe-rust-reviewer
description: Language-specific PR review for Rust code at ChainSafe (Forest, Mina-rs, ChainBridge Substrate, other Rust projects). Use this skill whenever the user is reviewing a Rust PR, asking for Rust code review, checking Rust code for common mistakes, verifying a Rust diff against ChainSafe conventions, looking for unwrap misuse, unsafe soundness, async pitfalls (mutex-across-await, missing Send/Sync), error-handling issues, or public-API problems. EVEN IF the user does not explicitly ask for "Rust review" — triggers on "review this Rust PR", "is this Rust correct", "check this Rust function", "look for issues in this Rust", "review the diff", "what's wrong with this Rust", "unsafe review", "Tokio review". Findings emit at SOFT WARNING by default; `unsafe` blocks promote to near-HARD-FAIL scrutiny per Forest's AI_POLICY. Do NOT use for Rust design (use chainsafe-rust-architect) or Rust implementation guidance (use chainsafe-rust-developer).
metadata:
  type: role-workflow
  language: rust
  role: reviewer
  severity-tier: SOFT WARNING (unsafe promotes to near-HARD-FAIL)
  source: 30-languages/rust/reviewer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Rust Reviewer

Reviewer skill for Rust PRs. Universal review framework at [`20-workflows/code-review.md`](../../20-workflows/code-review.md); full Rust-specific reference at [`30-languages/rust/reviewer.md`](../../30-languages/rust/reviewer.md).

## Severity tier

**SOFT WARNING by default.** `unsafe` blocks promote to **near-HARD-FAIL** scrutiny per Forest's [`AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md). Refuse to LGTM `unsafe` without a `// SAFETY:` comment.

## Checklist

### Errors and panics

- No `unwrap()` / `expect()` in production paths without `// SAFETY: ...`. Test code exempt.
- Typed errors (`thiserror`) in library crates; `anyhow::Result` in binaries. No mixing without reason.
- `?` propagation; no match-on-trivial-pass-through.
- Errors carry context (`.context(...)`).
- No `unimplemented!()` / `todo!()` / `panic!()` in production paths.

### Unsafe (near-HARD-FAIL)

- **Every `unsafe` block has a `// SAFETY: ...` comment.** Missing → refuse to LGTM.
- Justification is real (not just "performance").
- `miri` testing path exists if the project supports it.
- The unsafe is minimized — smallest possible `unsafe { }` block.

### Async

- `async fn` actually awaits something.
- `Send`/`Sync` met for `tokio::spawn` boundaries.
- `.await` doesn't span a critical invariant.
- `spawn` vs `spawn_blocking` — CPU-bound work in `spawn` starves the runtime.
- No unbounded `FuturesUnordered` / `JoinSet`.

### API design

- `pub(crate)` is the default; new `pub` items deliberate.
- `#[non_exhaustive]` on enums and structs that may grow.
- No tokio types in public library APIs unless feature-gated.
- Newtypes for domain values.

### Concurrency primitives

- `Arc<Mutex<T>>` reflex — could a channel model this better?
- `std::sync::Mutex` vs `tokio::sync::Mutex` — async paths need the tokio variant.
- No `.lock().unwrap()` chains without a comment on poisoning.

### Tests

- Tests exist for the change.
- Mocks are minimal — not "was called" theatre.
- Property tests via `proptest` for code with formal invariants.
- `miri` for unsafe.

### Lint and formatting

- `cargo fmt --check` clean.
- `cargo clippy -D warnings` clean.
- No `#[allow(...)]` without a comment.
- `cargo doc --no-deps` builds.

### Dependencies

- No unjustified new crates.
- License compatibility (GPL into Apache 2.0 is blocking).
- `cargo audit` clean.

## Refusal

The reviewer skill refuses to review and escalates if:

- Diff contains non-Rust code.
- PR description is empty.
- Diff touches code out of session scope.
- **Diff introduces `unsafe` and the PR description doesn't justify it.** Refuse and escalate to CODEOWNER.

## Phrasing

- Lead with concern: "This `unsafe` block transmutes between repr-C and a Rust struct; the SAFETY comment cites layout, but the layout is `repr(Rust)` and not guaranteed."
- Cite Forest's AI_POLICY when relevant.
- `nit:` for taste-level.

## Related

- Full reference: [`30-languages/rust/reviewer.md`](../../30-languages/rust/reviewer.md)
- Gotchas: [`30-languages/rust/gotchas.md`](../../30-languages/rust/gotchas.md)
- Universal review: [`20-workflows/code-review.md`](../../20-workflows/code-review.md)
- Sister roles: `chainsafe-rust-architect`, `chainsafe-rust-developer`
- Forest AI policy: https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md
