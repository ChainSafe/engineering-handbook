---
title: Go Idioms
status: draft (v2)
authors:
  - "@kalambet"
language: go
last_updated: 2026-05-27
---

# Go Idioms

Idiomatic patterns that come up often. Reference for both authors and reviewers; not exhaustive.

## Naming

- **Packages:** single word, all lowercase, descriptive (`store`, not `stores` or `storage_utils`). Match the directory name except for `package main`.
- **Variables:** short for short lifetimes (`i`, `err`, `ctx`), longer for broader scope. Avoid Hungarian notation; let types speak.
- **Acronyms:** keep the case consistent (`URL` not `Url`, `ID` not `Id`).
- **Receivers:** one or two characters matching the type (`s *Store`, not `store *Store`).

## Error handling

```go
data, err := fetch(ctx, url)
if err != nil {
    return fmt.Errorf("fetching %s: %w", url, err)
}
```

- Error message starts lowercase, no trailing punctuation.
- Context goes before the error: `fetching %s: %w`, not `%w while fetching`.
- Wrap with `%w`; let callers `errors.Is` / `errors.As`.

## Context

```go
func DoThing(ctx context.Context, arg T) (Result, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    // ...
}
```

- `ctx` is the first parameter, always.
- Derive new contexts with `WithTimeout`, `WithDeadline`, `WithCancel`, `WithValue` (sparingly).
- Always `defer cancel()` immediately after acquiring a cancellation function.
- Pass `ctx` down; never store it in a struct except in narrow framework-level cases.

## Early return

Handle errors and edge cases first; let the happy path stay un-indented.

```go
if err != nil {
    return err
}
if user == nil {
    return ErrNoUser
}
// happy path here, at the original indent
```

No `else` after `return`.

## Constructor pattern

```go
type Store struct { /* ... */ }

func NewStore(cfg Config) (*Store, error) {
    // validate cfg, return error if invalid
    return &Store{ /* ... */ }, nil
}
```

- Constructors named `New<Type>` (or `New` if it's the only one in the package).
- Configuration via a struct, not positional args, for extensibility.
- Functional options (`func(*Store)`) when configuration is genuinely optional and frequently mixed.

## Interface placement

Define interfaces where they are **consumed**, not where they are **implemented**. The consumer knows what shape it needs; the implementer's concrete type can satisfy whatever shape happens to be needed.

```go
// in package that uses the dependency:
type fetcher interface {
    Fetch(ctx context.Context, url string) ([]byte, error)
}

func (s *Service) Process(ctx context.Context, f fetcher) error { /* ... */ }
```

Small interfaces (1-3 methods) are good. Bigger interfaces are usually a sign the boundary isn't right.

## Defer for cleanup

```go
file, err := os.Open(path)
if err != nil {
    return err
}
defer file.Close()
```

Defer immediately after acquiring the resource. Don't bury defers deep in a function; the reader needs to see them at the top.

## Returning multiple values

`(T, error)` is the canonical pair. Named returns (`func DoThing() (result T, err error)`) are useful for documenting what the function returns and for `defer` patterns that modify return values, but don't overuse them — bare named returns in long functions are confusing.

## Table-driven tests

```go
func TestThing(t *testing.T) {
    cases := map[string]struct {
        in   T
        want U
        err  string
    }{
        "happy": {in: T{...}, want: U{...}},
        "empty": {in: T{}, err: "empty input"},
    }
    for name, c := range cases {
        t.Run(name, func(t *testing.T) {
            got, err := Thing(c.in)
            // assertions
        })
    }
}
```

Map-keyed test cases give you free naming; subtests give you isolation.

## Godoc commentary

Every exported identifier has a doc comment that begins with the identifier's name:

```go
// Store persists orders by buyer-seller pair. The zero value is not
// usable; construct with NewStore.
type Store struct { /* ... */ }

// Get returns the order for the given id, or ErrNotFound if no such order
// exists. It is safe to call from multiple goroutines.
func (s *Store) Get(id OrderID) (Order, error) { /* ... */ }
```

Every package has a package comment on the `package` clause in one file:

```go
// Package store provides durable persistence for orders indexed by
// buyer and seller party identifiers.
package store
```

godoc renders these into the standard documentation format and uses the first sentence as the summary. Write the first sentence to stand alone.

## Interface placement (consumer-side)

Define interfaces where they are **consumed**, not where they are **implemented**:

```go
// in the package that uses the dependency:
type fetcher interface {
    Fetch(ctx context.Context, url string) ([]byte, error)
}

func (s *Service) Process(ctx context.Context, f fetcher) error { /* ... */ }
```

The consumer knows the shape it needs; the producer's concrete type satisfies whatever shape happens to be needed. This keeps the producer's API surface narrow and lets multiple consumers each declare their own minimum interface.

Single-method interfaces are normal — the standard library is full of them (`io.Reader`, `io.Writer`, `fmt.Stringer`). Their names end in `-er`. Multi-method interfaces get descriptive nouns (`http.Handler`, `sort.Interface`).

## Accept interfaces, return concrete types

```go
// good: caller can pass any io.Reader
func ParseConfig(r io.Reader) (*Config, error) { /* ... */ }

// bad: forces caller to wrap in an interface even if they have a *Config
func Apply(c interface{ Validate() error }) error { /* ... */ }
```

A function takes interfaces so callers have flexibility about what to pass. A function returns concrete types so callers can use the full API of what they get back. Reversing this rule produces APIs that are simultaneously rigid (about inputs) and underspecified (about outputs).

## Receiver consistency

Pick pointer or value receivers per type and stick with the choice:

```go
// pointer receivers throughout — type carries state, is large, or has a mutex
type Store struct { mu sync.Mutex; items map[ID]Item }
func (s *Store) Get(id ID) Item { /* ... */ }
func (s *Store) Put(id ID, it Item) { /* ... */ }
```

Mixing pointer and value receivers on the same type without a reason confuses callers about whether the zero value is usable and whether copies preserve behavior. The rule of thumb:

- **Pointer receivers** when the method modifies state, when the type is large (>~80 bytes), or when the type has a `sync.Mutex` or similar.
- **Value receivers** for small immutable-like types where copying is cheap.

## Related

- [`developer.md`](./developer.md) — fuller guidance with rationale.
- [`gotchas.md`](./gotchas.md) — the inverse: anti-idioms and common mistakes.
- Upstream: [Effective Go](https://go.dev/doc/effective_go) — canonical idiom guide; this page draws from it.
