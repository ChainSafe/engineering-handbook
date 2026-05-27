---
name: chainsafe-typescript-developer
description: Idiomatic TypeScript development at ChainSafe — implementation-level guidance for writing TS in Lodestar, web3.js, ssz, bls, filsnap, and other TS projects. Use this skill whenever the user is writing TypeScript, asking how to do something in TS, debugging TS, picking between TS patterns, handling type narrowing, working with async/promises, configuring tsconfig or ESLint, setting up Yarn 3 workspaces, writing tests, or publishing npm packages. EVEN IF the user does not explicitly say "TypeScript" but the file is .ts or .tsx. Triggers on "write a TS function", "implement in TypeScript", "fix this TS", "how do I X in TS", "tsconfig strict", "ESLint config", "Yarn workspaces", "discriminated union", "branded type", "narrow this type", "type guard", "async pattern", "Promise.all", "AbortSignal", "Vitest", "publish to npm". Do NOT use for TypeScript architectural design (use chainsafe-typescript-architect) or TS PR review (use chainsafe-typescript-reviewer).
metadata:
  type: role-workflow
  language: typescript
  role: developer
  source: 30-languages/typescript/developer.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# TypeScript Developer

Idiomatic TypeScript at ChainSafe. Full reference: [`30-languages/typescript/developer.md`](../../30-languages/typescript/developer.md).

## Tooling baselines

- **Linter:** ESLint with `@chainsafe/eslint-config`. Run `yarn lint`.
- **Formatter:** Prettier (included transitively via the shared config). `yarn prettier --check` in CI.
- **TypeScript:** `"strict": true` floor; `"noUncheckedIndexedAccess": true` for new projects.
- **Monorepo:** Yarn 3 workspaces. `corepack enable`; `"packageManager": "yarn@3.x"`.
- **Testing:** Vitest for new projects; Mocha+Chai in entrenched Lodestar; Jest where set up.

## tsconfig baseline

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true,
    "isolatedModules": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "dist"
  }
}
```

Tighten per project; `strict: true` is the floor.

## Type discipline

- **No `any` in committed code.** `unknown` for genuinely-typeless values; narrow before use.
- **`as` casts only with a guard.** Use `typeof`, `instanceof`, or a schema validator (`zod`, `io-ts`).
- **`unknown` over `any` for caught errors:** `catch (err: unknown)`.
- **Discriminated unions** for state machines.
- **`readonly`** on properties that don't mutate; `as const` for literal narrowing.
- **Branded types** for domain values that shouldn't mix.

## Async

- `async`/`await` for readability.
- `Promise.all` for parallel; `Promise.allSettled` for partial-failure.
- No floating promises. ESLint catches.
- `AbortSignal` for cancellation: functions that can take time should accept optional `signal: AbortSignal`.
- `for await ... of` for sequential async iteration.

## Error handling

```ts
class FetchError extends Error {
  constructor(public readonly url: string, public readonly status: number) {
    super(`fetch ${url} failed: ${status}`);
    this.name = "FetchError";
  }
}
```

- Throw `Error` subclasses, never strings.
- Distinguish recoverable from non-recoverable by error class, not by message text.

## Monorepo setup (Yarn 3 workspaces)

1. Enable corepack: `corepack enable` (Node 16+).
2. Root `package.json`: `"packageManager": "yarn@3.4.1"`, `"workspaces": ["packages/*"]`.
3. Per-package `package.json` with its own deps and scripts.
4. TypeScript project references (`tsconfig.json` with `references: [...]`) for cross-package types.

Template: https://github.com/ChainSafe/yarn-workspaces-typescript-template.

## CI baseline

- `yarn lint`
- `yarn prettier --check '**/*.{ts,json,md}'`
- `yarn tsc --noEmit`
- `yarn build`
- `yarn test --coverage`
- `yarn audit`
- Type-surface check (`tsd`/`expect-type`) for libraries publishing types.

## Patterns

- **`unknown` then narrow** over `any`.
- **Discriminated unions** for state.
- **`readonly` arrays and tuples** for immutable data.
- **`Pick`, `Omit`, `Partial`, `Required`** for type composition.
- **Type predicates** (`value is Foo`) for custom guards.
- **`satisfies`** for type-checking literal values without widening.

## Anti-patterns

- `any` or `as Foo` in committed code.
- Floating promises.
- `default export` when named would do.
- `enum` when const object + `as const` produces better types.
- `@ts-ignore` without comment + issue link.
- Untyped network responses — validate at the boundary.

## Related

- Full reference: [`30-languages/typescript/developer.md`](../../30-languages/typescript/developer.md)
- Idioms: [`30-languages/typescript/idioms.md`](../../30-languages/typescript/idioms.md)
- Gotchas: [`30-languages/typescript/gotchas.md`](../../30-languages/typescript/gotchas.md)
- Sister roles: `chainsafe-typescript-architect`, `chainsafe-typescript-reviewer`
- Shared ESLint config: https://github.com/ChainSafe/eslint-config
