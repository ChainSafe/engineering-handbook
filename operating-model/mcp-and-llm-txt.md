# Discovery: MCP and `llms.txt`

How an agent discovers and loads this handbook from outside it — what an engineer's Claude Code session, Cursor instance, or other AI runtime should do to pull authoritative ChainSafe engineering context on demand.

> **In one line:** Two channels. Static deep links via `chainsafe.io/llms.txt` for URL consumers. GitHub MCP for tool-style browsing. Load on demand, never bulk.

## The two channels

### `chainsafe.io/llms.txt` (static deep links)

A single agent-facing index file served at the root of `chainsafe.io`. Conforming to the [`llms.txt`](https://llmstxt.org/) proposed standard. It lists every handbook section, every packaged skill, and every external canonical source as a deep link with a one-line description.

An agent that does not have access to MCP tooling — or that prefers static URLs — fetches `chainsafe.io/llms.txt`, picks the entries relevant to its task, and pulls those raw markdown URLs directly. Each linked page is self-contained enough to be consumed in isolation.

### GitHub MCP (tool-style browsing)

For agents in runtimes that expose the GitHub MCP server (Claude Code, Cursor, Continue, custom Agent-SDK bots with the connector loaded), the handbook repo is browsable as a tool surface. Agents discover pages by listing the repo tree, reading specific paths, and following cross-references.

This is the richer channel: agents can navigate the handbook's link graph rather than working off the flattened `llms.txt` index. Prefer this when available.

### Future: in-house ChainSafe MCP server

A dedicated ChainSafe MCP server is a possible future enhancement. It would add custom indexing, skill search, and ChainSafe-specific tooling beyond what the generic GitHub MCP provides. It is justified only if observed agent-usage patterns show GitHub MCP discovery is the bottleneck.

## `llms.txt` structure

### Format

Following the `llms.txt` proposed standard:

- An H1 with the project name.
- An optional blockquote summary.
- Free-text paragraphs giving short orientation.
- Section H2s grouping links.
- Each link is `- [Title](URL): One-line description.`

URLs in the live file point at the **raw markdown content** on GitHub (or `chainsafe.io` aliases that redirect there) — not at the rendered GitHub UI. Agents fetch raw content; humans land on the README via the repo home.

### What goes in it

- **Project identity.** Title, one-line description, link to the human README.
- **Section deep links.** One entry per handbook section (`operating-model/collaborator-statement.md`, `invariants/engineering-invariants.md`, `workflows/pr-authoring.md`, etc.) — keyed by question or intent, not by file structure.
- **Skill listings.** Every packaged skill in [`skills/`](../skills/) gets an entry: name, one-line description (matching the SKILL.md frontmatter), direct URL to the raw `SKILL.md`, and trigger conditions so foreign agents can decide whether to load it.
- **External canonical sources.** Deep links into the upstream `.invariants` and `ChainSafe/infrastructure-general` repos where the handbook defers to them.

### What does not go in it

- Internal-only or unreleased material.
- Build artifacts or generated files.
- Pages that are frequently changing without strong stewardship (drafts, TODOs).
- Anything the handbook does not yet have an actual page or skill for — never list a planned future entry as if it exists today. Foreign agents fetching a broken link is worse than not knowing the page is planned.

### Worked example (representative snippet, not the final file)

```markdown
# ChainSafe Engineering Handbook

> The AI-native handbook for how ChainSafe builds software. Operator-first, opinionated, public.

This is the agent-facing index. For humans, see the
[README](https://github.com/ChainSafe/engineering-handbook/blob/main/README.md).

## Operating model
- [Collaborator Statement](https://raw.githubusercontent.com/ChainSafe/engineering-handbook/main/operating-model/collaborator-statement.md): The operator/agent contract. Load before any non-trivial task.
- [Gates and Escalation](https://raw.githubusercontent.com/ChainSafe/engineering-handbook/main/operating-model/gates-and-escalation.md): Enumerated checkpoints where agents stop and ask. Refusals vs. gates.
- [Model and Tool Selection](https://raw.githubusercontent.com/ChainSafe/engineering-handbook/main/operating-model/model-and-tool-selection.md): Which model tier, which MCPs, which skills.

## Skills
- [chainsafe-research-plan-implement](https://raw.githubusercontent.com/ChainSafe/engineering-handbook/main/skills/chainsafe-research-plan-implement/SKILL.md): Research → plan → annotate → implement workflow. Trigger: any multi-file change, refactor, new feature.

## External canonical sources
- [.invariants starter kit](https://github.com/boorich/.invariants-starter-kit): `.invariants` framework. The handbook's `languages/<lang>/architect.md` pages deep-link here.
- [ChainSafe/infrastructure-general](https://github.com/ChainSafe/infrastructure-general/blob/main/AGENTS.md): Infrastructure & DevOps canonical source. The handbook's `workflows/infrastructure-and-devops.md` deep-links here.
```

The actual `llms.txt` lives at the repo root: [`llms.txt`](../llms.txt). It is published to `chainsafe.io/llms.txt` — `chainsafe.io` is configured to serve the file from `https://raw.githubusercontent.com/ChainSafe/engineering-handbook/main/llms.txt` or an equivalent route. The repo-root file is the source of truth; the chainsafe.io URL is the public surface.

## How an agent should use this

### On session start

1. Read [`AGENTS.md`](../AGENTS.md) at the repo root.
2. Load [`collaborator-statement.md`](./collaborator-statement.md) and [`gates-and-escalation.md`](./gates-and-escalation.md).
3. Identify the specific section or skill relevant to the task.
4. Fetch only that section, plus any external canonical source it deep-links into.

Do not bulk-load the handbook. The whole tree is larger than any single task needs, and loading everything wastes context that should hold task-specific material.

### When loading skills

- A skill listed in `llms.txt` with a triggering description that matches the task → load the SKILL.md, follow its instructions, do not re-derive its workflow.
- A skill that does not match → do not load it. The triggering descriptions are written so foreign agents can self-select.
- Two candidate skills → ask the operator before invoking either. See [`model-and-tool-selection.md` §"Do not chain skills automatically"](./model-and-tool-selection.md#do-not-chain-skills-automatically).

### When a referenced page is missing

Occasionally a cross-referenced page may be missing or moved. When that happens:

- Do not fabricate substitute content.
- Surface the gap to the operator. If the operator wants to proceed without the missing page, the agent flags this explicitly in any artifact it produces ("This plan was drafted without `<page>` because it does not yet exist; verify against `<page>` once available").
- Optionally file an issue in `ChainSafe/engineering-handbook` to track the gap.

## Maintenance

CI guarantees `llms.txt` does not drift from the handbook content:

- Every skill in [`skills/`](../skills/) must appear in `llms.txt`.
- Every `llms.txt` skill entry must resolve to an existing `SKILL.md`.
- All external deep links (into `.invariants`, `infrastructure-general`, Forest, etc.) are link-checked in CI and the build fails on any broken target.

When you add a new skill, section, or pointer page: update `llms.txt` in the same PR. The handbook treats the index and the content as a single commit, not two.

## Related

- [`collaborator-statement.md`](./collaborator-statement.md) — the contract that the discovery layer serves.
- [`gates-and-escalation.md`](./gates-and-escalation.md) — what stops the agent, including the external-communication gate that affects how agents post about discoveries.
- [`model-and-tool-selection.md`](./model-and-tool-selection.md) — when to load which MCP and skill.
- [`memory-conventions.md`](./memory-conventions.md) — what an agent should persist about handbook content across sessions.
