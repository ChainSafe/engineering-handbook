---
name: chainsafe-go-architect
description: Architectural guidance for designing Go services and systems at ChainSafe (Gossamer and Go projects). Use whenever the user starts a new Go service, designs a Go module, writes an ADR for Go work, picks concurrency patterns, decides on a public API surface, structures a Go workspace, or makes any Go-specific architectural decision. EVEN IF the user does not explicitly say "architecture" — triggers on "design a Go service", "new Go module", "Go project layout", "concurrency model in Go", "public API for this Go package", "ADR for Go", "internal vs pkg", "channels or mutexes", "interface design in Go", "context propagation", "goroutine ownership". Defers to `.invariance` for invariants. Do NOT use for line-level Go coding (use chainsafe-go-developer) or Go PR review (use chainsafe-go-reviewer).
metadata:
  type: role-workflow
  language: go
  role: architect
  source: languages/go/architect.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Go Architect

Use this when designing Go systems at ChainSafe — Gossamer-shaped work or any Go service/library.

## Operating context

You are the architect role for Go work. The architectural framework (invariant naming, lifecycle, testability) is `.invariance`; consult [`invariants/invariance-framework.md`](../../invariants/invariance-framework.md) and the upstream `.invariance` repo before proposing a design. This skill covers what is Go-specific *under* that framework.

The full reference is [`languages/go/architect.md`](../../languages/go/architect.md). Load that file for the complete guidance.

## Key Go-specific decisions

When designing a Go system or module, address:

- **Project layout.** `cmd/<app>/main.go` for binaries (minimal logic, just wiring). `internal/` is the default home for all non-library code. `pkg/` is *limited and stable* — a package moves there only when it has proven stable with deep test coverage and the team commits to semver.
- **Public surface discipline.** Start everything in `internal/`. Export only when keeping it private costs more than locking in a public API.
- **Concurrency model.**
  - Lifetimes via `context.Context`. Every long-running operation accepts `ctx` as the first parameter.
  - Channels for ownership transfer; mutexes for shared state. Mixing patterns in one component is a smell.
  - Bounded concurrency — never unbounded `go func()` spawn. Use worker pools, semaphores, or `errgroup` with limits.
  - No package-level mutable state.
- **Error model.** Errors are values. Sentinel errors with `errors.Is`, typed errors with `errors.As`. `fmt.Errorf("...: %w", err)` to preserve context. Never `panic` for non-fatal errors.
- **Dependency injection.** Functional options or explicit `Settings` structs. No globals, no hidden singletons.

## ADR template for Go work

Every non-trivial Go ADR should cover:

- Public surface: what's exported, why.
- Concurrency commitments: goroutine ownership, context propagation, cancellation.
- Error contract: which errors callers see, sentinel vs typed vs wrapped.
- Resource ownership: connections, files, goroutines — who closes them, when.
- Invariants impacted: deep links into `.invariance`.

## Defer to `.invariance` for

- The invariant definitions and lifecycle.
- Cross-service contracts.
- Failure-mode invariants.

This skill covers Go-specific *shape*; the framework is upstream.

## Anti-patterns to flag at design time

- Wide `pkg/` directory.
- Goroutines without `context.Context`.
- `interface{}` / `any` crossing module boundaries.
- `init()` functions doing work.
- Reach for `sync.Map` when a domain-specific structure would do.

## Related

- Full reference: [`languages/go/architect.md`](../../languages/go/architect.md)
- Sister roles: `chainsafe-go-developer` (implementation), `chainsafe-go-reviewer` (PR review)
- Workflow: `chainsafe-research-plan-implement` for the design-to-implementation flow
- Framework: [`invariants/invariance-framework.md`](../../invariants/invariance-framework.md)
