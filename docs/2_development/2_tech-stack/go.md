# Go

Our most notable Go projects:

* [Polkadot Gossamer](https://github.com/ChainSafe/gossamer)
* [ChainBridge Core](https://github.com/ChainSafe/chainbridge-core)
* [and others](https://github.com/chainsafe?q=&type=all&language=go&sort=)

## IDE configuration

:::note

TBD

:::

If you need a license for your development tooling, [read on how to request one](../../5_the-formal-stuff/process_and_policy.md#requesting-license)!

## Project structure

### Modules layout perspective

In the following, we assume your application name is `myapp` and the project name is `github.com/ChainSafe/repo`.

The file structure should look as follow:

```s
.
├── .git
├── cmd
|   └── myapp
|       └── main.go
├── examples
|   └── example1
|       └── main.go
├── internal
|   ├── config
|   |   └── config.go
|   └── store
|       └── store.go
├── pkg
|   ├── public1
|   |   └── public1.go
|   └── public2
|       └── public2.go
├── go.mod
└── go.sum
```

The `go.mod` file holds the project name, Go suggested version and dependencies of your Go project.
The `go.sum` should not be modified by hand, and only contains checksums for the dependencies.

#### The `cmd` directory

The `cmd` directory contains one directory per application.

In our case, we only have one application `myapp`, but it can contain multiple programs, for example:

```s
├── cmd
    ├── myapp
    |   └── main.go
    └── myotherapp
        └── main.go
```

Each application directory should only contain one file: `main.go`

Each `main.go` file represents the `package main` and should contain only the `main()` function.

Its code should be minimal, the bulk of the code should reside in the `internal` directory.

📖 The reading of the `main.go` file should be quick and provide a solid understanding of what the top moving pieces are.

#### The `internal` directory

Since Go 1.4, the [internal directory](https://golang.org/doc/go1.4#internalpackages) is treated specially.

It contains code that can be imported by other parts of the application but **not imported** by other Go projects as a dependency.

We thus use this directory to place packages internal to the project.

For example, in our case we have:

```s
├── internal
    ├── config
    |   └── config.go
    └── store
        └── store.go
```

The `internal/config` and `internal/store` directories contain the `config` and `store` packages respectively.

Each can be imported for example by `cmd/myapp/main.go` with:

```go
import (
 "github.com/ChainSafe/repo/internal/config"
 "github.com/ChainSafe/repo/internal/store"
)
```

But **cannot be imported by another Go project**, that is outside of `github.com/ChainSafe/repo`.

By default, you should place all your packages in the `internal` directory by creating a directory with the name of the package inside.

#### The `pkg` directory

Unlike `internal`, the `pkg` directory is more of a convention name.

The `pkg` directory is meant to contain packages to be imported by other projects.

In our example, we have:

```s
├── pkg
    ├── public1
    |   └── public1.go
    └── public2
        └── public2.go
```

We have two packages, `public1` and `public2`.
Each can be imported by any Go project (including this one) with for example

```go
import (
 "github.com/user/repo/pkg/public1"
)
```

⚠️ You should really limit the packages you place in the `pkg` directory.

Since these are exported to other projects, you should be careful about semver versioning to avoid breaking other Go projects depending on it.

It's always good practice to have all your packages in the `internal` directory, and only move them to the `pkg` directory once they have been proven to:

1. Be stable, ideally with full (and *deep*) unit testing coverage
2. Have their exported Go API stable

#### The `examples` directory

The `examples` directory should contain runnable examples to showcase your publicly exported Go API from `pkg`.

Each example should have a descriptive directory name and a runnable `main.go` file with only the `func main()` function.

For example:

```s
├── examples
    └── example1
        └── main.go
```

#### Go libraries

If you are writing a Go library with a single purpose, you might want to have your exported public Go API at the top level.
For example with this file structure:

```s
.
├── .git
├── examples
|   └── example1
|       └── main.go
├── internal
|   ├── package1
|   |   └── package1.go
|   └── package2
|       └── package2.go
├── api.go
├── go.mod
└── go.sum
```

The differences are as follows:

* no `cmd` directory since this is not a runnable application
* no `pkg` directory since this is a library, all exported Go API should be at the top level to reduce the length of import statements
* `api.go` file containing all your Go public API. It should contain your exported interfaces, constants and constructors.

Note that most of your code should still reside in the `internal` directory, and you should keep your public Go API to a minimum.

If it really makes sense, you may have directories at the top level to split the import statements.

### Business logic perspective

Beside official package layout recommendations describing packages structure and naming from the Go modules perspective, there is de facto standard named *Standard Package Layout* on how to organize your business logic, storage and abstractions.

First time concept was described by [Ben Jonson in an article with the same name](https://medium.com/@benbjohnson/standard-package-layout-7cdbc8391fc1). Another source of inspiration and a way to grasp the concept can be found in the beautiful [talk of Brain Ketelsen about Go best practices](https://www.youtube.com/watch?v=MzTcsI6tn-0).

### Other tips

* Package naming
  * Your package name should be the same as the directory containing it, **except for the `main` package**
  * Use single words for package names
  * Do not use generic names for package names such as `utils` or `helpers`
* Package nesting
  * Try to avoid nesting packages by default
  * You can nest packages if you have different implementations for the same interface (e.g. a store interface)
  * You can nest packages if you start having a lot of Go files (more than 10) and it really does make sense to make subpackages

## Linting

Use [golangci-lint](https://golangci-lint.run/):

```sh
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.46
```

Together with a `.golangci.yml` at the root of your project:

```yml title=".golangci.yml"
run:
  skip-dirs:
    - .github
  build-tags:
    - integration

linters-settings:
  misspell:
    locale: UK

issues:
  exclude-rules:
    # Do not run these linters for test files
    - path: _test\.go
      linters:
        - dupl
        - goerr113
        - containedctx
    # Do not require comments for sentinel errors
    - text: "exported: exported var Err*"
      linters:
        - revive
    # Allow long lines for //go:generate comments
    - linters:
        - lll
      source: "^//go:generate "

linters:
  # Default linters are enabled and not listed below:
  # https://golangci-lint.run/usage/linters/#enabled-by-default
  enable:
    - asciicheck
    - bidichk
    - bodyclose
    - containedctx
    - cyclop
    - decorder
    - dogsled
    - dupl
    - durationcheck
    - errchkjson
    - errname
    - exhaustive
    - exportloopref
    - forcetypeassert
    - gci
    - gochecknoglobals
    - gochecknoinits
    - gocognit
    - goconst
    - gocritic
    - gocyclo
    - godot
    - goerr113
    - goheader
    - goimports
    - gomnd
    - gomoddirectives
    - goprintffuncname
    - gosec
    - grouper
    - ifshort
    - importas
    - ireturn
    - lll
    - maintidx
    - makezero
    - misspell
    - nakedret
    - nestif
    - nilerr
    - nilnil
    - noctx
    - nolintlint
    - prealloc
    - predeclared
    - promlinter
    - revive
    - rowserrcheck
    - sqlclosecheck
    - tenv
    - thelper
    - tparallel
    - unconvert
    - unparam
    - wastedassign
    - whitespace
```

### Linting continuous integration

For your CI, you should have lint Github job. For example:

```yml title=".github/workflows/lint.yaml"
on:
  pull_request:
name: Linting

jobs:
  golangci-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-go@v3
      - uses: actions/checkout@v3
        uses: golangci/golangci-lint-action@v3
        with:
          version: v1.45
```

:::caution
Make sure to pin the linter version (`version: v1.45`) since the same linters can behave differently from a version to another.
:::

## Panic

In Go, `panic` should only be used when a **programming error** has been encountered.

For any error caused by external factors such as files or network, you should **NOT panic** and use errors instead.

An example of such a panic usage would be:

```go
type logLevel uint8

const (
  Info logLevel = iota
  Warn
  Error
)

func (l *logLevel) String() string {
  switch *l {
  case Info:
    return "info"
  case Warn:
    return "warn"
  case Error:
    return "error"
  default:
    // we panic since this should never happen
    panic(fmt.Sprintf("invalid log level: %d", *l))
  }
}
```

A `panic` should be placed such that its trigger condition is so critical that the program should crash and the end user should report it to the programmer.

Its counterpart `recover` should not really be used, except for testing a panic in test code (or use `assert.PanicsWithValue`).

## Continuous integration

:::note
TBD: testing
:::

* [Linting](#linting-continous-integration)

## Mocking

Mocking is useful in Go to mock behavior of Go interfaces for testing.

### Example production code

In the following sections, we will use the following example code:

```go title="something/something.go"
package something

import (
 "context"
 "fmt"
)

type Fetcher interface {
 Fetch(ctx context.Context) (data []byte, err error)
}

type Parser interface {
 Parse(data []byte) (id string, err error)
}

func something(ctx context.Context, fetcher Fetcher, parser Parser) (id string, err error) {
 data, err := fetcher.Fetch(ctx)
 if err != nil {
  return "", fmt.Errorf("cannot fetch: %w", err)
 }

 id, err = parser.Parse(data)
 if err != nil {
  return "", fmt.Errorf("cannot parse: %w", err)
 }

 return id, nil
}
```

where we want to test the `something` function using mocks for the `Fetcher` and `Parser` interfaces.

### Which mocking library

There are two main Go mocking libraries:

* [`vektra/mockery`](https://github.com/vektra/mockery)
* [`golang/mock`](https://github.com/golang/mock)

You should use [`golang/mock`](https://github.com/golang/mock) because:

* it is more type-safe and auto-completion is better
* its Go API is more stable
* it is more mature and has more star-gazers

Install it in your repository with:

```sh
go get github.com/golang/mock
```

### Mock generation

#### Tooling

Install the `mockgen` CLI from the [`golang/mock`](https://github.com/golang/mock) repository:

```sh
go install github.com/golang/mock/mockgen@v1.6.0
```

This is to be done only once on your development environment.

#### File setup

You should have two files **where the mocks are needed**:

* `mocks_generate_test.go`
* `mocks_test.go`

The `mocks_generate_test.go` is a single line file defining what mocks to generate, using a single `//go:generate mockgen` comment-command.

The `mocks_test.go` is the generate mock code for all the mocks needed by the package.

For example, to generate mocks for the `Fetcher` and `Parser` interfaces (defined in [the section above](#example-production-code)):

```go title="something/mocks_generate_test.go"
package something

//go:generate mockgen -destination=mocks_test.go -package $GOPACKAGE . Fetcher,Parser
```

You have to put each interface you want to generate a mock for at the end of the mockgen command, separated by commas.

In our example case, this is the `something` package name.

This file setup is designed such that:

* Mocks are only accessible to test files in the current Go package. Indeed `*_test.go` files are not exported and only accessible by other test files in the same package. This avoids pollution of the package Go API, and possible horrendous package dependencies.
* Minimal amount of files per package, and minimal Git diffs at code evolves
* No effect on Go test coverage, since `*_test.go` files are not included.
* Github auto collapses `*mock*` files in the PR diff view, making it easier to review.
* No particular mocking library or style is suggested to the user of the package, since no mock is exported.

:::caution
NEVER ever export mocks to other packages
:::

#### Generation command

Use `go generate -run mockgen ./...` to generate the mocks to `mocks_test.go`.

#### Generate mocks from other packages

You should really define interfaces locally in your package and use those to generate mocks.

Sometimes it however makes sense to use an interface such as `io.Reader` from the standard library. In that case, you can add another line to `mocks_generate_test.go`:

```go title="something/mocks_generate_test.go"
package something

//go:generate mockgen -destination=mocks_test.go -package $GOPACKAGE . Fetcher,Parser
//go:generate mockgen -destination=mocks_io_test.go -package $GOPACKAGE io Reader
```

Note the destination is now `mocks_io_test.go` to avoid conflicts with `mocks_test.go`. You can specify any import package path instead of `io` if needed.

### Mock usage

Now that your mocks are generated, you can use them in your Go tests in the `something` package.

Let's write a test for our `something` function defined in our example production code:

```go title="something/something_test.go"
package something

import (
 "context"
 "testing"

 "github.com/golang/mock/gomock"
 "github.com/stretchr/testify/assert"
)

func Test_something(t *testing.T) {
 ctrl := gomock.NewController(t)

 ctx := context.Background()
 fetcher := NewMockFetcher(ctrl)
 fetchCall := fetcher.EXPECT().
  Fetch(ctx). // define the expected argument(s)
  Return([]byte{1, 2, 3}, nil)  // define the returned values

 parser := NewMockParser(ctrl)
 parser.EXPECT().
  Parse([]byte{1, 2, 3}).
  Return("123", nil).
  After(fetchCall) // you can define the mock calls order with After()

 id, err := something(ctx, fetcher, parser)

 assert.NoError(t, err)
 assert.Equal(t, "123", id)
}
```

A few important points:

* **Never** use `gomock.Any()` as argument. Always use concrete, precise arguments. You might need to define a custom GoMock matcher for your argument in some very niche and corner cases.
* **Never** use `.AnyTimes()` on mocks. Always define the number of times a certain mock call should be called, with `.Times(3)` for example.
* **Always** set the `.Return(...)` on the mock if the function returns something.
* Avoid using **mock helpers** functions, prefer a bit of repetition than tight coupling and dependency

### Mocks with subtests

It is common in Go to use *subtests*, where a subtest has its own test's `t *testing.T` which is different from its parent test's `t *testing.T`.

As you have seen GoMock mocks usage requires a controller constructed using a `*testing.T`:

```go
ctrl := gomock.NewController(t)
```

You need to be careful to **pass** the subtest `*testing.T` and not the parent test one.
Otherwise, one subtest mock expectations failing will fail the parent test and all other subtests.

There are various ways to do this correctly, although one method that works in all cases elegantly is the 'functional field mock builder' as shown below.

We use again our example code, modifying the test we had for the `something` function:

```go title="something/something_test.go"
package something

import (
 "context"
 "errors"
 "testing"

 "github.com/golang/mock/gomock"
 "github.com/stretchr/testify/assert"
)

func Test_something(t *testing.T) {
 errTest := errors.New("test error")

 testCases := map[string]struct {
  ctx            context.Context
  fetcherBuilder func(ctrl *gomock.Controller) Fetcher
  parserBuilder  func(ctrl *gomock.Controller) Parser
  id             string
  errWrapped     error
  errMessage     string
 }{
  "parser error": {
   ctx: context.Background(),
   fetcherBuilder: func(ctrl *gomock.Controller) Fetcher {
    fetcher := NewMockFetcher(ctrl)
    fetcher.EXPECT().Fetch(context.Background()).
     Return([]byte{1, 2, 3}, nil)
    return fetcher
   },
   parserBuilder: func(ctrl *gomock.Controller) Parser {
    parser := NewMockParser(ctrl)
    parser.EXPECT().Parse([]byte{1, 2, 3}).
     Return("", errTest)
    return parser
   },
   errWrapped: errTest,
   errMessage: "cannot parse: test error",
  },
 }

 for name, testCase := range testCases {
  t.Run(name, func(t *testing.T) {
   ctrl := gomock.NewController(t) // we inject the testing t to construct the controller inside the subtest

   fetcher := testCase.fetcherBuilder(ctrl) // we inject the controller here inside the subtest
   parser := testCase.parserBuilder(ctrl)

   id, err := something(testCase.ctx, fetcher, parser)

   assert.Equal(t, testCase.id, id)
   assert.ErrorIs(t, err, testCase.errWrapped)
   if testCase.errWrapped != nil {
    assert.EqualError(t, err, testCase.errMessage)
   }
  })
 }
}
```

This test has only one test case for illustration purposes, but it's easy to add test cases and adapt the mock builder functional fields to configure the mocks as wanted.

This also works when a mock depends on another mock, where the functional mock builder signature can be adjusted to take more arguments, for example:

```go
parserBuilder  func(ctrl *gomock.Controller, other OtherInterface) Parser
```

### Mock continuous integration

⚠️ You should **commit** all your generated mocks to source control.

The CI should enforce:

1. mocks with a `//go:generate` comment are generated
2. mocks with a `//go:generate` comment are updated when their corresponding interface is changed
3. mocks with a removed `//go:genereate` comment are removed

The following Github workflow should achieve the 3 points above:

```yml title=".github/workflows/mocks.yaml"
name: Mocks check
on:
  pull_request:
    branches:
      - main
jobs:
  mocks-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v3
        with:
          go-version: 1.18
      - run: go mod download
      - run: go install github.com/golang/mock/mockgen@v1.6
      - name: Remove committed mocks
        run: grep -lr -E '^// Code generated by MockGen.+$' . | xargs -d '\n' rm
      - name: Generate mocks
        run: go generate -run mockgen -tags integration ./...
      - name: Check for diffs
        run: git diff --exit-code
```

### Advanced GoMock

#### Mock calls order

A call on the `EXPECT()` method of a mock returns a `*Mock<InterfaceName>MockRecorder` object.

This one contains the methods of the interface, and calling one of them will return a `*gomock.Call` object.

For example:

```go
mock := NewMockFetcher(ctrl) // returns *MockFetcher
recorder := mock.EXPECT() // returns *MockFetcherMockRecorder
call := recorder.Fetch(context.Background()) // returns *gomock.Call
```

Most chained method calls on this `*gomock.Call`, such as `.Return(...)`, also return a `*gomock.Call`.

This call can be used to assert the calling order of mocks, using:

```go
callB.After(callA)
```

Although ideal, it's not necessary to assert the calls order for every test.

It is however quite important in a few cases such as:

* Calls to a buffer's `Write` method, since you want to make sure things are written in the right order
* Asynchronous code where you want to sure calls happen in a certain predictable order

#### Custom GoMock matchers

In some corner cases where arguments are not predictable, you can define your own GoMock argument matchers, to have some level of assertion and not use `gomock.Any()`.

In the following we implement the `gomock.Matcher` interface for a string regular expression matcher.

```go title="server/mock_regex_matcher_test.go"
package server

import (
 "regexp"

 "github.com/golang/mock/gomock"
)

var _ gomock.Matcher = (*regexMatcher)(nil)

type regexMatcher struct {
 regexp *regexp.Regexp
}

func (r *regexMatcher) Matches(x interface{}) bool {
 s, ok := x.(string)
 if !ok {
  return false
 }
 return r.regexp.MatchString(s)
}

func (r *regexMatcher) String() string {
 return "regular expression " + r.regexp.String()
}

func newRegexMatcher(regex string) *regexMatcher {
 return &regexMatcher{
  regexp: regexp.MustCompile(regex),
 }
}
```

In this example, we use it to assert a server logger behavior for a test server binding to a random available port.

Indeed, in this particular case, we cannot predict which port will be available on the machine so we use our regex matcher.

Our production code to test looks like:

```go title="server/server.go"
package server

import (
 "fmt"
 "net"
)

type Logger interface {
 Info(s string)
}

func listenAndLog(logger Logger) (err error) {
 listener, err := net.Listen("tcp", "127.0.0.1:0")
 if err != nil {
  return fmt.Errorf("cannot listen: %w", err)
 }

 logger.Info("listening on " + listener.Addr().String())

 return listener.Close()
}
```

And our test using our custom matcher would be:

```go title="server/server_test.go"
package server


import (
 "testing"

 "github.com/golang/mock/gomock"
)

func Test_listenAndLog(t *testing.T) {
 ctrl := gomock.NewController(t)

 logger := NewMockLogger(ctrl)
 regexMatcher := newRegexMatcher(`^listening on 127.0.0.1:[0-9]{1,5}$`)
 logger.EXPECT().Info(regexMatcher)

 listenAndLog(logger)
}
```

#### Unpredictable mock arguments

This is very rare. Most of the time:

1. Arguments are predictable
2. Production code can be changed to have predictable arguments in test code
3. You can use a [custom GoMock matcher](#custom-gomock-matchers) to have some level of assertion

BUT there are corner cases. For example, modifying slightly our `something` example function:

```go title="something/something.go"
package something

import (
 "context"
 "fmt"
 "time"
)

type Fetcher interface {
 Fetch(ctx context.Context) (data []byte, err error)
}

type Parser interface {
 Parse(data []byte) (id string, err error)
}

func something(ctx context.Context, fetcher Fetcher, parser Parser) (id string, err error) {
 ctx, cancel := context.WithTimeout(ctx, time.Second) // time based and unpredictable
 defer cancel()

 data, err := fetcher.Fetch(ctx)
 if err != nil {
  return "", fmt.Errorf("cannot fetch: %w", err)
 }

 id, err = parser.Parse(data)
 if err != nil {
  return "", fmt.Errorf("cannot parse: %w", err)
 }

 return id, nil
}
```

In this situation, we do not want to change our code to have `context.WithTimeout` mocked since it would make our production code quite confusing.

We can't really use a custom matcher for the context either, since depending on the machine and timeout, results would differ and not be deterministic.

In that case, you can use `gomock.AssignableToTypeOf()` such that the implementation is at least asserted for the `context.Context` interface:

```go title="something/something_test.go"
package something

import (
 "context"
 "testing"
 "time"

 "github.com/golang/mock/gomock"
)

func Test_something(t *testing.T) {
 ctrl := gomock.NewController(t)

 fetcher := NewMockFetcher(ctrl)
 timedCtx, cancel := context.WithTimeout(context.Background(), time.Hour)
 cancel()
 timedCtxMatcher := gomock.AssignableToTypeOf(timedCtx)
 fetcher.EXPECT().Fetch(timedCtxMatcher).Return([]byte{1}, nil)

 parser := NewMockParser(ctrl)
 parser.EXPECT().Parse([]byte{1}).Return("1", nil)

 _, _ = something(context.Background(), fetcher, parser)
}
```

## Passing arguments

### By value or by reference

There is often a debate within code reviews about if we should pass an argument by value or by reference.

As a general rule, **prefer passing by value**:

- it removes the risk of `nil` arguments making the code panic
- callers should inject a value, functions should not behave specifically when a `nil` argument is passed, to avoid *dark magic code*. Prefer explicitness over laziness.
- Even when you need to modify an argument, often taking the argument as value and returning the updated argument is clearer.

The following addresses how commonly used types should be passed as argument:

- **slices** can have their elements changed if passed by value. Only pass them as pointers if you want to change the length of the slice.
- **maps**, **channels**, (most) **interfaces**  are pointers under the hood, so always pass them as values.
- **arrays**: if performance does not matter, pass it as value. Otherwise:
  - pass it as value if it is smaller or equal to 80 bytes (i.e. `[9]int64`)
  - pass it as pointer if it is larger than 80 bytes (i.e. `[90]byte`)
- **structs**: if performance does not matter, pass it as value (such as **configuration structs**). Otherwise:
  - pass it as pointer if it needs one of its non-pointer field or sub-field to be modified
  - pass it as pointer if its size is larger than 80 bytes
- **mutexes** should be passed as pointers to avoid locking/unlocking a copy of a mutex
- Other types should mostly be passed as values since they are less than 80 bytes, some exceptions:
  - if you want to use the `atomic` package, you need to pass i.e. `uint32` as a pointer

### Number of arguments and retro-compatibility

As the codebase evolves, there are two cases for a function:

1. A changing number of arguments allows for the compiler to scream at you (which is good) when you change the number of arguments. You should use this for all **unexported functions** and all functions in the **internal/** directory.
2. A fixed number of arguments keeps retro-compatibility with previous code. You should use this for all **exported functions outside the `internal/`** directory.
A useful technique is to have a single `Settings` struct for publicly exposed exported constructors, so that more settings can be added as fields to the struct without breaking compatibility.
