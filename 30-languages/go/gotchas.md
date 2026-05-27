---
title: Go Gotchas
status: draft (v2)
authors:
  - "@kalambet"
language: go
last_updated: 2026-05-27
---

# Go Gotchas

Common bug classes and surprising behavior in Go. Reviewer's screening list and author's pre-flight check.

## Loop variable capture (pre Go 1.22)

```go
// BUG (Go < 1.22):
for _, x := range items {
    go func() { use(x) }()  // all goroutines see the last x
}
```

Go 1.22+ scopes loop variables per-iteration, fixing this. For older code or unclear toolchain versions, bind explicitly:

```go
for _, x := range items {
    x := x  // shadow
    go func() { use(x) }()
}
```

Verify the project's `go.mod` Go version. Below 1.22, this is a real bug; above, it isn't.

## Nil interface vs. nil concrete type

```go
var e error
var pErr *MyError  // nil
if condition {
    pErr = computeError()
}
e = pErr  // e is now NON-nil even if pErr is nil

if e != nil { /* unexpectedly true */ }
```

An interface holding a typed nil is not nil. Return the bare `error` interface, not the concrete typed pointer.

## `append` and shared backing arrays

```go
a := []int{1, 2, 3, 4, 5}
b := a[1:3]                  // [2, 3], shares backing array
b = append(b, 99)            // b becomes [2, 3, 99]; a becomes [1, 2, 3, 99, 5]
```

Slices share underlying memory with their parents until appending forces a reallocation. If you need an independent slice, allocate one explicitly (`make` + `copy`).

## `defer` evaluation timing

Arguments to `defer` are evaluated **at defer time**, not at call time:

```go
i := 0
defer fmt.Println(i)  // prints 0
i = 5
return
```

Use a closure when you need the call-time value:

```go
defer func() { fmt.Println(i) }()  // prints 5
```

## Map iteration order

Go intentionally randomizes map iteration. Tests that depend on iteration order are flaky tests.

```go
for k, v := range m { /* order is NOT stable */ }
```

If order matters, extract keys, sort them, iterate.

## Goroutine leaks

```go
// LEAK: goroutine has no exit
go func() {
    for {
        select {
        case msg := <-ch:
            process(msg)
        }
    }
}()
```

Always include a `case <-ctx.Done():` branch (or equivalent done channel). Goroutines without an exit path live forever.

## Empty struct as a set / signal

```go
set := map[string]struct{}{}
set["key"] = struct{}{}
```

This is idiomatic and saves memory vs. `map[string]bool`. Use it for sets and for done-signaling channels (`chan struct{}`).

## Channel closed twice / send on closed

```go
close(ch)
close(ch)  // PANICS
ch <- 1    // PANICS if ch is closed
```

Closing is the **sender's** responsibility. Receivers detect closure via the second return value (`v, ok := <-ch`). Multiple senders → use a dedicated coordinator goroutine or a `sync.Once` around `close`.

## `time.After` in a loop leaks

```go
for {
    select {
    case <-time.After(time.Second):  // allocates a new timer every iteration; not GC'd until fires
        // ...
    case <-ctx.Done():
        return
    }
}
```

Use `time.NewTimer` + `Reset` (or `time.Ticker`) when looping.

## `sync.WaitGroup` `Add` after `Go`

```go
go func() {
    wg.Add(1)  // RACE: Wait may have already returned
    defer wg.Done()
    // ...
}()
```

`wg.Add(1)` must happen before the goroutine starts:

```go
wg.Add(1)
go func() {
    defer wg.Done()
    // ...
}()
```

## `os.Args` and config in `init()`

`init()` runs at import. Reading `os.Args`, env vars, or config in `init()` means tests can't override them and import order matters. Initialize lazily in a constructor.

## JSON encoding of typed `nil` slices vs. empty slices

```go
type Resp struct{ Items []Item `json:"items"` }

a := Resp{}              // marshals to {"items":null}
a.Items = []Item{}       // marshals to {"items":[]}
```

If your API contract says "empty array, not null," initialize to `[]T{}`.

## Pointer to range variable

```go
var ptrs []*Item
for _, item := range items {  // item is a value, reused each iteration
    ptrs = append(ptrs, &item)  // all point to the same memory in Go < 1.22
}
```

Same as the goroutine loop-capture issue. Go 1.22+ fixes; earlier versions need explicit binding (`item := item`).

## Mocks with `gomock.Any()` hide real bugs

The legacy guide is firm on this: never use `gomock.Any()`. Tests pass with it; real bugs hide behind it. If you can't specify the argument, your test isn't ready to be written.

## `%v` instead of `%w` in error wrapping

```go
return fmt.Errorf("doing X: %v", err)  // loses the chain
return fmt.Errorf("doing X: %w", err)  // preserves the chain for errors.Is / errors.As
```

`%v` formats; `%w` wraps. Almost always you want `%w`.

## Related

- [`idioms.md`](./idioms.md) — the inverse: how to do these things right.
- [`reviewer.md`](./reviewer.md) — uses this list as a screening surface.
