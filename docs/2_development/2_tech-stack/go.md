# Go

## Table of contents

- [Project structure](#Project-structure)

## Project structure

### The file structure

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

### The `cmd` directory

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

### The `internal` directory

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

### The `pkg` directory

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

### The `examples` directory

The `examples` directory should contain runnable examples to showcase your publicly exported Go API from `pkg`.

Each example should have a descriptive directory name and a runnable `main.go` file with only the `func main()` function.

For example:

```s
├── examples
    └── example1
        └── main.go
```

### Other tips

- Package naming
  - Your package name should be the same as the directory containing it, **except for the `main` package**
  - Use single words for package names
  - Do not use generic names for package names such as `utils` or `helpers`
- Package nesting
  - Try to avoid nesting packages by default
  - You can nest packages if you have different implementations for the same interface (e.g. a store interface)
  - You can nest packages if you start having a lot of Go files (more than 10) and it really does make sense to make subpackages

### Go libraries

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
