# Engineering Handbook — Overhaul Plan

> **Working agreement — read first.** Every PR in this overhaul targets the branch **`peter/agentic-handbook-overhaul`**, *never* `main`. `main` continues to serve the legacy handbook (tagged `v1`) publicly until v0 of the rewrite is complete and review-ready, at which point we ship a single merge to `main`. Tag-on-v3 convention: `v2` stays untagged in the meantime. If you (human or agent) find yourself about to open a PR against `main`, stop and redirect.

**Status:** Draft (2026-05-27)
**Owner:** peter@chainsafe.io
**Scope:** Complete content replacement of the existing public **`github.com/ChainSafe/engineering-handbook`** repo. The legacy Docusaurus handbook currently in that repo is replaced by an AI-native source of truth consumable by agents (Claude Code, Cursor, Continue, etc.) via MCP or `chainsafe.io/llms.txt`. Delivery is a series of PRs against the existing repo, not a new repo. Legacy content is preserved by the `v1` tag in git history, not by an in-tree archive (see §6).

---

## 1. Spine: operator-first, not autopilot

The ideology threading every section of the new handbook is that **a human is the operator and is responsible for the output**, not an unsupervised automaton. Concretely this means:

- Agents propose plans before acting on any multi-step or destructive work.
- Agents surface uncertainty rather than guess.
- Agents stop at explicit gates: anything touching production, secrets, irreversible writes, public communication, or merge requires human approval.
- Agents produce diffs, ADRs, and artifacts the operator can review.

The handbook is the contract that lets a human stay accountable for output without re-reading every token an agent produces. Every page is written with that lens. If a section wouldn't change either an agent's behavior or an operator's review checklist, it doesn't belong.

---

## 2. Repo layout

Reorganize the existing `engineering-handbook` repo around four top-level concerns plus the language matrix. The Docusaurus tree is retired; markdown is rendered on GitHub and pointed to from `chainsafe.io/llms.txt`.

```
/
├── README.md                   # human-facing intro + index
├── AGENTS.md                   # agent-facing entrypoint (or CLAUDE.md)
├── VISION.md                   # ChainSafe mission, vision, core values — carried forward unchanged
├── PLAN.md                     # this file
├── operating-model/
│   ├── collaborator-statement.md   # the operator/agent contract (new)
│   ├── gates-and-escalation.md
│   ├── model-and-tool-selection.md
│   ├── mcp-and-llm-txt.md
│   └── memory-conventions.md
├── invariants/
│   ├── engineering-invariants.md   # rewrite of the 10 principles
│   ├── invariance-framework.md     # pointer to Martin Maurer's `.invariance` repo
│   └── agent-era-invariants.md     # no silent edits, no fabricated APIs, etc.
├── workflows/
│   ├── repo-and-ci-setup.md
│   ├── pr-authoring.md
│   ├── code-review.md
│   ├── testing-and-qa.md
│   ├── incident-response.md        # pointer to ChainSafe/infrastructure-general
│   ├── release-and-deploy.md       # pointer to ChainSafe/infrastructure-general
│   └── infrastructure-and-devops.md # pointer to ChainSafe/infrastructure-general
├── languages/
│   ├── go/         { architect.md, developer.md, reviewer.md, idioms.md, gotchas.md }
│   ├── rust/       { ... }
│   ├── typescript/ { ... }
│   ├── solidity/   { ... }
│   ├── daml/       { ... }
│   ├── python/     { ... }   (v2)
│   └── zig/        { ... }   (v2)
├── references/
│   ├── attribution.md
│   ├── sources.md              # Infra IR (Josh), Forest AI_POLICY, .invariance, etc.
│   ├── contributors.md
│   └── changelog.md
└── skills/                # Anthropic Skills authored via `skill-creator` (source-of-truth, not generated)
    ├── chainsafe-research-plan-implement/SKILL.md   # adopted from Peter's existing skill
    ├── chainsafe-go-developer/SKILL.md
    ├── chainsafe-rust-reviewer/SKILL.md
    └── ...
```

Two access modes are supported by design: an agent can either consume the handbook markdown directly via an MCP server pointed at this repo, or load a specific skill from `skills/`. Both layers are source-of-truth — the handbook pages explain the practice in prose for human and agent reading, and the skills package the same practice in Anthropic SKILL.md form for agent triggering. Skills are authored independently via `skill-creator`, not generated from the handbook prose.

---

## 3. Preserved and new top-level pages

**VISION.md** carries forward the existing ChainSafe mission, vision, and core values (Openness, Learning, Collaboration, Compassion, Accountability, Diligence, Freedom, Friendliness) verbatim from the legacy handbook. The file keeps its name. These are not replaced. They describe the people and culture of ChainSafe; the agent contract is additive, not a substitute.

**`operating-model/collaborator-statement.md`** is the new flagship page — the operator/agent contract. It is intentionally separate from VISION.md because it answers a different question: not "what do we believe as humans," but "how do an operator and an AI collaborator share responsibility for an output." It is the page every agent loads first.

**AGENTS.md** is the directory map: where to find what, in what order to read it, when to ask. Lives at the root so any tool dropped into the repo can find its way.

---

## 4. Cross-cutting sections (the rewrites)

All four cross-cutting themes carry forward from the legacy handbook but are rewritten through the operator-first lens. Original authors are credited where content is canonicalized from existing org artifacts (Infra IR, `.invariance`, Forest `AI_POLICY.md`).

**Operating model** is the new piece. It covers when an agent should plan vs. act, what operator-in-the-loop means in practice (review checkpoints, dry-runs, scoped permissions), how to escalate ambiguity, how to choose a model or tool for a task, how to read and update memory, how to use MCPs, and how to leave an audit trail (commit messages, PR descriptions, ADRs).

**Invariants** carries the 10 engineering principles forward but trims aspirational language to crisp rules. "Document everything" becomes "every non-trivial change ships with an ADR or PR description an operator can audit." "Standards lead to better code" becomes "lint, format, type-check, test — never bypass without an explicit operator override." This handbook does not duplicate the `.invariance` framework — see §4a below.

**Repo & CI setup** turns the legacy checklist into an agent-runnable runbook: branch protection settings, CODEOWNERS, CLA bot, label taxonomy, required checks, and the security baseline (secret scanning, dependency review, SBOM, signed commits). The operator approves the plan; the agent executes; each step lists its rollback path. Anything deeper than per-repo hygiene — deployment topology, IaC, observability, on-call, runbooks — defers to `infrastructure-general` (see §4b).

**PR authoring** keeps the legacy author-guide's strongest rules (small focused PRs, no self-resolving threads, commits address reviewer comments) and adds agent-era ones: declare what was AI-generated vs. human, link to the plan, surface assumptions, flag any file touched that wasn't in the original ticket scope. The PR-authoring workflow itself — research, plan, implement, with the invariance check explicit at each step — is delegated to Peter's existing **`research-plan-implement`** skill (current source: `~/.config/agents/research-plan-implement.md`). The handbook deep-links into the packaged skill rather than re-deriving the workflow; if the source file isn't already in Anthropic SKILL.md format, the build step converts it (kebab-case name, frontmatter with description in `[What it does] + [When to use it] + [Key capabilities]` shape, references/ for any longer detail).

**Code review** splits into two modes. (a) Operator reviewing agent output — what to look for, when to demand a re-plan vs. accept, common failure modes (over-eager refactors, fabricated imports, silent scope creep). (b) Agent reviewing a human or agent PR — checklist, what to flag vs. fix in place, how to phrase comments, when to refuse review and escalate.

**Testing & QA** keeps the legacy QA principles but reframes around what agents should generate (unit, property-based, fuzz inputs, integration scaffolding) vs. what an operator must own (acceptance criteria, manual exploratory testing, security-sensitive paths). Borrows directly from Forest's `AI_POLICY.md` with Ghostty attribution preserved.

---

## 4a. Architecture & system design — canonical source: `.invariance`

For **all architecture and system design work**, this handbook does not re-derive a methodology. The canonical source is Martin Maurer's **`.invariance`** project. The handbook's job is to deep-link into it from precisely the places agents and operators need it — not to gesture at it as a separate resource to "go read."

Concretely:

- `invariants/invariance-framework.md` is a navigation page, not a "see also" page. It surfaces a short, curated map of deep links into specific `.invariance` files, headings, and anchors — keyed by question ("how do I name an invariant?", "what makes an invariant testable?", "how is a violation reported?") — so an agent reading the handbook lands on the exact paragraph it needs in the upstream repo. It also names Martin as the maintainer and lists the small set of `.invariance`-derived rules that other handbook pages reference inline (so trivial lookups don't require a hop).
- Every language **`architect.md`** in `languages/<lang>/` does not say "consult `.invariance` first." It opens with a section of deep links into the specific `.invariance` pages that govern architectural decisions for that language's typical workloads — e.g., the concurrency invariants page anchored to the relevant heading for the Rust architect, the data-integrity invariants page for the Daml architect.
- ADR templates referenced from the workflows section have an "Invariants impacted" field that takes deep links into `.invariance` (file + heading anchor), not free-text mentions.

If `.invariance` content needs to be mirrored locally for agent ergonomics (e.g., a stripped-down cheatsheet), it is mirrored with attribution and a back-link to the upstream file/anchor as the source of truth.

---

## 4b. Infrastructure & DevOps — canonical source: `ChainSafe/infrastructure-general`

For **all infrastructure, IaC, deployment, observability, on-call, and DevOps practices**, the canonical source is the **`ChainSafe/infrastructure-general`** repo (a clone is available locally at `/Users/peter/Documents/Claude/Projects/Copilot/infrastructure-general/`, which already ships its own `AGENTS.md` and `CLAUDE.md` — confirming the agent-native posture). The handbook does not duplicate it.

Concretely:

- `workflows/infrastructure-and-devops.md` is a navigation page, not a "see also" page. It does not link to the repo root and stop. It deep-links into the specific files an agent needs by intent — e.g., "to bootstrap a new service" links to the precise Terraform module or Ansible role; "to add an alert" links to the specific observability config file and heading; "to onboard a new engineer to infra" links to `docs/onboarding.md` at the relevant section anchor.
- `workflows/incident-response.md` and `workflows/release-and-deploy.md` link to the specific runbook files and anchors in `infrastructure-general/docs/runbooks/`, indexed by scenario (e.g., a degraded validator, a failed deploy, a paging escalation). The handbook keeps only the *operator decision policy* layer inline — when to page, when to roll back, who approves a deploy — and defers every *how-to* step to a linked anchor.
- `workflows/repo-and-ci-setup.md` retains the per-repo hygiene checklist inline (branch protection, CODEOWNERS, etc.) because that's a property of individual product repos, not infra. Anything cluster-, account-, or env-level deep-links into `infrastructure-general`.
- Coordination point: Josh (Head of Infra) is the owner of `infrastructure-general`; any change to handbook pointers that touches infra practice gets reviewed with him.

The Infra IR doc previously flagged as a v0 candidate for the standards repo is reframed under this model: it stays in `infrastructure-general`, and the handbook deep-links into its sections rather than copying them.

---

## 4c. Convention: deep links, not "see also"

When the handbook defers to an external source (`.invariance`, `infrastructure-general`, Forest `AI_POLICY.md`, anything else), the deferral is a **deep link to a specific file, heading, or anchor**, indexed by the question the reader is trying to answer. A handbook page saying "consult X" or linking only to a repo root is a bug.

Requirements that follow from this:

- Every external reference is a URL with a file path and, where the upstream supports it, a heading anchor.
- Links are keyed by intent ("how do I name an invariant?", "how do I roll back a deploy?"), not by source structure. Two intents pointing at the same upstream file get two separate links.
- Link rot is a real risk; the handbook's CI includes a link checker that runs against the markdown corpus and fails the build on any broken external link.
- When the upstream restructures, the handbook updates its anchors. The pointer pages are the contract.
- If the upstream lacks the headings/anchors needed to deep-link cleanly, the handbook coordinates with the upstream owner (Martin for `.invariance`, Josh for `infrastructure-general`) to add them — rather than working around with deeper inline copies.

---

## 5. Language ecosystems — role × language matrix

Each language gets a directory with three roles plus shared idioms and gotchas:

- **Architect** — patterns, libraries, project layouts, ADR shape, trade-offs to surface, service boundaries, error model, concurrency model. **Defers to `.invariance` (§4a) for the architectural framework itself**; the language architect page covers what changes *because* the implementation language is this one.
- **Developer** — idiomatic code, dependency management, testing tooling, CI setup, common pitfalls. Expansion of the legacy `tech-stack/` pages.
- **Reviewer** — language-specific things to look for in a PR. Memory safety in Rust, goroutine leaks in Go, reentrancy in Solidity, upgrade safety in Solidity, ledger semantics in Daml, etc. Reviewer skills are tiered by language risk (per §7.5): Solidity and Daml reviewers emit HARD FAIL on security-critical checks; other-language reviewers emit SOFT WARNING. Agent never blocks merge; operator always decides.

Each role page is the markdown source; the corresponding skill bundle in `skills/chainsafe-<lang>-<role>/` is authored using Anthropic's **`skill-creator`** skill (canonical authoring tool — see §5a). Skill-creator enforces the schema (kebab-case name, description in `[What it does] + [When to use it] + [Key capabilities]` shape, sub-1024-char description, under-5000-word SKILL.md, deeper material in `references/`), runs triggering tests, and benchmarks variance. Skill bundles are **authored via skill-creator, committed to the repo, and discoverable** so any agent (Claude Code, Cursor, Continue, etc.) can pull them.

### 5a. Authoring: every skill goes through `skill-creator`

Every skill in `skills/` is authored, edited, or optimized using Anthropic's **`skill-creator`** skill. This is non-negotiable for this project:

- **From scratch:** invoke `skill-creator` in bootstrap mode with the source content (a role page in `languages/`, a workflow page in `workflows/`, or a brought-in skill like `research-plan-implement`).
- **Edits:** invoke `skill-creator` in iteration/optimization mode against the existing `SKILL.md`.
- **Triggering quality:** rely on `skill-creator`'s eval loop rather than eyeballing whether a description fires.
- **No custom generator script.** An earlier plan version proposed a Python/Node script that emitted SKILL.md from role markdown and stored output under `dist/skills/`; that's dropped. Skills live at the root `skills/` directory as authored content, each one a `skill-creator` output committed by hand. The role-page markdown in `languages/` is reference material the author draws on; it is not a build input.

### 5b. Skill distribution via `llms.txt`

`chainsafe.io/llms.txt` is the agent-facing index. In addition to deep links into the handbook prose, it lists every packaged skill in `skills/` with:

- a kebab-case skill name,
- a one-line description matching the SKILL.md frontmatter,
- a direct URL to the raw `SKILL.md` (so an agent can fetch it without cloning the repo),
- the skill's intended trigger conditions (so a foreign agent can decide whether to load it).

The same `skills/` directory is also the source the in-house MCP server (or the GitHub MCP fallback) serves to agents. Distribution paths are therefore: (a) `llms.txt` deep links for agents that consume static URLs; (b) MCP server endpoint for agents that prefer tool-style discovery; (c) raw GitHub clone for engineers who want to install a skill into their local agent config.

A CI job validates that every skill in `skills/` appears in `llms.txt` and that every `llms.txt` skill entry resolves to an existing `SKILL.md`. Drift fails the build.

### Phasing

The role × language matrix is 7 × 3 = 21 cells, and they are not equally load-bearing. Suggested phasing:

**v0 — production languages with active ChainSafe use.** Go (Gossamer), Rust (Forest), TypeScript (Lodestar), Solidity (Sygma + most crypto work). Twelve cells. This is the defensible-on-HN core.

**v1 — significant but narrower scope.** Daml (Canton). Treated carefully because Canton is strategically live (Super Validator wt 1.95, May 1 2026 effective). Architect and reviewer roles are likely more valuable than a generic developer doc; surface area is smaller.

**v2 — aspirational or tooling.** Python (confirm usage — likely scripts, ML, ops) and Zig (confirm current ChainSafe use; if mostly experimental, a placeholder + "when not to reach for this" page is more honest than a fabricated guide).

---

## 6. What to skip (deliberately)

Calling these out so they don't waste cycles in v0:

- **Career ladders and 360 reviews** (`4_the-formal-stuff/2_career-development`, `1_360-reviews.md`) — HR/people, not agent guidance. Lives elsewhere.
- **Process & policy** (licenses, education benefits) — admin, not standards.
- **HOME.md welcome blurb** — replaced by README + AGENTS.md.
- **Docusaurus setup, CloudFlare Pages deployment, IPFS WIP, Redocly WIP** — Docusaurus is retired; markdown is rendered on GitHub and pointed to from `llm.txt`.
- **Unity stub** — not in scope, drop it.
- **Generic "best practices" filler** — anything that doesn't change agent or operator behavior gets cut.

VISION.md is explicitly **not** skipped. It carries forward under its existing name.

**No `legacy/` archive subtree.** An earlier plan version proposed moving the legacy Docusaurus pages into `legacy/` so they'd be available for cross-referencing in the working tree. Dropped: the `v1` tag on `main` already preserves every legacy file in git history forever, and an in-tree archive would surface in agent search results alongside current pages — undermining the "this is the canonical AI-native handbook" contract. Legacy pages are deleted outright during the v0 launch sweep (Phase 8). `git show v1:<path>` or a temporary `git worktree add ../handbook-v1 v1` are the canonical retrieval paths if anyone needs the old content.

---

## 7. Decisions (resolved 2026-05-27)

All five open decisions closed. Resolutions are load-bearing for the sections above; implications are summarized here.

1. **Repo name → already `engineering-handbook`.** No rename action needed. The target repo `github.com/ChainSafe/engineering-handbook` already exists and is the repo we are overhauling — it currently hosts the legacy Docusaurus handbook. The overhaul is delivered as a series of PRs against the existing branch `peter/agentic-handbook-overhaul`, with a single merge to `main` once v0 is complete. The legacy state on `main` is tagged `v1`; the rewrite stays untagged until the next major milestone (tag-on-v3 convention). The legacy pages stay at the repo root during Phases 0–7 (in-place, untouched) and get deleted outright in the Phase 8 launch sweep — the `v1` tag preserves them in history (see §6).
2. **Skill packaging → `skill-creator` for all skills.** No custom generator script. Every skill in `skills/` is authored, edited, or optimized via Anthropic's `skill-creator`. See §5a.
3. **MCP distribution → both, phased.** v0 ships with GitHub MCP + `llms.txt` deep links (zero infra, defensible immediately). An in-house ChainSafe MCP server is a Phase 8+ enhancement, justified only if observed agent-usage patterns show GitHub MCP discovery is the bottleneck. See §5b.
4. **Attribution → all three layers.** `CODEOWNERS` enforces review on changes to a section, `CONTRIBUTORS.md` is the central index, and every content file carries an inline credit in its header. The curatorial model only works if credit is visible at every level it matters.
5. **Reviewer skill severity → tier by language risk; agent never blocks.** Solidity and Daml reviewer skills emit **HARD FAIL** findings on specific checks (Solidity: reentrancy, upgrade safety, audit-readiness; Daml: ledger invariants, upgrade safety, authorization correctness). Reviewer skills for Go, Rust, TypeScript, Python, Zig emit **SOFT WARNING** findings on style/idiom violations. In all cases the agent reports — the human operator decides whether to merge. This preserves the operator-first contract (§1) while making the safety story for security-critical languages crisp.

---

## 8. Suggested next step

Draft `operating-model/collaborator-statement.md` first. It is the most novel page and the one every other section hangs off. If the operator/agent contract is crisp in a page or two, every other rewrite has a clear lens to apply against. After that lands, the v0 invariants page is the next natural target.
