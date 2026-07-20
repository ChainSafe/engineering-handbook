# Go Developer

Idiomatic Go development at ChainSafe. Tooling, dependency management, testing, CI, panic discipline, and the patterns that come up in code review week after week.

> **In one line:** Lint clean, type-check clean, test what changed, mock locally only. Pass by value unless you have a reason; pass `context.Context` always.

## Tooling

### Linting

[`golangci-lint`](https://golangci-lint.run/) is the standard. Install at a pinned version:

```sh
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.46
```

A `.golangci.yml` at the repo root pins enabled linters. The [baseline config](./references/golangci-config.md) is a strong starting point; copy it and adjust per-project. Pin the version in CI — different linter versions catch different things.

### Mocking

[`golang/mock`](https://github.com/golang/mock) (gomock). Preferred over `vektra/mockery` for type-safety and Go-API stability.

Conventions:

- **Per-package mocks.** In each package needing mocks, two files: `mocks_generate_test.go` with the `//go:generate mockgen` directive, and `mocks_test.go` (generated). The `_test.go` suffix keeps mocks out of the package's exported surface.
- **Never export mocks.** They're a test-time artifact.
- **No `gomock.Any()`.** Use concrete arguments or custom matchers.
- **No `.AnyTimes()`.** State exact call counts (`.Times(n)`).
- **Always set `.Return(...)`** for functions that return.
- For subtests, build a fresh `gomock.NewController(t)` per subtest with the subtest's `t`.

The [gomock patterns reference](./references/gomock-patterns.md) has a full worked example with subtests and functional mock builders. Mocks are committed; CI regenerates and `git diff --exit-code` catches drift.

### Dependency management

Go modules. `go.mod` and `go.sum` live in the repo. `go.sum` is never edited by hand.

- Pin tool versions in CI scripts (e.g., the linter, mockgen).
- Use `go mod tidy` before committing dependency changes.
- For monorepos with multiple modules, declare each module's own `go.mod`.

## Argument passing

The argument-passing heuristics:

- **Prefer passing by value.** Removes nil risk; makes function behavior independent of mutation; clearer.
- **Slices** pass by value if you only mutate elements. Pass `*[]T` only if you need to change the slice length.
- **Maps, channels, most interfaces** are pointers under the hood — always pass by value.
- **Arrays:** by value if ≤80 bytes, by pointer if larger or if performance matters.
- **Structs:** by value if performance allows and you don't need to mutate non-pointer fields; by pointer otherwise.
- **Mutexes:** always by pointer (copying a mutex is a bug).

For **exported** functions outside `internal/`, fixed argument count + `Settings` struct for extensibility. For **unexported** functions and `internal/`, changing argument count is fine and is good — the compiler tells you when callers need updating.

## Panic

`panic` is for **programmer error**: states that should be impossible. Default switch cases on enums, sentinel-invariant violations, "this constructor only takes a positive integer and zero was passed."

`panic` is **not** for external-input errors (file missing, network down, parse failure, bad user input). Those return `error`.

`recover` is rarely used in production code. Test code uses it for asserting that a panic happened (`assert.PanicsWithValue` or equivalent).

## Testing

- **Unit tests** in `<package>_test.go` files, same package. Use the in-package test convention by default.
- **Black-box tests** in `<package>_test.go` with `package <name>_test` — when you want to test only the exported surface. Useful for documentation examples.
- **Table-driven tests** for any function with >1 case. Subtests via `t.Run(name, ...)`.
- **Parallel tests** with `t.Parallel()` when they don't share mutable state.
- **`go test -race`** in CI for any code touching concurrency. Catches data races early.

## CI

Baseline (extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md)):

- `go vet ./...`
- `gofmt -l .` — must produce no output.
- `golangci-lint run` with the project's `.golangci.yml`.
- `go test -race ./...` for race-sensitive packages; `go test ./...` everywhere else.
- `go build ./...` to confirm everything compiles.
- For projects with mocks: regenerate mocks and `git diff --exit-code`.

Pin Go version per-project in `go.mod` and the CI workflow.

## Dependency policy: stdlib first

ChainSafe's default for new Go code is **stdlib-first**. Reach for the standard library and the `golang.org/x/*` extension packages before reaching for anything else. External dependencies require a compelling case, documented in an ADR, and operator approval.

See [`architect.md` § Stdlib first](./architect.md#stdlib-first) for the full rationale and the list of project-approved deps that don't require per-use justification (`golang/mock` / `go.uber.org/mock`, `testify`, `golangci-lint`).

Common stdlib reaches that catch developers reflexively reaching for external libraries:

| Need | Use this from stdlib | Not these |
|---|---|---|
| HTTP server | `net/http` + `http.ServeMux` (Go 1.22+ has method+path patterns) | gin, echo, chi, gorilla/mux, fiber |
| Structured logging | `log/slog` (Go 1.21+) | logrus, zap, zerolog |
| JSON | `encoding/json` | jsoniter, easyjson (only if benchmarked) |
| Test assertions | `testing` (plus testify when established) | gocheck, ginkgo |
| Validation | hand-rolled `func Validate() error` methods | go-playground/validator (unless schema-driven) |
| Configuration | `flag` + `os.Getenv` (or simple unmarshalling) | viper |
| Database access | `database/sql` + `pgx` for Postgres | ORMs (gorm, ent) — usually overkill |
| HTTP client | `net/http` `Client` | resty, req |
| Templates | `text/template` / `html/template` | none needed |
| UUIDs | `crypto/rand` + hand-rolled, or `google/uuid` if v4 is fine | bigger deps |

Every external dep added to `go.mod` is a supply-chain decision. Treat each one accordingly.

## Effective Go alignment

ChainSafe Go follows [Effective Go](https://go.dev/doc/effective_go) as the canonical idiom guide. The following are the items that come up most in review at ChainSafe — see [`idioms.md`](./idioms.md) for the broader idiom set.

### Naming

- **Package names: short, lowercase, single-word nouns.** `store`, `http`, `metrics`. Not `storage_utils`. The package name *is* part of the namespace, so `store.Get` is fine; `store.GetStore` repeats the namespace.
- **Avoid generic package names** (`util`, `common`, `helpers`, `misc`) — they grow into junk drawers.
- **Getters don't carry a `Get` prefix.** `Owner()` not `GetOwner()`. Setters do carry `Set`: `SetOwner()`.
- **Single-method interfaces end in `-er`.** `Reader`, `Writer`, `Closer`, `Formatter`. Multi-method interfaces get a descriptive noun: `FileStore`, `BlockProcessor`.
- **`MixedCaps`** for multi-word names. Exported `MixedCaps`, unexported `mixedCaps`. Never `snake_case` (and never `ALL_CAPS` for constants either — `MaxItems`, not `MAX_ITEMS`).
- **Acronyms stay in case.** `URL` not `Url`, `ID` not `Id`, `HTTP` not `Http`. Applies in both exported and unexported names: `parseURL`, `userID`.
- **Receivers: one or two letters** matching the type. `s *Store`, not `store *Store` (and never `self` / `this` / `me`).

### Commentary (godoc)

- **Every exported identifier has a doc comment** starting with the name itself:
  ```go
  // Fetch retrieves the bytes at url. The returned error wraps any
  // underlying network or parse failure.
  func Fetch(ctx context.Context, url string) ([]byte, error) { ... }
  ```
- **Package comment** at the top of one file per package, describing what the package does:
  ```go
  // Package store provides durable persistence for orders, indexed
  // by buyer and seller party identifiers.
  package store
  ```
- Comments are sentences — start with a capital letter, end with a period. The first word *is* the identifier name; godoc relies on this convention.
- Comment **why**, not **what**. The code says what. Exceptions: regex, hard-to-understand algorithms, anything where intent isn't obvious from the code.

### Interfaces — consumer-side, small

- **Define interfaces where they are used,** not where they are implemented. The consumer knows the shape it needs; the implementer's concrete type satisfies whatever shape happens to fit.
- **Small interfaces win.** 1–3 methods. The standard library is full of single-method interfaces because they compose well.
- **Accept interfaces, return concrete types.** Functions take a `Reader`; return a `*Foo`. This keeps callers maximally flexible and implementations clear at the type level.

### Methods — receiver consistency

- **Pointer receiver** when the method modifies state, when the type is "large" (>~80 bytes), or when the type has a mutex.
- **Value receiver** when the method doesn't mutate and the type is small (basic types, small structs).
- **Don't mix** pointer and value receivers on the same type without a reason — it confuses callers about whether the type's zero value is usable.

### Control structures

- **No `else` after `return`.** Handle the error/edge, return, continue with the happy path un-indented:
  ```go
  if err != nil {
      return err
  }
  // happy path here
  ```
- **`for` is the only loop.** Range over arrays/slices/maps/channels.
- **`switch`** is more flexible than C's — cases break automatically; use `fallthrough` to override (rarely needed). Switch on values, types, or bare booleans (`switch {`).
- **`defer`** for cleanup, placed immediately after the resource is acquired. Arguments to `defer` are evaluated at *defer* time, not at call time.

### Functions

- **Multiple return values, especially `(value, error)`.** Don't try to encode errors as sentinel values; return them explicitly.
- **Named return values** for documentation and for `defer`-pattern manipulation of return values. Don't use them for "naked returns" in long functions — that's hard to read.

## Patterns that come up in review

- **`context.Context` as first parameter** for any operation that can be canceled or has a deadline. Never `context.TODO()` in committed code; either it's a real context (`context.Background()` at the top level, derived contexts below) or a `context.WithTimeout`/`WithDeadline`/`WithCancel`.
- **Errors wrapped with `%w`** to preserve the chain. Callers use `errors.Is` and `errors.As`.
- **Defer for cleanup** at the top of the function, immediately after the resource is acquired.
- **`if err != nil { return ..., fmt.Errorf("...: %w", err) }`** is the standard error-handling pattern. Don't elide the check.
- **No `else` after `return`.** Go style: handle the error, return, continue with the happy path at the original indent level.

## Anti-patterns

- **`panic` for non-fatal errors.** Use `error`.
- **Goroutines without context.** Leak hazards.
- **`init()` functions that connect to external services.** Hard to test, surprising at import time.
- **`interface{}` / `any` parameters.** Type-erase only when you must; document why.
- **Mocks reaching for `gomock.Any()`.** Be specific.
- **Package-level mutable state.** Use a constructor.

## Related

- [`architect.md`](./architect.md) — design-level decisions, including the stdlib-first ADR shape.
- [`reviewer.md`](./reviewer.md) — what to look for when reviewing a Go PR.
- [`idioms.md`](./idioms.md) and [`gotchas.md`](./gotchas.md).
- [`references/golangci-config.md`](./references/golangci-config.md) — the lint baseline (`.golangci.yml` + CI workflow).
- [`references/gomock-patterns.md`](./references/gomock-patterns.md) — detailed GoMock worked examples (subtests, custom matchers, mocks-check CI).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md) — the broader testing posture this page lives under.
- Upstream: [Effective Go](https://go.dev/doc/effective_go) — the canonical idiom guide this page aligns with.
- Upstream: [Go Standard Library](https://pkg.go.dev/std) — the default loadout for the stdlib-first policy.
