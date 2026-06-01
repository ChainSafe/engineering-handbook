# TypeScript Developer

Idiomatic TypeScript at ChainSafe. Tooling, lint, testing, monorepo setup, and the patterns that come up in review.

> **In one line:** `strict: true`. ESLint with the [ChainSafe shared config](https://github.com/ChainSafe/eslint-config). Yarn 3 workspaces for monorepos. No `any`, no floating promises, no `as` casts without a guard.

## Tooling

### Linter

ESLint with the [`@chainsafe`](https://github.com/ChainSafe/eslint-config) shared config:

```sh
yarn add --dev eslint@8 @chainsafe/eslint-config
```

`.eslintrc.cjs`:

```js
module.exports = {
  extends: "@chainsafe",
};
```

Run via `yarn lint` (script: `eslint 'src/**/*.ts'`). If a rule feels wrong, the right move is to PR the shared config, not local override.

Prettier is included transitively for formatting. Run `prettier --check` in CI.

### TypeScript config

A strict-by-default `tsconfig.json` baseline:

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

### Monorepos: Yarn 3 workspaces

ChainSafe uses **Yarn 3 with workspaces**, having migrated off `lerna`.

Setup:

1. **Enable corepack.** `corepack enable` (Node 16+) or `npm i -g corepack` for older.
2. **Root `package.json`** declares:
   ```json
   {
     "packageManager": "yarn@3.4.1",
     "workspaces": ["packages/*"]
   }
   ```
3. **Per-package `package.json`** with its own dependencies, `main`/`exports`, scripts.
4. **TypeScript project references** (`tsconfig.json` with `references: [...]`) for cross-package types and incremental builds.

A [template](https://github.com/ChainSafe/yarn-workspaces-typescript-template) exists; consult before bootstrapping from scratch.

### Testing

- **Vitest** for new projects (fast, ESM-native).
- **Mocha + Chai** in legacy Lodestar / web3.js (entrenched; don't rewrite without reason).
- **Jest** for projects where it's already set up.

Whichever framework: run via `yarn test`, configure with a `test/` or `__tests__/` convention. Coverage via the framework's built-in reporter; CI fails if coverage drops below a per-project threshold.

### Editor

VSCode is the de-facto editor; recommended extensions: ESLint, GitLens, DotEnv, YAML. Whatever IDE the developer prefers as long as it talks to `tsserver`.

## Type discipline

- **No `any` in committed code.** `unknown` for genuinely-typeless values; narrow before use. ESLint's `no-explicit-any` enforces.
- **`as` casts only with a guard.** A bare `value as Foo` is a lie. Use `typeof`, `instanceof`, or a schema validator (`zod`, `io-ts`) to narrow.
- **`unknown` over `any` for caught errors:** `try { ... } catch (err: unknown) { ... }`.
- **Discriminated unions** for state machines:
  ```ts
  type State =
    | { kind: "idle" }
    | { kind: "loading"; startedAt: number }
    | { kind: "loaded"; data: Data }
    | { kind: "error"; error: Error };
  ```
- **`readonly` on properties that don't mutate.** `as const` for literal narrowing.
- **Branded types** for domain values that shouldn't mix (see [architect.md § Branded types](./architect.md#branded-types-for-domain-values)).

## Async

- **`async`/`await`** for readability. Top-level await in ESM is fine.
- **`Promise.all`** for parallel independent work. **`Promise.allSettled`** when partial failure is acceptable.
- **No floating promises.** Either `await`, attach `.catch(...)`, or assign and await later. ESLint's `no-floating-promises` is on.
- **`AbortSignal` for cancellation.** Functions that can take a while should accept an optional `signal: AbortSignal`.
- **`for await ... of`** for sequential consumption of async iterables.

## Error handling

```ts
class FetchError extends Error {
  constructor(public readonly url: string, public readonly status: number) {
    super(`fetch ${url} failed: ${status}`);
    this.name = "FetchError";
  }
}

async function fetchData(url: string): Promise<Data> {
  const res = await fetch(url);
  if (!res.ok) throw new FetchError(url, res.status);
  return res.json() as Promise<Data>;  // (with a guard or schema in production code)
}
```

- **Throw `Error` subclasses.** Always. Never strings.
- **Distinguish recoverable from non-recoverable** by error class, not by inspecting messages.
- **`AggregateError`** for the `Promise.allSettled` multi-error case.

## CI

Baseline (extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md)):

- `yarn lint`
- `yarn prettier --check '**/*.{ts,json,md}'`
- `yarn tsc --noEmit` (type-check separately from build)
- `yarn build` (real build, catches different failures than `--noEmit`)
- `yarn test --coverage`
- `yarn audit` for vulnerability scanning
- Type-surface check (`tsd` / `expect-type`) for libraries publishing types

## Publishing npm packages

- **Semver discipline.** Major for breaking changes, minor for additive, patch for fixes. TypeScript-level breaking changes (renaming a type, narrowing a return) are also major.
- **`exports` field** in `package.json`, not just `main`. Modern Node resolution depends on it.
- **`files` field** to ship only `dist/` and necessary docs. Don't ship `src/` or tests.
- **CHANGELOG.md** updated in the same PR as the change. `changesets` (used in some ChainSafe projects) automates this nicely.
- **`prepublishOnly` script** runs build + tests one more time before publish.

## Patterns that come up in review

- **`unknown` then narrow** over `any`.
- **Discriminated unions** for "one of N states."
- **`readonly` arrays and tuples** for immutable data.
- **`Pick`, `Omit`, `Partial`, `Required`** for type composition rather than re-declaring.
- **Type predicates (`value is Foo`)** for custom type guards.
- **`satisfies`** for type-checking literal values without widening.

## Anti-patterns

- **`any` or `as Foo`** in committed code.
- **Floating promises.**
- **`default export`** when a named export would do.
- **`enum`** when a const object + `as const` produces better types.
- **`@ts-ignore`** without a comment and an issue link.
- **Untyped network responses.** Validate at the boundary.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md), [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md).
