---
name: chainsafe-go-reviewer
description: Language-specific PR review for Go code at ChainSafe (Gossamer and Go-language projects). Use this skill whenever the user is reviewing a Go PR, asking for a Go code review, checking Go code for common mistakes, verifying a Go diff against ChainSafe conventions, looking for goroutine leaks, error-handling problems, panic misuse, or mock-discipline issues. EVEN IF the user does not explicitly ask for "Go review" — triggers on "review this Go PR", "is this Go code correct", "check this Go function", "look for issues in this Go file", "review the diff", "what's wrong with this Go", "lint review Go", "concurrency review", "context propagation review". Findings emit at SOFT WARNING severity (agent reports; operator decides on merge); the agent never blocks. Do NOT use for Go design decisions (use chainsafe-go-architect) or Go implementation guidance (use chainsafe-go-developer).
metadata:
  type: role-workflow
  language: go
  role: reviewer
  severity-tier: SOFT WARNING
  source: languages/go/reviewer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Go Reviewer

Reviewer skill for Go PRs. Operates under [`workflows/code-review.md`](../../workflows/code-review.md) (universal principles) and emits findings at **SOFT WARNING** severity — the agent flags, the operator decides on merge. The agent never blocks. The full reference is [`languages/go/reviewer.md`](../../languages/go/reviewer.md).

## Severity tier

**SOFT WARNING.** Per [PLAN.md §7.5](../../PLAN.md), Go is not in the security-critical-language list. HARD FAIL is reserved for Solidity and Daml.

## Checklist

### Concurrency

- `context.Context` propagation — every I/O or potentially-blocking function takes `ctx` as first parameter and uses it.
- Goroutine ownership — every `go func()` has a clear exit (ctx.Done, wg.Done, bounded scope).
- Unbounded concurrency — `for ... { go work() }` without limits is a bug for large inputs.
- Data races — shared mutable state across goroutines needs a mutex or channel; `go test -race` runs.
- Channel direction in function signatures (`chan<- T`, `<-chan T`).

### Errors

- `%w` (not `%v`) when wrapping with `fmt.Errorf`.
- `errors.Is` / `errors.As` at call sites, not direct `==` on errors.
- Sentinel errors documented as contract.
- No swallowed errors — `_ = something()` deserves a comment.

### Panic

- `panic` only on programmer error (impossible states, sentinel violations).
- I/O / network / parse / user input — never panic. Returns error.
- `recover` is suspicious in production paths.

### Layout

- New packages default to `internal/`. Move to `pkg/` only with explicit justification.
- Package names: single word, descriptive, no `utils`/`helpers`/`common`.
- `main.go` is minimal; logic lives elsewhere.

### Testing

- Race-sensitive code under `go test -race`.
- Mocks regenerated, no drift (`git diff --exit-code` after regenerate).
- No `gomock.Any()` or `.AnyTimes()` without explicit justification.
- Subtests build their own `gomock.NewController(t)`.
- Table-driven tests for >1 case.

### Arguments and types

- Pass-by-value default; pointer receivers only with reason.
- `interface{}` / `any` parameters — flag; suggest generics.
- No package-level mutable state.

### Lint and format

- `gofmt` clean.
- `go vet` clean.
- No `//nolint` without a comment.

## Refusal

The reviewer skill refuses to review and escalates if:

- Diff contains non-Go code (use the right reviewer skill).
- PR description is empty (nothing to verify against).
- Diff touches packages out of session scope.

## Phrasing

- Lead with concern, not fix: "This goroutine has no exit path. What's the intended lifetime?"
- Cite the rule when relevant.
- `nit:` for taste-level comments.
- Avoid "you" framing for design comments.

## Related

- Full reference: [`languages/go/reviewer.md`](../../languages/go/reviewer.md)
- Gotchas (review screening surface): [`languages/go/gotchas.md`](../../languages/go/gotchas.md)
- Universal review framework: [`workflows/code-review.md`](../../workflows/code-review.md)
- Sister roles: `chainsafe-go-architect`, `chainsafe-go-developer`
