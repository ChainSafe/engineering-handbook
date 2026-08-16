---
name: chainsafe-zig-reviewer
description: Language-specific PR review for Zig code at ChainSafe (lodestar-z — consensus-critical Zig: SSZ, hashTreeRoot, Merkleization, hashing). Use this skill whenever the user is reviewing a Zig PR, asking for Zig code review, checking Zig for common mistakes, verifying a Zig diff against ChainSafe conventions, looking for allocator/leak issues, missing defer/errdefer, swallowed errors, undefined behavior, unjustified @setRuntimeSafety(false) or @ptrCast, integer-overflow bugs, or consensus-correctness gaps. EVEN IF the user does not explicitly ask for "Zig review" — triggers on "review this Zig PR", "is this Zig correct", "check this Zig function", "review the diff", "memory leak review", "undefined behavior check", "SSZ correctness", "allocator review". Findings emit at SOFT WARNING by default; memory-safety/UB and consensus-correctness paths promote to near-HARD-FAIL scrutiny. Do NOT use for Zig design (use chainsafe-zig-architect) or Zig implementation guidance (use chainsafe-zig-developer).
metadata:
  type: role-workflow
  language: zig
  role: reviewer
  severity-tier: SOFT WARNING (memory-safety + consensus paths promote to near-HARD-FAIL)
  source: languages/zig/reviewer.md
  authored-via: anthropic-skills:skill-creator (2026-06-01)
---

# Zig Reviewer

Reviewer skill for Zig PRs. Universal review framework at [`workflows/code-review.md`](../../workflows/code-review.md); full Zig-specific reference at [`languages/zig/reviewer.md`](../../languages/zig/reviewer.md).

## Severity tier

**SOFT WARNING by default.** Two surfaces **promote to near-HARD-FAIL** — the reviewer stops and a human must engage:

1. **Memory-safety / undefined-behavior surface** — `@setRuntimeSafety(false)`, `@ptrCast` / `@alignCast`, raw many-item pointer arithmetic, `catch unreachable` on fallible ops, reliance on ReleaseFast semantics.
2. **Consensus-correctness surface** — SSZ encode/decode, `hashTreeRoot`, Merkleization. A byte wrong here is a fork, not a bug.

Mirrors how Rust's `unsafe` is treated: the language allows it, the reviewer demands justification.

## Checklist

### Memory and allocators

- Every allocation has a paired `defer` / `errdefer` free at the acquire.
- Allocator is injected, not global. Ownership across returns and the C ABI is clear.
- No leaks — `std.testing.allocator` stays green. Allocator choice fits the lifetime.

### Errors

- No swallowed error unions — every `!T` is `try`-propagated, `catch`-handled, or exhaustively `switch`ed.
- `errdefer` unwinds partial construction correctly.
- `catch unreachable` only where success is a real invariant (near-HARD on fallible I/O).

### Undefined behavior and safety

- `@setRuntimeSafety(false)` justified and scoped (unscoped/unexplained → near-HARD).
- Integer-overflow intent explicit (`+%` / `+|` / `@addWithOverflow`); otherwise overflow impossible or handled.
- `@ptrCast` / `@alignCast` sound — alignment honored, target layout guaranteed. No reading `undefined`; no reliance on ReleaseFast eliding checks.

### Comptime · C ABI

- Comptime surfaces minimal and documented; no comptime where runtime fits.
- Exported surface stable; cross-boundary memory ownership documented; null/optional handled at the boundary.

### Consensus correctness (lodestar-z and similar)

- Spec-test coverage for SSZ / Merkleization / hashing changes, against the Ethereum consensus spec.
- Fuzz coverage for serializers; determinism (endianness explicit, no floats on consensus paths).

### Tests, lint, format

- Test blocks exist; `std.testing.allocator` used so leaks fail. `zig fmt --check` clean.

## Refusal

The reviewer skill refuses to review and escalates if:

- The diff contains non-Zig code.
- The PR description is empty.
- The diff touches code out of session scope.
- **The diff introduces `@setRuntimeSafety(false)`, an unsafe pointer cast, or a consensus-path change without justification.** Refuse and escalate to the CODEOWNER.

## Phrasing

- Lead with the concern: "This `@ptrCast` reinterprets `[]u8` as `[]u32`; the SAFETY note cites length but not alignment — what guarantees 4-byte alignment?"
- Cite the spec for consensus findings.
- `nit:` for taste-level.

## Related

- Full reference: [`languages/zig/reviewer.md`](../../languages/zig/reviewer.md)
- Gotchas: [`languages/zig/gotchas.md`](../../languages/zig/gotchas.md)
- Universal review: [`workflows/code-review.md`](../../workflows/code-review.md)
- Sister roles: `chainsafe-zig-architect`, `chainsafe-zig-developer`
