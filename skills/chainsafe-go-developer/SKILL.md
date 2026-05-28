---
name: chainsafe-go-developer
description: Idiomatic Go development at ChainSafe — implementation-level guidance for writing Go code in Gossamer and other Go projects. Use this skill whenever the user is writing Go code, asking how to do something in Go, debugging Go, picking between Go patterns at the line/function level, setting up Go tooling, configuring golangci-lint, writing Go tests, mocking interfaces in Go, dealing with context propagation, structuring errors with %w, or any other concrete Go coding task. EVEN IF the user does not say "Go" explicitly but the file in scope is .go. Triggers on "write a Go function", "implement in Go", "how do I X in Go", "fix this Go code", "test this Go function", "mock this interface", "lint my Go", "Go CI setup", "context handling", "gomock", "table-driven test", "%w vs %v", "error wrapping in Go", ".golangci.yml". Do NOT use for Go architectural design (use chainsafe-go-architect) or Go PR review (use chainsafe-go-reviewer).
metadata:
  type: role-workflow
  language: go
  role: developer
  source: languages/go/developer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Go Developer

Idiomatic Go implementation at ChainSafe. The full reference is [`languages/go/developer.md`](../../languages/go/developer.md); load that file for complete guidance. This skill is the operational summary.

## Tooling baselines

- **Linter:** [`golangci-lint`](https://golangci-lint.run/) pinned to a specific version in CI. Use `.golangci.yml` at repo root.
- **Mocking:** `golang/mock` (gomock). Per-package, kept in `mocks_test.go` (generated) + `mocks_generate_test.go` (the `//go:generate` directive). Never export mocks.
- **Modules:** `go.mod` + `go.sum` committed; `go.sum` never edited by hand.
- **Race detector:** `go test -race` in CI for any package touching concurrency.

## Mock discipline (most-flagged in review)

- **No `gomock.Any()`.** Use concrete arguments or custom matchers.
- **No `.AnyTimes()`.** State exact call counts.
- **Always set `.Return(...)`** for functions that return.
- For subtests, build a fresh `gomock.NewController(t)` per subtest. Mocks built from parent `t` leak between subtests.
- Use functional mock builders (`func(ctrl *gomock.Controller) Fetcher`) for table-driven tests with mocks.

## Argument passing

- **Default to pass-by-value.** Reduces nil-risk; clearer behavior.
- **Slices:** by value if you mutate elements; `*[]T` only to change slice length.
- **Maps, channels, most interfaces:** always by value (pointers under the hood).
- **Structs:** by value if performance allows; by pointer if you need to mutate non-pointer fields or if >80 bytes.
- **Mutexes:** always by pointer.

## Panic

- `panic` is **only** for programmer error — impossible states, sentinel-invariant violation, default switch on enum.
- I/O errors, network errors, parse failures, user input — return `error`. Never panic.
- `recover` only in test code (`assert.PanicsWithValue`).

## Context

```go
func DoThing(ctx context.Context, arg T) (Result, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    // ...
}
```

`ctx` is the first parameter. Always. Never `context.TODO()` in committed code. Pass `ctx` down; do not store in structs except in narrow framework cases.

## Errors

```go
data, err := fetch(ctx, url)
if err != nil {
    return fmt.Errorf("fetching %s: %w", url, err)
}
```

- `%w` to preserve the chain.
- Lowercase first letter, no trailing punctuation.
- Context before the error: `"fetching %s: %w"`, not `"%w while fetching"`.
- Callers use `errors.Is` / `errors.As`.

## Testing

- Table-driven tests for >1 case. Map-keyed for free naming; subtests for isolation.
- `t.Parallel()` when tests don't share mutable state.
- `go test -race ./...` for race-sensitive packages.

## CI baseline

- `go vet ./...`
- `gofmt -l .` → no output
- `golangci-lint run`
- `go test -race ./...`
- `go build ./...`
- Mocks regenerated; `git diff --exit-code` confirms no drift.

## Anti-patterns

- `panic` for non-fatal errors.
- Goroutines without `context.Context`.
- `init()` connecting to external services.
- `interface{}` / `any` parameters (use generics where possible).
- Mocks with `gomock.Any()`.
- Package-level mutable state.

## Related

- Full reference: [`languages/go/developer.md`](../../languages/go/developer.md)
- Idioms cheat sheet: [`languages/go/idioms.md`](../../languages/go/idioms.md)
- Gotchas: [`languages/go/gotchas.md`](../../languages/go/gotchas.md)
- Sister roles: `chainsafe-go-architect`, `chainsafe-go-reviewer`
- Workflow: `chainsafe-research-plan-implement`
