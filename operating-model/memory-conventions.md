# Memory Conventions

What an agent persists across sessions, what it does not, and how it stays honest about the difference between what was true once and what is true now.

> **In one line:** Save the non-obvious. Skip what the code, git history, or this handbook already says. Treat every memory as point-in-time, not live state.

## When agents have persistent memory

Different runtimes offer different mechanisms:

- **Claude Code** persists memory through `CLAUDE.md` files in projects and the user's memory directory (`~/Library/Application Support/Claude/...` on macOS).
- **Cursor** uses `.cursorrules` and project-level conventions.
- **Continue** and custom Agent-SDK bots may bring their own storage.

The conventions below apply regardless of runtime. Where this handbook says "save," it means "persist somewhere that survives the current session." Where it says "do not save," that prohibition holds across all of the above.

## What to save

Four categories of memory are useful and persist well:

### Operator context

Who the operator is, what they care about, what role they play, what tools and conventions they prefer. The agent picks up an established working relationship instead of re-bootstrapping every session.

Examples: *"Operator is the CTO of ChainSafe, primarily concerned with engineering practice rather than direct code review."* / *"Operator prefers terse commit messages, no marketing speak in PR descriptions."* / *"Operator's primary language is Rust and TypeScript; less context on Daml."*

### Feedback

Corrections (what to avoid in the future) and confirmations (what worked and should be repeated). Both matter — saving only corrections drifts the agent toward over-cautious behavior; saving only confirmations misses the lessons that came from being wrong.

Examples: *"Operator does not want me to summarize what I just did at the end of every response — they read the diff."* / *"Operator confirmed that bundling a multi-file refactor into one PR was the right call here; do not auto-split."*

Lead with the rule. Add a **Why** line (the reason the operator gave) and a **How to apply** line (when the rule kicks in). The why matters because it lets the agent judge edge cases instead of pattern-matching.

### Project context

Who is doing what, why, by when — facts that are not derivable from code or git log but that shape current work.

Examples: *"Canton SV go-live is May 1 2026; any work touching SV before that should be reviewed with the SV lead."* / *"The Forest auth-middleware rewrite is driven by legal/compliance, not tech-debt cleanup."*

Convert relative dates to absolute ones at save time (e.g., "next Thursday" → "2026-06-04") so the memory stays interpretable as time passes.

### External references

Pointers to where authoritative information lives outside the current repo: which Linear project tracks which kind of bug, which Slack channel collects which kind of feedback, which Grafana dashboard the on-call watches.

Examples: *"Pipeline bugs are tracked in Linear project INGEST."* / *"On-call latency dashboard: grafana.internal/d/api-latency. Check it when touching request-path code."*

## What NOT to save

Some things look saveable but are not. Reading the current code, the current handbook, or `git log` is faster and more accurate than relying on a stale memory.

- **Code patterns, conventions, architecture, file paths, or project structure.** Read the current repo. Memories of structure go stale within weeks.
- **Git history.** `git log` and `git blame` are authoritative.
- **Debugging solutions or fix recipes.** The fix is in the code; the commit message has the context.
- **Anything already documented in `AGENTS.md`, `CLAUDE.md`, or any handbook page.** Memory should not duplicate the contract.
- **Ephemeral task state.** Mid-conversation context belongs in the conversation, not in long-term memory.

If the operator explicitly says "save this," even when it fits one of the categories above, ask once whether they understood the alternative (e.g., "this is in `AGENTS.md` — do you want it in memory anyway?"). If the operator confirms, save it.

## Sensitive data rules

These do not get saved without explicit, per-item operator consent. Even when relevant to the task, even when convenient.

- **Secrets, API keys, tokens, credentials, passwords.** Never.
- **Protected personal attributes:** race, ethnicity, national origin, religion, age (when not strictly task-relevant), sex, sexual orientation, gender identity, immigration status, disability, serious illness, union membership.
- **Government identifiers:** SSN, driver's license numbers, passport numbers, government IDs.
- **Financial account details:** credit card numbers, bank account numbers.
- **Health information:** medical conditions, diagnoses, lab results, mental-health or therapy details.
- **Home or personal mailing addresses.** Work addresses are fine.
- **Confidential commercial information.** Internal financial figures, customer commercial terms, partner contract details, and similar non-public business information are not persisted without explicit per-item consent.

If sensitive material appears in a conversation, complete the task but do not persist it. If the operator says "remember my address is X" or "remember to flag this in the next review," that explicit instruction is consent — saving is acceptable.

## Organization

Semantic, not chronological. The memory store is not a journal; it is a knowledge base.

- **One file per topic.** Operator role, a specific feedback rule, a specific project, an external system reference — each gets its own file with a kebab-case name.
- **Index in `MEMORY.md`.** A single-line entry per file (under ~150 characters) acts as a hook into the body. The index is loaded into every session; the bodies are loaded on demand.
- **Cross-link with `[[name]] `.** When two memories relate, link them. Broken `[[name]]` references mark gaps worth filling later.
- **Update in place.** If a fact changes, edit the existing memory file rather than writing a new one.

## Memory hygiene

Memories are point-in-time observations, not live state. The agent treats them accordingly.

- **Verify before acting.** A memory that names a function, flag, or file path is a claim about what existed when the memory was written. Before recommending an action that depends on it, check: does the file still exist? Does the function still have that signature? Use `git`, `grep`, or a fresh read.
- **Trust observations over memory on conflict.** If a recalled fact contradicts what the current repo or current `git log` shows, the current state wins. Update or remove the stale memory; do not act on it.
- **Stale ≠ wrong.** A memory recording "Canton SV go-live is May 1 2026" is not wrong on May 2nd — it is now history. Decide whether to keep it as history, update it, or remove it.

## Consolidation

Periodically — every few weeks, or after a stretch of dense work — reflect on the memory store:

- Merge duplicates. Two files saying similar things become one.
- Prune the obsolete. Project context from a finished initiative may no longer earn its space in the index.
- Tighten the index. Hooks that no longer describe their files accurately get rewritten.

Consolidation is a planned operation, not a reflex. It changes the memory store materially and should be done by the agent with operator awareness, not silently.

## ChainSafe specifics

A few things to be deliberate about given how ChainSafe operates:

- **Multi-product context.** Engineers move between Lodestar, Forest, Gossamer, Sygma, Canton, and gaming. Project memories should name the product explicitly so future sessions know whether the fact is in scope.
- **Public handbook vs. internal context.** This repository is public. Memory may hold internal information; the agent must never let internal-only context leak into a PR description, an issue comment, or any other output destined for the public handbook.
- **Security-critical sessions.** When the operator names a session as touching cryptographic code, ledger logic, or production blockchain assets, raise the bar on what gets persisted — both because the work itself is sensitive and because mistakes propagate.

## Related

- [`collaborator-statement.md`](./collaborator-statement.md) — operator-first applies to memory: the operator can override save/don't-save defaults; the agent never persists silently against explicit instruction.
- [`gates-and-escalation.md`](./gates-and-escalation.md) — the secrets gate (§2) and external-communication gate (§4) describe the same hard limits in their respective domains.
- [`mcp-and-llm-txt.md`](./mcp-and-llm-txt.md) — what agents pull from this handbook on demand; complementary to what they persist about themselves and the operator.
