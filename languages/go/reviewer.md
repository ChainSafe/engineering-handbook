---
title: Go Reviewer
status: draft (v2)
authors:
  - "@kalambet"
language: go
role: reviewer
severity: SOFT WARNING (default tier for non-security-critical languages — see PLAN.md §7.5)
last_updated: 2026-05-27
---

# Go Reviewer

Language-specific checklist when reviewing a Go PR. Operates under the [universal review principles](../../workflows/code-review.md#universal-principles); this page adds the Go-specific surface.

> **In one line:** Context propagation, goroutine ownership, error wrapping, mocks discipline. Findings emit as SOFT WARNING; operator decides on merge.

## Severity tier

Per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27), Go reviewer findings emit as **SOFT WARNING**. The agent flags, the operator decides. HARD FAIL is reserved for security-critical languages (Solidity, Daml).

## What to look for

### Concurrency

- **`context.Context` propagation.** Any function that does I/O, can block, or can be canceled must accept a `context.Context` as the first parameter. Verify it's used (not just accepted and ignored).
- **Goroutine ownership.** Every `go func()` must have a clear lifetime. Look for: a `context.Done()` exit path, a `defer wg.Done()` after `wg.Add(1)`, or a clearly-bounded scope. Bare `go func()` with no exit is a leak.
- **Unbounded concurrency.** A `for range items { go work(...) }` pattern with no limit is a memory and scheduler bug for large inputs. Look for worker pools, semaphores, or `errgroup.SetLimit`.
- **Data races.** Shared mutable state across goroutines without a mutex or channel is a race. `go test -race` should be on for the package.
- **Channel direction.** Channels passed to functions should declare their direction (`chan<- T` for send-only, `<-chan T` for receive-only). Bidirectional channels in function signatures are usually a missed opportunity.

### Errors

- **Wrapping.** `fmt.Errorf("...: %w", err)` to preserve the chain. Verify `%w`, not `%v`.
- **`errors.Is` / `errors.As`** at the call site for sentinel and typed errors respectively. Direct `==` comparison on errors is wrong post-1.13.
- **Sentinel discipline.** Sentinel errors (`var ErrFoo = errors.New("foo")`) should be exported only when callers need to match on them; document the contract.
- **No swallowed errors.** `_ = something()` deserves a comment.

### Panic

- **`panic` only on programmer error.** I/O errors, network errors, parse errors, user input — never. Flag any `panic` in production code paths and ask whether it should be an error return.
- **`recover` is suspicious in production code.** Test fixtures and the very top of a goroutine handler are the typical valid uses. Anywhere else, ask.

### Layout

- **`internal/` vs. `pkg/`.** New packages default to `internal/`. Moving to `pkg/` is a deliberate decision worth its own justification in the PR description.
- **Package names.** Single words, descriptive, match the directory. No `utils`, `helpers`, `common`, `misc`.
- **`main.go` minimalism.** The `main()` function wires; logic lives elsewhere.

### Testing

- **Race-sensitive code under `-race`.** If the package touches concurrency and CI isn't running `-race` on it, flag.
- **Mocks committed and regenerated.** `mocks_test.go` should match the current interface; CI should be checking with `git diff --exit-code` after regeneration.
- **No `gomock.Any()` or `.AnyTimes()`** without an explicit comment justifying the corner case (and almost always there's a better way; ask).
- **Subtests use their own `t.Run` controller.** Mocks built from the parent test's `t` leak between subtests.
- **Table tests** for >1 case; bare repeated assertions are a refactor candidate.

### Arguments and types

- **Pass by value unless** the type rule from [`developer.md` § Argument passing](./developer.md#argument-passing) says otherwise. Pointer receivers for "I will modify" or "this is large." Value receivers everywhere else.
- **`interface{}` / `any` parameters** are a flag. Ask what concrete type was intended; if generics fit better (Go 1.18+), suggest them.
- **No package-level mutable state.** Convert to constructor.

### Linting and formatting

- **`gofmt` clean.** Anything unformatted should never make it past CI; if it did, the CI baseline needs fixing.
- **`go vet` clean.** No `nolint` directives without a comment explaining why.
- **No `//nolint`** without a rationale.

### Dependencies (stdlib-first)

- **New entries in `go.mod` require justification.** Every external dep is a supply-chain decision. The PR description should say what stdlib (or `golang.org/x/*`) alternative was considered and why it was insufficient.
- **Project-approved deps are exempt** from per-PR justification: `golang/mock` (or `go.uber.org/mock`), `stretchr/testify`, `golangci-lint`-bundled linters. Anything else is a real decision.
- **Watch for the reflexive framework reach.** New HTTP server using `gin`/`echo`/`chi` when `net/http` + `http.ServeMux` would do (Go 1.22+ has method+path routing). New logger using `logrus`/`zap` when `log/slog` would do (Go 1.21+). Flag and ask.
- **ORM in a new service** → near-HARD scrutiny. ChainSafe Go services default to `database/sql` + `pgx`. An ORM (gorm, ent) needs a real case.

See [`architect.md` § Stdlib first](./architect.md#stdlib-first) for the full policy.

### Effective Go alignment (naming, commentary, structure)

- **Package names** are short, lowercase, single-word nouns. No `util` / `common` / `helpers`. Flag any new package with a generic name.
- **Getters without a `Get` prefix.** `Owner()`, not `GetOwner()`. Setters have `Set`.
- **Single-method interfaces named with `-er` suffix.** `Reader`, `Closer`, `Formatter`. Flag if a single-method interface uses a noun name.
- **MixedCaps**, not snake_case. Acronyms preserve case (`URL`, `ID`, `HTTP`).
- **Receivers** are one or two letters matching the type. Never `self` / `this` / `me`.
- **Doc comments on every exported identifier**, starting with the identifier's own name. Missing godoc on exported items is a SOFT WARNING.
- **Package comment** at the top of one file per package describing what the package does. Missing → SOFT WARNING.
- **Interface defined consumer-side**, not in the implementing package. Flag interfaces defined alongside their implementations unless there's a reason.
- **Accept interfaces, return concrete types.** A function returning `interface{...}` when a `*Foo` would do is over-abstracting; flag.
- **Receiver consistency.** A type with both pointer and value receivers, mixed, is confusing. Ask why.

See [Effective Go](https://go.dev/doc/effective_go) for the canonical reference.

## What to flag vs. fix in place

- **Flag** (review comment, not a fix): missing context propagation, goroutine leaks, error wrapping issues, panic-vs-error questions, mocking shortcuts, package-layout decisions, naming.
- **Suggest with code suggestion**: typos, lint-clean trivia, missing `defer cancel()` on a `context.WithTimeout`.
- **Don't fix and push** unless the operator has authorized co-authorship for this PR.

## When the reviewer skill refuses to review

- The diff contains code in a language other than Go (use the right reviewer skill).
- The PR description is empty (nothing to verify against).
- The diff touches packages out of the session's named scope.

## Phrasing

- Lead with the concern, not the fix: "This goroutine starts in `processBatch` and has no exit path other than `panic`. What's the intended lifetime?"
- Cite the rule when there is one: "Per [Go developer guide](./developer.md#panic), `panic` is for programmer error only — `processItem` accepts user input, so this should be a returned error."
- `nit:` for taste comments. "nit: `userMap` reads to me as plural; consider `usersByID`."

## Related

- [`architect.md`](./architect.md) and [`developer.md`](./developer.md) — what's being reviewed against.
- [`gotchas.md`](./gotchas.md) — the bug classes this checklist is screening for.
- [`../../workflows/code-review.md`](../../workflows/code-review.md) — the universal review framework.
- [`../../invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md#7-no-bypass-of-reviewer-skill-hard-fail-findings) — HARD FAIL semantics (Go reviewer findings are SOFT WARNING, not HARD FAIL).
