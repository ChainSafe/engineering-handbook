# `(wip)-career/` — Career & People (WIP)

This directory holds career-development and people-process content extracted from the legacy `4_the-formal-stuff/` Docusaurus tree. It is **work-in-progress** and intentionally **not** part of the v2 handbook's main tree.

## Why it's here, not in the main tree

[PLAN.md §6](../PLAN.md) explicitly skipped career ladders, 360 reviews, and process-and-policy from the v2 handbook on the grounds that "career ladders and 360 reviews — that's HR/people, not agent guidance. Lives elsewhere." The handbook's primary audience is engineering practice — for humans doing the work and for AI agents helping them — and people-process documentation belongs in a different home.

This content is **public-safe** — no secrets, no confidential org material. The open question isn't whether to publish, only where to publish it: a `career/` or `people/` top-level here as a peer to `operating-model/` etc., or a separate People-Ops / HR home. The decision is deferred until the v2 launch settles. Until then, this directory keeps the content reachable and clean.

## What was cleaned in the extraction (2026-05-27)

The legacy files arrived with Docusaurus-specific markup. The following was stripped:

- Docusaurus YAML frontmatter (`sidebar_position`, `sidebar_label`, `title:` Docusaurus form) — removed entirely; per [PLAN.md §4d](../PLAN.md#4d-convention-no-yaml-frontmatter-on-content-pages), v2 content pages do not carry frontmatter.
- Numbered filename prefixes (`1_`, `2_`, etc.) — Docusaurus ordering hints; the v2 convention doesn't use them.
- `.mdx` extensions — renamed to `.md`; without Docusaurus, MDX rendering is moot.
- `_category_.yml` files — Docusaurus directory config; not applicable.
- `:::info` / `:::note` admonitions — converted to markdown blockquotes.
- JSX inline `<span className="axis">X</span> ➡ <span className="level">Y</span>` — converted to plain markdown `**X** → **Y**`.
- `import EngLadderGraph from "@site/src/components/EngLadderGraph"` and `<EngLadderGraph type="..." />` React component embeds — removed; these only rendered under Docusaurus as interactive comparison charts and have no markdown equivalent. The static role charts (per-role JPGs in `career-development/assets/`) still render fine.
- Notion link to "ChainSafe OS pages / Core Concepts v1.0" — preserved as-is; content is public-safe.

Note: a few macOS `.DS_Store` files and the original `_category_.yml` may still be on disk — the sandbox permission model prevented deletion. They are git-ignored (`.DS_Store`) or harmless residue; clean them up from the Mac terminal as needed.

## Contents

- [`360-reviews.md`](./360-reviews.md) — purpose, goals, and setup of ChainSafe's 360-review system.
- [`career-development/`](./career-development/)
  - [`introduction.md`](./career-development/introduction.md) — Engineering Ladders framework: levels, axes, glossary.
  - [`how-to.md`](./career-development/how-to.md) — how individuals and managers use the framework.
  - [`engineering.md`](./career-development/engineering.md) — engineering role ladder (Associate → Distinguished).
  - [`engineering-management.md`](./career-development/engineering-management.md) — engineering management ladder.
  - [`research.md`](./career-development/research.md) — research role ladder.
  - [`assets/`](./career-development/assets/) — role-card JPGs and radar-chart templates.
- [`process-and-policy.md`](./process-and-policy.md) — education budget and license-request policy (with internal-form links preserved).

## Reading order

For a new ChainSafer or anyone trying to understand the system from scratch:

1. [`career-development/introduction.md`](./career-development/introduction.md) — what the framework is, what the axes mean.
2. [`career-development/how-to.md`](./career-development/how-to.md) — how to apply it from either side (individual or manager).
3. The role page that fits the function: [engineering](./career-development/engineering.md), [engineering-management](./career-development/engineering-management.md), or [research](./career-development/research.md).
4. [`360-reviews.md`](./360-reviews.md) — the company-wide review cadence the ladder feeds into.
5. [`process-and-policy.md`](./process-and-policy.md) — the surrounding people-ops policies (education, licenses).
