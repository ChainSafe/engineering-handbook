---
title: Engineering Invariants
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 1_principles/index.md (ChainSafe engineering principles)
last_updated: 2026-05-27
---

# Engineering Invariants

The non-negotiables of how we build software. These are the rules every contributor — human or agent — operates under by default. Overriding any of them requires an explicit, logged, operator decision.

> **In one line:** Invariants are rules, not aspirations. Each one is testable, enforced by something concrete (CI, gate, reviewer skill), and overridable only on the record.

This page rewrites the legacy "engineering principles" into crisp invariants. Three of the legacy principles — *empower people*, *take initiative*, *autonomous and aligned teams* — are about culture, not engineering. They live in [`../VISION.md`](../VISION.md) under core values and are not re-stated here.

## 1. Open-source by default

**Rule.** All work — code, infrastructure config, documentation, handbooks — is public unless there is a specific, documented reason it must be private. Exceptions are written down (in the repo's README or in an internal log) and revisited.

**Why.** Public work is reviewable by more eyes, attracts external contributors, and serves recruiting and DD. Private work is invisible by default; the cost of that invisibility compounds.

**How it's checked.** Repository creation defaults to public; private repos require a written exception in the repo description or `README.md`. Quarterly review of private-repo list.

## 2. Standards are enforced, not suggested

**Rule.** Lint, format, type-check, test — never bypass without an explicit, logged operator override. CI failures block merge to protected branches.

**Why.** Standards exist because the consequences of skipping them are paid by future readers, not the person skipping. Making "the easy path" go through the standards is what makes them real.

**How it's checked.** CI runs the relevant tooling on every PR. Required checks on `main` and equivalent branches. Overrides require the override reason to land in the PR description, not in the commit message alone (PR description is harder to forget and easier to audit).

## 3. Quality is defined before the build, not after

**Rule.** Every non-trivial change ships with a definition of quality that was set before implementation — acceptance criteria, success metrics, or a test plan, depending on shape. Implementation is not "done" until the definition is met.

**Why.** "Done" without a pre-set definition becomes "done" with a post-hoc one. The post-hoc version always matches what was built, even when what was built is wrong.

**How it's checked.** PR template asks for acceptance criteria or links to the ADR/spec containing them. Reviewer skills check the diff against the stated criteria; missing criteria are a SOFT WARNING from the reviewer skill ([`30-languages/<lang>/reviewer.md`](../30-languages/) when those land).

## 4. Composable by design

**Rule.** Code is written to be composed. Public surfaces are small; modules export only what callers need; cross-module coupling goes through documented interfaces.

**Why.** Large public surfaces become permanent constraints. The cost of a too-wide API is paid every time it gets used wrong, and that cost lasts for the API's lifetime.

**How it's checked.** Architecture reviews (see [`../30-languages/<lang>/architect.md`](../30-languages/)) call out unnecessarily-wide public surfaces. ADRs for new modules include a "public surface" section listing what's exported and why.

## 5. Decisions live in the repo, not in chat

**Rule.** Architectural, technical, and process decisions are written down in the repo where the work happens — as ADRs, README updates, RFCs, or issue/PR descriptions. If a decision was made in Slack or DM, write it down before acting on it.

**Why.** Decisions in chat are invisible to anyone not in the channel at the time, including the person who needs to revisit the decision in six months. Writing it down is the cheapest form of transparency, and chat is the most expensive form of opacity.

**How it's checked.** PR descriptions reference the ADR or written rationale where applicable. Reviewer skills flag substantive design choices that lack a documented rationale.

## 6. Ship value to users, not effort to the calendar

**Rule.** Work is measured by what it changes for users, not by hours spent or tasks completed. Effort that does not change the system or its users is invisible by default and gets surfaced explicitly when it does count.

**Why.** Effort decoupled from outcome rewards work that looks busy. The org has finite attention and capital; spending them on motion rather than progress compounds badly.

**How it's checked.** Sprint reviews, OKRs, and product metrics. At the engineering-invariant level: PR descriptions name what changed for users (or for the operator running the system, or for the next contributor reading the code).

## 7. Every non-trivial change ships with auditable context

**Rule.** Every non-trivial change ships with an ADR, a PR description, or a commit-message body sufficient for an operator to reconstruct the reasoning later. Code without context is half-shipped.

**Why.** Code outlives the heads that wrote it. Reasoning that lives only in the author's memory becomes inaccessible the moment the author moves on, leaves, or simply forgets. The audit trail is the contract with future maintainers.

**How it's checked.** PR template requires a description. CODEOWNERS hold the line on review when descriptions are too thin. Reviewer skills flag commits whose messages or PR descriptions are mismatched to the diff size.

## What this is not

- **Not a license to bypass review.** Invariants and review are layered defenses, not alternatives. Both apply.
- **Not absolute.** Overrides exist. They are logged in the PR with the override reason. Frequent override of the same invariant is a sign the invariant needs revision, not that the override is fine.
- **Not exhaustive.** Domain-specific invariants live elsewhere — the `.invariance` framework ([`./invariance-framework.md`](./invariance-framework.md)) is the canonical source for architectural invariants; language-specific invariants live in [`../30-languages/<lang>/`](../30-languages/) reviewer pages.

## Related

- [`agent-era-invariants.md`](./agent-era-invariants.md) — additional invariants specific to agent-assisted work (no silent edits, no fabrication, no commits of secrets, etc.).
- [`invariance-framework.md`](./invariance-framework.md) — pointer page deep-linking into Martin Maurer's `.invariance` framework for architectural invariants.
- [`../00-operating-model/collaborator-statement.md`](../00-operating-model/collaborator-statement.md) — the operator-first contract these invariants operate under.
- [`../VISION.md`](../VISION.md) — the cultural values (openness, learning, collaboration, etc.) the legacy principles also addressed.
