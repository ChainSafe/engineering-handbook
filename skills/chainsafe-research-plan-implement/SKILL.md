---
name: chainsafe-research-plan-implement
description: Research-first coding workflow that gates code changes behind a human-approved written plan. Use when starting any non-trivial change — a new feature, refactor, multi-file edit, or anything touching existing systems — but not for one-line fixes or pure formatting. The skill produces research.md (deep read of existing code, conventions, hidden coupling), then plan.md (approach, code snippets, file paths, trade-offs), runs an annotation cycle of 1–6 rounds with the human editing the plan inline, and only then executes implementation mechanically with continuous typechecks. Trigger phrases include "implement X feature", "refactor the Y system", "fix this bug across the codebase", "add a new endpoint", "I want to change how Z works".
metadata:
  type: workflow
  origin: ~/.config/agents/research-plan-implement.md
  based-on: Boris Tane — https://boristane.com/blog/how-i-use-claude-code/
  curator: Peter Kalambet (ChainSafe CTO)
---

## Core principle

**Never write code until the human has reviewed and approved a written plan.**

Separate thinking from typing. Research prevents ignorant changes. The plan prevents wrong changes. The annotation cycle injects human judgement. Implementation runs without interruption once every decision has been made.

---

## Workflow pipeline

```
Research → Plan → Annotate (repeat 1–6×) → Implement
```

All phases run in a **single long session**. Do not split across separate sessions. Context built during research and planning carries through to implementation. The plan document survives compaction and serves as the persistent source of truth.

---

## Phase 1 — Research

Before planning anything, deeply read the relevant code. Surface-level skimming is not acceptable.

**What to do:**

- Read the specified folders/files in depth — understand how the code works, what it does, and all its specificities
- Study the intricacies of the systems involved
- Look for existing patterns, conventions, caching layers, ORM conventions, and reusable logic
- Write all findings into `research.md` — never give a verbal summary only

**Example directives:**

> "Read this folder in depth, understand how it works deeply, what it does and all its specificities. When that's done, write a detailed report of your learnings and findings in research.md"

> "Study the notification system in great detail, understand the intricacies of it and write a detailed research.md document with everything there is to know about how notifications work"

> "Go through the task scheduling flow, understand it deeply and look for potential bugs. Keep researching the flow until you find all the bugs. When you're done, write a detailed report of your findings in research.md"

**Why this matters:** If the research is wrong, the plan will be wrong, and the implementation will be wrong. The most expensive failure mode is implementations that work in isolation but break the surrounding system — a function that ignores an existing caching layer, a migration that doesn't account for ORM conventions, an API endpoint that duplicates logic that already exists elsewhere.

---

## Phase 2 — Plan

Once the human has reviewed `research.md`, create a detailed implementation plan in a **separate** markdown file (`plan.md`).

**The plan must include:**

- A detailed explanation of the approach
- Code snippets showing actual changes
- File paths that will be modified
- Considerations and trade-offs

**Reference implementations:** When available, use concrete reference implementations from the codebase or open-source projects. Working from a reference produces dramatically better results than designing from scratch.

**Critical:** After writing the plan, **stop**. Do not implement. Wait for human annotation.

---

## Phase 3 — Annotation cycle

This is where the human adds the most value. The human opens `plan.md` in their editor and adds inline notes directly into the document. These notes:

- Correct assumptions
- Reject proposed approaches
- Add constraints or domain knowledge
- Redirect entire sections

**Examples of real annotations:**

- *"Use drizzle:generate for migrations, not raw SQL"* — domain knowledge
- *"No — this should be a PATCH, not a PUT"* — correcting wrong assumptions
- *"Remove this section entirely, we don't need caching here"* — rejecting approaches
- *"The queue consumer already handles retries, so this retry logic is redundant. Remove it and just let it fail"* — explaining existing system behavior
- *"This is wrong, the visibility field needs to be on the list itself, not on individual items"* — redirecting design

**After each annotation round:** Update the plan based on the notes, then **stop again** — do not implement yet. The cycle repeats 1–6 times until the human is satisfied.

**Before implementation:** Add a granular todo list to the plan with all phases and individual tasks. This serves as a progress tracker.

> "Add a detailed todo list to the plan, with all the phases and individual tasks necessary to complete the plan — don't implement yet"

---

## Phase 4 — Implementation

When the human approves the plan, execute everything in one continuous run:

> implement it all. when you're done with a task or phase, mark it as completed in the plan document. do not stop until all tasks and phases are completed. do not add unnecessary comments or jsdocs, do not use any or unknown types. continuously run typecheck to make sure you're not introducing new issues.

**What each instruction means:**

| Instruction | Purpose |
|---|---|
| "Implement it all" | Do everything in the plan, don't cherry-pick |
| "Mark it as completed in the plan document" | The plan is the source of truth for progress |
| "Do not stop until all tasks and phases are completed" | Don't pause for confirmation mid-flow |
| "Do not add unnecessary comments or jsdocs" | Keep the code clean |
| "Do not use any or unknown types" | Maintain strict typing |
| "Continuously run typecheck" | Catch problems early |

Implementation should be **boring**. All creative decisions were made in the annotation cycles.

---

## Feedback during implementation

Once implementation is running, the human's role shifts from architect to supervisor. Prompts become short and direct:

- *"You didn't implement the `deduplicateByTitle` function."*
- *"You built the settings page in the main app when it should be in the admin app, move it."*
- *"Wider"*
- *"Still cropped"*
- *"There's a 2px gap"*

**Guidelines for feedback:**

- For visual issues, use screenshots — they communicate faster than descriptions
- Reference existing code: *"This table should look exactly like the users table, same header, same pagination, same row density."*
- When something goes wrong, **revert and re-scope** rather than patching: *"I reverted everything. Now all I want is to make the list view more minimal — nothing else."*

---

## Key rules

1. **Never implement without an approved plan.** The plan document sits between the agent and the code.
2. **Research first, always.** Understand the existing system before proposing changes.
3. **Write artifacts, not chat.** All research, plans, and progress live in markdown files — not in conversation history.
4. **Respect the annotation cycle.** When told "don't implement yet," stop. Wait for human input.
5. **Stay in a single session.** Context compounds — research informs planning, planning informs implementation.
6. **The plan is the source of truth.** Mark tasks complete in the plan. Point back to it when context is needed.
7. **Keep implementation mechanical.** All decisions are pre-made. Execute the plan faithfully.
8. **Run typechecks continuously.** Don't accumulate errors — catch them as they happen.

---

*Based on [How I Use Claude Code](https://boristane.com/blog/how-i-use-claude-code/) by Boris Tane. Adopted into the ChainSafe Engineering Handbook by Peter Kalambet.*
