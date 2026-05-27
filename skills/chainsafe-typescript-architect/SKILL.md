---
name: chainsafe-typescript-architect
description: Architectural guidance for designing TypeScript projects at ChainSafe (Lodestar, web3.js 4.x, ssz, bls, filsnap, other TS projects). Use this skill whenever the user is starting a new TypeScript project, designing a TS package, structuring a Yarn 3 monorepo workspace, picking ESM vs CJS, deciding on type strictness baseline, designing public APIs with branded types, choosing testing frameworks, or writing an ADR for TS work. EVEN IF the user does not explicitly say "architecture" — triggers on "design a TS package", "new TS project", "Lodestar architecture", "monorepo setup", "Yarn workspaces", "ESM or CJS", "branded types", "public API design", "ADR for TypeScript", "tsconfig strict baseline", "type-level tests". Defers to .invariance for invariants themselves. Do NOT use for line-level TS coding (use chainsafe-typescript-developer) or TS PR review (use chainsafe-typescript-reviewer).
metadata:
  type: role-workflow
  language: typescript
  role: architect
  source: 30-languages/typescript/architect.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# TypeScript Architect

Use this when designing TypeScript systems at ChainSafe — Lodestar-shaped work or any TS package/library/app. Full reference: [`30-languages/typescript/architect.md`](../../30-languages/typescript/architect.md).

## Key TypeScript-specific decisions

### Project layout

- **Monorepo:** Yarn 3 workspaces. (`lerna` is deprecated at ChainSafe.)
- **Root `package.json`** with `"packageManager": "yarn@3.x"` and `"workspaces": ["packages/*"]`.
- Each package: own `package.json`, `src/`, `test/`, `tsconfig.json`.
- Shared dev tooling (ESLint, Prettier, base tsconfig) at root; extended per-package.
- TypeScript build via `tsc -b` (composite projects) or bundler.

### Type strictness baseline

- **`"strict": true`** — non-negotiable floor.
- **`"noUncheckedIndexedAccess": true`** — array indexing returns `T | undefined`.
- **`"exactOptionalPropertyTypes": true`** when the project can take it.
- **`"isolatedModules": true`** for bundler compatibility.

### Module system

- **ESM by default** for new projects. `"type": "module"` in `package.json`, `.js` extensions in import paths.
- **CJS only** where downstream consumers require it.
- **Dual-publish** (`main` + `module` + `exports`) for libraries needing both.

### Branded types

```ts
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
```

Domain identifiers must not be interchangeable. Branded types enforce at the type level with zero runtime cost.

### Error model

- Throw `Error` subclasses (not plain `Error`) so callers can `instanceof` discriminate.
- `Result<T, E>` types for libraries where error-as-value semantics fit; throw for binary entrypoints.
- `AggregateError` for `Promise.allSettled` multi-error cases.
- Never throw strings or non-`Error` objects.

### Async

- `async`/`await` over raw promises for readability.
- `Promise.all` for parallel independent work.
- `Promise.allSettled` when partial failure is acceptable.
- No floating promises. ESLint's `no-floating-promises` catches.
- `AbortSignal` for cancellation propagation.

### Public API

- Type-level tests (`tsd`, `expect-type`) for libraries publishing types.
- Re-exports through a single `index.ts` per package.
- `@internal` JSDoc tag for tooling-exported items not in public API.

## ADR template for TypeScript work

- Public surface — what's exported. Type-level tests covering it.
- Async commitments — where cancellation propagates; where parallelism is exploited.
- Error contract — thrown types vs returned types.
- Build target — Node version, browser support, ESM/CJS, bundler.
- Invariants impacted — deep links into `.invariance`.

## Anti-patterns at design time

- `any` in committed code.
- `as` type assertions without runtime checks.
- Unbounded `Promise.all` over a large input calling a rate-limited API.
- Default exports.
- `enum` when a const object + `as const` produces better types.
- `tsc --noEmit` not in CI.

## Related

- Full reference: [`30-languages/typescript/architect.md`](../../30-languages/typescript/architect.md)
- Sister roles: `chainsafe-typescript-developer`, `chainsafe-typescript-reviewer`
- Framework: [`10-invariants/invariance-framework.md`](../../10-invariants/invariance-framework.md)
- Workflow: `chainsafe-research-plan-implement`
