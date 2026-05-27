---
title: Attribution Policy
status: draft (v2)
authors:
  - "@kalambet"
last_updated: 2026-05-27
---

# Attribution Policy

How original authors are credited across the ChainSafe Engineering Handbook. The curatorial model is only credible if credit is visible everywhere it matters.

> **In one line:** Three layers, no exceptions. File header, [`CONTRIBUTORS.md`](./CONTRIBUTORS.md), [`CODEOWNERS`](../.github/CODEOWNERS). Plus [`NOTICE`](../NOTICE) for upstream content carrying license obligations.

## The curatorial model

This handbook is curated, not solo-authored. Practices already exist across the org and within the wider open-source ecosystem; the curator (currently [@kalambet](https://github.com/kalambet)) aggregates them, ensures consistency of voice, and routes content to the right reviewers — but does not claim authorship of material someone else wrote.

This creates an asymmetry from the usual "author of record" pattern: the person who *adapts* a practice into the handbook is not the same as the person who *originated* it, and both get credit. Section 5 below explains the difference.

## The three attribution layers

Every piece of content carries credit at three layers. None of them can be skipped.

### Layer 1: Inline file-header credit

Every content file in the handbook has YAML frontmatter at the top with at least these fields:

```yaml
---
title: <human-readable title>
status: <draft | active | deprecated>
authors:
  - "@<github-handle>"
last_updated: YYYY-MM-DD
---
```

When content is adapted from an upstream source, a sixth field is added:

```yaml
adapted_from: <upstream identifier and a brief lineage note>
```

Example: the [`engineering-invariants.md`](../10-invariants/engineering-invariants.md) page declares `adapted_from: legacy 1_principles/index.md (ChainSafe engineering principles)` to credit the v1 source. The [`chainsafe-research-plan-implement` skill](../skills/chainsafe-research-plan-implement/SKILL.md) declares its `based-on: Boris Tane — https://boristane.com/blog/how-i-use-claude-code/`.

When multiple authors contributed substantively, list all of them in `authors`. Frontmatter is the single most durable record of authorship — it stays with the file when the file moves, gets renamed, or is reorganized.

### Layer 2: `CONTRIBUTORS.md`

The central index. Lives at [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md). One entry per contributor: GitHub handle, name, role, sections owned or contributed to, optional free-form notes.

The index is for navigation ("who do I ask about this section?") and for credit ("who has contributed?"). Two distinct purposes; both are served by the same page.

Entry conventions:

- Add yourself (or get added) when authoring new content or contributing material from an upstream source.
- Past contributors remain credited after they leave the org. Removal is the rare case — a typo fix or trivial edit does not earn an entry on its own, but a substantive section contribution does.
- The index is organized by *role* (curator, section owner, contributor), not chronologically.

### Layer 3: `CODEOWNERS`

Lives at [`../.github/CODEOWNERS`](../.github/CODEOWNERS). Routes review of changes — when someone (human or agent) opens a PR touching a section, the right reviewer is auto-requested.

CODEOWNERS is not just review routing; it is a public statement of who owns what. A CODEOWNERS entry is read by humans as "this person has authority and responsibility for this section." During the v2 rewrite, the default owner is [@kalambet](https://github.com/kalambet); section-specific overrides are added as content lands.

## Why three layers and not one

Single-layer attribution fails in predictable ways:

- **File headers alone** are easy to skim past. Readers who land on the page from a search may not look at the frontmatter; credit is recorded but not visible.
- **A central index alone** drifts from the content. The index says X owns section Y, but the file headers say Z wrote it. Readers do not know which to believe.
- **CODEOWNERS alone** conflates ownership with authorship. The CODEOWNER reviews changes; they did not necessarily write the original content.

All three together provide redundancy and serve different purposes: headers are at the point of use, the index is navigable, and CODEOWNERS enforces routing.

## Adapted vs. originated

A distinction worth being deliberate about:

- **Originator** — the person who wrote the substantive content or who developed the practice the content is documenting. Credited in `authors` (when they wrote the page) and in `adapted_from` (when their work was adapted).
- **Adapter** — the person who pulled the originator's work into the handbook, restructured it, kept it consistent with handbook conventions. Credited in `authors`.
- **Curator** — the person responsible for the handbook as a whole. Credited in CODEOWNERS as the default owner and named explicitly in [`CONTRIBUTORS.md`](./CONTRIBUTORS.md).

The same person can occupy multiple roles for different content. Peter is the curator and the adapter of the `research-plan-implement` skill; Boris Tane is the originator. Both appear in different layers.

## Upstream content and Apache 2.0 §4(d)

When content carries license obligations from upstream — Ghostty's AI policy via Forest, Boris Tane's "How I Use Claude Code" via the `research-plan-implement` skill, etc. — Apache 2.0 §4(d) requires attribution preservation in derivative works.

The handbook satisfies this via:

- Inline credits in the relevant file's header (`adapted_from` or `based-on` frontmatter field).
- The [`NOTICE`](../NOTICE) file at the repo root, which lists every third-party source the handbook carries and the relevant attribution.
- The corresponding entry in [`./sources.md`](./sources.md) (External Canonical Sources catalog).

When new third-party material is incorporated, the NOTICE file is updated in the same PR that adds the material. Drift between NOTICE and the actual file headers is a license-compliance bug; CI checks for this once Phase 6 ships.

## Adding a contributor

When a new person contributes substantive content:

1. Add YAML `authors` entry in the file they wrote or co-wrote.
2. Add an entry in [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md) under the appropriate role section.
3. If they will review future changes to that section, add them in [`../.github/CODEOWNERS`](../.github/CODEOWNERS).
4. If the content is adapted from a source with license obligations, update [`../NOTICE`](../NOTICE).
5. If the contribution involves a new canonical upstream source, add an entry to [`./sources.md`](./sources.md).

All five steps land in the same PR as the content. The handbook treats content + attribution as a single commit, not two.

## When the policy breaks

If a contribution lands without correct attribution:

- **A reviewer missed it.** The PR is amended; attribution is added; the original author is notified.
- **A contributor objected to their credit being added.** The handbook respects the request. Credit is removed or modified per the contributor's wish.
- **An upstream source's license terms were not properly attributed.** Treated as a license-compliance issue, not a style issue. Fixed immediately; NOTICE updated; the originator is notified.

## Related

- [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md) — the central contributor index.
- [`./sources.md`](./sources.md) — the catalog of external canonical sources the handbook defers to.
- [`../NOTICE`](../NOTICE) — Apache 2.0 §4(d) third-party attribution record.
- [`../.github/CODEOWNERS`](../.github/CODEOWNERS) — review routing and ownership statement.
- [`../LICENSE`](../LICENSE) — Apache License 2.0.
