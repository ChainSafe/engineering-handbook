# Zig Architect

Architectural guidance for Zig at ChainSafe. The canonical codebase is [lodestar-z](https://github.com/ChainSafe/lodestar-z) — Zig consensus libraries for Lodestar: SSZ serialization, Merkleization, hashing, persistent Merkle trees, and the Ethereum consensus types, consumed by the TypeScript client across a C-ABI boundary. The architectural framework lives in `.invariance` (see the [pointer page](../../invariants/invariance-framework.md)); this page covers Zig-specific shaping.

> **In one line:** Allocators are explicit and injected. Errors are values. Safety is a build-mode decision you make on purpose. Comptime replaces macros. The exported C ABI is a contract.

## When Zig (and when not)

Zig earns its place where the realistic alternative is C: small, performance-critical, memory-controlled libraries that are consumed across an FFI boundary — hashing, SSZ encode/decode, Merkleization hot paths. That is exactly lodestar-z's brief.

It is **not** the default for general work. Services and tooling have a chosen language already: TypeScript (Lodestar), Go (Gossamer), Rust (Forest), Solidity (contracts), Python (ops/scripts). Reaching for Zig outside the "C-replacement library" niche is an org-level decision, not an individual-PR one — raise it with the curator and capture the rationale in an ADR before starting.

## Defer to `.invariance` for

| Decision | `.invariance` section |
|---|---|
| Service/module boundaries and contracts | Component contracts |
| Invariant naming and testability | Invariant lifecycle |
| Cross-component failure modes | Failure-mode invariants |
| Memory-ownership invariants | Ownership/lifetime invariants |

## Zig-specific architectural choices

### Project layout

- `build.zig` + `build.zig.zon` at the root. `build.zig.zon` is the package manifest: pinned dependencies and a `minimum_zig_version`.
- `src/` with a library root (`root.zig`) and/or an executable entry (`main.zig`).
- **Public modules are declared in `build.zig`** (`b.addModule`) so consumers `@import` them by name. lodestar-z exposes `ssz`, `hashing`, `persistent_merkle_tree`, and `consensus_types` this way — the module list *is* the public surface.
- `test/` for spec and integration tests, `bench/` for benchmarks, `bindings/` for the C-ABI / language-binding surface.
- Files are structs. One primary type per file; the filename is `TitleCase` when the file *is* that struct, `snake_case` otherwise.

### Allocator strategy (the central decision)

Zig has no hidden allocations — every API that allocates takes an `std.mem.Allocator`. The architecture decision is **who owns allocation at each boundary**:

- **Inject, never capture.** Functions and types receive an allocator; they do not reach for a global. This is what makes a library usable in tests, in WASM, and across the FFI boundary.
- **Match the allocator to the lifetime.** An arena for operation-scoped bulk allocation freed in one shot; a fixed-buffer allocator for bounded hot paths; a leak-detecting general-purpose allocator in debug and tests.
- **Ownership is explicit.** Document who frees what, especially for values that cross a function return or the C ABI. Pair every acquire with `defer` / `errdefer`.

### Error model

- **Explicit error sets at public boundaries.** Expose a named error set so callers can `switch` exhaustively; let inference (`!T`) handle internal helpers.
- **`try` to propagate, `errdefer` to clean up the partial-construction path.** Errors are values and cannot be silently dropped.
- **`unreachable` / `catch unreachable` only where success is a proven invariant** — and remember it is undefined behavior in the unsafe build modes. Never on genuinely fallible I/O.

### Comptime over macros and codegen

Generics are functions that return a `type`: `fn List(comptime T: type) type`. lodestar-z's SSZ type constructors (`UintType(64)`, `FixedContainerType(struct { ... })`) are the canonical pattern — zero-cost, type-safe, no macro layer. Keep comptime surfaces small and documented; comptime that could have been runtime hurts readability and compile time.

### Build mode and safety posture

Decide the optimization mode per artifact, on purpose:

- **ReleaseSafe is the default for anything where a wrong answer matters** — which is all of lodestar-z. Runtime safety checks stay on.
- **ReleaseFast only for measured hot paths,** with `@setRuntimeSafety(false)` scoped to the smallest region and justified in a comment. In the unsafe modes, integer overflow and out-of-bounds access become undefined behavior rather than a panic — never assume them away for correctness.

### The C ABI is a contract

lodestar-z is consumed by Lodestar across a C ABI. Treat the exported surface (`export fn`, `callconv(.C)`, `extern` structs with defined layout) like a public API: versioned, documented, and with explicit memory ownership across the boundary (who allocates, who frees). Breaking it breaks a downstream client in another language.

### Pre-1.0 reality

Zig is pre-1.0; the language and standard library change across releases. Pin `minimum_zig_version` in `build.zig.zon` and the exact compiler in CI, wrap std APIs you depend on heavily, and budget for migration on each upgrade.

## ADR shape for Zig modules

- **Allocator ownership.** Who allocates, who frees, which allocator type, and why.
- **Error set.** The public error set and what each variant means.
- **Build-mode / safety posture.** ReleaseSafe vs. ReleaseFast, and the justification for any disabled safety.
- **Comptime surface.** What is resolved at compile time and why.
- **Exported C ABI.** The stable surface and cross-boundary memory ownership, if any.
- **Zig version floor.** The `minimum_zig_version` and the upgrade story.
- **Invariants impacted.** Deep links into `.invariance`.

## Anti-patterns

- **A hidden or global allocator.** It defeats testability, leak detection, and FFI use.
- **ReleaseFast for correctness-critical code** without a measured reason and scoped safety justification.
- **Comptime where runtime would do.** Cleverness that costs compile time and readability.
- **Leaking allocator ownership across the C ABI** without a documented contract — the downstream binding will leak or double-free.
- **`catch unreachable` on fallible operations.** A panic in safe builds, undefined behavior in unsafe ones.

## Related

- [`developer.md`](./developer.md) — implementation-level Zig practice.
- [`reviewer.md`](./reviewer.md) — what to look for in a Zig PR.
- [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../invariants/invariance-framework.md`](../../invariants/invariance-framework.md) — the architectural framework this page defers to.
- [Zig Language Reference](https://ziglang.org/documentation/master/) and [Learn Zig](https://ziglang.org/learn/) — the upstream canonical guidance this page is built on.
