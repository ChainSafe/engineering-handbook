---
name: chainsafe-zig-architect
description: Architectural guidance for designing Zig modules and libraries at ChainSafe (lodestar-z — Zig consensus libraries for Lodestar: SSZ, Merkleization, hashing, persistent Merkle trees, consensus types). Use this skill whenever the user is starting a new Zig module, designing a build.zig layout, deciding allocator ownership or strategy, choosing a build mode (ReleaseSafe vs ReleaseFast) and safety posture, designing an error set, shaping a comptime/generic API, designing a C-ABI/FFI surface for bindings, pinning a Zig version, or writing an ADR for Zig work. EVEN IF the user does not explicitly say "architecture" — triggers on "design a Zig module", "new Zig library", "build.zig layout", "allocator strategy", "arena vs gpa", "who owns this allocation", "ReleaseSafe or ReleaseFast", "Zig error set", "comptime generic", "export to C ABI", "lodestar-z module", "SSZ type design", "ADR for Zig", "minimum_zig_version". Defers to .invariants for invariants themselves; covers what Zig changes about applying them. Do NOT use for line-level Zig coding (use chainsafe-zig-developer) or Zig PR review (use chainsafe-zig-reviewer).
metadata:
  type: role-workflow
  language: zig
  role: architect
  source: languages/zig/architect.md
  authored-via: anthropic-skills:skill-creator (2026-06-01)
---

# Zig Architect

Use this when designing Zig modules at ChainSafe — lodestar-z-shaped work (consensus libraries consumed by Lodestar across a C ABI) or any Zig library. Full reference: [`languages/zig/architect.md`](../../languages/zig/architect.md).

## When Zig (and when not)

Zig earns its place where the realistic alternative is C: small, performance-critical, memory-controlled libraries consumed across an FFI boundary — hashing, SSZ encode/decode, Merkleization. It is **not** the default for services or tooling (those are TypeScript/Go/Rust/Solidity/Python). Introducing Zig outside that niche is an org-level decision — raise it with the curator and capture the rationale in an ADR first.

## Key Zig-specific decisions

### Project layout

- `build.zig` + `build.zig.zon` at the root; `build.zig.zon` pins dependencies and `minimum_zig_version`.
- Public modules declared in `build.zig` via `b.addModule` — the module list *is* the public surface (lodestar-z exposes `ssz`, `hashing`, `persistent_merkle_tree`, `consensus_types`).
- `src/` (root.zig / main.zig), `test/`, `bench/`, `bindings/`. Files are structs; one primary type per file.

### Allocator strategy (the central decision)

- **Inject, never capture.** Every allocating function/type takes an `std.mem.Allocator`; none reaches for a global. This is what makes code testable, leak-checkable, and FFI-usable.
- **Match the allocator to the lifetime** — arena for operation-scoped bulk frees, fixed-buffer for bounded hot paths, leak-detecting GPA in tests/debug.
- **Ownership is explicit** across returns and the C ABI. Pair every acquire with `defer` / `errdefer`.

### Error model

- Explicit error sets at public boundaries so callers `switch` exhaustively; inference (`!T`) for internal helpers.
- `try` to propagate, `errdefer` to unwind partial construction.
- `catch unreachable` only where success is a proven invariant — never on fallible I/O (UB in unsafe builds).

### Build mode and safety posture

- **ReleaseSafe is the default** for anything where a wrong answer matters (all of lodestar-z). Runtime safety stays on.
- **ReleaseFast only on measured hot paths**, with `@setRuntimeSafety(false)` scoped tightly and justified. Overflow and bounds checks become UB there — never assume them for correctness.

### Comptime over macros

Generics are functions returning `type` (`fn UintType(comptime bits: u16) type`). Keep comptime surfaces small and documented; comptime that could be runtime costs compile time and readability.

### The C ABI is a contract

Bindings cross a C ABI (`export fn`, `callconv(.C)`, `extern` layout). Treat the exported surface as a versioned public API with explicit cross-boundary memory ownership — breaking it breaks a downstream client in another language.

### Pre-1.0 reality

Zig is pre-1.0; pin `minimum_zig_version` and the CI compiler, wrap heavily-used std APIs, and budget for migration on upgrades.

## ADR shape for Zig modules

Allocator ownership · error set · build-mode/safety posture · comptime surface · exported C ABI + memory ownership · Zig version floor · invariants impacted (`.invariants`).

## Anti-patterns at design time

- A hidden/global allocator.
- ReleaseFast for correctness-critical code without a measured, scoped justification.
- Comptime where runtime would do.
- Leaking allocator ownership across the C ABI without a documented contract.
- `catch unreachable` on fallible operations.

## Related

- Full reference: [`languages/zig/architect.md`](../../languages/zig/architect.md)
- Sister roles: `chainsafe-zig-developer`, `chainsafe-zig-reviewer`
- Framework: [`invariants/invariants-framework.md`](../../invariants/invariants-framework.md)
- Workflow: `chainsafe-research-plan-implement`
- Upstream: [Zig Language Reference](https://ziglang.org/documentation/master/), [Learn Zig](https://ziglang.org/learn/)
