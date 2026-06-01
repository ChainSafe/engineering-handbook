# Zig Gotchas

Common bug classes and surprising behavior in Zig. Reviewer screen and author pre-flight.

## Integer overflow is illegal behavior

```zig
var x: u8 = 255;
x += 1;   // panic in safe builds; undefined behavior in ReleaseFast
```

Unlike C, this applies to **both signed and unsigned** integers. It's a compile error at comptime, a panic in safety-checked builds, and UB in ReleaseFast. When you want wraparound, say so:

```zig
const wrapped = x +% 1;   // wrapping
const clamped = x +| 1;   // saturating
const r = @addWithOverflow(x, 1);   // value + overflow bit
```

## ReleaseFast disables safety

Out-of-bounds access, overflow, `unreachable`, and reading `undefined` are checked illegal behavior in Debug/ReleaseSafe — they panic. In **ReleaseFast and ReleaseSmall they are undefined behavior.** Never rely on a safety check firing in a release-fast build. For consensus code, default to ReleaseSafe and disable safety only on a measured, scoped, commented hot path.

## `catch unreachable` on fallible operations

```zig
const file = openFile(path) catch unreachable;   // panics in safe builds, UB in fast
```

`unreachable` asserts the branch is impossible. On something that genuinely can fail (I/O, allocation, parsing) it's a latent crash. Handle the error, or `try` it.

## Reading `undefined`

```zig
var buf: [32]u8 = undefined;
const x = buf[0];   // reading before writing → UB
```

`undefined` means "uninitialized — I promise to write before I read." Reading first is UB; safe builds poison the memory with `0xAA` to surface it. Initialize, then read.

## Dangling slices and pointers

```zig
fn bad() []const u8 {
    var local: [4]u8 = .{ 1, 2, 3, 4 };
    return &local;   // slice into a stack frame that's about to vanish
}
```

A slice is a pointer plus a length; it does not own its backing memory. Returning a slice into a local, or into memory you're about to free, leaves a dangling reference. Return owned memory (allocated, with documented ownership) or have the caller pass the buffer in.

## `defer` and ownership transfer → double free

```zig
const buf = try allocator.alloc(u8, n);
defer allocator.free(buf);    // BUG if you also return buf to the caller
return buf;                   // caller now frees it too → double free
```

Use `errdefer` for the failure path and let ownership transfer cleanly on success. `defer`-free only what this scope truly owns at exit.

## Alignment in pointer casts

```zig
const bytes: []u8 = ...;
const words: []u32 = @ptrCast(bytes);          // wrong: ignores alignment
const words2: []u32 = @alignCast(@ptrCast(bytes));  // asserts alignment (UB if unaligned)
```

`@ptrCast` to a more-aligned type without honoring alignment is UB. `@alignCast` makes the alignment assertion explicit — and is itself checked illegal behavior in safe builds if the pointer isn't actually aligned. Make sure the buffer really is aligned.

## Unused variables and imports are errors

```zig
const std = @import("std");   // error if unused
fn f(ctx: Ctx) void {}        // error: unused parameter
```

Zig rejects unused locals, parameters, and imports. Discard intentionally with `_ = ctx;` — but don't paper over genuinely dead code; delete it.

## Shadowing is not allowed

```zig
const count = 1;
const count = 2;   // compile error: redeclaration
```

Zig forbids shadowing an existing name in scope. Pick a new name; the compiler won't let a "shadowed" variable hide a bug.

## Inferred error sets widen silently

```zig
fn parse(buf: []const u8) !Value { ... }   // error set inferred from the body
```

Inference is convenient internally, but at a **public boundary** an inferred `!T` can quietly grow new error variants as the implementation changes, breaking callers' exhaustive `switch`. Name the error set on public functions.

## Endianness and floats in consensus code

SSZ is little-endian; serialization must be explicit about byte order rather than assuming the host's. And floating point has no place on a consensus path — it isn't deterministic across platforms. Both are byte-for-byte correctness issues: a mismatch is a fork.

## Standard-library churn (pre-1.0)

Zig is pre-1.0; `std` APIs are renamed and reshaped across releases. Code that built on one version may not build on the next. Pin `minimum_zig_version`, pin the compiler in CI, and wrap heavily-used volatile std APIs behind a thin internal layer so an upgrade touches one place.

## `comptime` forcing values compile-time

```zig
fn lookup(comptime key: []const u8) Value { ... }
lookup(runtime_key);   // error: runtime value where comptime is required
```

Marking a parameter `comptime` means every caller must supply a compile-time-known value. Useful for generics; surprising when applied too broadly. Keep comptime to where it earns its place.

## Related

- [`idioms.md`](./idioms.md) — the inverse: how to do these right.
- [`reviewer.md`](./reviewer.md) — uses this list as the screening surface.
