# TypeScript Idioms

Idiomatic patterns in TypeScript at ChainSafe.

## Naming

- **Types and interfaces:** `PascalCase`.
- **Variables, functions, methods:** `camelCase`.
- **Constants (top-level, immutable):** `SCREAMING_SNAKE_CASE` for genuine constants; `camelCase` for module-level singletons.
- **Files:** `kebab-case.ts` for source, matching the primary export's name when sensible.
- **Type parameters:** single letter (`T`, `K`, `V`) when role is obvious; descriptive (`TItem`, `TError`) when not.

## Discriminated unions for state

```ts
type Async<T, E = Error> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: E };

function render(state: Async<User>) {
  switch (state.status) {
    case "idle": return spinner();
    case "loading": return spinner();
    case "success": return userCard(state.data);
    case "error": return errorBanner(state.error);
  }
}
```

The compiler enforces all cases are handled (with `noFallthroughCasesInSwitch`). Adding a new state case becomes a compile error in every consumer — exactly what you want.

## Branded types

```ts
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };

function getUserId(raw: string): UserId {
  // validate, then assert
  return raw as UserId;
}
```

Construction is centralized; once you have a `UserId`, the type system stops you from passing it where an `OrderId` is expected.

## `unknown` then narrow

```ts
function isUser(value: unknown): value is User {
  return (
    typeof value === "object" &&
    value !== null &&
    "id" in value &&
    typeof value.id === "string"
  );
}

const data: unknown = JSON.parse(raw);
if (isUser(data)) {
  // data is User
}
```

For larger schemas, use `zod`, `io-ts`, or `valibot` to validate at the boundary and infer types from the schema.

## `as const` for literal narrowing

```ts
const ROLES = ["admin", "editor", "viewer"] as const;
type Role = (typeof ROLES)[number];  // "admin" | "editor" | "viewer"
```

Avoid `enum`; `as const` plus `typeof[number]` produces a better-typed set with no runtime overhead.

## `satisfies` for type checking without widening

```ts
const config = {
  timeout: 5000,
  retries: 3,
  endpoints: { api: "/v1/api", health: "/v1/health" },
} satisfies AppConfig;

// config.endpoints.api stays the literal "/v1/api", not widened to `string`
```

`satisfies` checks shape without losing literal-type information.

## Type predicates

```ts
function isError(value: unknown): value is Error {
  return value instanceof Error;
}
```

Functions returning `value is Foo` participate in narrowing.

## Composition with utility types

```ts
type UserSummary = Pick<User, "id" | "name">;
type CreateUser = Omit<User, "id" | "createdAt">;
type PartialConfig = Partial<Config>;
type RequiredConfig = Required<Config>;
type ReadonlyUser = Readonly<User>;
```

Compose instead of re-declaring. The compiler keeps the relationship; refactors propagate.

## Async patterns

```ts
// parallel independent
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);

// allow partial failure
const results = await Promise.allSettled(jobs.map(run));
const succeeded = results.flatMap((r) => (r.status === "fulfilled" ? [r.value] : []));

// cancellable
async function fetchWithTimeout(url: string, ms: number) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), ms);
  try {
    return await fetch(url, { signal: ctrl.signal });
  } finally {
    clearTimeout(timer);
  }
}
```

## Error subclasses

```ts
export class FetchError extends Error {
  constructor(
    public readonly url: string,
    public readonly status: number,
    cause?: Error,
  ) {
    super(`fetch ${url} failed: ${status}`);
    this.name = "FetchError";
    if (cause) (this as any).cause = cause;  // Error.cause is stage-4
  }
}

try {
  await something();
} catch (err) {
  if (err instanceof FetchError && err.status === 404) {
    return null;
  }
  throw err;
}
```

Named subclasses let callers `instanceof`-discriminate without string-matching on the message.

## Exports

Named exports, single `index.ts` per module, no default exports for libraries:

```ts
// index.ts
export { Client } from "./client.js";
export type { ClientOptions } from "./client.js";
export * from "./errors.js";
```

The `.js` extension on imports is required for ESM resolution.

## Related

- [`developer.md`](./developer.md), [`gotchas.md`](./gotchas.md).
