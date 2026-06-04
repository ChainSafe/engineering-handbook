# The `.invariants` Framework

For architecture and system-design invariants, this handbook does not re-derive a methodology. The canonical source is Martin Maurer's **`.invariants`** convention and optional reference workspace. This page's job is to deep-link into it by intent, not to duplicate it here.

| Resource | URL |
|----------|-----|
| **Starter kit (repo)** | [github.com/boorich/.invariants-starter-kit](https://github.com/boorich/.invariants-starter-kit) |
| **Landing page** | [boorich.github.io/.invariants-starter-kit/](https://boorich.github.io/.invariants-starter-kit/) |
| **[vecs](https://github.com/boorich/vecs)** (code index CLI) | Used by the starter kit; optional for Level 1 dotfile-only adoption |

> **In one line:** Architectural invariants live in **`.invariants`** dotfiles (plural). This page is the navigation surface; the convention, examples, and agent loop live in the starter kit.

> **Filename:** **`.invariants`** — not `.invariance`. The dotfile is YAML; there is no special file terminator.

## Why we defer here

**`.invariants`** is a multi-repo dotfile convention ([@boorich](https://github.com/boorich)). It is one of the strongest existing artifacts within ChainSafe for the question "how do we make architectural decisions consistent across products?" The handbook treats the starter kit as canonical for that question — duplicating its content here would create drift; the handbook's value here is *navigation*, not substance.

## Adoption depth

| Level | What you do | Starter kit required? |
|-------|-------------|------------------------|
| **1** | `cp .invariants.example .invariants` in your repo | No |
| **2** | Apex + per-repo cascade (`inherits`, `cascades_to`) | No |
| **3** | `bash setup.sh` — vecs code index, `gh` triage, conformance agent | Yes — [repo](https://github.com/boorich/.invariants-starter-kit) |

## Deep-link map

Keyed by the question an agent or operator is trying to answer. Fetch upstream content; do not paraphrase from training.

### By question

| If you are asking… | Go to |
|---|---|
| What is the convention? | [Starter kit README](https://github.com/boorich/.invariants-starter-kit/blob/main/README.md) · [Landing page](https://boorich.github.io/.invariants-starter-kit/) |
| What does a dotfile look like? | [`.invariants.example`](https://github.com/boorich/.invariants-starter-kit/blob/main/.invariants.example) · Spec section on the [landing page](https://boorich.github.io/.invariants-starter-kit/#spec) |
| How are verdicts chosen? | [Conformance agent rule](https://github.com/boorich/.invariants-starter-kit/blob/main/.cursor/rules/conformance-agent.mdc) · [Verdict section](https://boorich.github.io/.invariants-starter-kit/#verdict) |
| How do I run the full loop locally? | [Try it](https://boorich.github.io/.invariants-starter-kit/#try) · `bash setup.sh` in the repo |
| Code vs markdown for agents? | README [Two layers](https://github.com/boorich/.invariants-starter-kit#two-layers-code-in-vecs-markdown-on-disk) · `·NAV` sentinels in `GLOSSARY.md` |
| Qdrant without Docker (macOS)? | [README — native install](https://github.com/boorich/.invariants-starter-kit#qdrant-without-docker-macos-power-users) |

### By context

| Handbook section | Upstream target |
|---|---|
| `languages/<lang>/architect.md` (every architect role) | This pointer page + product-repo `.invariants` files |
| `workflows/pr-authoring.md` (ADR templates) | "Invariants impacted" — cite assertion `id` from the cascade |
| Reviewer / architect skills | [`invariants-framework.md`](./invariants-framework.md) before architecture tasks |

## How to use this page

- **As an agent:** Before architecture or system-design work, consult the by-question table. Pull files from the [starter kit repo](https://github.com/boorich/.invariants-starter-kit) or product `.invariants` dotfiles. Do not invent assertion ids or severities.
- **As an operator:** When reviewing an ADR or design, verify threatened claims against the cascade. PASS/FAIL belongs in reports — never in the dotfile.
- **As a contributor:** Do not duplicate `.invariants` rules in handbook pages. Deep-link here and upstream. Coordinate anchor changes with [@boorich](https://github.com/boorich).

## What not to put in `.invariants`

Issue numbers, "currently failing", fork labels, or temporary waivers. Forks are articulated in **conformance reports**, not in the dotfile. See the [landing page](https://boorich.github.io/.invariants-starter-kit/) and starter kit README.

## Coordination

[@boorich](https://github.com/boorich) maintains the upstream convention and is CODEOWNER for this pointer page (see [`../.github/CODEOWNERS`](../.github/CODEOWNERS)). When the starter kit restructures, update this map in the same PR.

## Related

- [`engineering-invariants.md`](./engineering-invariants.md) — general engineering invariants. `.invariants` is the complement for architecture.
- [`agent-era-invariants.md`](./agent-era-invariants.md) — agent-specific invariants; orthogonal to `.invariants`.
- [`../languages/`](../languages/) — architect pages defer to `.invariants` per the by-context table above.
- [`../references/sources.md`](../references/sources.md) — full catalog of external canonical sources.
