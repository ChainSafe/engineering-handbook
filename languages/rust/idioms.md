# Rust Idioms

Idiomatic patterns in Rust at ChainSafe. Reference for authors and reviewers.

## Naming

- **Types and traits:** `PascalCase`.
- **Variables, fields, methods, modules:** `snake_case`.
- **Constants and statics:** `SCREAMING_SNAKE_CASE`.
- **Lifetimes:** `'a`, `'b`, or descriptive (`'src`, `'dst`) for complex cases.
- **Generics:** single letter (`T`, `U`, `K`, `V`) when their role is obvious; descriptive (`Item`, `Error`) when not.

## Errors

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum FetchError {
    #[error("not found: {key}")]
    NotFound { key: String },
    #[error("decode failed")]
    Decode(#[from] DecodeError),
}

pub fn fetch(key: &str) -> Result<Data, FetchError> {
    let raw = read(key).ok_or_else(|| FetchError::NotFound { key: key.into() })?;
    Ok(decode(&raw)?)
}
```

- `thiserror` for libraries, `anyhow` for binaries.
- Error variants are structured, not stringly-typed.
- `?` propagation; reach for `match` only when transforming.

## Newtypes

```rust
pub struct UserId(pub u64);
pub struct OrderId(pub u64);
```

A `UserId` and `OrderId` are not interchangeable. Newtypes make the type system enforce that.

For numeric newtypes, `derive_more` or hand-written `From`/`Into`/`Display` are common.

## Enums over booleans

```rust
fn set_visibility(v: Visibility)   // Visibility::Hidden — intent is obvious
fn set_visible(visible: bool)      // what does set_visible(true) mean at the call site?
```

A `bool` parameter erases intent at the call site, and a pair of them makes illegal combinations representable. An `enum` names the states and gets exhaustiveness checking (mre/idiomatic-rust: *Enums Instead of Booleans*).

## Accept flexible input types

```rust
fn greet(name: &str)                    // &str, not &String
fn join(parts: &[&str]) -> String        // &[T], not &Vec<T>
fn read(path: impl AsRef<Path>) -> ...   // &str / String / &Path / PathBuf all work
```

Take the most general borrowed form. Callers pass what they already have without converting, and ownership decisions stay at the boundary. A recurring theme across the idiomatic-Rust corpus.

> **Caveat — don't use this in a `dyn`-compatible trait.** A generic or `impl Trait` parameter on a *trait method* makes the trait no longer `dyn`-compatible (formerly "object safe"), so `Box<dyn MyTrait>` / `&dyn MyTrait` stop compiling. In a trait you intend to use behind `dyn`, take the concrete borrowed type in the trait method and expose the flexible form as a wrapper — an inherent `impl dyn MyTrait`, or a default method bounded `where Self: Sized` (which keeps it out of the vtable):
>
> ```rust
> trait Loader {
>     fn load(&self, path: &Path) -> io::Result<Vec<u8>>;   // concrete type → `dyn Loader` works
> }
>
> impl dyn Loader {
>     fn load_any(&self, path: impl AsRef<Path>) -> io::Result<Vec<u8>> {
>         self.load(path.as_ref())                          // ergonomic wrapper, off the vtable
>     }
> }
> ```
>
> Free functions and inherent methods have no such constraint — use the flexible form freely. See the dispatch section in [`architect.md`](./architect.md).

## Conversion method naming

Name conversions by cost, per the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/):

- **`as_`** — cheap, borrow-to-borrow, no allocation (`str::as_bytes`).
- **`to_`** — expensive, borrow-to-owned; it allocates (`str::to_string`).
- **`into_`** — consumes `self`, owned-to-owned (`String::into_bytes`).

Iterator producers are `iter` / `iter_mut` / `into_iter`; getters take no `get_` prefix (`config.timeout()`, not `config.get_timeout()`).

## Builder

```rust
let config = Config::builder()
    .timeout(Duration::from_secs(10))
    .max_retries(3)
    .build()?;
```

Builders shine when the type has many optional fields. The `build()` returns a `Result` so missing required fields are a compile-time-checkable concept.

## Type-state

```rust
pub struct Connection<S> { /* ..., _state: PhantomData<S> */ }
pub struct Disconnected;
pub struct Connected;

impl Connection<Disconnected> {
    pub fn connect(self) -> Result<Connection<Connected>, ConnectError> { /* ... */ }
}
impl Connection<Connected> {
    pub fn send(&self, msg: Message) -> Result<(), SendError> { /* ... */ }
}
```

When the protocol has phases, encode them in the type. Callers can't `send` on a `Connection<Disconnected>` — the compiler refuses.

## `?` and `From`

```rust
#[derive(Error, Debug)]
pub enum AppError {
    #[error(transparent)]
    Io(#[from] std::io::Error),
    #[error(transparent)]
    Parse(#[from] ParseError),
}

fn run() -> Result<(), AppError> {
    let data = std::fs::read("config")?;   // io::Error → AppError::Io
    let cfg: Config = parse(&data)?;        // ParseError → AppError::Parse
    Ok(())
}
```

`#[from]` lets `?` convert errors at propagation points.

## `Iterator` adapters

Prefer iterator chains over explicit loops when the chain is short and clear:

```rust
let total: u64 = orders.iter().filter(|o| o.active).map(|o| o.total).sum();
```

When a chain gets long enough to wrap several lines, a loop with intermediate variables is often clearer. Readability beats cleverness.

## `Option` and `Result` combinators

```rust
config
    .timeout
    .map(|s| Duration::from_secs(s))
    .unwrap_or_else(default_timeout)
```

`map`, `and_then`, `unwrap_or_else`, `ok_or_else` are the standard set. Avoid `unwrap()` and `unwrap_or(...)` with non-trivial defaults; the `_else` variants defer computation.

## `Default` for "empty" instances

```rust
#[derive(Default)]
pub struct Config {
    pub timeout: Option<Duration>,
    pub max_retries: u32,
}

let cfg = Config::default();
```

Combined with `..Default::default()` in struct literals, this lets callers specify only the fields they care about.

## `derive` everything that fits

`Clone`, `Debug`, `PartialEq`, `Eq`, `Hash`, `Default`, `serde::{Serialize, Deserialize}` — derive freely. Re-implementing them by hand is a smell unless you have a specific reason.

## Static vs. dynamic dispatch

```rust
fn process(items: impl Iterator<Item = Tx>) { ... }   // static: monomorphized, fast
fn register(handlers: Vec<Box<dyn Handler>>) { ... }   // dynamic: one vtable, heterogeneous
```

`impl Trait` (and generic `<T: Trait>`) compile to specialized code per type — the default, and what hot paths want. `dyn Trait` trades a pointer indirection for a smaller binary and the ability to hold different concrete types together. Reach for `dyn` at boundaries and for heterogeneous collections; stay generic where performance matters.

## Smart pointers: which one

- **`&T` / `&mut T`** — borrow; the default. No ownership, no allocation.
- **`Box<T>`** — single heap owner; for recursive types or moving a large value cheaply.
- **`Rc<T>` / `Arc<T>`** — shared ownership; `Rc` single-threaded, `Arc` across threads. Add a `Mutex` / `RwLock` only when you also need shared *mutation*.
- **`Cow<'a, T>`** — borrow until you must mutate, then clone-on-write. Good for APIs that usually don't allocate.

Reach for the cheapest one that expresses the ownership you actually need.

## Module structure

```
src/
├── lib.rs              # crate root, re-exports public surface
├── error.rs            # public error type(s)
├── client/
│   ├── mod.rs          # public Client type
│   ├── request.rs
│   └── response.rs
└── internal/           # not re-exported
    └── ...
```

`mod.rs` (or `<name>.rs` since 2018 edition) is the module's root. The crate root re-exports what's public.

## Doc comments

```rust
/// Fetches the value stored under `key`.
///
/// # Errors
/// Returns [`FetchError::NotFound`] when the key is absent.
pub fn fetch(key: &str) -> Result<Data, FetchError> { ... }
```

`///` on public items, `//!` for the module. Document the error and panic conditions. The example compiles and runs under `cargo test`, so the docs can't drift from the code.

## Related

- [`developer.md`](./developer.md) — fuller rationale.
- [`gotchas.md`](./gotchas.md) — what to avoid.
- [Effective Rust](https://effective-rust.com/) · [The Rust Book](https://doc.rust-lang.org/book/) — the upstream practice references.
- [Idiomatic Rust](https://github.com/mre/idiomatic-rust) · [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) — the idiomatic-Rust corpus and API conventions.
