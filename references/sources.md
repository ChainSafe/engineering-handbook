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

### `.invariance` framework

- **Source.** Martin Maurer's `.invariance` repo. See [`../invariants/invariance-framework.md`](../invariants/invariance-framework.md) for the deep-link map.
- **Maintainer.** [@boorich](https://github.com/boorich) (Martin Maurer).
- **Covers.** Architectural invariants — what they are, how they are named, how they are tested, how they are versioned, how violations are reported. Multi-repo convention.
- **Used by.** [`../invariants/invariance-framework.md`](../invariants/invariance-framework.md) (pointer page); every [`../languages/<lang>/architect.md`](../languages/) page deep-links into per-language invariant sections; ADR templates referenced from [`../workflows/pr-authoring.md`](../workflows/) require an "Invariants impacted" field sourced from `.invariance`.
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
- **Used by.** [`../workflows/testing-and-qa.md`](../workflows/) borrows the QA framing around what agents should generate vs. what operators must own. Forest-specific reviewer skills will reference it once they land.
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
- **Used by.** Every skill in [`../skills/`](../skills/) is authored via `skill-creator` per [PLAN.md §5a](../PLAN.md#5a-authoring-every-skill-goes-through-skill-creator). The handbook references the spec for format requirements but does not duplicate it.
- **Coordination.** External. The spec is treated as authoritative; if it changes, the handbook's skill-authoring guidance changes alongside.

## Sources we expect to add

Surfacing known candidates rather than fabricating coverage:

- **Other internal artifacts to canonicalize.** When team members surface practices that exist in product repos or docs and could become canonical sources, they get added here with the original author credited (see [`./attribution.md`](./attribution.md)).
- **Language-specific upstream references.** Per-language reviewer pages may deep-link into language-community standards (e.g., the Rust API guidelines). Those entries land as Phase 4 language pages are drafted.

## Related

- [`../NOTICE`](../NOTICE) — third-party attribution required under Apache 2.0 §4(d). Sources with upstream licenses or attribution requirements are also recorded there.
- [`./attribution.md`](./attribution.md) — the curatorial credit policy; how original authors are surfaced across the three-layer attribution model.
- [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md) — the contributor index. Maintainers named here also appear there.
- [`../PLAN.md` §4a and §4b](../PLAN.md) — the architecture/system-design and infrastructure deferral decisions that grounded this catalog.
