# Zig Idioms

Idiomatic patterns in Zig at ChainSafe. Reference for authors and reviewers, grounded in the [Zig style guide](https://ziglang.org/documentation/master/#Style-Guide).

## Naming

- **Functions:** `camelCase` — `hashTreeRoot`, `serializeToBytes`.
- **Types, and functions that return a type:** `TitleCase` — `TreeView`, `UintType`.
- **Variables and fields:** `snake_case` — `fixed_size`, `root_node`.
- **Constants** follow the value: `TitleCase` if it is a type, `snake_case` otherwise.
- **Files:** `snake_case`, or `TitleCase` when the file *is* a single struct/namespace.
- No abbreviations that aren't already universal. Spell it out.

## Inject the allocator

```zig
pub fn init(allocator: std.mem.Allocator, capacity: usize) !Pool {
    const nodes = try allocator.alloc(Node, capacity);
    return .{ .nodes = nodes, .allocator = allocator };
}
```

Every allocating function or type takes an `std.mem.Allocator`. It is never a global. This is the single most important Zig idiom — it is what makes code testable, leak-checkable, and usable across the FFI boundary.

## `defer` and `errdefer` at the acquire

```zig
var pool = try Node.Pool.init(allocator, 100_000);
defer pool.deinit();                 // always runs at scope exit

const device = try allocator.create(Device);
errdefer allocator.destroy(device);  // runs only if a later step returns an error
device.name = try std.fmt.allocPrint(allocator, "id={d}", .{id});
errdefer allocator.free(device.name);
```

Place cleanup immediately after the thing it cleans up. `defer` for unconditional release; `errdefer` for releasing a half-built value when construction fails.

## Errors are values

```zig
const DecodeError = error{ ShortBuffer, BadTag };

fn decodeTag(buf: []const u8) DecodeError!Tag {
    if (buf.len == 0) return error.ShortBuffer;
    return std.meta.intToEnum(Tag, buf[0]) catch error.BadTag;
}
```

Name the error set at public boundaries. Propagate with `try`, handle with `catch`, and `switch` on an error to force every case to be handled.

## Optionals over null

```zig
fn find(self: *Map, key: Key) ?*Value {
    // ... returns null when absent
}

if (map.find(key)) |value| {
    use(value);
} else {
    // absent
}

const v = map.find(key) orelse return error.Missing;
```

Plain pointers can't be null; `?T` makes absence explicit and the compiler forces you to unwrap it. `while (it.next()) |item|` is the same pattern over iterators.

## Tagged unions with exhaustive switch

```zig
const Value = union(enum) {
    uint: u64,
    bytes: []const u8,
    list: []Value,
};

fn size(v: Value) usize {
    return switch (v) {
        .uint => 8,
        .bytes => |b| b.len,
        .list => |items| items.len,
    };
}
```

`union(enum)` is Zig's sum type. A `switch` with no `else` is checked for exhaustiveness — add a variant and the compiler points you at every switch that needs updating.

## Slices, not bare pointers

```zig
fn sum(xs: []const u32) u32 { ... }   // pointer + length, bounds-checked
const window = buffer[4..36];          // a slice, not pointer math
```

Prefer `[]T` / `[]const T` (a fat pointer with a length) over many-item `[*]T`. Sentinel-terminated slices (`[:0]const u8`) model C strings. Bounds are checked in safe builds.

## Generics are functions that return a type

```zig
fn FixedVector(comptime n: usize, comptime T: type) type {
    return struct {
        data: [n]T,
        pub fn zero() @This() { return .{ .data = [_]T{0} ** n }; }
    };
}
```

This is how the standard library and lodestar-z's SSZ types (`UintType(64)`, `FixedContainerType(...)`) are built — generic, type-safe, zero-cost, and no macro layer.

## Struct literals with inferred type

```zig
const cp: Checkpoint = .{ .epoch = 42, .root = [_]u8{0} ** 32 };
return .{ .nodes = nodes, .len = 0 };   // type inferred from the return type
```

When the target type is known, `.{ ... }` infers it. Enum literals work the same way: `.mainnet`, `.ok`.

## Test next to the code

```zig
test "uint64 round-trips" {
    const uint64 = ssz.UintType(64);
    var buf: [uint64.fixed_size]u8 = undefined;
    _ = uint64.serializeToBytes(&value, &buf);
    try std.testing.expectEqual(@as(u64, 42), value);
}
```

Tests are `test "..." { ... }` blocks in the same file, run with `zig build test`, using `std.testing.allocator` so leaks fail the run.

## Comptime assertions for invariants

```zig
comptime {
    std.debug.assert(@sizeOf(Header) == 40);
}
```

Catch layout and configuration mistakes at compile time rather than runtime — especially valuable for `extern`/ABI structs.

## Related

- [`developer.md`](./developer.md) — fuller rationale.
- [`gotchas.md`](./gotchas.md) — the inverse: what to avoid.
