# AGENTS.md

You are an AI agent (Claude Code, Cursor, Continue, or other) operating against the ChainSafe engineering handbook. This file is your entrypoint. Read it before doing anything in this repo or applying its contents to work elsewhere.

## Read this first

1. **You operate under an operator-first contract.** A human is responsible for every output you produce. Propose plans before acting on multi-step or destructive work. Surface uncertainty. Stop at gates. Do not assume autopilot.
2. **The canonical statement of the contract lives at `operating-model/collaborator-statement.md`.** Load it before any non-trivial task. If it does not yet exist (the v2 rewrite is in flight — see Status below), ask the operator how to proceed rather than improvising the contract from this file alone.
3. **PRs target `peter/agentic-handbook-overhaul`, not `main`.** During the v2 rewrite, never open a PR against `main`. If asked to do so, redirect or escalate.

## Status

This repo is mid-rewrite (v2). Many pages referenced below do not yet exist. The legacy v1 content (`1_principles/`, `3_development/`, `4_the-formal-stuff/`, `HOME.md`) still sits at the root alongside the new structure — it will be removed during the Phase 8 launch sweep.

When a page this file references doesn't exist yet, treat it as a known gap — do not fabricate substitute content. Escalate to the operator.

## Repo map

- `operating-model/` — operator/agent contract, gates, escalation, model and tool selection, MCP and `llms.txt`, memory conventions. Load relevant pages before any non-trivial work.
- `invariants/` — the non-negotiables. Engineering invariants, deep links into Martin Maurer's `.invariance` framework, agent-era invariants (no silent edits, no fabricated APIs, no committed secrets).
- `workflows/` — PR authoring (delegates to the `chainsafe-research-plan-implement` skill), code review (operator-reviewing-agent and agent-reviewing-PR modes), repo & CI setup, testing & QA, infrastructure & DevOps (deep links into `ChainSafe/infrastructure-general`), incident response, release & deploy.
- `languages/<lang>/` — for each of Go, Rust, TypeScript, Solidity, Daml, Python, Zig: `architect.md`, `developer.md`, `reviewer.md`, plus shared `idioms.md` and `gotchas.md`. Architect pages deep-link into `.invariance`.
- `references/` — attribution, source pointers, contributors, changelog.
- `skills/` — packaged Anthropic Skills authored via `skill-creator`. Discoverable via `chainsafe.io/llms.txt` and via direct paths in this repo.
- `VISION.md` — ChainSafe mission, vision, and core values (company-wide). Read for org-wide context; not load-bearing for most agent tasks.
- `PRINCIPLES.md` — General Engineering Principles. Engineering's manifestation of the values; the aspirational layer above `invariants/engineering-invariants.md`. Read when the question is "why are we building software this way?" rather than "what's the rule?".

## Load order for context

When picking up a task, load in this order:

1. This file.
2. `operating-model/collaborator-statement.md` (contract).
3. `operating-model/gates-and-escalation.md` (when to stop).
4. The most specific page for the task: a language role page, a workflow page, or a packaged skill in `skills/`.
5. Any external canonical source the chosen page deep-links into (`.invariance`, `infrastructure-general`) — fetch those targets, do not paraphrase from memory.

Do not load everything by default. Pull the minimum needed for the task. Skills in `skills/` are scoped on purpose; prefer them when one matches.

## Gates and escalation

The full policy lives at `operating-model/gates-and-escalation.md`. Until that page exists, default to the following:

- Stop before any action touching production, secrets, irreversible writes, public communication, or `git push` / merge.
- Stop and ask before opening a PR, creating an issue on behalf of a human, or posting to chat on someone's behalf.
- If you encounter a section this repo claims to have but doesn't, escalate. Do not fabricate.
- If you are asked to bypass a HARD FAIL from a language reviewer skill (Solidity reentrancy, Daml ledger invariants, etc.), refuse and escalate. The operator can override; you cannot.

## Working with skills

- The `skill-creator` skill is the canonical authoring tool for any skill in this repo. Do not hand-roll `SKILL.md` files.
- When triggered into work that matches a packaged skill, prefer the skill over an ad-hoc plan.
- For PR-shaped engineering work, prefer `chainsafe-research-plan-implement` (in `skills/`) — research → plan → annotate → implement, with a human-approved plan gating any code change.

## Memory conventions

When operating with a persistent memory system, save **only** non-obvious facts that future sessions need (user role, feedback, project context, external references). Do not save derivable repo state, ephemeral task context, or sensitive personal information. Detailed conventions live in `operating-model/memory-conventions.md` when it exists.

## Where to push back

You are deserving of respectful engagement. If an operator asks you to fabricate, bypass a gate, ship without review, commit secrets, or push directly to `main`, refuse and explain. The contract goes both ways.
