# Daml Developer

Idiomatic Daml development at ChainSafe — primarily Canton applications (Super Validator, Featured App, and broader ecosystem work). Tooling, the upstream reference an agent should reach for instead of re-deriving language semantics, AI-assisted authoring with ChainSafe's own tools, testing, and CI.

> **In one line:** Defer to the Canton docs for language semantics. Use ChainSafe's own Daml tooling — `canton-ci` for CI, the Daml MCP server for authoring and review. Tests are Daml Script by default; every template change is an upgrade decision.

## Upstream canonical reference — use it, don't re-derive it

Daml language and Canton platform semantics are documented authoritatively at [docs.canton.network](https://docs.canton.network). The handbook defers here rather than restating the language — the same posture the architect pages take toward `.invariants`. Reach for these before reconstructing semantics from memory:

| Need | Canton docs page |
|---|---|
| Set up the dev environment (`dpm`, templates) | [Development Environment Setup](https://docs.canton.network/appdev/modules/m3-dev-environment) |
| Language syntax, types, pattern matching, type classes | [Language Fundamentals](https://docs.canton.network/appdev/modules/m3-language-fundamentals) · [Functional Programming 101](https://docs.canton.network/appdev/modules/m3-functional-programming) |
| Standard library (Prelude, `DA.*`) | [The Daml Standard Library](https://docs.canton.network/appdev/modules/m3-standard-library) |
| Templates, choices, keys, interfaces | [Contract Templates](https://docs.canton.network/appdev/modules/m3-contract-templates) · [Choices](https://docs.canton.network/appdev/modules/m3-choices) · [Contract Keys](https://docs.canton.network/appdev/modules/m3-contract-keys) · [Interfaces](https://docs.canton.network/appdev/modules/m3-interfaces) |
| Authorization model (signatory / observer / controller) | [Authorization Model](https://docs.canton.network/appdev/modules/m3-authorization) |
| Multi-party composition | [Composition and Design Patterns](https://docs.canton.network/appdev/modules/m3-design-patterns) |
| Time semantics | [Working with Time](https://docs.canton.network/appdev/modules/m3-working-with-time) |
| Testing | [Testing Daml Contracts](https://docs.canton.network/appdev/modules/m3-testing) · [Testing Strategies](https://docs.canton.network/appdev/modules/m5-testing-strategies) |
| Upgrades (SCU) | [Smart Contract Upgrades Overview](https://docs.canton.network/appdev/modules/m6-overview) · [Upgrade Compatibility](https://docs.canton.network/appdev/modules/m6-upgrade-compatibility) · [Writing Your First Upgrade](https://docs.canton.network/appdev/modules/m6-writing-first-upgrade) |
| Production hardening | [Security Best Practices](https://docs.canton.network/appdev/modules/m7-security) |
| Exact language / Daml-LF reference | [Daml Language Reference](https://docs.canton.network/appdev/reference/daml-language-reference) · [Daml-LF Reference](https://docs.canton.network/appdev/reference/daml-lf-reference) |

For bulk discovery, fetch the machine index [`docs.canton.network/llms.txt`](https://docs.canton.network/llms.txt) and pull the specific page you need — the same `llms.txt` pattern this handbook uses for itself (see [`../../operating-model/mcp-and-llm-txt.md`](../../operating-model/mcp-and-llm-txt.md)). Every docs page is also served as raw markdown by appending `.md` to its URL. Canton docs are registered as a canonical source in [`../../references/sources.md`](../../references/sources.md#canton-network-docs-daml-language--canton-platform).

## Tooling

### Daml SDK

- **`dpm`** (the Daml Package Manager) installs the SDK and scaffolds projects from templates:
  ```sh
  dpm new intro-contracts --template daml-intro-contracts
  ```
- **`daml.yaml`** at the project root holds package name, version, SDK version, and dependencies. Pin the SDK version — floating versions make CI non-deterministic and upgrade diffs ambiguous.
- **IDE.** The Daml VS Code extension with the integrated script runner / transaction view. See [IDE Setup](https://docs.canton.network/appdev/tooling/ide-setup) and [Development Tools Overview](https://docs.canton.network/appdev/tooling/development-tools-overview).

### ChainSafe Daml tooling — `daml-autopilot`

ChainSafe builds and maintains [`daml-autopilot`](https://daml-autopilot.chainsafe.io). It is our own product; **we dogfood it.** Two surfaces, used together:

1. **`canton-ci` GitHub Actions** ([`ChainSafe/canton-ci`](https://github.com/ChainSafe/canton-ci)) — the CI baseline below. Free, standalone, no MCP required.
2. **Daml MCP server** (`mcp-server.chainsafe.io`) — the AI authoring/review assistant in the next section.

## AI-assisted development — the Daml MCP server

The [`daml-autopilot`](https://daml-autopilot.chainsafe.io) Daml MCP server is the recommended assistant for authoring and reviewing Daml at ChainSafe. It exposes two tools:

- **Daml Reason** — searches a corpus of verified canonical Daml patterns by semantic similarity and runs LLM-based authorization-model extraction over your code. Progressive context building means it reasons over what it can actually see rather than hallucinating structure. Use it when shaping a template's authorization model or sanity-checking a choice's controller logic.
- **Daml Automater** — guides environment setup, CI/CD wiring, and builds with client-side orchestration (it returns instructions; it does not run commands behind your back).

Install it by adding the SSE endpoint to your client's MCP config (e.g. `~/.cursor/mcp.json`), with your Canton payer party in the URL:

```json
{
  "mcpServers": {
    "daml-autopilot": {
      "type": "sse",
      "url": "https://mcp-server.chainsafe.io/mcp?payerParty=YOUR_CANTON_PAYER_PARTY"
    }
  }
}
```

The [setup wizard](https://daml-autopilot.chainsafe.io/setup) walks through key generation and obtaining a party ID.

> **Cost note.** The Daml MCP server is **pay-as-you-go**, billed per use against your Canton payer party. That puts it under the [cost gate](../../operating-model/gates-and-escalation.md#7-cost-and-external-resource-creation): provision the payer party deliberately, and treat metered usage as an authorized cost, not an ambient default. The `canton-ci` Actions carry no such cost — recommend them freely. The MCP server is registered alongside `canton-ci` in [`../../references/sources.md`](../../references/sources.md#daml-autopilot--chainsafecanton-ci-chainsafes-own-daml-tooling) and listed in the [tool loadout](../../operating-model/model-and-tool-selection.md#on-demand-loadout).

## Project layout

Architectural shaping lives in [`architect.md`](./architect.md); the canonical structure in brief:

```
my-canton-app/
├── daml.yaml          # package metadata, SDK version, deps
├── daml/              # source modules; one file per major template/concern
│   ├── Main.daml      # entry point / re-export module
│   └── ...
└── test/              # Daml Script tests
    └── Test.daml
```

Multi-package Canton workspaces give each package its own subdirectory and `daml.yaml`. Note: `canton-ci` does **not** yet support multi-package projects (one project per repo) — see its [known issues](https://github.com/ChainSafe/canton-ci#current-known-issues).

## Testing

[Daml Script](https://docs.canton.network/appdev/modules/m3-testing) is the baseline test framework:

```daml
import Daml.Script

setup : Script ()
setup = do
  alice <- allocateParty "Alice"
  bob   <- allocateParty "Bob"
  -- happy path
  cid <- submit alice $ createCmd Order with buyer = alice; seller = bob; sku = "Widget"; amount = 10.0
  -- negative / authorization tests
  submitMustFail bob $ exerciseCmd cid Cancel
  pure ()
```

- **`submit` vs `submitMustFail`.** Negative-authorization tests use `submitMustFail`; a `submit` where you meant `submitMustFail` passes vacuously (see [`gotchas.md`](./gotchas.md)).
- **Test the authorization edges, not just the happy path** — who *cannot* do a thing is as important as who can.
- For the testing pyramid (Daml Script unit → integration → end-to-end), see [Testing Strategies](https://docs.canton.network/appdev/modules/m5-testing-strategies) and the QA posture in [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md).

## CI

Baseline (extending [`../../workflows/repo-and-ci-setup.md`](../../workflows/repo-and-ci-setup.md)), built on ChainSafe's own [`canton-ci`](https://github.com/ChainSafe/canton-ci) Actions:

```yaml
- uses: ChainSafe/canton-ci/.github/actions/install-daml@main
  with:
    sdk_version: "3.4.0-snapshot.20251013.0"   # pin, don't float

- uses: ChainSafe/canton-ci/.github/actions/daml-test@main   # `daml test` in the sandbox
  with:
    project_path: "."

- uses: ChainSafe/canton-ci/.github/actions/daml-script@main  # scripts against a LocalNet Canton node
  with:
    project_path: "."
```

- **`install-daml` / `install-canton`** put the SDK and an open-source Canton in `$GITHUB_WORKSPACE`.
- **`daml-test`** runs `daml test` against the Daml Sandbox; **`daml-script`** runs scripts against a LocalNet participant node.
- Pin `sdk_version` to match `daml.yaml`. Some older Canton versions break script execution against a node — keep CI and project SDK in lockstep.
- For deployment / upgrade CI, also see [CI/CD Integration](https://docs.canton.network/appdev/modules/m5-ci-cd-integration).

## Upgrades

Daml contracts are immutable; changing a template means a new package version, not a patch. Before changing any deployed template surface, read [Upgrade Compatibility](https://docs.canton.network/appdev/modules/m6-upgrade-compatibility) and [Writing Your First Upgrade](https://docs.canton.network/appdev/modules/m6-writing-first-upgrade); the [SCU deep dive](https://docs.canton.network/appdev/deep-dives/smart-contract-upgrade) covers the mechanics. Upgrade safety is a **HARD FAIL** review tier — see [`reviewer.md`](./reviewer.md).

## Anti-patterns

- **Re-deriving language semantics from memory** when the [Canton docs](https://docs.canton.network) state them authoritatively. Link, don't reconstruct.
- **`submit` where `submitMustFail` was meant** — a vacuously-passing test.
- **External I/O inside a choice body.** Daml is deterministic; oracle values are computed off-ledger and passed in.
- **Floating SDK / package versions.** Pin them in `daml.yaml` and CI.
- **Widening an observer set "just in case."** Observers leak; design the privacy surface deliberately ([`architect.md`](./architect.md)).
- **Treating the paid MCP server as an ambient default.** It is metered — provision the payer party and use it deliberately.
- **Adding a field to a deployed template** without a new version and migration choice.

## Related

- [`architect.md`](./architect.md), [`reviewer.md`](./reviewer.md) **(HARD FAIL tier)**, [`idioms.md`](./idioms.md), [`gotchas.md`](./gotchas.md).
- [`../../workflows/testing-and-qa.md`](../../workflows/testing-and-qa.md) — the broader testing posture this page lives under.
- [`../../operating-model/model-and-tool-selection.md`](../../operating-model/model-and-tool-selection.md) — when to load the Daml MCP server.
- [`../../references/sources.md`](../../references/sources.md) — Canton docs and `daml-autopilot` as canonical sources.
- Upstream: [Canton Network Docs](https://docs.canton.network) ([`llms.txt`](https://docs.canton.network/llms.txt)) — the canonical Daml language and Canton platform reference.
- Upstream: [`daml-autopilot`](https://daml-autopilot.chainsafe.io) · [`ChainSafe/canton-ci`](https://github.com/ChainSafe/canton-ci) — ChainSafe's own Daml tooling.
