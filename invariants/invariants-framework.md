# The `.invariants` Framework

For architecture and system-design invariants, this handbook does not re-derive a methodology. The canonical source is Martin Maurer's **`.invariants`** convention and optional [reference workspace](https://github.com/boorich/.invariants-starter-kit). This page's job is to deep-link into it by intent, not to gesture at it as a separate resource to "go read."

| Resource | URL |
|----------|-----|
| **Starter kit (repo)** | [github.com/boorich/.invariants-starter-kit](https://github.com/boorich/.invariants-starter-kit) |
| **Landing page** | [boorich.github.io/.invariants-starter-kit/](https://boorich.github.io/.invariants-starter-kit/) |

> **In one line:** Architecture invariants live in `.invariants` (plural). This page is the navigation surface; the rules themselves live upstream.

> **Filename:** **`.invariants`** — not the deprecated singular `.invariance`. The dotfile is YAML; no special file terminator.

## Why we defer here

`.invariants` is a multi-repo invariant convention authored by [@boorich](https://github.com/boorich). It is one of the strongest existing artifacts within ChainSafe for the question "how do we make architectural decisions consistent across products?" The handbook treats the [starter kit](https://github.com/boorich/.invariants-starter-kit) as canonical for that question — duplicating its content here would create drift; the handbook's value here is in the *navigation*, not the substance.

The deep-link map below is keyed by the question an agent or operator is trying to answer, so readers land on the exact upstream section they need.

## Deep-link map

The map is keyed by the question an agent or operator is trying to answer. Where the upstream repo lacks an anchor needed for clean linking, the convention is to request the anchor upstream rather than work around it with a deeper inline copy.

### By question

| If you are asking… | Go to (upstream `.invariants`) |
|---|---|
| What is an invariant in this framework? | [Starter kit README](https://github.com/boorich/.invariants-starter-kit/blob/main/README.md) · [Landing — What](https://boorich.github.io/.invariants-starter-kit/#what) |
| What does the dotfile look like? | [`.invariants.example`](https://github.com/boorich/.invariants-starter-kit/blob/main/.invariants.example) · [Landing — Spec](https://boorich.github.io/.invariants-starter-kit/#spec) |
| How do I name an invariant? | Naming convention section *(anchor TBD upstream — coordinate with @boorich)* |
| How do I make an invariant testable? | `verify` hints in dotfile + [conformance agent](https://github.com/boorich/.invariants-starter-kit/blob/main/.cursor/rules/conformance-agent.mdc) |
| What is the lifecycle of an invariant — proposal → approval → enforcement → retirement? | Lifecycle section *(anchor TBD upstream)* |
| How is an invariant violation reported and triaged? | [Conformance agent](https://github.com/boorich/.invariants-starter-kit/blob/main/.cursor/rules/conformance-agent.mdc) · GitHub labels (`needs_triage` → `in_triage`) in starter kit README |
| How are invariants versioned and migrated? | Versioning section *(anchor TBD upstream)* · severity table on [landing — Verdict](https://boorich.github.io/.invariants-starter-kit/#verdict) |
| How does `.invariants` interact with ADRs in product repos? | [PR authoring — invariants impacted](https://github.com/ChainSafe/engineering-handbook/blob/main/workflows/pr-authoring.md) (handbook) + cascade in dotfile |
| How do I run the optional agent + code-index loop? | [Landing — Try it](https://boorich.github.io/.invariants-starter-kit/#try) · `bash setup.sh` in starter kit |

### By context

Where the handbook deep-links into `.invariants` from elsewhere:

| Handbook section | Upstream target |
|---|---|
| `languages/<lang>/architect.md` (every architect role) | Per-language invariant section, e.g. concurrency invariants for the Rust architect, data-integrity invariants for the Daml architect — plus product-repo `.invariants` files |
| `workflows/pr-authoring.md` (ADR templates) | "Invariants impacted" template guidance — cite assertion `id` from the cascade |
| Reviewer skills — when a language reviewer needs to check whether an architectural invariant is violated | Reviewer-facing rules; architectural claims defer to dotfiles + [conformance agent](https://github.com/boorich/.invariants-starter-kit/blob/main/.cursor/rules/conformance-agent.mdc) |

## How to use this page

- **As an agent:** before any architecture or system-design task, consult the by-question table above. Fetch the upstream `.invariants` content for the entries that apply. Do not paraphrase upstream content from your training; pull the actual file.
- **As an operator:** when reviewing an architectural proposal (ADR, design doc, system design), use the deep-link table to verify the proposal addresses the relevant invariants. The `languages/<lang>/architect.md` pages cite specific invariants per language; this page is the meta-index.
- **As a contributor adding architectural content to this handbook:** do not duplicate `.invariants` rules in your page. Deep-link them. If the upstream rule you need is not anchorable cleanly, coordinate with [@boorich](https://github.com/boorich) to add the heading, then link.

## Inline `.invariants`-derived rules (for trivial-lookup cases only)

To keep agents from chasing the link for every minor question, a small set of `.invariants`-derived rules is restated inline. This list is kept short on purpose — anything beyond a one-liner belongs upstream, not here.

*Which rules earn an inline restatement versus a link-only entry is coordinated with [@boorich](https://github.com/boorich). The bar is deliberately high: only genuinely one-line, frequently-needed rules are restated here; everything else stays upstream.*

**Do not put in dotfiles:** issue numbers, "currently failing", fork labels, or temporary waivers — see starter kit README and landing page.

## Coordination

[@boorich](https://github.com/boorich) is the maintainer of `.invariants` and the CODEOWNER for this pointer page (see [`../.github/CODEOWNERS`](../.github/CODEOWNERS)). Any change to the deep-link map or to the inline-rules section goes through him. Conversely, when the upstream repo restructures, the anchors here update — the pointer page is the contract between the handbook and the upstream repo.

## Related

- [`engineering-invariants.md`](./engineering-invariants.md) — general engineering invariants. `.invariants` is the domain-specific complement for architecture.
- [`agent-era-invariants.md`](./agent-era-invariants.md) — agent-specific invariants; orthogonal to `.invariants`.
- [`../languages/`](../languages/) — language-specific architect pages deep-link into `.invariants` per the by-context table above.
- [`../references/sources.md`](../references/sources.md) — full catalog of external canonical sources the handbook defers to.
