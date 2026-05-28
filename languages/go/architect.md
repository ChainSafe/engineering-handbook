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

## ADR shape for Go services

When opening an ADR for a Go service or significant Go module, the template should cover:

- **Public surface.** What's exported. Why.
- **Concurrency commitments.** Goroutine ownership, context propagation, cancellation semantics.
- **Error contract.** What errors callers see. Which are sentinel, which are typed, which are wrapped.
- **Resource ownership.** Connections, files, goroutines — who closes them, when.
- **Invariants impacted.** Deep links into `.invariance` for the architectural invariants this decision touches.

## Anti-patterns

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
