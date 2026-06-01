# Model and Tool Selection

How an agent picks which model to run on, which MCPs and tools to load, and which skills to invoke — without violating the [Collaborator Contract](./collaborator-statement.md).

> **In one line:** Start with the cheapest viable tool. Escalate when the work earns it. Do not load everything by default.

## Who picks what

In most runtimes (Claude Code, Cursor, the Claude desktop app, custom Agent-SDK bots), the **operator** picks the model before launching the session. The agent does not unilaterally switch. The agent's job is to **notice and surface** when the current model is the wrong size for the task — not to silently reach for a different one.

The **agent** picks freely among:

- Which MCPs and tools to load, within the operator's authorized scope.
- Which skill to invoke for a given work shape.
- Which sub-agent or delegation pattern to use, if the runtime supports them.

The **operator** picks:

- Base model tier (Opus / Sonnet / Haiku).
- Which integrations and credentials are available.
- Hard constraints — cost ceiling, allowed-tool list, etc.

## Model selection

### Principle

Start with the cheapest model that can complete the task. Escalate to a larger model when the work earns it — not preemptively.

"Earns it" means one of:

- The task involves multi-step reasoning across files or systems.
- The task is security- or correctness-critical (Solidity, Daml, cryptographic code, anything in a hot production path).
- An attempt with a smaller model produced wrong output or got stuck in a loop.
- The operator asked for higher rigor.

### Rough mapping

| Task class | Starting model tier |
|---|---|
| Quick lookups, summaries, simple edits, classifications | Haiku |
| Most engineering work: code, code review, planning, ADR drafting | Sonnet |
| Hard debugging, complex multi-file refactors, security-critical review, novel system design, ledger or invariant work | Opus |

This is a starting point, not a contract. If a Sonnet session is repeatedly producing weak output on a class of task, escalate. If an Opus session is being used for one-line README edits, downsize.

### Surfacing model mismatch to the operator

When the agent notices the model is mismatched, it says so explicitly. Examples:

- "I am running on Haiku and this task involves cross-file reasoning over the Forest p2p layer. I will continue but recommend switching to Sonnet or Opus for this session."
- "I have made three attempts at this debugging session on Sonnet and the proposed fixes have been wrong each time. I recommend a fresh Opus session, picking up from the research artifact I wrote."

Do not silently bail. Do not silently push through.

This page refers to capability tiers (Haiku-class, Sonnet-class, Opus-class), not specific model versions. Map your provider's current generations onto these tiers; the tier logic holds as new models ship.

## Tool and MCP selection

### Default loadout

- **This handbook**, via MCP or direct file access. The agent is operating against this contract; it must be loaded.
- **The current project's source tree.** Read access is baseline.

That is the default. Everything else is on-demand.

### On-demand loadout

- **GitHub MCP** — when opening PRs, reading issues, listing branches, working with reviews.
- **`ChainSafe/infrastructure-general`** — when touching infra, IaC, observability, deploys, runbooks. Coordinate with `@joshdougall` as the canonical owner.
- **`.invariance` repo** — when doing architecture or system-design work. Coordinate with `@boorich` as the framework maintainer.
- **Linear / Jira / project-tracker MCPs** — when the task involves issue triage, sprint planning, or status updates.
- **Slack / Discord / email MCPs** — when the task involves communication. Note the [external-communication gate](./gates-and-escalation.md#4-external-communication).
- **Product-specific repos** (`ChainSafe/forest`, `ChainSafe/lodestar`, `ChainSafe/sygma`, etc.) — when working on that product. Do not load a product repo just to browse it; the operator authorized work on a specific scope.

### Tools to be skeptical of

- **Production credentials and secrets stores.** Almost never. Loading these without a specific gated task is permission creep — see [§2 of gates-and-escalation](./gates-and-escalation.md#2-secrets-and-credentials).
- **Cost-incurring API access** beyond a small exploratory budget. The agent does not see the bill — see [§7 of gates-and-escalation](./gates-and-escalation.md#7-cost-and-external-resource-creation).
- **MCPs the agent does not understand the surface of.** If you cannot describe what the tool does and what its failure modes look like, you are not ready to use it. Ask the operator first.

### Discovery: how an agent learns what tools exist

- For ChainSafe-specific MCPs and skills: `chainsafe.io/llms.txt` is the index.
- For Claude-runtime tools: the runtime advertises them; no action needed.
- For MCPs not on `llms.txt`: ask the operator. Do not install or attempt to add MCP endpoints from the session.

## Skill selection

When a task matches a packaged skill in [`skills/`](../skills/), prefer the skill over an ad-hoc plan. Reasons:

- Skills have been authored deliberately (via `skill-creator`) and reviewed.
- Skills carry their own load order, escalation defaults, and gate references.
- The operator can predict what the agent will do because the skill is a known surface — surprises shrink.

### Default skill picks

| Work shape | Skill |
|---|---|
| Any non-trivial code change | [`chainsafe-research-plan-implement`](../skills/chainsafe-research-plan-implement/SKILL.md) |
| Language-specific architecture, development, or review | The matching `chainsafe-<lang>-{architect,developer,reviewer}` skill |
| Authoring or editing a Claude skill | Anthropic's `skill-creator` |

When no skill matches, work from first principles using the Collaborator Contract.

### Do not chain skills automatically

If the work could plausibly invoke two skills, ask the operator which is in scope before invoking either. Auto-chaining is a frequent source of scope creep.

## Anti-patterns

- **"Use Opus just in case."** Opus is expensive in latency and tokens. Use it when the work earns it; the cheaper tiers handle most engineering work fine.
- **"Load every available MCP."** More tools means more surface area, more confusion, and more places for the agent to do something the operator did not authorize.
- **"Combine three skills into one mega-flow."** If a task does not match a single skill, work from the contract; do not improvise multi-skill choreography.
- **"Silently switch model mid-session."** Agents do not switch models. Agents surface model-mismatch and let the operator decide.
- **"Browse product repos for context."** If you have not been authorized to work on a product, do not load its repo just because it looks relevant.

## Related

- [`collaborator-statement.md`](./collaborator-statement.md) — the contract these selections operate under.
- [`gates-and-escalation.md`](./gates-and-escalation.md) — what stops the agent regardless of model or tool.
- [`mcp-and-llm-txt.md`](./mcp-and-llm-txt.md) — how agents discover tools and content from this handbook.
- [`../skills/`](../skills/) — the packaged skills the agent can invoke.
