# External Canonical Sources

The handbook defers, rather than duplicates, where another artifact is already the canonical source. This page is the catalog: every external source the handbook deep-links into, its maintainer, what it covers, and how it is referenced.

> **In one line:** When the handbook says "see X," X is listed here with a maintainer and a coordination point. No "see also" links — only deep-linked deferrals.

## How to read this page

Each entry below names:

- **Source** — the canonical repository, file, or document.
- **Maintainer** — the person who owns it. Changes to how the handbook references the source are coordinated with them.
- **Covers** — what subject area this source is canonical for.
- **Used by** — which handbook pages defer to this source.
- **Coordination** — who reviews changes to the deferral.

Entries are added when the handbook starts deferring to a new source. Removal is rare; when a source is no longer canonical, the entry is marked deprecated rather than deleted, with a pointer to its replacement.

## Sources

### `.invariants` framework

- **Source.** [github.com/boorich/.invariants-starter-kit](https://github.com/boorich/.invariants-starter-kit) (convention + optional reference workspace). Landing page: [boorich.github.io/.invariants-starter-kit/](https://boorich.github.io/.invariants-starter-kit/). Deep-link map: [`../invariants/invariants-framework.md`](../invariants/invariants-framework.md).
- **Maintainer.** [@boorich](https://github.com/boorich) (Martin Maurer).
- **Covers.** Architectural invariants — dotfile format, severity cascade, conformance agent, optional vecs code index and GitHub triage. Multi-repo convention.
- **Used by.** [`../invariants/invariants-framework.md`](../invariants/invariants-framework.md) (pointer page); every [`../languages/<lang>/architect.md`](../languages/) page deep-links into per-language invariant sections; ADR templates referenced from [`../workflows/pr-authoring.md`](../workflows/) require an "Invariants impacted" field sourced from `.invariants`.
- **Coordination.** [@boorich](https://github.com/boorich) is CODEOWNER for the pointer page. Anchor changes upstream → re-anchor here in the same PR (or close behind).

### `ChainSafe/infrastructure-general`

- **Source.** [github.com/ChainSafe/infrastructure-general](https://github.com/ChainSafe/infrastructure-general) — the canonical repo for ChainSafe infrastructure, IaC, deployment topology, observability, on-call rotations, and runbooks. Already ships its own `AGENTS.md` and `CLAUDE.md`, confirming the agent-native posture.
- **Maintainer.** [@joshdougall](https://github.com/joshdougall) (Josh, Head of Infra).
- **Covers.** All infrastructure and DevOps practice: Ansible roles, Terraform modules, service catalog, observability dashboards, runbooks, incident response procedures, deployment topology, on-call scheduling. The Infra IR doc (previously flagged as a candidate to lift into the handbook) lives here and stays here.
- **Used by.** [`../workflows/infrastructure-and-devops.md`](../workflows/) (pointer page deep-linking into the infra repo by intent), [`../workflows/incident-response.md`](../workflows/), [`../workflows/release-and-deploy.md`](../workflows/). Handbook keeps only the *operator decision policy* layer inline; *how-to* defers to the linked runbook.
- **Coordination.** [@joshdougall](https://github.com/joshdougall) is CODEOWNER for the three pointer pages listed above.

### Forest `AI_POLICY.md` (Ghostty lineage)

- **Source.** `AI_POLICY.md` in [github.com/ChainSafe/forest](https://github.com/ChainSafe/forest). Originally adapted from the [Ghostty](https://github.com/ghostty-org/ghostty) project's AI policy, with attribution preserved in the upstream Forest file.
- **Maintainer.** Forest engineering team (current owners listed in Forest's CODEOWNERS).
- **Covers.** AI-assisted development policy at the product-repo level. Sets norms for what AI agents may and may not do when contributing to Forest specifically.
- **Used by.** [`../workflows/testing-and-qa.md`](../workflows/) borrows the QA framing around what agents should generate vs. what operators must own; the Rust reviewer guidance references it for `unsafe`-block scrutiny.
- **Coordination.** Forest team owns the upstream file. Ghostty attribution is preserved per Apache 2.0 §4(d) — see [`../NOTICE`](../NOTICE).

### `chainsafe-research-plan-implement` skill (Boris Tane lineage)

- **Source.** [`../skills/chainsafe-research-plan-implement/SKILL.md`](../skills/chainsafe-research-plan-implement/SKILL.md). Adapted by [@kalambet](https://github.com/kalambet) from ["How I Use Claude Code"](https://boristane.com/blog/how-i-use-claude-code/) by Boris Tane.
- **Maintainer.** [@kalambet](https://github.com/kalambet); adaptations to the workflow itself are coordinated with the wider engineering team given how central this skill is.
- **Covers.** Pipeline-style workflow for non-trivial coding work: research → plan → annotate (1–6 rounds) → implement. Human-approved plan gates every code change.
- **Used by.** [`../workflows/pr-authoring.md`](../workflows/) delegates the PR-shape engineering workflow to this skill rather than re-deriving it; [`../operating-model/model-and-tool-selection.md`](../operating-model/model-and-tool-selection.md) lists it as the default skill for any non-trivial code change; [`AGENTS.md`](../AGENTS.md) cross-references it.
- **Coordination.** [@kalambet](https://github.com/kalambet) is CODEOWNER. Material changes to the workflow itself are an org-level decision, not a curator-only one.

### Anthropic's Skills Specification

- **Source.** Anthropic's "Complete Guide to Building Skills for Claude" (the canonical skill-authoring playbook) and the [`anthropic-skills:skill-creator`](https://github.com/anthropics/skills) skill itself.
- **Maintainer.** Anthropic.
- **Covers.** Skill format (kebab-case names, YAML frontmatter, description shape, file-size constraints), authoring workflow, and triggering evals.
- **Used by.** Every skill in [`../skills/`](../skills/) is authored via `skill-creator` — the canonical authoring tool, no hand-rolled SKILL.md files. The handbook references the spec for format requirements but does not duplicate it.
- **Coordination.** External. The spec is treated as authoritative; if it changes, the handbook's skill-authoring guidance changes alongside.

### Canton Network Docs (Daml language + Canton platform)

- **Source.** [docs.canton.network](https://docs.canton.network) — the official Canton Network documentation: the Daml language, the app-development modules, deep dives, tooling, and the full Daml standard-library reference. Machine-readable index at [`docs.canton.network/llms.txt`](https://docs.canton.network/llms.txt) (every page is also served as raw markdown by appending `.md`). Upstream docs repo: [canton-network/cf-docs](https://github.com/canton-network/cf-docs). Documentation licensed CC-BY-4.0.
- **Maintainer.** External — the Canton Foundation. Internal coordination via the Daml CODEOWNERS — [@boorich](https://github.com/boorich), [@salindne](https://github.com/salindne), [@sqhell](https://github.com/sqhell) — per [`.github/CODEOWNERS`](../.github/CODEOWNERS).
- **Covers.** The authoritative Daml language and Canton platform reference: authorization model, contract templates, choices, keys, interfaces, the standard library, testing with Daml Script, Smart Contract Upgrades (SCU) and upgrade compatibility, working with time, security best practices, CI/CD integration, and Canton-specific topology (domain / synchronizer / sequencer / mediator). The handbook's Daml pages defer here rather than re-deriving language semantics — the same way the architect pages defer to `.invariants`.
- **Used by.** [`../languages/daml/architect.md`](../languages/daml/architect.md) (authorization / upgrade / privacy semantics), [`../languages/daml/developer.md`](../languages/daml/developer.md) (dev environment, tooling, standard library, testing), [`../languages/daml/idioms.md`](../languages/daml/idioms.md), [`../languages/daml/gotchas.md`](../languages/daml/gotchas.md), [`../languages/daml/reviewer.md`](../languages/daml/reviewer.md) (authorization, upgrade compatibility, security checks).
- **Coordination.** External upstream, treated as canonical for Daml language semantics. When Canton restructures the docs, re-anchor the deep links in the same pass — the weekly link-check run catches rot. The internal deferral is reviewed by the Daml CODEOWNERS.

### `daml-autopilot` / `ChainSafe/canton-ci` (ChainSafe's own Daml tooling)

- **Source.** [daml-autopilot.chainsafe.io](https://daml-autopilot.chainsafe.io) — ChainSafe's precision tooling for Daml development. Two surfaces: the [`ChainSafe/canton-ci`](https://github.com/ChainSafe/canton-ci) GitHub Actions (`install-daml`, `install-canton`, `daml-test`, `daml-script` — free, standalone, no MCP required) and the **Daml MCP server** (`mcp-server.chainsafe.io`) — an AI dev assistant: *Daml Reason* (canonical-pattern search + authorization-model analysis) and *Daml Automater* (environment / CI / build guidance), billed pay-as-you-go via a Canton payer party.
- **Maintainer.** ChainSafe — built and maintained by the same team that owns the handbook's Daml section: [@boorich](https://github.com/boorich) (Martin Maurer), [@salindne](https://github.com/salindne) (Sebastian Lindner), and [@sqhell](https://github.com/sqhell) (Colin Sloss), the Daml CODEOWNERS per [`.github/CODEOWNERS`](../.github/CODEOWNERS). They own both [`ChainSafe/canton-ci`](https://github.com/ChainSafe/canton-ci) and the hosted Daml MCP server.
- **Covers.** ChainSafe-built Daml developer tooling: CI/CD for Daml projects (SDK + Canton install, sandbox / LocalNet test execution) and AI-assisted Daml authoring and review. This is a ChainSafe product; the handbook recommends it as the default Daml dev tooling — we dogfood our own tools.
- **Used by.** [`../languages/daml/developer.md`](../languages/daml/developer.md) (CI baseline + MCP setup), [`../operating-model/model-and-tool-selection.md`](../operating-model/model-and-tool-selection.md) (on-demand MCP loadout), and referenced from [`../languages/daml/architect.md`](../languages/daml/architect.md) and [`../languages/daml/reviewer.md`](../languages/daml/reviewer.md) for authorization analysis.
- **Coordination.** Internal ChainSafe product, owned by the Daml CODEOWNERS named above — the same people who review the handbook's Daml pages also build the tooling those pages recommend. The Daml MCP server incurs per-use cost — its use is subject to the [cost gate](../operating-model/gates-and-escalation.md#7-cost-and-external-resource-creation).

### Zig Language & Standard Library Docs

- **Source.** [ziglang.org](https://ziglang.org) — the official Zig documentation: the [Language Reference](https://ziglang.org/documentation/master/), the [Standard Library reference](https://ziglang.org/documentation/master/std/), and the [Learn](https://ziglang.org/learn/) section (in-depth overview, the [build-system guide](https://ziglang.org/learn/build-system/), code samples, and the Style Guide). Documentation under the Zig project's MIT license. Zig is pre-1.0: the `master` docs track the unreleased compiler, and each release carries its own versioned reference.
- **Maintainer.** External — the Zig Software Foundation. Internal coordination point: the Zig CODEOWNER ([@wemeetagain](https://github.com/wemeetagain) / [@matthewkeil](https://github.com/matthewkeil) / [@kalambet](https://github.com/kalambet)).
- **Covers.** The authoritative Zig language and standard-library reference: syntax, build modes and Illegal Behavior, the allocator model, error unions and `errdefer`, optionals, comptime and generics, the build system (`build.zig` / `build.zig.zon`), C interop, and the naming Style Guide. The handbook's Zig pages defer here for language semantics rather than re-deriving them — the same way the architect pages defer to `.invariants` and the Daml pages defer to the Canton docs.
- **Used by.** [`../languages/zig/architect.md`](../languages/zig/architect.md), [`../languages/zig/developer.md`](../languages/zig/developer.md), [`../languages/zig/reviewer.md`](../languages/zig/reviewer.md), [`../languages/zig/idioms.md`](../languages/zig/idioms.md), [`../languages/zig/gotchas.md`](../languages/zig/gotchas.md). ChainSafe's canonical Zig codebase is [lodestar-z](https://github.com/ChainSafe/lodestar-z) (consensus libraries for Lodestar).
- **Coordination.** External upstream, treated as canonical for Zig language semantics. Because Zig is pre-1.0, the language and std reshape across releases — re-anchor deep links and version-pinned guidance when bumping the project's Zig version; the weekly link-check run catches rot.

### Rust References (Effective Rust + The Rust Book)

- **Source.** [Effective Rust](https://effective-rust.com/) by David Drysdale (35 specific items; CC-BY-NC-ND 4.0) and [The Rust Programming Language](https://doc.rust-lang.org/book/) ("the Rust Book"; MIT / Apache-2.0). Together they are the canonical references for writing idiomatic, effective Rust.
- **Maintainer.** External — David Drysdale (Effective Rust) and the Rust project / community (the Book). Internal coordination point: the Rust CODEOWNER ([@LesnyRumcajs](https://github.com/LesnyRumcajs) / [@hanabi1224](https://github.com/hanabi1224)).
- **Covers.** Idiomatic Rust practice: type-driven design, idiomatic error types, `Option`/`Result` transforms, the newtype and builder patterns, standard traits and `Drop`/RAII, generics vs. trait objects, lifetimes and the borrow checker, avoiding `unsafe`, shared-state-parallelism hazards, SemVer and visibility, documenting public interfaces, Clippy, testing beyond unit tests, and FFI / `no_std`. The handbook's Rust pages apply these rather than re-deriving them.
- **Used by.** [`../languages/rust/architect.md`](../languages/rust/architect.md), [`../languages/rust/developer.md`](../languages/rust/developer.md), [`../languages/rust/reviewer.md`](../languages/rust/reviewer.md), [`../languages/rust/idioms.md`](../languages/rust/idioms.md), [`../languages/rust/gotchas.md`](../languages/rust/gotchas.md). ChainSafe's canonical Rust codebase is [Forest](https://github.com/ChainSafe/forest) (Filecoin).
- **Coordination.** External upstream, treated as canonical for idiomatic Rust. **Effective Rust is CC-BY-NC-ND** — the handbook references and credits specific items by number and link; it does not reproduce or adapt the text. Re-anchor item links if the upstream reorganizes; the weekly link-check catches rot.

### Effective Python (idiomatic Python)

- **Source.** [Effective Python](https://effectivepython.com/) by Brett Slatkin — *125 Specific Ways to Write Better Python* (3rd ed., Pearson Addison-Wesley; covers the language through Python 3.13). The book is copyrighted and not free online; the companion code is open at [bslatkin/effectivepython](https://github.com/bslatkin/effectivepython). The handbook references items by number and title, and does not reproduce the text.
- **Maintainer.** External — Brett Slatkin. Internal coordination point: the Python CODEOWNER ([@kalambet](https://github.com/kalambet)).
- **Covers.** Idiomatic, effective Python: Pythonic thinking and PEP 8, functions (keyword-only arguments, raising over returning `None`), comprehensions and generators, dataclasses and interfaces, robustness (`try`/`except`/`else`/`finally`, exception hygiene), concurrency choice (threads for blocking I/O, `asyncio`, true parallelism), performance (profile before optimizing; when to drop to a native extension or another language), and collaboration (docstrings, virtual environments, typing). The handbook's Python pages apply these within Python's internal-tooling scope at ChainSafe.
- **Used by.** [`../languages/python/architect.md`](../languages/python/architect.md), [`../languages/python/developer.md`](../languages/python/developer.md), [`../languages/python/reviewer.md`](../languages/python/reviewer.md), [`../languages/python/idioms.md`](../languages/python/idioms.md), [`../languages/python/gotchas.md`](../languages/python/gotchas.md). Python at ChainSafe is internal-tooling-grade (ops, Ansible, data/ML prototyping), not production services.
- **Coordination.** External upstream, treated as canonical for idiomatic Python. Cite by item number and title; re-check the numbers against the current edition when bumping the reference (the 3rd edition covers Python through 3.13).

## Sources we expect to add

Surfacing known candidates rather than fabricating coverage:

- **Other internal artifacts to canonicalize.** When team members surface practices that exist in product repos or docs and could become canonical sources, they get added here with the original author credited (see [`./attribution.md`](./attribution.md)).
- **Language-specific upstream references.** Per-language reviewer pages may deep-link into language-community standards (e.g., the Rust API guidelines). Those entries are added here when a page starts deferring to one.

## Related

- [`../NOTICE`](../NOTICE) — third-party attribution required under Apache 2.0 §4(d). Sources with upstream licenses or attribution requirements are also recorded there.
- [`./attribution.md`](./attribution.md) — the curatorial credit policy; how original authors are surfaced across the three-layer attribution model.
- [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md) — the contributor index. Maintainers named here also appear there.
- [`../invariants/invariants-framework.md`](../invariants/invariants-framework.md) — the architecture/system-design deferral that grounded this catalog.
- [`../workflows/infrastructure-and-devops.md`](../workflows/infrastructure-and-devops.md) — the infrastructure deferral that grounded this catalog.
