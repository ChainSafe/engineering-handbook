---
title: TypeScript Gotchas
status: draft (v2)
authors:
  - "@kalambet"
language: typescript
last_updated: 2026-05-27
---

# TypeScript Gotchas

Common bug classes and surprising behavior in TypeScript.

## `any` propagates silently

```ts
function take(x: any) { return x.foo.bar.baz; }   // no errors
```

`any` flows through expressions. Once it's in your codebase, it spreads. Reach for `unknown` instead and narrow.

## `as` lies to the compiler

```ts
const value = somethingUnsafe as User;
// the runtime value is whatever it is; the compiler thinks it's a User
```

`as` is a developer assertion. Use a type guard or schema validator. If you must `as`, comment why.

## `!` non-null assertion

```ts
const user = users.find((u) => u.id === id)!;
```

If the find returns undefined, you get a runtime crash with a worse stack than a proper error. Use an explicit check.

## `[]` access without `noUncheckedIndexedAccess`

```ts
const arr: string[] = [];
const first: string = arr[0];   // compiler says string; runtime says undefined
```

Enable `"noUncheckedIndexedAccess": true` in tsconfig. The type becomes `string | undefined` and you have to handle it.

## Floating promises

```ts
async function fireAndForget() {
  doStuffAsync();   // returns a Promise; not awaited; errors silently swallowed
}
```

Either `await`, `.catch(...)` it, or assign and await later. ESLint catches; turn the rule on.

## `for ... in` vs `for ... of` on arrays

```ts
const arr = [10, 20, 30];
for (const i in arr) { /* i is the string "0", "1", "2" */ }
for (const v of arr) { /* v is 10, 20, 30 */ }
```

`for ... in` iterates keys (and inherited enumerable properties). For arrays, almost never what you want.

## `JSON.parse` returns `any`

```ts
const data = JSON.parse(raw);   // any
data.user.id;                    // no error, runtime crash possible
```

Validate the result with a schema (`zod`, `io-ts`, `valibot`) or a hand-written type guard.

## `process.env` returns `string | undefined`

```ts
const port: number = parseInt(process.env.PORT);   // NaN if not set
```

Validate at boot. Set defaults explicitly. `env.ts` modules that parse and freeze environment config catch this.

## `Promise.race` and ignored losers

```ts
const winner = await Promise.race([fetchA(), fetchB()]);
// fetchB still runs to completion if A wins. If it errors, you have an unhandled rejection.
```

`AbortController` to actually cancel the loser, or `Promise.any`/`Promise.allSettled` depending on intent.

## `setTimeout` does not return a number in Node

```ts
const t: number = setTimeout(() => {}, 1000);   // type error in Node typings; returns Timeout
```

`ReturnType<typeof setTimeout>` is the portable type. Don't store it as `number`.

## Recursive types and `infer`

```ts
type Flat<T> = T extends (infer U)[] ? Flat<U> : T;   // TS 5+ supports
```

Older TypeScript versions hit recursion limits. Check the project's TypeScript version before reaching for deep recursive types.

## `tsc` and bundler disagreements

`tsc --noEmit` may pass; the bundler (esbuild, swc, vite) may still fail at build time. Run both in CI. They check different things.

## Class field initialization order

```ts
class Foo {
  private a = this.b;   // ReferenceError at runtime (b is undefined here)
  private b = 1;
}
```

Field initialization is top-to-bottom; don't reference fields declared later.

## `===` vs `==` with `null` / `undefined`

```ts
if (x == null) { /* true for both null and undefined */ }
if (x === null) { /* true only for null */ }
```

`== null` is the one place loose-equality is idiomatic — when you want both. Otherwise `===`.

## `Map` and `Set` JSON serialization

```ts
const m = new Map([["a", 1]]);
JSON.stringify(m);   // "{}"
```

`Map` and `Set` aren't JSON. Convert (`Array.from(m.entries())`) or use a serialization library.

## `Date` is mutable and timezone-fraught

```ts
const d = new Date();
d.setDate(d.getDate() + 1);   // mutates d
```

Use `temporal` polyfill (when available) or `date-fns` (immutable functions) for non-trivial date math. Always store UTC; convert at display.

## `try`/`catch` and `Error.cause`

```ts
try { ... } catch (err) {
  throw new MyError("wrapping", { cause: err });
}
```

`Error.cause` (stage-4 / ES2022) is widely supported now. Use it to preserve the chain when re-throwing.

## ESM and CJS interop

```ts
// in an ESM project:
import express from "express";   // works
import { Router } from "express";   // may not work depending on Express version
```

CJS packages don't always behave well under ESM imports. Check the package's `exports` field. When in doubt, default-import then destructure.

## Module resolution: `.js` in import paths

In ESM TypeScript projects with `"module": "NodeNext"`, imports must include the `.js` extension even though the file is `.ts`:

```ts
import { Client } from "./client.js";   // resolves client.ts at compile, client.js at runtime
```

Counterintuitive but correct.

## Related

- [`idioms.md`](./idioms.md), [`reviewer.md`](./reviewer.md).
