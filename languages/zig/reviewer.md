# Zig Reviewer

Language-specific checklist when reviewing a Zig PR. Operates under the [universal review principles](../../workflows/code-review.md#universal-principles).

> **In one line:** `zig fmt` clean, allocators injected and paired with `defer`, errors handled not swallowed, no unjustified disabled safety or pointer casts. SOFT WARNING in general; memory-safety and consensus-correctness paths get near-HARD scrutiny.

## Severity tier

Per [reviewer-severity tier table](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail), Zig reviewer findings emit as **SOFT WARNING** by default. Two surfaces **promote to near-HARD-FAIL** scrutiny — the agent reviewer stops and a human must engage:

1. **Memory-safety / undefined-behavior surface.** `@setRuntimeSafety(false)`, `@ptrCast` / `@alignCast`, raw many-item pointer arithmetic, `catch unreachable` on fallible operations, and any code that relies on ReleaseFast semantics.
2. **Consensus-correctness surface.** SSZ encode/decode, `hashTreeRoot`, Merkleization, and anything whose wrong output is a consensus fault. A byte wrong here is a fork, not a bug.

These mirror how Rust's `unsafe` is treated: the language allows it, the reviewer demands justification.

## What to look for

### Memory and allocators

- **Every allocation has a paired free** via `defer` / `errdefer`, placed at the acquire.
- **The allocator is injected, not global.** A captured global allocator is a design smell and breaks testability.
- **Ownership is clear** across returns and the C ABI — who frees what is documented or obvious.
- **No leaks.** Tests use `std.testing.allocator`, which fails on a leak; new code keeps it green.
- **Allocator choice fits the lifetime** — arena for bulk, fixed-buffer for bounded, general-purpose otherwise.

### Errors

- **No swallowed error unions.** Every `!T` is `try`-propagated, `catch`-handled, or exhaustively `switch`ed.
- **`errdefer` unwinds partial construction** correctly — freed on error, retained on success.
- **`catch unreachable` only where success is a real invariant.** On fallible I/O it is a near-HARD finding.

### Undefined behavior and safety

- **`@setRuntimeSafety(false)` is justified and scoped** to the smallest region, with a comment. Unscoped or unexplained → near-HARD.
- **Integer-overflow intent is explicit.** Wrapping/saturating ops (`+%`, `+|`) or `@addWithOverflow` where wraparound is wanted; otherwise overflow must be impossible or handled.
- **`@ptrCast` / `@alignCast` are sound** — alignment is honored, the target layout is guaranteed, not assumed.
- **No reading of `undefined`** before initialization. No reliance on ReleaseFast eliding a check.

### Comptime

- **Comptime surfaces are minimal and documented.** No comptime where a runtime value fits.
- **`inline for` / recursion is bounded** — no accidental compile-time blowup.

### C ABI and bindings

- **The exported surface is stable** (`export` / `callconv(.C)` / `extern` layout) and treated as a versioned contract.
- **Cross-boundary memory ownership is documented** — the downstream binding must know who frees.
- **Optionals/null are handled at the boundary**, not assumed away.

### Consensus correctness (lodestar-z and similar)

- **Spec-test coverage** exists for SSZ / Merkleization / hashing changes, against the Ethereum consensus spec.
- **Fuzz coverage** for serializers and parsers.
- **Determinism** — byte-for-byte, endianness explicit, no floating point on consensus paths.

### Tests, lint, format

- **Test blocks exist for the change**; the [testing-and-qa](../../workflows/testing-and-qa.md) page applies — agent-authored tests get the same scrutiny as agent-authored code.
- **`std.testing.allocator`** used so leaks fail the suite.
- **`zig fmt --check`** clean.

## What to flag vs. fix in place

- **Flag**: disabled safety, pointer-cast soundness, allocator ownership, swallowed errors, ABI changes, consensus-correctness gaps.
- **Suggest with a code suggestion**: `zig fmt` nits, trivial naming, comment typos.
- **Don't fix and push** unless the operator authorized co-authorship.

## When the reviewer skill refuses to review

- The diff contains code in a language other than Zig.
- The PR description is empty.
- The diff touches code out of session scope.
- **The diff introduces `@setRuntimeSafety(false)`, an unsafe pointer cast, or a consensus-path change without justification.** Refuse and escalate to the CODEOWNER.

## Phrasing

- Lead with the concern: "This `@ptrCast` reinterprets a `[]u8` as `[]u32`; the SAFETY note cites length but not alignment — what guarantees the buffer is 4-byte aligned?"
- Cite the spec for consensus findings: "`hashTreeRoot` here pads before mixing the length; the SSZ spec mixes length last. Spec-test for the boundary case?"
- `nit:` for taste-level.

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md) — universal review framework.
- [`../../invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings) — HARD FAIL semantics; the memory-safety and consensus surfaces promote toward here.
