# ChainSafe Engineering Handbook

How we build software at ChainSafe — written for the humans doing the work and the AI agents helping them.

## What this is

A public, opinionated handbook of how ChainSafe builds software. Curated by the CTO, authored across the org, with original contributors credited. Two access modes are supported by design: humans browse it on GitHub, and AI agents consume it via MCP or the deep links in `chainsafe.io/llms.txt`.

The premise: engineering practices are a competitive asset, AI agents are now first-class users of those practices, and the handbook should be written for both. We don't ship vague "best practices" filler — every page is meant to change behavior, agent or operator.

## How it's organized

The structure is:

- **`operating-model/`** — the operator/agent contract. How a human and an AI collaborator share responsibility for an output. Read this first.
- **`invariants/`** — the non-negotiables. Engineering invariants, the `.invariance` framework (deep-linked, not duplicated), and agent-era invariants.
- **`workflows/`** — PR authoring, code review, repo & CI setup, testing & QA, infrastructure & DevOps (deep-linked into `ChainSafe/infrastructure-general`), incident response, release & deploy.
- **`languages/`** — opinionated guidance per language ecosystem (Go, Rust, TypeScript, Solidity, Daml, Python, Zig) split into three roles: architect, developer, reviewer.
- **`references/`** — attribution, source pointers, contributors.
- **`skills/`** — packaged Anthropic Skills authored via `skill-creator`, distributable to any agent runtime that supports them.
- **`career/`** — people-process reference: career ladders, the 360-review cadence, education and license policy. Adjacent to the engineering-practice core, not part of the agent-facing contract.

Three top-level guiding documents sit at the repo root, layered from most general to most enforceable:

- **`VISION.md`** — ChainSafe's mission, vision, and core values. Company-wide.
- **`PRINCIPLES.md`** — General Engineering Principles. Engineering's manifestation of the values; ten principles guiding how we build software.
- **`invariants/engineering-invariants.md`** — the testable subset of those principles. What gets enforced in CI, in review, and at gates.

## How to use it

**Humans:** browse the directory structure above. Start with `operating-model/`, then the section relevant to your work.

**AI agents:** read [`AGENTS.md`](./AGENTS.md) (also `CLAUDE.md`) for read-order, escalation rules, and the operator contract. The handbook expects to be loaded as agent context, not just human reference.

**Hiring and external review:** the operating model, invariants, and language reviewer pages give the fastest read on how we work.

## Contributing

> **How to contribute.** Open a PR against `main` following [OneFlow](workflows/oneflow.md); the [PR authoring guide](workflows/pr-authoring.md) covers scope, description, and review. Material changes route to the relevant `CODEOWNERS`.

Contributions follow the curatorial model: practices already exist across the org, get aggregated here with original authors credited via `CODEOWNERS`, `references/CONTRIBUTORS.md` (when populated), and inline credits in each content file's header.

## About ChainSafe

ChainSafe is a blockchain research and development firm building infrastructure for web3 — major contributions to Ethereum, Polkadot, Filecoin, and others, plus products in [gaming](https://gaming.chainsafe.io/), [bridging](https://www.sprinter.tech/), NFTs, and [decentralized storage](https://storage.chainsafe.io/). [chainsafe.io](https://chainsafe.io/).

## License

Apache License 2.0 — see [`LICENSE`](./LICENSE). Third-party content carried into this repository (e.g. the `chainsafe-research-plan-implement` skill, adapted from Boris Tane; the Forest AI policy, originally adapted from Ghostty) is credited in [`NOTICE`](./NOTICE) and inline in the relevant files. Derivative works must preserve these attributions per Section 4(d) of the License.
