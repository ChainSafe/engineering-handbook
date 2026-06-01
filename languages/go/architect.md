---
title: Go Architect
status: draft (v2)
authors:
  - "@kalambet"
language: go
role: architect
last_updated: 2026-05-27
---

# Go Architect

Architectural guidance for Go projects at ChainSafe. The framework for architectural invariants is `.invariance` (see [§4a of PLAN.md](../../PLAN.md#4a-architecture--system-design--canonical-source-invariance) and the [pointer page](../../invariants/invariance-framework.md)). This page covers the Go-specific shape of decisions that sit under that framework.

> **In one line:** Small public surfaces. Concrete types behind interfaces only where they earn it. Errors are values; panics are programming bugs.

## Defer to `.invariance` for

Architectural decisions in this language should be expressed in `.invariance` terms wherever they apply. Start with the upstream framework and only return here for Go-specific shaping.

| If you are deciding… | Go to (`.invariance`) |
|---|---|
| What is the system boundary? | The framework's boundary-definition section *[anchor pending]* |
| What invariants does this service hold? | Invariant naming + testability *[anchor pending]* |
| How does this service interact with others? | Cross-component contracts *[anchor pending]* |
| What's the failure model? | Failure-mode invariants *[anchor pending]* |

Anchors confirmed when the pointer page in `invariants/invariance-framework.md` is finalized with [@boorich](https://github.com/boorich).

## Go-specific architectural choices

### Project layout

ChainSafe's Go projects (notably [Gossamer](https://github.com/ChainSafe/gossamer)) follow the conventional Go layout:

- `cmd/<app>/main.go` — the entrypoint(s). One `main.go` per binary; minimal logic, just wiring.
- `internal/` — packages the project uses but does not export. Default home for all non-library code.
- `pkg/` — packages exported for use by other Go projects. **Limited and stable.** A package moves from `internal/` to `pkg/` only when it has proven stable, has deep test coverage, and the team commits to semver.
- `examples/` — runnable examples for the public API.
- For libraries: no `cmd/`, no `pkg/`. Public API at the top level (`api.go`), internals in `internal/`.

### Public surface discipline

Engineering invariant §4 (composability) lands in Go as: **start everything in `internal/`**. Only export when the cost of keeping it private is higher than the cost of locking in a public API. Public Go APIs are versioning contracts — under-think them and you live with the consequences.

### Concurrency model

Choose deliberately. Go's primitives (goroutines, channels, contexts, sync primitives) compose powerfully but also footgun-prone. Architectural commitments worth making at the design stage:

- **Lifetimes via `context.Context`.** Every long-running operation accepts a `context.Context` as the first parameter. Cancellation propagates explicitly; goroutines without a context are goroutine leaks waiting to happen.
- **Channels for ownership transfer, mutexes for shared state.** Mixing the two patterns inside one component is a smell.
- **Bounded concurrency.** Unbounded `go func()` spawning is a memory and scheduler-pressure bug. Use worker pools, semaphores, or `errgroup` with limits.
- **No package-level mutable state.** It interacts badly with tests, with parallelism, and with init order.

### Error model

- **Errors are values.** Return them; check them; wrap them with `fmt.Errorf("...: %w", err)` for context.
- **Sentinel errors** for callers to match on via `errors.Is`. Document them.
- **Typed errors** for callers that need structured info via `errors.As`. Use sparingly.
- **No `panic` for non-fatal errors.** Panic is for programmer bugs that should crash the program (impossible state, invariant violation that means the binary is corrupt). See [Developer §panic](./developer.md#panic).

### Dependency injection

Functional options or explicit `Settings` structs for constructors. No global state, no hidden singletons. Tests build the system from the outside.

### Stdlib first

Go's standard library is unusually capable, and idiomatic Go leans on it heavily. ChainSafe's default for new Go code is **stdlib-first**: reach for an external dependency only when there's a compelling reason and the operator agrees.

**The default loadout — no justification required:**

- The Go standard library (everything at [pkg.go.dev/std](https://pkg.go.dev/std)).
- The `golang.org/x/*` extension packages (Go-team maintained — `x/sync`, `x/sys`, `x/net`, `x/crypto`, etc.). Treat these as stdlib-equivalent.
- Tools that ship with or are blessed by the Go distribution (`gofmt`, `go vet`, `go test`, `go mod`).

**Project-approved external deps — established at the org level:**

- `golang/mock` (or `go.uber.org/mock`) — testing mock generation. See [`references/gomock-patterns.md`](./references/gomock-patterns.md).
- `github.com/stretchr/testify` — test assertions, when not using stdlib's `testing` directly.
- `golangci-lint` and the linters it bundles — code quality. See [`references/golangci-config.md`](./references/golangci-config.md).

These are documented org-level choices; they don't require per-project justification.

**Everything else — needs a compelling case and operator approval:**

A web framework instead of `net/http`. A logging library instead of `log/slog`. A router instead of `http.ServeMux`. A retry/circuit-breaker library instead of `context`-driven retries. An ORM instead of `database/sql`. In each case, the question is: *what does this give us that the standard library can't, and is that worth the supply-chain, version-skew, and learning-curve cost?*

The architect's ADR must answer this explicitly:

- What stdlib (or `x/*`) primitive was considered first?
- What's missing or insufficient about it?
- Why is the external dep worth its cost in dependency surface, audit burden, and ongoing maintenance?
- What's the exit path if the dep becomes unmaintained?

Reaching for the popular framework reflexively is the anti-pattern. Most Go services don't need one. The standard library was designed by people who knew what they were doing; default to trusting them.

### Effective Go alignment

ChainSafe Go follows [Effective Go](https://go.dev/doc/effective_go) as the canonical idiom guide. The architect's job is to set up the codebase so following it is the path of least resistance:

- **Interfaces small and consumer-side.** Define interfaces where they are *used*, not where they are *implemented*. Single-method interfaces are normal — that's why the standard library is full of `Reader`, `Writer`, `Closer`. Interface names follow the `-er` convention for single-method interfaces.
- **Accept interfaces, return concrete types.** A function takes a `Reader`, returns a `*Foo`. This keeps callers maximally flexible and implementations maximally clear.
- **No package-level naming gymnastics.** Package names are short, lowercase, single-word nouns. The package name *is* the namespace, so `store.Get` is fine; `store.GetStore` is repetitive.
- **Getters do not have a `Get` prefix.** `owner` field → `Owner()` method. Setters do have a `Set` prefix.
- **`MixedCaps`, not `snake_case` or `lowerCamelCase` for multi-word names.** Exported identifiers `MixedCaps`, unexported `mixedCaps`.

These are detailed in [`developer.md`](./developer.md) and [`idioms.md`](./idioms.md); the architect's job is to not contradict them in the project's foundation.

## ADR shape for Go services

When opening an ADR for a Go service or significant Go module, the template should cover:

- **Public surface.** What's exported. Why.
- **Concurrency commitments.** Goroutine ownership, context propagation, cancellation semantics.
- **Error contract.** What errors callers see. Which are sentinel, which are typed, which are wrapped.
- **Resource ownership.** Connections, files, goroutines — who closes them, when.
- **Dependency choices.** Any external (non-stdlib, non-`x/*`, non-project-approved) dependency the design assumes, with the compelling-case justification per the stdlib-first rule above.
- **Invariants impacted.** Deep links into `.invariance` for the architectural invariants this decision touches.

## Anti-patterns

- **Reaching for a framework reflexively.** `net/http` + `http.ServeMux` (Go 1.22+ adds method+path routing) covers most service needs. Pick a router or framework only when stdlib genuinely can't deliver.
- **Wide `pkg/` directory.** Most things belong in `internal/` and stay there.
- **Goroutines without a `context.Context`.** Leak hazards.
- **`sync.Map` reached for instead of a domain-specific structure.** It's correct but usually wrong for the problem.
- **Empty interfaces (`interface{}` / `any`) crossing module boundaries.** Pushes typing problems onto callers.
- **`init()` functions doing work.** Hard to test, hard to control order.

## Related

- [`developer.md`](./developer.md) — implementation-level Go practice.
- [`reviewer.md`](./reviewer.md) — what to look for in a Go PR.
- [`idioms.md`](./idioms.md) and [`gotchas.md`](./gotchas.md) — shared shorter references.
- [`../../invariants/invariance-framework.md`](../../invariants/invariance-framework.md) — the architectural framework this page defers to.
