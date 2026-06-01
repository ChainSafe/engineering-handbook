# golangci-lint configuration

A baseline `.golangci.yml` for ChainSafe Go projects, with notes on what changes across golangci-lint versions.

> Treat this as a starting point. Tighten or loosen per project; pin the golangci-lint version in CI so runs are deterministic.

## The config

```yaml
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

## Notes on linter naming drift since v1.46

Some linters above have been renamed, replaced, or removed in newer golangci-lint releases. When applying this config to a project on golangci-lint v1.55+ or v2.x:

- **`exportloopref`** → replaced by the built-in loop-variable-capture check (Go 1.22+) and/or `copyloopvar`.
- **`ifshort`** → removed from golangci-lint.
- **`goerr113`** → renamed to `err113`.
- **`gomnd`** → renamed to `mnd`.
- **`exhaustivestruct`** (if you add it) → renamed to `exhaustruct`.
- **`structcheck`, `varcheck`, `deadcode`** (if present elsewhere) → consolidated into `unused`.

Run `golangci-lint linters` against the version you've pinned to confirm what's available; the CI step will fail loudly if a name is wrong.

## CI workflow

Pin the linter version in your CI workflow so the build is deterministic:

```yaml
name: Linting
on:
  pull_request:

jobs:
  golangci-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version-file: go.mod
      - uses: golangci/golangci-lint-action@v6
        with:
          version: v1.55  # pin a specific version; never `latest`
```

Pin to a specific version (not `latest`), since the same linters produce different findings across versions. Bump deliberately as a separate PR.

## Per-package overrides

For genuinely-justified deviations from the baseline, use `//nolint:<linter>` directives in the source, with an inline comment explaining why:

```go
//nolint:gosec // file path is from a trusted internal config, not user input
data, err := os.ReadFile(cfg.Path)
```

A `//nolint` without a comment is a SOFT WARNING finding from the [Go reviewer skill](../reviewer.md). The agent flags; the operator decides whether the rationale is sufficient.

## Related

- [`../developer.md`](../developer.md) — broader Go development guidance, including this lint baseline as a CI gate.
- [`../reviewer.md`](../reviewer.md) — lint-related review checks.
- [`./gomock-patterns.md`](./gomock-patterns.md) — companion reference for GoMock at ChainSafe.
- [golangci-lint linters list](https://golangci-lint.run/usage/linters/) — upstream documentation.
