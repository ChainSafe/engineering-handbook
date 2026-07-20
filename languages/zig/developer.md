# Zig Developer

Idiomatic Zig development at ChainSafe. Tooling, the build system, testing, memory discipline, the patterns that show up in review. The working example throughout is [lodestar-z](https://github.com/ChainSafe/lodestar-z).

> **In one line:** `zig fmt --check` and `zig build test` are the floor. Allocators are passed in, never global. `defer` / `errdefer` sit next to every acquire. Safety stays on unless a benchmark says otherwise.

## Tooling

### Formatting

```sh
zig fmt --check .     # must pass without diffs
```

`zig fmt` is canonical and unconfigurable — the gofmt of Zig. No style bikeshedding; the formatter decides. Run it on save; gate it in CI.

### Build system

`build.zig` (the build script, written in Zig) plus `build.zig.zon` (the package manifest). Common commands:

```sh
zig build              # default install step
zig build test         # run the test step
zig build run          # run an executable artifact
zig build -Doptimize=ReleaseSafe   # choose the optimization mode
zig build -Dtarget=wasm32-wasi     # cross-compile; no separate toolchain needed
```

Projects define their own steps. lodestar-z, for example, exposes `zig build test:int`, `zig build test:generic_spec_tests`, and `zig build test:static_spec_tests -Dpreset=mainnet` — wire spec/conformance suites in as named steps so they are one command to run.

### Dependencies and toolchain

- Dependencies live in `build.zig.zon`; add them with `zig fetch --save <url>` so the hash is pinned.
- **Pin the Zig version.** Set `minimum_zig_version` in `build.zig.zon` and pin the exact compiler in CI. Zig is pre-1.0 — language and std change across releases, and an unpinned toolchain makes CI non-deterministic.
- Vendor or pin cryptographic / consensus dependencies where a quiet upstream change is expensive.

### Editors

Anything that speaks ZLS (the Zig Language Server): VSCode, Neovim, Helix, Emacs, Sublime, and others. The editor doesn't matter; the LSP integration does.

## Memory and allocators

Every allocation takes an injected allocator and is paired with its free:

```zig
fn loadRoots(allocator: std.mem.Allocator, count: usize) ![]Root {
    const roots = try allocator.alloc(Root, count);
    errdefer allocator.free(roots);          // freed only if a later step fails
    try fill(roots);
    return roots;                            // ownership transfers to the caller
}
```

- **Inject, never capture a global.** The allocator is a parameter.
- **`defer` for unconditional cleanup, `errdefer` for the error-only path.** Place them immediately after the acquire so the reader sees the pairing.
- **Arena** for operation-scoped bulk allocation freed in one shot; **fixed-buffer** for bounded hot paths.
- In tests, use `std.testing.allocator` — it fails the test on a leak or double-free.

## Error handling

```zig
const ParseError = error{ InvalidCharacter, Overflow };

fn parseDigit(c: u8) ParseError!u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        else => error.InvalidCharacter,
    };
}
```

- **Explicit error sets at public boundaries**, inferred (`!T`) for internal helpers.
- **`try` to propagate**, `catch` to handle, `switch` on the error to handle each case exhaustively.
- **`catch unreachable` only where success is a proven invariant** — never on real I/O. It panics in safe builds and is undefined behavior in unsafe ones.

## Safety and integer math

- **Integer overflow is illegal behavior.** It is a compile error at comptime and a panic in safety-checked builds — but undefined behavior in ReleaseFast. When you *want* wraparound, say so: `+%` (wrapping), `+|` (saturating), or `@addWithOverflow`.
- **`@setRuntimeSafety(false)`** disables checks for a scope — use it only on a measured hot path, scoped as tightly as possible, with a comment.
- **Reading `undefined` memory is undefined behavior.** Initialize before use; safe builds poison `undefined` with `0xAA` to surface the bug.

## Comptime

```zig
fn Vector(comptime n: usize, comptime T: type) type {
    return struct { data: [n]T };
}
```

Generics are functions returning `type`. `@typeInfo` gives compile-time reflection; `inline for` iterates fields at comptime. Keep these surfaces small and documented — comptime that could be runtime costs compile time and readability.

## Testing

```zig
test "round-trips through serialization" {
    const allocator = std.testing.allocator;
    var value = try decode(allocator, input);
    defer value.deinit(allocator);
    try std.testing.expectEqualSlices(u8, input, try encode(allocator, value));
}
```

- **Test blocks live next to the code** and run with `zig build test`.
- `std.testing.allocator` catches leaks; `expectEqual` / `expectEqualSlices` / `expectError` are the workhorses.
- **Conformance tests** against the Ethereum consensus spec for anything in SSZ / Merkleization / consensus-types — byte-for-byte determinism is the property.
- **Fuzzing** for parsers and serializers: Zig has built-in fuzzing (`zig build --fuzz`); lodestar-z also runs AFL++ under `pkg/afl++`.
- **Benchmarks** (`bench/`) where performance is the reason Zig was chosen — track regressions.

## C interop and bindings

```zig
export fn add(a: i32, b: i32) callconv(.C) i32 {
    return a + b;
}
```

- `@cImport(@cInclude("..."))` pulls C headers in directly — no hand-written bindings.
- `export fn` + `callconv(.C)` + `extern` structs define the surface other languages call. Memory ownership across the boundary must be explicit (who frees what).
- `zig cc` is a drop-in C/C++ cross-compiler if you need to build C sources too.

## CI baseline

Extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md):

- `zig fmt --check .`
- `zig build` in **ReleaseSafe**
- `zig build test`
- Spec / conformance suites for consensus code
- A fuzz smoke run for serializers
- Pinned Zig version (no floating `master`)

## Anti-patterns

- **A global allocator** instead of an injected one.
- **Swallowing an error union** or `catch unreachable` on fallible operations.
- **Assuming ReleaseFast semantics** for correctness — overflow and bounds checks are gone there.
- **Comptime bloat** where a runtime value would do.
- **An unused variable or import** — Zig rejects them; use `_ = x;` deliberately, don't leave dead code.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md) — the broader testing posture.
- [Zig Build System guide](https://ziglang.org/learn/build-system/) and [Zig Language Reference](https://ziglang.org/documentation/master/) — upstream canonical references.
