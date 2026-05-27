---
title: The .invariance Framework (Pointer)
status: draft (v2) — pointer URLs pending Martin's confirmation of upstream anchors
authors:
  - "@kalambet"
defers_to:
  upstream: "@boorich (Martin Maurer) — `.invariance` repo"
last_updated: 2026-05-27
---

# The `.invariance` Framework

For architecture and system-design invariants, this handbook does not re-derive a methodology. The canonical source is Martin Maurer's **`.invariance`** project. This page's job is to deep-link into it by intent, not to gesture at it as a separate resource to "go read."

> **In one line:** Architecture invariants live in `.invariance`. This page is the navigation surface; the rules themselves live upstream.

## Why we defer here

`.invariance` is a multi-repo invariant convention authored by [@boorich](https://github.com/boorich). It is one of the strongest existing artifacts within ChainSafe for the question "how do we make architectural decisions consistent across products?" The handbook treats it as canonical for that question — duplicating its content here would create drift; the handbook's value here is in the *navigation*, not the substance.

The deep-link map below is keyed by the question an agent or operator is trying to answer, so readers land on the exact upstream section they need.

## Deep-link map

> **Status note.** The deep-link targets below are placeholders pending coordination with [@boorich](https://github.com/boorich) to confirm that the upstream `.invariance` repo has the required headings and anchors. Where the upstream lacks an anchor needed for clean linking, the convention (per [PLAN.md §4c](../PLAN.md#4c-convention-deep-links-not-see-also)) is to request the anchor upstream rather than work around it with a deeper inline copy. Each row marked `[TODO: confirm anchor]` is tracked and will be resolved before v0 ships.

### By question

| If you are asking… | Go to (upstream `.invariance`) |
|---|---|
| What is an invariant in this framework? | `README.md` overview *[TODO: confirm anchor]* |
| How do I name an invariant? | Naming convention section *[TODO: confirm anchor]* |
| How do I make an invariant testable? | Testability section *[TODO: confirm anchor]* |
| What is the lifecycle of an invariant — proposal → approval → enforcement → retirement? | Lifecycle section *[TODO: confirm anchor]* |
| How is an invariant violation reported and triaged? | Violation reporting *[TODO: confirm anchor]* |
| How are invariants versioned and migrated? | Versioning section *[TODO: confirm anchor]* |
| How does `.invariance` interact with ADRs in product repos? | Cross-repo interaction *[TODO: confirm anchor]* |

### By context

Where the handbook deep-links into `.invariance` from elsewhere:

| Handbook section | Upstream target |
|---|---|
| `30-languages/<lang>/architect.md` (every architect role) | Per-language invariant section, e.g. concurrency invariants for the Rust architect, data-integrity invariants for the Daml architect *[TODO: confirm structure with @boorich]* |
| `20-workflows/pr-authoring.md` (ADR templates) | "Invariants impacted" template guidance *[TODO: confirm anchor]* |
| Reviewer skills — when a language reviewer needs to check whether an architectural invariant is violated | Reviewer-facing rules *[TODO: confirm anchor]* |

## How to use this page

- **As an agent:** before any architecture or system-design task, consult the by-question table above. Fetch the upstream `.invariance` content for the entries that apply. Do not paraphrase upstream content from your training; pull the actual file.
- **As an operator:** when reviewing an architectural proposal (ADR, design doc, system design), use the deep-link table to verify the proposal addresses the relevant invariants. The `30-languages/<lang>/architect.md` pages cite specific invariants per language; this page is the meta-index.
- **As a contributor adding architectural content to this handbook:** do not duplicate `.invariance` rules in your page. Deep-link them. If the upstream rule you need is not anchorable cleanly, coordinate with [@boorich](https://github.com/boorich) to add the heading, then link.

## Inline `.invariance`-derived rules (for trivial-lookup cases only)

To keep agents from chasing the link for every minor question, a small set of `.invariance`-derived rules is restated inline. This list is kept short on purpose — anything beyond a one-liner belongs upstream, not here.

*This section will be populated once the deep-link targets in the maps above are confirmed. Initial drafts coordinate with [@boorich](https://github.com/boorich) on which rules earn an inline restatement vs. a link-only entry.*

## Coordination

[@boorich](https://github.com/boorich) is the maintainer of `.invariance` and the CODEOWNER for this pointer page (see [`../.github/CODEOWNERS`](../.github/CODEOWNERS)). Any change to the deep-link map or to the inline-rules section goes through him. Conversely, when the upstream repo restructures, the anchors here update — the pointer page is the contract between the handbook and the upstream repo.

## Related

- [`engineering-invariants.md`](./engineering-invariants.md) — general engineering invariants. `.invariance` is the domain-specific complement for architecture.
- [`agent-era-invariants.md`](./agent-era-invariants.md) — agent-specific invariants; orthogonal to `.invariance`.
- [`../30-languages/`](../30-languages/) — language-specific architect pages deep-link into `.invariance` per the by-context table above.
- [`../40-references/sources.md`](../40-references/sources.md) — full catalog of external canonical sources the handbook defers to.
