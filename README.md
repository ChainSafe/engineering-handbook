# ChainSafe Engineering Handbook

How we build software at ChainSafe — written for the humans doing the work and the AI agents helping them.

> **Status: v2 rewrite in progress.** This repo is being overhauled from a human-readable Docusaurus handbook into an AI-native source of truth that engineers' agents (Claude Code, Cursor, Continue, others) can pull as authoritative context. The legacy v1 content is preserved by the `v1` tag and currently still sits at the repo root alongside the new structure — both will coexist until v0 of the rewrite ships, at which point the legacy pages are removed.
>
> Curious about the rewrite? See **[PLAN.md](./PLAN.md)** for the structural plan and **[TODO.md](./TODO.md)** for execution progress.

## What this is

A public, opinionated handbook of how ChainSafe builds software. Curated by the CTO, authored across the org, with original contributors credited. Two access modes are supported by design: humans browse it on GitHub, and AI agents consume it via MCP or the deep links in `chainsafe.io/llms.txt`.

The premise: engineering practices are a competitive asset, AI agents are now first-class users of those practices, and the handbook should be written for both. We don't ship vague "best practices" filler — every page is meant to change behavior, agent or operator.

## How it's organized

Once v2 lands, the structure is:

- **`operating-model/`** — the operator/agent contract. How a human and an AI collaborator share responsibility for an output. Read this first.
- **`invariants/`** — the non-negotiables. Engineering invariants, the `.invariance` framework (deep-linked, not duplicated), and agent-era invariants.
- **`workflows/`** — PR authoring, code review, repo & CI setup, testing & QA, infrastructure & DevOps (deep-linked into `ChainSafe/infrastructure-general`), incident response, release & deploy.
- **`languages/`** — opinionated guidance per language ecosystem (Go, Rust, TypeScript, Solidity, Daml, Python, Zig) split into three roles: architect, developer, reviewer.
- **`references/`** — attribution, source pointers, contributors, changelog.
- **`skills/`** — packaged Anthropic Skills authored via `skill-creator`, distributable to any agent runtime that supports them.

Three top-level guiding documents sit at the repo root, layered from most general to most enforceable:

- **`VISION.md`** — ChainSafe's mission, vision, and core values. Company-wide. Carries forward unchanged from v1.
- **`PRINCIPLES.md`** — General Engineering Principles. Engineering's manifestation of the values; ten principles guiding how we build software.
- **`invariants/engineering-invariants.md`** — the testable subset of those principles. What gets enforced in CI, in review, and at gates.

During the rewrite, you'll also see the legacy `3_development/`, `4_the-formal-stuff/`, and `HOME.md` at the root. These get removed in the v0 launch sweep; `v1` preserves them in git history. The legacy `1_principles/` content has been extracted to `PRINCIPLES.md` and is preserved that way.

## How to use it

**Humans:** browse the directory structure above. Each section's `README.md` (forthcoming) names what's in it and who owns it.

**AI agents:** read [`AGENTS.md`](./AGENTS.md) (also `CLAUDE.md`) for read-order, escalation rules, and the operator contract. The handbook expects to be loaded as agent context, not just human reference.

**Hiring / due diligence:** the operating model, invariants, and language reviewer pages give the fastest read on how we work.

## Contributing

> **Working agreement.** During the v2 rewrite, every PR targets the branch **`peter/agentic-handbook-overhaul`**, not `main`. The legacy state on `main` is tagged `v1`. The branch will be merged to `main` as a single drop once v0 is complete. If you find yourself about to open a PR against `main`, stop and redirect — unless you're shipping a bugfix against the legacy handbook (rare).

Contributions follow the curatorial model: practices already exist across the org, get aggregated here with original authors credited via `CODEOWNERS`, `references/CONTRIBUTORS.md` (when populated), and inline credits in each content file's header.

## About ChainSafe

ChainSafe is a blockchain research and development firm building infrastructure for web3 — major contributions to Ethereum, Polkadot, Filecoin, and others, plus products in [gaming](https://gaming.chainsafe.io/), [bridging](https://www.sprinter.tech/), NFTs, and [decentralized storage](https://storage.chainsafe.io/). [chainsafe.io](https://chainsafe.io/).

## License

Apache License 2.0 — see [`LICENSE`](./LICENSE). Third-party content carried into this repository (e.g. the `chainsafe-research-plan-implement` skill, adapted from Boris Tane; the Forest AI policy, originally adapted from Ghostty) is credited in [`NOTICE`](./NOTICE) and inline in the relevant files. Derivative works must preserve these attributions per Section 4(d) of the License.
