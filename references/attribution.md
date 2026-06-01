# Attribution Policy

How original authors are credited across the ChainSafe Engineering Handbook. The curatorial model is only credible if credit is visible everywhere it matters.

> **In one line:** Three layers — git history, [`CONTRIBUTORS.md`](./CONTRIBUTORS.md), [`CODEOWNERS`](../.github/CODEOWNERS). Plus [`NOTICE`](../NOTICE) for upstream content carrying license obligations.

## The curatorial model

This handbook is curated, not solo-authored. Practices already exist across the org and within the wider open-source ecosystem; the curator (currently [@kalambet](https://github.com/kalambet)) aggregates them, ensures consistency of voice, and routes content to the right reviewers — but does not claim authorship of material someone else wrote.

This creates an asymmetry from the usual "author of record" pattern: the person who *adapts* a practice into the handbook is not the same as the person who *originated* it, and both get credit. Section 5 below explains the difference.

## The three attribution layers

Every piece of content carries credit at three layers. None of them can be skipped.

### Layer 1: Git history

The authoritative record of *who touched this file and when*. `git log` and `git blame` are true by construction — every commit carries author identity and timestamp, and the history is immutable.

This handbook deliberately does **not** maintain `authors:` or `last_updated:` fields in YAML frontmatter on content pages. Hand-maintained authorship and timestamps rot the moment someone else touches the file; git already has the answer, more accurately. For the same reason, the handbook does not maintain a "last reviewed" timestamp — if you want to know how stale a file is, run `git log -1 --format=%cs <file>`.

The single exception is `skills/*/SKILL.md` files, where the Anthropic skills spec requires YAML frontmatter (`name:`, `description:`, `metadata:`) and a CI sync-check parses it. Those keep frontmatter; everything else gets attribution from git.

### Layer 2: `CONTRIBUTORS.md`

The central index. Lives at [`./CONTRIBUTORS.md`](./CONTRIBUTORS.md). One entry per contributor: GitHub handle, name, role, sections owned or contributed to, optional free-form notes.

The index is for navigation ("who do I ask about this section?") and for credit ("who has contributed?"). Two distinct purposes; both are served by the same page.

Entry conventions:

- Add yourself (or get added) when authoring new content or contributing material from an upstream source.
- Past contributors remain credited after they leave the org. Removal is the rare case — a typo fix or trivial edit does not earn an entry on its own, but a substantive section contribution does.
- The index is organized by *role* (curator, section owner, contributor), not chronologically.

### Layer 3: `CODEOWNERS`

Lives at [`../.github/CODEOWNERS`](../.github/CODEOWNERS). Routes review of changes — when someone (human or agent) opens a PR touching a section, the right reviewer is auto-requested.

CODEOWNERS is not just review routing; it is a public statement of who owns what. A CODEOWNERS entry is read by humans as "this person has authority and responsibility for this section." The default owner is [@kalambet](https://github.com/kalambet) (CTO and curator); section-specific overrides are added in CODEOWNERS as sections gain dedicated owners.

## Why three layers and not one

Single-layer attribution fails in predictable ways:

- **Git history alone** is not navigable — there is no curator-level view of "who owns the Rust section." `git log` shows commits, not ownership.
- **A central index alone** drifts from the content. The index says X owns section Y, but the history shows Z wrote it. Readers do not know which to believe.
- **CODEOWNERS alone** conflates ownership with authorship. The CODEOWNER reviews changes; they did not necessarily write the original content.

All three together provide redundancy and serve different purposes: git is true by construction at the line level, the index is navigable at the page level, and CODEOWNERS enforces routing at the directory level.

## Adapted vs. originated

A distinction worth being deliberate about:

- **Originator** — the person who wrote the substantive content or who developed the practice the content is documenting. Credited in [`CONTRIBUTORS.md`](./CONTRIBUTORS.md) and, when license obligations apply, in [`NOTICE`](../NOTICE) and [`sources.md`](./sources.md).
- **Adapter** — the person who pulled the originator's work into the handbook, restructured it, kept it consistent with handbook conventions. Credited in [`CONTRIBUTORS.md`](./CONTRIBUTORS.md) and visible in git history.
- **Curator** — the person responsible for the handbook as a whole. Credited in CODEOWNERS as the default owner and named explicitly in [`CONTRIBUTORS.md`](./CONTRIBUTORS.md).

The same person can occupy multiple roles for different content. Peter is the curator and the adapter of the `research-plan-implement` skill; Boris Tane is the originator. Both appear in different layers.

## Upstream content and Apache 2.0 §4(d)

When content carries license obligations from upstream — Ghostty's AI policy via Forest, Boris Tane's "How I Use Claude Code" via the `research-plan-implement` skill, etc. — Apache 2.0 §4(d) requires attribution preservation in derivative works.

The handbook satisfies this via:

- A prose attribution line in the page itself (typically in the opening paragraph or a "Related" section), naming the upstream source with a link.
- For SKILL.md files, the `metadata.based-on` or equivalent field in the YAML frontmatter.
- The [`NOTICE`](../NOTICE) file at the repo root, which lists every third-party source the handbook carries and the relevant attribution. **This is the authoritative record for license-compliance purposes.**
- The corresponding entry in [`./sources.md`](./sources.md) (External Canonical Sources catalog).

When new third-party material is incorporated, the NOTICE file is updated in the same PR that adds the material. Drift between NOTICE and what the content actually carries is a license-compliance bug.

## Adding a contributor

When a new person contributes substantive content:

1. Commit the change under their GitHub identity (git history captures Layer 1 automatically).
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
