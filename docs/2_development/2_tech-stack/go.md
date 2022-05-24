# Go

Our most notable Go stack:
* https://github.com/ChainSafe/gossamer (Polkadot Gossamer)
* https://github.com/ChainSafe/chainbridge-core (ChainBridge)
* [and others](https://github.com/chainsafe?q=&type=all&language=go&sort=)

## IDE configuration

:::note

TBD

:::

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

- no `cmd` directory since this is not a runnable application
- no `pkg` directory since this is a library, all exported Go API should be at the top level to reduce the length of import statements
- `api.go` file containing all your Go public API. It should contain your exported interfaces, constants and constructors.

Note that most of your code should still reside in the `internal` directory, and you should keep your public Go API to a minimum.

If it really makes sense, you may have directories at the top level to split the import statements.

### Business logic perspective

Beside official package layout recommendations describing packages structure and naming from the Go modules perspective, there is de facto standard named *Standard Package Layout* on how to organize your business logic, storage and abstractions.

First time concept was described by [Ben Jonson in an article with the same name](https://medium.com/@benbjohnson/standard-package-layout-7cdbc8391fc1). Another source of inspiration and a way to grasp the concept can be found in the beautiful [talk of Brain Ketelsen about Go best practices](https://www.youtube.com/watch?v=MzTcsI6tn-0).

### Other tips

- Package naming
  - Your package name should be the same as the directory containing it, **except for the `main` package**
  - Use single words for package names
  - Do not use generic names for package names such as `utils` or `helpers`
- Package nesting
  - Try to avoid nesting packages by default
  - You can nest packages if you have different implementations for the same interface (e.g. a store interface)
  - You can nest packages if you start having a lot of Go files (more than 10) and it really does make sense to make subpackages

## Linting

Use [golangci-lint](https://golangci-lint.run/):

```sh
go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.45
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

## Recommended Libraries

:::note

TBD

:::

## Continuous integration

:::note
TBD: testing 
:::

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

### Mock generation

Install the `mockgen` CLI from the [`golang/mock`](https://github.com/golang/mock) repository:

```sh
go install github.com/golang/mock/mockgen@v1.6.0
```

This is to be done only once on your development environment.

To generate mocks for the `Fetcher` and `Parser` interfaces (defined in [the section above](#Example-production-code)):

1. Create a file `mocks_generate_test.go` in the package **where the test needs the mock**.
This file should hold only `//go:generate mockgen` comment-commands for all the tests in the package it's located in.
In our case, it would be:

    ```go title="something/mocks_generate_test.go"
    package something

    //go:generate mockgen -destination=mocks_test.go -package $GOPACKAGE . Fetcher,Parser
    ```

2. Use `go generate -run mockgen ./...` to generate both mocks to `mocks_test.go`. A few notes about this:
    * We use `$GOPACKAGE` which is a special variable available to `//go:generate` comments. It specifies the package name of the file it's located in.
    In our example case, this is the `something` package name.
    * The mocks are generated to the Go test file `mocks_test.go` such that it does not pollute the package Go API.
    Indeed `*_test.go` files are not exported and only accessible by other test files in the same package.

### Mock usage

You first need to add the GoMock dependency to your Go module:

```sh
go get github.com/golang/mock/gomock
```

This is to be done only once on your project.

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

### Mocks with subtests

TODO

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

#### Custom GoMock matchers

#### Unpredictable mock arguments
