---
name: chainsafe-typescript-reviewer
description: Language-specific PR review for TypeScript code at ChainSafe (Lodestar, web3.js 4.x, ssz, bls, filsnap, other TS projects). Use this skill whenever the user is reviewing a TypeScript PR, asking for TS code review, checking TS code for common mistakes, looking for `any`/`as` misuse, floating promises, `@ts-ignore` abuse, error-handling issues, or public-API problems. EVEN IF the user does not explicitly ask for "TS review" — triggers on "review this TS PR", "is this TypeScript correct", "check this TS function", "look for issues in this .ts", "review the diff", "what's wrong with this TS", "type review", "any check", "promise review". Findings emit at SOFT WARNING severity (agent reports; operator decides on merge); agent never blocks. Do NOT use for TS design (use chainsafe-typescript-architect) or TS implementation guidance (use chainsafe-typescript-developer).
metadata:
  type: role-workflow
  language: typescript
  role: reviewer
  severity-tier: SOFT WARNING
  source: 30-languages/typescript/reviewer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# TypeScript Reviewer

Reviewer skill for TypeScript PRs. Universal review framework at [`20-workflows/code-review.md`](../../20-workflows/code-review.md); full reference at [`30-languages/typescript/reviewer.md`](../../30-languages/typescript/reviewer.md).

## Severity tier

**SOFT WARNING.** Agent flags; operator decides on merge.

## Checklist

### Type discipline

- `any` in committed code → flag. `unknown` with narrowing is the alternative.
- `as` type assertions → require an accompanying type guard or schema check.
- `@ts-ignore` / `@ts-expect-error` → require comment with reason and ideally an issue link.
- `!` non-null assertion → flag. Prefer explicit narrowing.
- Index access without bounds check → verify `noUncheckedIndexedAccess: true` is on.
- `Function` and `Object` types → too wide. Use specific signatures.

### Module hygiene

- Default exports → ask if named would do.
- Circular imports → flag; tend to produce undefined-at-load-time bugs.
- Implementation imports of internals across package boundaries → API surface violation.

### Async

- Floating promises → `.catch(...)` or `await` required.
- `Promise.all` over rate-limited APIs unbounded → use `p-limit`.
- Missing `await` before Promise-returning expressions (especially in conditionals).
- `async` functions that don't await anything → probably sync.
- No `AbortSignal` on long-running operations.

### Error handling

- Thrown non-`Error` values → always throw an `Error` subclass.
- `catch (err)` without typing as `unknown` and narrowing.
- `try`/`catch` swallowing errors → at minimum log; usually re-throw or wrap.

### Tests

- Type-level tests for libraries publishing types.
- Tests touch behavior, not implementation.
- `describe`/`it` names are sentences.
- Coverage threshold enforced in CI.

### Build and config

- `strict: true` in tsconfig.
- `noUncheckedIndexedAccess` on for new projects.
- `tsc --noEmit` as its own CI step.
- Lint and format pass before commit.
- No `node_modules` or `dist` in diff.

### Dependencies

- No `latest` or floating versions.
- `yarn audit` clean.
- License-compatible.
- No new deps without justification.

### Public API (for libraries)

- New `export`s are deliberate.
- `@internal` JSDoc on tooling-exported items.
- CHANGELOG entry in the same PR as breaking changes.

## Refusal

The reviewer skill refuses to review and escalates if:

- Non-TypeScript code in diff.
- Empty PR description.
- Out-of-session-scope code.
- **No `strict: true` in tsconfig** — refuse and escalate. Type discipline is the foundation.

## Phrasing

- Lead with concern: "This function takes `data: any` and forwards it to the network layer. What's the actual shape?"
- Cite the rule.
- `nit:` for taste.

## Related

- Full reference: [`30-languages/typescript/reviewer.md`](../../30-languages/typescript/reviewer.md)
- Gotchas: [`30-languages/typescript/gotchas.md`](../../30-languages/typescript/gotchas.md)
- Universal review: [`20-workflows/code-review.md`](../../20-workflows/code-review.md)
- Sister roles: `chainsafe-typescript-architect`, `chainsafe-typescript-developer`
