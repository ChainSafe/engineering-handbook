---
title: TypeScript Reviewer
status: draft (v2)
authors:
  - "@kalambet"
language: typescript
role: reviewer
severity: SOFT WARNING (default tier)
last_updated: 2026-05-27
---

# TypeScript Reviewer

Language-specific checklist for TypeScript PRs. Operates under the [universal review principles](../../workflows/code-review.md#universal-principles).

> **In one line:** No `any`, no `as` without a guard, no floating promises, no `@ts-ignore` without justification. SOFT WARNING tier.

## Severity tier

Per [PLAN.md §7.5](../../PLAN.md#7-decisions-resolved-2026-05-27), TypeScript reviewer findings emit as **SOFT WARNING**. Agent flags, operator decides.

## What to look for

### Type discipline

- **`any` in committed code** → flag. `unknown` with narrowing is the right alternative.
- **`as` type assertions** → require an accompanying type guard or schema check. Bare `value as Foo` is lying to the compiler.
- **`@ts-ignore` / `@ts-expect-error`** → require a comment with a reason and ideally an issue link. CI should fail bare-comment forms.
- **`!` non-null assertion** → flag. Use a real narrowing or an explicit check.
- **Index access without bounds check** → with `noUncheckedIndexedAccess: true` the compiler catches this; verify the tsconfig has it on.
- **`Function` and `Object` types** → too wide. Use specific signatures.

### Module hygiene

- **Default exports** → ask if a named export would do. Default exports lose their name on import and complicate refactors.
- **Circular imports** → flag. They tend to produce undefined-at-load-time bugs.
- **Implementation imports of internals** → if a package's internal module is imported across package boundaries, the package's API surface is being violated.

### Async

- **Floating promises** → `.catch(...)` or `await` required. ESLint catches most; review catches the rest.
- **`Promise.all` over a large input calling a rate-limited service** → use `p-limit` or similar.
- **Missing `await` before a Promise-returning expression** → especially in conditionals (`if (somePromise)` is always truthy).
- **`async` functions that don't await anything** → probably should be sync.
- **No `AbortSignal` on long-running operations** → callers can't cancel; flag.

### Error handling

- **Thrown non-`Error` values** → strings, plain objects. Always throw an `Error` subclass.
- **`catch (err)` without typing as `unknown` and narrowing** → `err.message` access on an untyped catch is fragile.
- **`try`/`catch` that swallows errors** → at minimum log; usually re-throw or wrap.

### Tests

- **Type-level tests** for libraries publishing types — `tsd` or `expect-type` assertions covering the public surface.
- **Tests touch behavior, not implementation.** Asserting that an internal function was called is theatre.
- **`describe`/`it` names are sentences** — when the test name plus the assertion message tell you what broke, debugging is fast.
- **Coverage threshold enforced in CI** — not just reported.

### Build and config

- **`strict: true`** in tsconfig.
- **`noUncheckedIndexedAccess`** on for new projects.
- **`tsc --noEmit`** runs in CI as its own step, not just baked into the build.
- **Lint and format pass** locally before commit (pre-commit hook present?).
- **No `node_modules` or `dist` in PR diff.**

### Dependencies

- **No `latest` or floating versions** in `package.json`.
- **`yarn audit` clean** post-merge.
- **License-compatible** — GPL in an Apache 2.0 distribution is blocking.
- **No new dependencies without justification.** Each new dep is a supply-chain choice.

### Public API (for libraries)

- **New `export`s are deliberate.** Anything exported is a versioning commitment.
- **`@internal` JSDoc** on tooling-exported items that aren't public API.
- **CHANGELOG entry** in the same PR as a breaking change.

## What to flag vs. fix in place

- **Flag**: `any`, `as` without guards, floating promises, error-type issues, public-API decisions.
- **Suggest with code suggestion**: trivial lint, prettier, typo, JSDoc fix.
- **Don't fix and push** unless authorized.

## When the reviewer skill refuses to review

- Non-TypeScript code in diff.
- Empty PR description.
- Out-of-session-scope code.
- **No `strict: true` in tsconfig** — refuse and escalate. Type discipline is the foundation; reviewing under non-strict mode catches less than half the bugs.

## Phrasing

- Lead with concern: "This function takes `data: any` and forwards it to the network layer. What's the actual shape? If it's polymorphic, a discriminated union models it; if it's truly opaque, `unknown` plus a guard is the right call."
- Cite the rule: "Per [TS developer guide](./developer.md#type-discipline), `as` requires a guard."
- `nit:` for taste.

## Related

- [`architect.md`](./architect.md), [`developer.md`](./developer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/code-review.md`](../../workflows/code-review.md).
