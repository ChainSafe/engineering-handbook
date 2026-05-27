---
title: Go Developer
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 3_development/2_tech-stack/go.md
language: go
role: developer
last_updated: 2026-05-27
---

# Go Developer

Idiomatic Go development at ChainSafe. Tooling, dependency management, testing, CI, panic discipline, and the patterns that come up in code review week after week.

> **In one line:** Lint clean, type-check clean, test what changed, mock locally only. Pass by value unless you have a reason; pass `context.Context` always.

## Tooling

### Linting

[`golangci-lint`](https://golangci-lint.run/) is the standard. Install at a pinned version:

```sh
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.46
```

A `.golangci.yml` at the repo root pins enabled linters. The legacy configuration is a strong starting point; copy it and adjust per-project. Pin the version in CI — different linter versions catch different things.

### Mocking

[`golang/mock`](https://github.com/golang/mock) (gomock). Preferred over `vektra/mockery` for type-safety and Go-API stability.

Conventions:

- **Per-package mocks.** In each package needing mocks, two files: `mocks_generate_test.go` with the `//go:generate mockgen` directive, and `mocks_test.go` (generated). The `_test.go` suffix keeps mocks out of the package's exported surface.
- **Never export mocks.** They're a test-time artifact.
- **No `gomock.Any()`.** Use concrete arguments or custom matchers.
- **No `.AnyTimes()`.** State exact call counts (`.Times(n)`).
- **Always set `.Return(...)`** for functions that return.
- For subtests, build a fresh `gomock.NewController(t)` per subtest with the subtest's `t`.

The legacy guide has a full worked example with subtests and functional mock builders; it remains the right pattern. Mocks are committed; CI regenerates and `git diff --exit-code` catches drift.

### Dependency management

Go modules. `go.mod` and `go.sum` live in the repo. `go.sum` is never edited by hand.

- Pin tool versions in CI scripts (e.g., the linter, mockgen).
- Use `go mod tidy` before committing dependency changes.
- For monorepos with multiple modules, declare each module's own `go.mod`.

## Argument passing

The legacy guide's heuristics are still right:

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

Baseline (extending [`../../20-workflows/repo-and-ci-setup.md`](../../20-workflows/repo-and-ci-setup.md)):

- `go vet ./...`
- `gofmt -l .` — must produce no output.
- `golangci-lint run` with the project's `.golangci.yml`.
- `go test -race ./...` for race-sensitive packages; `go test ./...` everywhere else.
- `go build ./...` to confirm everything compiles.
- For projects with mocks: regenerate mocks and `git diff --exit-code`.

Pin Go version per-project in `go.mod` and the CI workflow.

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

- [`architect.md`](./architect.md) — design-level decisions.
- [`reviewer.md`](./reviewer.md) — what to look for when reviewing a Go PR.
- [`idioms.md`](./idioms.md) and [`gotchas.md`](./gotchas.md).
- [`../../20-workflows/testing-and-qa.md`](../../20-workflows/testing-and-qa.md) — the broader testing posture this page lives under.
