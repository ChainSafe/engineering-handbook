# Engineering Handbook — Execution TODO

> **Working agreement — read first.** Every PR in this overhaul targets the branch **`peter/agentic-handbook-overhaul`**, *never* `main`. See PLAN.md top banner for the full rationale. If you (human or agent) find yourself about to open a PR against `main`, stop and redirect.

Bite-sized steps for executing the overhaul described in [PLAN.md](./PLAN.md). Each step is scoped to a single PR-sized unit of work. Order is suggested, not strict — items in the same phase can parallelize.

Conventions:
- `[ ]` = not started, `[~]` = in progress, `[x]` = done
- Each step names its **owner** (default: Peter as curator) and lists its **deliverable**.
- **Every step's "deliverable" lands as a PR against `peter/agentic-handbook-overhaul`.** Never against `main`.

---

## Phase 0 — Decisions and scaffolding

- [x] **0.1 Resolve open decisions in PLAN.md §7.** Done 2026-05-27. Resolutions: (1) rename to `engineering-handbook`; (2) skill packaging via `skill-creator`; (3) MCP distribution = GitHub MCP + llms.txt for v0, in-house MCP as Phase 8+ enhancement; (4) attribution via all three layers (CODEOWNERS + CONTRIBUTORS.md + inline credits); (5) reviewer tiering by language risk with no agent-blocks. See PLAN.md §7.
- [x] **0.2 Repo naming.** Closed 2026-05-27. No rename needed — the target repo is `github.com/ChainSafe/engineering-handbook`, which already exists and currently hosts the legacy Docusaurus handbook. The overhaul ships as PRs against this existing repo, replacing its content. PLAN.md §7.1 updated to reflect this. Implication: TODO 0.3 (archive legacy Docusaurus tree) is on the critical path — must land before any replacement content does.
- [x] **0.2a Working-branch strategy.** Closed 2026-05-27. Branch `peter/agentic-handbook-overhaul` already exists in `github.com/ChainSafe/engineering-handbook`. Legacy state on `main` tagged as `v1`. The rewrite is "v2" conceptually but stays untagged until the next major milestone (tag-on-v3 convention). Implication for all subsequent TODOs: every PR in Phases 0–8 lands against `peter/agentic-handbook-overhaul`, not `main`. A single merge of that branch to `main` happens once v0 is complete and review-ready.
- [x] **0.3 Legacy Docusaurus tree — decision: do not archive into `legacy/`.** Closed 2026-05-27. Initial plan was to move `1_principles/`, `3_development/`, `4_the-formal-stuff/`, `HOME.md` into a `legacy/` subtree. Reversed after Peter's challenge: the `v1` tag on `main` already preserves the legacy content in git history forever (`git show v1:<path>` or `git worktree add ../handbook-v1 v1` retrieves any file), so a working-tree archive is redundant. More importantly, this repo's purpose is to be the *canonical* AI-native handbook — an in-tree `legacy/` would surface in agent search results alongside current pages, polluting the "what's current" contract. The legacy files stay at the root for now and will be **deleted outright** during the v0 launch sweep (Phase 8), with `v1` as the permanent reference. Stale `.github/CODEOWNERS` path (`/docs/2_development/...`) still flagged for cleanup in 0.8. `.bookignore` and `.spellcheck.yml` (Docusaurus-era tooling configs) similarly assessed for deletion in Phase 8.
- [x] **0.4 Create the new top-level directory skeleton.** Done 2026-05-27. Created with `.gitkeep` files: `00-operating-model/`, `10-invariants/`, `20-workflows/`, `30-languages/{go,rust,typescript,solidity,daml,python,zig}/`, `40-references/`. `skills/` already populated from the `research-plan-implement` conversion, no `.gitkeep` added there. All seven language placeholders created up front (v0 + v1 + v2 per PLAN §5) to make the planned coverage visible in the tree; empty v2 dirs cost nothing and signal intent.
- [x] **0.5 Create root `README.md`.** Done 2026-05-27. Human-facing intro with: status banner acknowledging v2 rewrite in progress and legacy state, what this is (curatorial, opinionated, AI-native), directory map of v2 structure, three audience cuts (humans / agents / hiring + DD), Contributing section restating the working-agreement (PRs target `peter/agentic-handbook-overhaul`), short About ChainSafe, License flagged as Phase 8 decision. Forward-links AGENTS.md (created in 0.6), PLAN.md, TODO.md, VISION.md, and the future CONTRIBUTORS.md.
- [x] **0.6 Create root `AGENTS.md` + `CLAUDE.md`.** Done 2026-05-27. `AGENTS.md` is the canonical agent entrypoint covering: operator-first contract, status (v2 rewrite in flight, missing pages are gaps not improv targets), repo map keyed by intent, explicit load order, gates and escalation defaults until `00-operating-model/gates-and-escalation.md` lands, skill conventions (`skill-creator` canonical, prefer `chainsafe-research-plan-implement` for PR work), memory conventions pointer, and an explicit "where to push back" clause. `CLAUDE.md` is a one-line pointer at AGENTS.md — content is single-source. Sandbox can't replace it with a true symlink (macOS permission quirk); Peter can convert it manually from the Mac terminal (`rm CLAUDE.md && ln -s AGENTS.md CLAUDE.md`) if he wants the symlink form.
- [x] **0.7 Carry forward `VISION.md`.** Done 2026-05-27. File was already at the root from legacy state. Stripped the Docusaurus frontmatter (`sidebar_position: 2`); all content (mission, vision, 8 core values) preserved verbatim.
- [x] **0.8 Rewrite `.github/CODEOWNERS`.** Done 2026-05-27. Replaced legacy default line (`@morrigan @mpetrunic @kalambet @AlexeyKrasnoperov @joshdougall`) with `@kalambet` as sole default during the v2 rewrite — sole curator, minimal review burden, section reviewers added as content lands. Section overrides: `/10-invariants/invariance-framework.md` → @boorich (Martin) + @kalambet; `/20-workflows/{infrastructure-and-devops,incident-response,release-and-deploy}.md` → @joshdougall + @kalambet; `/30-languages/typescript/` → @wemeetagain @beroburny @kalambet (inherited from legacy, pending v2 confirmation). Stale legacy path `/docs/2_development/2_tech-stack/Typescript/readme.md` removed (the actual legacy path was `3_development/...` without `/docs/` — never matched anything). Curator-level overrides added for PLAN.md, TODO.md, VISION.md, AGENTS.md, CLAUDE.md, README.md, and CODEOWNERS itself.
- [x] **0.9 Create `40-references/CONTRIBUTORS.md` stub.** Done 2026-05-27. Index file with the three-layer attribution model explained (this index + inline file-header credits + `CODEOWNERS`), Peter listed as sole curator at v0 status, section-owners table left empty for organic growth across Phases 2–4, and a link to `NOTICE` for Apache 2.0 Section 4(d) third-party attributions. `40-references/.gitkeep` is now redundant (directory is no longer empty); harmless if left in place, can be removed in a cleanup pass.
- [x] **0.10 Apply Apache License 2.0.** Done 2026-05-27. Added root `LICENSE` (canonical Apache 2.0 text, copyright 2026 ChainSafe Systems) and root `NOTICE` (records the third-party content already known: Boris Tane's `research-plan-implement` lineage, Ghostty/Forest `AI_POLICY.md` lineage). NOTICE is the durable place new third-party attributions get added as content lands. README.md license section updated to point at LICENSE and NOTICE. Closes the licensing question that PLAN.md and README.md had previously deferred to Phase 8.

---

## Phase 1 — Operator-first spine (the load-bearing pages)

- [x] **1.1 Draft `00-operating-model/collaborator-statement.md`.** Done 2026-05-27. Flagship operator/agent contract. ~1200 words. Structure: definitions (operator / agent / the work), why-a-contract (autopilot fails subtly; pure mistrust wastes capability; contract is the middle path), operator responsibilities (5 duties), agent responsibilities (8 duties), when-the-agent-refuses (6 cases), when-the-agent-escalates (4 cases), what-this-is-not (4 anti-patterns), when-the-contract-breaks (4 failure modes + recovery), living-document section with forward links to gates-and-escalation, model-and-tool-selection, mcp-and-llm-txt, memory-conventions (all forthcoming in 1.2–1.5) and agent-era-invariants (Phase 2). Includes YAML frontmatter convention (title, status, authors, last_updated) as the inline-attribution baseline for all future content files. The `00-operating-model/.gitkeep` is now redundant since the directory has content; harmless if left, can be removed in a cleanup pass.
- [x] **1.2 Draft `00-operating-model/gates-and-escalation.md`.** Done 2026-05-27. Operational enumeration of the contract's "stop at gates" principle. ~1700 words. Eight gate categories (production/deployment, secrets/credentials, irreversible writes, external communication, version-control state, repo/account boundaries, cost/external-resource creation, reviewer-skill HARD FAIL), each with concrete trigger examples and a "why" line. Standardized 6-step stop pattern with a worked migration-deploy example. Escalation paths covering: refusal-list collisions, two-authority conflicts, operator unavailability mid-task, ambiguous scope. Quick-reference escalation matrix table. Closing "what to do when in doubt" — the gate list is a floor, not a ceiling. Explicit cross-reference to refusals in collaborator-statement (refusals sit *above* gates: operator can approve a gate, cannot override a refusal).
- [x] **1.3 Draft `00-operating-model/model-and-tool-selection.md`.** Done 2026-05-27. Practical guidance on model tiers (Haiku/Sonnet/Opus), MCP loadout, and skill selection — all keyed off operator-first framing. Structure: who-picks-what (operator owns model tier and integrations; agent owns tool/skill picks within scope), model selection (principle, rough mapping table, when-to-surface-mismatch with concrete language), tool/MCP selection (default loadout = handbook + project source; on-demand list with canonical owners flagged; tools-to-be-skeptical-of list cross-linked to gate sections), discovery via `chainsafe.io/llms.txt`, skill selection (prefer skill over ad-hoc, default picks table, do-not-chain-automatically rule), five anti-patterns. Dated note on current model generation (Opus 4.6 / Sonnet 4.6 / Haiku 4.5) with explicit instruction that the page references tiers, not version numbers, so re-anchoring is a single-line edit when new generations ship.
- [x] **1.4 Draft `00-operating-model/mcp-and-llm-txt.md`.** Done 2026-05-27. Discovery spec covering both channels (static `chainsafe.io/llms.txt` deep links + GitHub MCP for tool-style browsing) per the phased §7.3 decision. Structure: two channels (with future in-house MCP flagged as Phase 8+), llms.txt format following the proposed standard, what goes in (sections, skills with trigger conditions, external canonical sources) and what doesn't (internal-only, transients, planned-but-not-extant pages), worked-example snippet showing actual markdown format and raw-URL convention, how-an-agent-should-use-it (session-start sequence, skill loading, handling missing references during the v2 rewrite), versioning policy during v2 (llms.txt on main reflects v1 until the single merge to main; agents testing v2 use GitHub MCP against the overhaul branch), maintenance pointers to TODO 6.3 (link checker) and 6.4 (skills↔llms.txt sync check). Explicit "do not fabricate substitute content; surface the gap" instruction for missing-reference cases.
- [ ] **1.5 Draft `00-operating-model/memory-conventions.md`.** Read/write conventions, what's appropriate to persist, sensitive-data rules.

---

## Phase 2 — Invariants and external canonical sources

- [ ] **2.1 Draft `10-invariants/engineering-invariants.md`.** Rewrite of the legacy 10 principles into crisp rules.
- [ ] **2.2 Draft `10-invariants/agent-era-invariants.md`.** No silent edits, no fabricated APIs, no committing secrets, no merging without approval, scope discipline.
- [ ] **2.3 Draft `10-invariants/invariance-framework.md` (pointer page).** Deep-link map into Martin Maurer's `.invariance` repo by question/intent. Coordinate with Martin to ensure target headings/anchors exist; request additions if not.
- [ ] **2.4 Draft `40-references/sources.md`.** Catalog of external canonical sources with attribution: `.invariance` (Martin Maurer), `infrastructure-general` (Josh, Head of Infra), Forest `AI_POLICY.md` (Ghostty origin preserved), Peter's `research-plan-implement` skill, anything else surfaced from the team.
- [ ] **2.5 Draft `40-references/attribution.md` + `40-references/contributors.md`.** Curatorial credit model — how original authors are surfaced.

---

## Phase 3 — Cross-cutting workflows

- [ ] **3.1 Draft `20-workflows/pr-authoring.md`.** Author guide rewritten for the agent era. Deep-links into the packaged `research-plan-implement` skill (see step 5.1).
- [ ] **3.2 Draft `20-workflows/code-review.md`.** Two modes: operator-reviewing-agent, agent-reviewing-PR.
- [ ] **3.3 Draft `20-workflows/repo-and-ci-setup.md`.** Per-repo hygiene checklist as an agent-runnable runbook.
- [ ] **3.4 Draft `20-workflows/testing-and-qa.md`.** What agents generate vs what operators own. Borrows from Forest `AI_POLICY.md` with attribution.
- [ ] **3.5 Draft `20-workflows/infrastructure-and-devops.md` (pointer page).** Deep-link map into `infrastructure-general` by intent. Coordinate with Josh on anchor/heading additions where needed.
- [ ] **3.6 Draft `20-workflows/incident-response.md` (pointer page).** Operator decision policy inline; deep-links into `infrastructure-general/docs/runbooks/`.
- [ ] **3.7 Draft `20-workflows/release-and-deploy.md` (pointer page).** Same pattern as 3.6.

---

## Phase 4 — Language ecosystems (v0 production languages)

Each language is its own step, expanded into three role pages plus shared idioms/gotchas. Per PLAN.md §5 phasing, v0 covers the four languages with active ChainSafe production use.

- [ ] **4.1 Go (Gossamer).** `30-languages/go/{architect.md, developer.md, reviewer.md, idioms.md, gotchas.md}`. Architect page deep-links into the relevant `.invariance` sections.
- [ ] **4.2 Rust (Forest).** `30-languages/rust/{architect.md, developer.md, reviewer.md, idioms.md, gotchas.md}`. Pull from Forest's existing AI policy where applicable.
- [ ] **4.3 TypeScript (Lodestar).** `30-languages/typescript/{architect.md, developer.md, reviewer.md, idioms.md, gotchas.md}`. Lift the strongest material from the legacy `tech-stack/Typescript/` pages.
- [ ] **4.4 Solidity (Sygma + crypto work).** `30-languages/solidity/{architect.md, developer.md, reviewer.md, idioms.md, gotchas.md}`. Reviewer page is the aggressive variant — reentrancy, upgrade safety, audit-readiness — per the §7 open decision.

---

## Phase 5 — Skills authoring (via `skill-creator`)

**Convention:** every skill in this project is authored, converted, or edited using Anthropic's `skill-creator` skill. No hand-rolled SKILL.md files, no custom generator script. See PLAN.md §5a.

- [x] **5.1 Source-fetch Peter's `research-plan-implement` skill.** Copied from `Copilot/research-plan-implement.md` into `engineering-handbook/skills/chainsafe-research-plan-implement/SKILL.md`. Audit done: missing frontmatter, titled `# AGENTS.md`, lived as a loose `.md` rather than a kebab-case folder.
- [~] **5.2 Convert `research-plan-implement` to SKILL.md format.** Manual conversion completed 2026-05-27 but **needs re-run through `skill-creator`** to align with project convention (see PLAN.md §5a). Treat the current file as a draft input; re-author via `skill-creator` iteration mode against the existing `SKILL.md`.
- [ ] **5.3 Re-author `research-plan-implement` via `skill-creator`.** Invoke `skill-creator` against the existing `skills/chainsafe-research-plan-implement/SKILL.md`. Take its output as the canonical version. Closes 5.2.
- [ ] **5.4 Author v0 language × role skills via `skill-creator`.** One `skill-creator` invocation per skill, sourcing from the corresponding `30-languages/<lang>/<role>.md`. v0 = 4 languages × 3 roles = 12 skills. Commit each output bundle to `skills/`.
- [ ] **5.5 Author cross-cutting workflow skills via `skill-creator` as needed.** Candidate skills derived from `20-workflows/`: `chainsafe-pr-author`, `chainsafe-code-review`, `chainsafe-repo-setup`, `chainsafe-testing-qa`. Confirm scope before authoring each — not every workflow page needs a packaged skill.

---

## Phase 6 — Distribution

- [ ] **6.1 Draft `chainsafe.io/llms.txt`.** Top-level index pointing to handbook sections (deep links) + every skill in `skills/` (name, one-line description, direct raw `SKILL.md` URL, trigger conditions).
- [ ] **6.2 Wire MCP distribution via GitHub MCP + `llms.txt`.** Per resolved §7.3: v0 ships the lightweight path. Document the discovery flow in `00-operating-model/mcp-and-llm-txt.md`. In-house ChainSafe MCP server is deferred to Phase 8+ as an enhancement, only if observed agent-usage shows GitHub MCP discovery is the bottleneck.
- [ ] **6.3 CI: external link checker.** Validates every external deep link (into `.invariance`, `infrastructure-general`, Forest, etc.) resolves to a real anchor.
- [ ] **6.4 CI: skill ↔ llms.txt sync check.** Every skill in `skills/` appears in `llms.txt`; every `llms.txt` skill entry resolves to an existing `SKILL.md`.

---

## Phase 7 — v1 / v2 language coverage

- [ ] **7.1 Daml (Canton).** `30-languages/daml/{architect.md, reviewer.md, idioms.md, gotchas.md}`. Developer page deferred unless demand surfaces. Reviewer is the aggressive variant — ledger semantics, upgrade safety, audit-readiness.
- [ ] **7.2 Python.** Confirm scope (scripts, ML, ops) before drafting. Then `30-languages/python/{architect.md, developer.md, reviewer.md, idioms.md, gotchas.md}`.
- [ ] **7.3 Zig.** Confirm current usage at ChainSafe. If experimental only, ship a single `30-languages/zig/README.md` page covering "when not to reach for this" rather than fabricating a full role triad.

---

## Phase 8 — Public launch

- [ ] **8.1 HN-defensibility pass.** Read every public page as if it were going to the front page. Cut filler. Tighten claims. Confirm attribution is visible.
- [ ] **8.2 Internal review with Josh and Martin.** Specifically the pointer pages into their repos.
- [ ] **8.3 Announce internally.** ChainSafe-wide post; invite contributions and corrections.
- [ ] **8.4 Wire `chainsafe.io/llms.txt` live.**
- [ ] **8.5 External announcement.** Public post + recruiting/DD signal as applicable (M&A context — coordinate with Areta on timing).

---

## Tracking

This file is the single source of truth for execution progress. Update inline (`[ ]` → `[~]` → `[x]`) as steps move. When a step grows beyond a single PR, split it into sub-steps in place rather than letting it sit half-done.
