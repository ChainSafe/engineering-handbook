---
name: chainsafe-zig-developer
description: Idiomatic Zig development at ChainSafe — implementation-level guidance for writing Zig in lodestar-z (SSZ, Merkleization, hashing, consensus types) and other Zig libraries. Use this skill whenever the user is writing Zig, debugging Zig, picking between Zig patterns, passing allocators, using defer/errdefer, handling error unions with try/catch, writing comptime generics, dealing with integer overflow or undefined behavior, using the build system (build.zig / build.zig.zon), writing tests with std.testing, or building C-ABI bindings. EVEN IF the user does not explicitly say "Zig" but the file is .zig. Triggers on "write a Zig function", "implement in Zig", "how do I X in Zig", "allocator parameter", "defer vs errdefer", "error set", "comptime", "zig build test", "build.zig.zon", "std.testing.allocator", "export fn callconv(.C)", "@setRuntimeSafety". Do NOT use for Zig architectural design (use chainsafe-zig-architect) or Zig PR review (use chainsafe-zig-reviewer).
metadata:
  type: role-workflow
  language: zig
  role: developer
  source: languages/zig/developer.md
  authored-via: anthropic-skills:skill-creator (2026-06-01)
---

# Zig Developer

Idiomatic Zig at ChainSafe. Full reference: [`languages/zig/developer.md`](../../languages/zig/developer.md).

## Tooling baselines

```sh
zig fmt --check .       # canonical, unconfigurable formatter — gate in CI
zig build               # build.zig + build.zig.zon drive everything
zig build test          # run test blocks
zig build -Doptimize=ReleaseSafe   # choose the build mode on purpose
```

- **Pin the Zig version.** Set `minimum_zig_version` in `build.zig.zon` and pin the exact compiler in CI — Zig is pre-1.0 and an unpinned toolchain makes CI non-deterministic.
- Add dependencies with `zig fetch --save` so hashes are pinned. Projects expose their own steps (lodestar-z: `zig build test:static_spec_tests -Dpreset=mainnet`).

## Memory and allocators

```zig
fn loadRoots(allocator: std.mem.Allocator, count: usize) ![]Root {
    const roots = try allocator.alloc(Root, count);
    errdefer allocator.free(roots);   // freed only if a later step fails
    try fill(roots);
    return roots;                     // ownership transfers to the caller
}
```

- Inject the allocator; never reach for a global.
- `defer` for unconditional cleanup, `errdefer` for the error-only path — placed at the acquire.
- Arena for bulk/operation-scoped, fixed-buffer for bounded hot paths. In tests use `std.testing.allocator` (fails on leak).

## Error handling

- Explicit error sets at public boundaries, inferred (`!T`) internally.
- `try` to propagate, `catch` to handle, `switch` on the error for exhaustiveness.
- `catch unreachable` only where success is a proven invariant — never on real I/O.

## Safety and integer math

- **Integer overflow is illegal behavior** (both signed and unsigned): compile error at comptime, panic in safe builds, UB in ReleaseFast. Use `+%` (wrapping), `+|` (saturating), or `@addWithOverflow` when wraparound is intended.
- `@setRuntimeSafety(false)` only on a measured, scoped, commented hot path.
- Reading `undefined` memory is UB — initialize before reading.

## Comptime

Generics are `fn(comptime T: type) type`; `@typeInfo` + `inline for` give compile-time reflection. Keep comptime surfaces small — it costs compile time and readability when overused.

## Testing

```zig
test "round-trips" {
    const a = std.testing.allocator;
    var v = try decode(a, input);
    defer v.deinit(a);
    try std.testing.expectEqualSlices(u8, input, try encode(a, v));
}
```

- Test blocks live next to the code; `std.testing.allocator` catches leaks.
- **Spec/conformance tests** for SSZ/Merkleization/consensus types (byte-for-byte determinism). **Fuzz** serializers (`zig build --fuzz`; lodestar-z also runs AFL++). **Bench** the hot paths Zig was chosen for.

## C interop and bindings

- `@cImport(@cInclude("..."))` imports C headers directly; `export fn` + `callconv(.C)` + `extern` define the surface other languages call.
- Memory ownership across the boundary must be explicit. `zig cc` is a drop-in C cross-compiler.

## CI baseline

`zig fmt --check` · `zig build` in ReleaseSafe · `zig build test` · spec/conformance suites · fuzz smoke · pinned Zig version.

## Anti-patterns

- A global allocator instead of an injected one.
- Swallowing an error union, or `catch unreachable` on fallible operations.
- Assuming ReleaseFast semantics for correctness.
- Comptime bloat; unused variables/imports (Zig rejects them — discard with `_ = x;` deliberately).

## Related

- Full reference: [`languages/zig/developer.md`](../../languages/zig/developer.md)
- Idioms: [`languages/zig/idioms.md`](../../languages/zig/idioms.md) · Gotchas: [`languages/zig/gotchas.md`](../../languages/zig/gotchas.md)
- Sister roles: `chainsafe-zig-architect`, `chainsafe-zig-reviewer`
- Upstream: [Zig Build System](https://ziglang.org/learn/build-system/), [Zig Language Reference](https://ziglang.org/documentation/master/)
