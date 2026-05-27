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

## Related

- [`developer.md`](./developer.md) — fuller guidance with rationale.
- [`gotchas.md`](./gotchas.md) — the inverse: anti-idioms and common mistakes.
