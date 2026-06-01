# TypeScript Architect

Architectural guidance for TypeScript projects at ChainSafe — [Lodestar](https://github.com/ChainSafe/lodestar) (Ethereum consensus client), [web3.js 4.x](https://github.com/ChainSafe/web3.js), [ssz](https://github.com/ChainSafe/ssz), [bls](https://github.com/ChainSafe/bls), [filsnap](https://github.com/ChainSafe/filsnap), and others. The architectural framework is `.invariance` (see the [pointer page](../../invariants/invariance-framework.md)).

> **In one line:** Strict mode, branded types for domain values, no `any`. ESM by default. Public API stability via type-level tests.

## Defer to `.invariance` for

| Decision | `.invariance` section |
|---|---|
| Service boundaries | Component contracts *[anchor pending — @boorich]* |
| Invariant naming + testability | Invariant lifecycle *[anchor pending — @boorich]* |
| Cross-component contracts | API invariants *[anchor pending — @boorich]* |

## TypeScript-specific architectural choices

### Project layout

For most ChainSafe TS projects, **Yarn 3 workspaces** is the monorepo standard (the legacy `lerna` setup is deprecated). Layout:

- Root `package.json` with `"packageManager": "yarn@3.x"` and `"workspaces": ["packages/*"]`.
- Each package in `packages/<name>/` with its own `package.json`, `src/`, `test/`, `tsconfig.json`.
- Shared dev tooling (eslint config, prettier, base tsconfig) lives at the root and is extended per-package.
- TypeScript build via `tsc -b` (composite projects) or via a bundler (esbuild, swc) per package's needs.

For non-monorepo projects: standard `src/` + `test/`, single `package.json`, single `tsconfig.json`.

### Type strictness

- **`"strict": true`** in `tsconfig.json` is the floor. With every sub-flag on.
- **`"noUncheckedIndexedAccess": true`** — array indexing returns `T | undefined`. Catches a large class of bugs.
- **`"exactOptionalPropertyTypes": true`** when the project can take it.
- **`"isolatedModules": true`** for bundler compatibility.

### Module system

- **ESM by default** for new projects. `"type": "module"` in `package.json`, `.js` extensions in import paths.
- **CJS only where downstream consumers require it** (Node-only tooling, certain frameworks).
- **Dual-publish** (`main` + `module` + `exports`) for libraries that need to support both.

### Branded types for domain values

```ts
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };
```

Domain identifiers should not be interchangeable. Branded types catch the mix-up at the type level without runtime cost.

### Error model

- **Throw `Error` subclasses, not plain `Error` instances**, so callers can `instanceof` discriminate.
- **`Result<T, E>` or `Either`-like types** for libraries where error-as-value semantics fit; throw for binary entrypoints.
- **`AggregateError`** for Promise.allSettled-style multi-error cases.
- **Never throw strings or non-`Error` objects.** Always throw an instance with a stack.

### Async

- **`async`/`await` over raw promises** for readability.
- **`Promise.all` for parallel independent work; `Promise.allSettled` when you need each result's status; sequential `await` only when one operation depends on the previous.**
- **No floating promises.** Either `await`, `.then()`, or assign to a variable that's later awaited. ESLint's `no-floating-promises` catches.
- **AbortSignal** for cancellation propagation. Long-running operations accept an `AbortSignal`.

### Public API

- **Type-level tests** for public types — `tsd` or `expect-type` to assert the type surface doesn't drift.
- **Re-exports through a single `index.ts`** per package. Implementation files are not stable surface.
- **`@internal` JSDoc tag** for items that need to be exported for tooling reasons but aren't public API. API extractor tooling can enforce.

## ADR shape for TypeScript projects

When opening an ADR for a TS project or significant module:

- **Public surface.** What's exported. Type-level tests covering it.
- **Async commitments.** Where cancellation is propagated; where parallelism is exploited.
- **Error contract.** Thrown types vs. returned types. How callers should handle each.
- **Build target.** Node version, browser support, ESM/CJS, bundler.
- **Invariants impacted.** Deep links into `.invariance`.

## Anti-patterns

- **`any` in committed code.** `unknown` is the right escape hatch when you genuinely don't know the type.
- **`as` type assertions without a runtime check.** Lying to the compiler. Use guards or schema validation.
- **Unbounded `Promise.all` over a large input** that calls a rate-limited API. Use `p-limit` or similar.
- **Default exports.** Named exports are refactorable; default exports lose their name on import.
- **`enum`s when union types would do.** Const objects + `as const` produce better-typed sets.
- **`tsc --noEmit` not in CI.** Type errors should fail the build, not just IDE squiggles.

## Related

- [`developer.md`](./developer.md) — implementation-level practice.
- [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../invariants/invariance-framework.md`](../../invariants/invariance-framework.md) — the architectural framework.
