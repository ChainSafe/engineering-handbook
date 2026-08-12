---
name: chainsafe-research-plan-implement
description: Research-first coding workflow that gates ALL non-trivial code changes behind a human-approved written plan. Use this skill whenever the user asks for any substantive code change — implementing a feature, refactoring, fixing a multi-file bug, adding an endpoint, integrating a service, migrating between systems, wiring something up, or changing how an existing system works — EVEN IF they do not explicitly ask for "research" or a "plan." The skill enforces three artifacts (research.md, plan.md, annotated plan) that survive context compaction and gate implementation behind explicit operator approval. Triggers on phrases like "implement", "refactor", "fix this bug", "add a feature", "change how X works", "integrate", "migrate from X to Y", "rewrite", "restructure", "wire up", "build out", "extend", "modify the X system", "I want to add", "let's change". Also covers breaking planned work down into tracked units — "break this into issues", "decompose this", "create the epic", "what milestones do we need", "how should we split this up", "is this issue too big". Do NOT use for one-line typo fixes, pure formatting, lint-only changes, or other trivial single-file edits where research would be overkill.
metadata:
  type: workflow
  origin: ~/.config/agents/research-plan-implement.md
  based-on: Boris Tane — https://boristane.com/blog/how-i-use-claude-code/
  curator: Peter Kalambet (ChainSafe CTO)
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

## Core principle

**Never write code until the human has reviewed and approved a written plan.**

Separate thinking from typing. Research prevents ignorant changes. The plan prevents wrong changes. The annotation cycle injects human judgement. Implementation runs without interruption once every decision has been made.

---

## Workflow pipeline

```
Research → Plan → Annotate (repeat 1–6×) → Decompose → Implement
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

## Phase 3b — Decomposition

The phased todo list is not just a progress tracker — it is the work breakdown. Before implementation begins, map it onto three levels and get the mapping approved along with the rest of the plan.

| In `plan.md` | Tracked as |
|---|---|
| The plan as a whole | One **epic** — the outcome, linking `research.md` and `plan.md` |
| Each phase | A **milestone** — a demonstrable slice; `main` is releasable at its end |
| Each individual task | An **issue** — bite-sized, closed by exactly one PR |

**An issue is bite-sized when all of these hold:**

- One PR closes it.
- One reviewer can review that PR in a single focused pass. There is no line-count threshold — the bar is reviewability.
- It has written acceptance criteria, decided now, not at review time.
- It carries no open design decision. Implementation of a bite-sized issue is mechanical.
- It names the files or areas it expects to touch.
- Someone can pick it up without reading the whole epic.

If a task fails any of these, split it in the plan before implementing. Usual seams: interface before implementation, migration before cutover, one call site per issue, tests-for-existing-behavior before the behavior change.

**Propose, do not create.** Write the breakdown into `plan.md`. Do not create epics, milestones, or issues in GitHub / Linear / Jira until the operator approves — creating tracker items on a human's behalf is a gate, not a default.

> "Map the todo list onto an epic, milestones, and bite-sized issues. Each issue must be closeable by one reviewable PR and carry acceptance criteria. Write it into the plan — don't create anything in GitHub yet."

Small work does not need all three levels. A single-issue fix is a single issue. The rule is that work large enough to need a plan is large enough to need decomposition.

Full reference: [`workflows/work-decomposition.md`](../../workflows/work-decomposition.md).

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

**Ship it issue by issue.** One issue, one PR, each PR linking its issue. Running implementation continuously does not mean accumulating everything into one branch — the decomposition from Phase 3b is what makes the output reviewable, and collapsing it at the last moment throws that away.

If a diff outgrows the issue it belongs to — even when every file touched is in scope — **stop**. Do not open an oversized PR and apologize in the description. Surface it, propose a split, and let the operator decide. An oversized PR ships only with an explicit approval recorded in its description (`Oversized PR approved by @operator: <reason>`). This is [gate §10](../../operating-model/gates-and-escalation.md#10-oversized-or-multi-concern-changes); the agent never self-approves it.

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
9. **Decompose before implementing.** Epic → milestones → bite-sized issues, approved as part of the plan. A PR can only be as small as the issue behind it.
10. **Never self-approve an oversized PR.** If the change won't fit one reviewable PR, stop and ask. The operator decides; the approval is recorded in the PR description.

---

*Based on [How I Use Claude Code](https://boristane.com/blog/how-i-use-claude-code/) by Boris Tane. Adopted into the ChainSafe Engineering Handbook by Peter Kalambet.*
