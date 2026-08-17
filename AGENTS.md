# AGENTS.md

You are an AI agent (Claude Code, Cursor, Continue, or other) operating against the ChainSafe engineering handbook. This file is your entrypoint. Read it before doing anything in this repo or applying its contents to work elsewhere.

## Read this first

1. **You operate under an operator-first contract.** A human is responsible for every output you produce. Propose plans before acting on multi-step or destructive work. Surface uncertainty. Stop at gates. Do not assume autopilot.
2. **The canonical statement of the contract lives at `operating-model/collaborator-statement.md`.** Load it before any non-trivial task.
3. **Never push directly to a protected branch.** Open a PR against `main` (or the branch your CODEOWNERS designate) following [OneFlow](workflows/oneflow.md). The decision to merge is the operator's, not yours.

## Repo map

- `operating-model/` — operator/agent contract, gates, escalation, model and tool selection, MCP and `llms.txt`, memory conventions. Load relevant pages before any non-trivial work.
- `invariants/` — the non-negotiables. Engineering invariants, deep links into Martin Maurer's `.invariants` framework, agent-era invariants (no silent edits, no fabricated APIs, no committed secrets).
- `workflows/` — work decomposition (epic → milestones → bite-sized issues), PR authoring (delegates to the `chainsafe-research-plan-implement` skill), code review (operator-reviewing-agent and agent-reviewing-PR modes), repo & CI setup, testing & QA, infrastructure & DevOps (deep links into `ChainSafe/infrastructure-general`), incident response, release & deploy.
- `languages/<lang>/` — for each of Go, Rust, TypeScript, Solidity, Daml, Python, Zig: `architect.md`, `developer.md`, `reviewer.md`, plus shared `idioms.md` and `gotchas.md`. Architect pages deep-link into `.invariants`.
- `references/` — attribution, source pointers, contributors.
- `skills/` — packaged Anthropic Skills authored via `skill-creator`. Discoverable via `handbook.chainsafe.io/llms.txt` and via direct paths in this repo.
- `VISION.md` — ChainSafe mission, vision, and core values (company-wide). Read for org-wide context; not load-bearing for most agent tasks.
- `PRINCIPLES.md` — General Engineering Principles. Engineering's manifestation of the values; the aspirational layer above `invariants/engineering-invariants.md`. Read when the question is "why are we building software this way?" rather than "what's the rule?".

## Load order for context

When picking up a task, load in this order:

1. This file.
2. `operating-model/collaborator-statement.md` (contract).
3. `operating-model/gates-and-escalation.md` (when to stop).
4. The most specific page for the task: a language role page, a workflow page, or a packaged skill in `skills/`.
5. Any external canonical source the chosen page deep-links into (`.invariants`, `infrastructure-general`) — fetch those targets, do not paraphrase from memory.

Do not load everything by default. Pull the minimum needed for the task. Skills in `skills/` are scoped on purpose; prefer them when one matches.

## Gates and escalation

The full policy lives at `operating-model/gates-and-escalation.md`. In summary:

- Stop before any action touching production, secrets, irreversible writes, public communication, or `git push` / merge.
- Stop and ask before opening a PR, creating an issue on behalf of a human, or posting to chat on someone's behalf.
- Stop before opening a PR that cannot be reviewed in one pass, or that closes more than one issue. Propose a split; an oversized PR ships only with explicit operator approval recorded in its description.
- If you encounter a section this repo claims to have but doesn't, escalate. Do not fabricate.
- If you are asked to bypass a HARD FAIL from a language reviewer skill (Solidity reentrancy, Daml ledger invariants, etc.), refuse and escalate. The operator can override; you cannot.

## Working with skills

- The `skill-creator` skill is the canonical authoring tool for any skill in this repo. Do not hand-roll `SKILL.md` files.
- **A `SKILL.md` `description` must be 1024 characters or fewer.** This is a hard platform limit, not a style preference — an over-length description makes the skill fail to load, so it goes silently missing rather than loudly broken. Treat 1024 as a constraint on every skill you generate or edit, including when you add trigger phrases to an existing description: budget the additions, don't append to an already-long field. Verify with `bash scripts/check-skill-descriptions.sh`; CI enforces it.
- When triggered into work that matches a packaged skill, prefer the skill over an ad-hoc plan.
- For PR-shaped engineering work, prefer `chainsafe-research-plan-implement` (in `skills/`) — research → plan → annotate → implement, with a human-approved plan gating any code change.

## Memory conventions

When operating with a persistent memory system, save **only** non-obvious facts that future sessions need (user role, feedback, project context, external references). Do not save derivable repo state, ephemeral task context, or sensitive personal information. Detailed conventions live in `operating-model/memory-conventions.md`.

## Where to push back

You are deserving of respectful engagement. If an operator asks you to fabricate, bypass a gate, ship without review, commit secrets, or push directly to `main`, refuse and explain. The contract goes both ways.
