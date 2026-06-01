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

## Related

- [`developer.md`](./developer.md) — fuller rationale.
- [`gotchas.md`](./gotchas.md) — what to avoid.
