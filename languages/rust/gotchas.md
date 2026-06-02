# Rust Gotchas

Common bug classes and surprising behavior in Rust. Reviewer screen and author pre-flight.

## `unwrap()` in production paths

The single most common Rust review finding. Tests panic; production code shouldn't. Either handle the case or add a `// SAFETY: ...` comment justifying why the invariant holds.

## `as` casts that lose precision

```rust
let big: i64 = 10_000_000_000;
let small: i32 = big as i32;  // silently truncates
```

Use `TryFrom` / `TryInto` for fallible conversions:

```rust
let small: i32 = big.try_into()?;
```

## Holding a `MutexGuard` across `.await`

```rust
async fn bug(state: Arc<Mutex<State>>) {
    let guard = state.lock().unwrap();   // std::sync::Mutex
    do_async(&*guard).await;             // holds the mutex across await → deadlock risk
}
```

Use `tokio::sync::Mutex` when locks span `.await`, or scope the guard tightly:

```rust
async fn fixed(state: Arc<Mutex<State>>) {
    let value = {
        let guard = state.lock().unwrap();
        guard.value.clone()
    };
    do_async(&value).await;
}
```

## Forgetting `Send + 'static` on spawned futures

```rust
tokio::spawn(async move {
    let rc = Rc::new(...);  // !Send
    rc.do_thing();
}); // compile error
```

Use `Arc` instead of `Rc`, ensure captured types are `Send`.

## `Cell<T>` / `RefCell<T>` in async contexts

`RefCell` is `!Sync` — won't cross thread boundaries. For async-shared interior mutability, use `Mutex` or `RwLock` (tokio variants when spanning `await`).

## Floating-point in `Eq` / `Hash`

```rust
#[derive(Eq, Hash)]   // ERROR: f64 doesn't impl Eq
struct Point { x: f64, y: f64 }
```

`f64` is `PartialEq`, not `Eq`. For hashing floats, use a wrapper that handles NaN explicitly, or `ordered_float`.

## `Box<dyn Trait>` everywhere

A `Box<dyn Error>` return type erases information and adds an allocation. Use a concrete error type (via `thiserror`) when you can.

## `Vec::with_capacity(0)` misconception

`with_capacity` is a hint, not a guarantee — and allocating with capacity 0 is functionally equivalent to `Vec::new()`. Use realistic estimates or skip the hint.

## Lifetime annotations on `'static`

```rust
fn make() -> &'static str { ... }
```

`'static` does NOT mean "lives forever in memory." It means "doesn't borrow from anything with a shorter lifetime." `String::leak()` produces `&'static str`; `Box::leak(...)` produces `&'static T`. Use sparingly; memory is leaked.

## `?` in `main` requires `Result`-returning main

```rust
fn main() {
    let x = read()?;   // ERROR
}
```

```rust
fn main() -> Result<(), Box<dyn Error>> {
    let x = read()?;
    Ok(())
}
```

Or use `anyhow::Result<()>` for ergonomics.

## `.unwrap()` and `Option<T>` with `Default`

```rust
let timeout = config.timeout.unwrap_or_default();  // 0 seconds if missing
```

`Duration::default()` is zero. `unwrap_or_default` can produce silently-wrong defaults. Specify a sensible default:

```rust
let timeout = config.timeout.unwrap_or(Duration::from_secs(30));
```

## `String` vs `&str` confusion in error variants

```rust
#[derive(Error, Debug)]
pub enum E {
    #[error("bad: {0}")]
    Bad(String),   // allocates; fine if message is dynamic
    #[error("frozen: {0}")]
    Frozen(&'static str),   // for compile-time-known strings
}
```

Match the storage to the lifetime. Allocating a `String` for a fixed message wastes allocations on the error path.

## Implicit drop order

Local variables drop in reverse declaration order. When a destructor's behavior matters (releasing a lock, closing a file, sending a final message), be deliberate about declaration order.

```rust
let _guard = mutex.lock().unwrap();   // dropped LAST → unlocked last → good
let result = compute();
```

## `Arc<Mutex<T>>` reflex

```rust
let shared = Arc::new(Mutex::new(Vec::new()));
// ... spawn tasks that lock and append
```

Often a channel models the problem better. `Arc<Mutex<T>>` is correct but heavyweight; ask whether senders/receivers, or an immutable snapshot pattern, would fit.

## `dbg!` and `println!` in committed code

`dbg!` and `println!` debug output is rarely what you want in production. Clippy catches some; review catches the rest.

## `.collect::<Vec<_>>()` mid-iterator unnecessarily

```rust
items.iter().map(transform).collect::<Vec<_>>().into_iter().filter(...)
```

vs.

```rust
items.iter().map(transform).filter(...)
```

The intermediate `Vec` allocates and forces evaluation. Chain the iterator unless you need the materialized collection.

## Integer overflow: debug panics, release wraps

```rust
let n: u8 = 255;
let m = n + 1;   // debug build: panics; release build: wraps to 0
```

Arithmetic overflow is checked in debug builds (panic) and wraps by default in release — so a bug can stay hidden until production. Be explicit about intent: `checked_add` (→ `Option`), `saturating_add`, `wrapping_add`, or `overflowing_add`. For consensus and crypto math, prefer `checked_*` and reject on `None` rather than silently wrapping.

## Wildcard imports

```rust
use some_crate::prelude::*;   // fine — a curated prelude
use some_crate::*;            // smell — where did this name come from?
```

`use foo::*` outside a prelude or `#[cfg(test)]` hides where names come from and silently pulls in new symbols when the dependency grows, which can change resolution or introduce conflicts. Import what you use.

## `unsafe` without `SAFETY` comment

The single most flagged Rust issue at security-conscious reviews. Every `unsafe { }` block needs the comment. No exceptions.

## Related

- [`idioms.md`](./idioms.md) — the inverse: how to do these right.
- [`reviewer.md`](./reviewer.md) — uses this list as the screening surface.
- [Effective Rust](https://effective-rust.com/) · [The Rust Book](https://doc.rust-lang.org/book/) — upstream practice references.
