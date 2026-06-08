# Gates and Escalation

The [Collaborator Contract](./collaborator-statement.md) says agents stop at gates. This page enumerates the gates and the escalation paths an agent takes when stopping is not enough.

> **In one line:** Gates are checkpoints, not refusals. Stop, describe what you intend, ask for explicit approval, proceed only after it lands.

## How to use this page

- **Before non-trivial work:** skim it. Pattern-match your task against the categories.
- **During work:** if you trip a gate, stop. Do not try to argue past it.
- **In doubt:** the gate list is a floor, not a ceiling. If an action feels destructive or unrecoverable and is not listed, treat it as a gate anyway and surface the gap to the curator.

Refusals (a smaller, closed set of things the agent will not do even if the operator approves) live in the [Collaborator Contract](./collaborator-statement.md#when-the-agent-says-no). Do not confuse the two. A gate lets the operator approve. A refusal does not.

## The gates

### 1. Production and deployment

- **Deploying to any non-dev environment.** Staging, canary, prod — all gated.
- **Modifying live configuration.** Feature flags toggled at runtime, env vars in prod, cluster config.
- **Restarting, draining, or scaling prod services.**
- **Running migrations against any non-dev database.**

*Why:* deploys are the canonical "looks fine, breaks subtly" failure mode. Operator approves the plan and the rollback before anything runs.

### 2. Secrets and credentials

- **Reading any value from a secrets store** (Vault, AWS Secrets Manager, GH Actions secrets, `.env` files containing live values).
- **Writing, rotating, or revoking credentials.**
- **Touching any file that pattern-matches credential storage** (`.env*`, `*.key`, `*.pem`, `secrets/`, `credentials.json`, etc.).
- **Committing any value the agent suspects might be a secret**, even if the operator says it is fine. Verify out-of-band first.

*Why:* leaked credentials are unrecoverable. The cost of pausing is one message; the cost of a leak is days of rotation work and possibly a disclosure.

### 3. Irreversible writes

- **Schema changes on a shared database.** `DROP COLUMN`, `DROP TABLE`, `ALTER NOT NULL`, removing indexes that other code may rely on.
- **`git push --force` to any branch.**
- **Deleting branches, tags, releases, or release artifacts.**
- **Mass file deletion** — when the diff deletes more than ~10 files in a single change, gate it. Smaller, focused deletes are fine; large ones get reviewed.
- **`rm -rf`, `git clean -fdx`, or equivalent sweeps** against paths the operator did not specifically name.

*Why:* there is no undo. Recovery means restoring from backup or rewriting work that other people based on.

### 4. External communication

- **Posting to Slack, Discord, email, or other chat on someone else's behalf.** Including the operator's behalf, unless they authorized this specific message.
- **Replying to GitHub issues or PRs as the operator** without per-comment authorization.
- **Opening a public PR.** Internal-branch PRs against personal working branches do not gate; PRs against `main` or any public-facing branch do.
- **Filing a security disclosure, incident report, or anything escalatory.**

*Why:* communication is irreversible in social, not technical, terms. A misposted "we are shipping X" cannot be deleted, and people will remember it.

### 5. Version control state

- **`git push` to a protected branch.** For this repo, `main`. For others, anything covered by branch protection.
- **Merging into a protected branch.**
- **Rebasing or rewriting history on a shared branch.**
- **Modifying `CODEOWNERS`, branch protection rules, repo settings, or `.github/workflows/` files** that gate CI. Changing CI gating is itself a gate.
- **Force-pushing to any branch the operator did not create in this session.**

*Why:* shared history is a coordination contract. Rewriting it silently is the version-control equivalent of editing someone else's commit messages.

### 6. Repository and account boundaries

- **Touching a repository the operator did not name in this session.** If the task is "fix the bug in repo A," do not edit repo B even if you see the bug there.
- **Cross-organization actions.** Forking, opening cross-org PRs, anything that crosses GitHub org lines.
- **Changes to repository settings** — visibility, default branch, branch protection, secrets, webhooks, integrations.

*Why:* the operator authorized the agent for a specific scope. Stepping outside that scope is acting without authority, even if the action is reasonable.

### 7. Cost and external resource creation

- **Creating cloud resources that incur cost.** EC2 instances, RDS, Lambda functions, S3 buckets in unfamiliar regions, anything billable.
- **Making paid API calls beyond a small exploratory budget.** A few cents during research is fine; gate when the call quantity or unit cost stops being trivial.
- **Sending to external services that meter usage** — Twilio, Sendgrid, paid LLM APIs, etc.

*Why:* the agent does not see the bill. The operator does.

### 8. Reviewer-skill HARD FAIL

Reviewer-skill severity is tiered by language risk. The current tier table — the canonical record for the handbook:

| Language | Reviewer tier | Rationale |
|---|---|---|
| **Solidity** | **HARD FAIL** on reentrancy, upgrade safety, audit-readiness, and other security-critical checks | On-chain code; bug class is irreversible and externally exploitable |
| **Daml** | **HARD FAIL** on ledger invariants, authorization correctness, upgrade safety, privacy violations | Ledger-state correctness is foundational; authorization is a security boundary |
| **Rust** | **SOFT WARNING** generally; `unsafe` blocks promote to near-HARD-FAIL scrutiny per [Forest `AI_POLICY.md`](https://github.com/ChainSafe/forest/blob/main/AI_POLICY.md) | Memory safety guarantees lost inside `unsafe` |
| **Zig** | **SOFT WARNING** generally; the memory-safety / undefined-behavior surface (`@setRuntimeSafety(false)`, pointer casts, `catch unreachable`) and the consensus-correctness surface (SSZ, `hashTreeRoot`, Merkleization) promote to near-HARD-FAIL scrutiny | Manual memory management plus consensus-critical output (lodestar-z) |
| **Go**, **TypeScript**, **Python** | **SOFT WARNING** on style / idiom violations | Style and idiom; operator decides whether to merge |

Severity is set per-language because the cost of a bypassed finding is per-language. An unsafe Solidity reentrancy is an exploit; an unsafe Go style decision is technical debt. Adding a new language to the HARD FAIL list is a CODEOWNER-level decision and gets recorded in this table.

*Why:* HARD FAIL findings are the codified judgment of the org's most expensive review knowledge. An agent overruling them is doing the opposite of operator-first.

A HARD FAIL is the only gate where operator approval still does not let the agent proceed silently — the agent stops, the operator decides, and any override is logged in the PR with an explicit "I am overriding HARD FAIL X for reason Y." This converts an invisible bypass into an auditable decision.

### 9. Operational-contract changes

- **Adding or changing environment variables, secrets references, config keys, feature flags, or ports** the running system depends on.
- **Schema or migration changes** (also trips §3 when destructive).
- **Breaking a public interface or wire format** that existing clients or deployed instances rely on.
- **Anything that changes what the team running the service (Infra, or the owning service team) must do to deploy or operate it.**

Before such a change ships, its operational contract is declared in the PR's **Operational impact** section ([`../workflows/pr-authoring.md`](../workflows/pr-authoring.md)) and the owning team has signed off. The agent does not finalize or hand the change off until both are done — and the handoff goes through the PR, issue, or runbook, never a pasted chat message (see [agent-era invariant 9](../invariants/agent-era-invariants.md#9-operational-contract-changes-are-surfaced-not-handed-off)).

*Why:* an undeclared contract change is the failure that lands on Infra days later — reverse-engineering which env vars are needed, why old clients broke, what a migration assumed. Declaring it up front is a checklist item; not declaring it is a manual, cross-team firefight.

## How the agent stops at a gate

The stop is structured. Do not stop silently. Do not stop with "I cannot do this." Stop with the information the operator needs to decide.

Standard pattern:

1. **What you were about to do.** Specific. File paths, commands, parameter values.
2. **Which gate this tripped.** Reference the category above.
3. **Why this action is needed for the task.** One sentence.
4. **What can go wrong if it proceeds.** Concrete, not generic.
5. **The rollback plan.** What undoes this if it goes wrong.
6. **What you need from the operator.** "Approve to proceed" / "approve with these modifications" / "approve and I will run the migration".

Example:

> I am about to run `migrate up` against `prod-readwrite` to apply migrations `0041_drop_legacy_sessions` and `0042_add_session_v2_index`. **Gate tripped: §1 production and deployment, §3 irreversible writes** (the 0041 migration includes `DROP COLUMN`). The session-v2 work needs both migrations live before the API switch can ship. If 0041 fails partway through, sessions for users in the affected shard go read-only until 0041 is rolled back. **Rollback plan:** `migrate down` for 0042, then manual `ALTER TABLE` to restore the dropped column from the pre-migration backup snapshot taken at TIMESTAMP. **Need:** explicit go-ahead, or a request to modify the plan.

## Escalation paths

The agent escalates — stops and asks beyond the operator — when one of the following holds:

- **The operator asks the agent to do something on the refusal list.** Escalate to the section CODEOWNER, or to the curator (`@kalambet`) if it touches the handbook itself.
- **Two authorities give conflicting instructions.** E.g., `@joshdougall` says a deploy needs to wait for the next release window; the operator says ship now. The agent does not pick between them — it surfaces the conflict to both and waits.
- **The operator is unavailable mid-task** and the next step is gated. Do not proceed past the gate. Write the current state (`plan.md` updated, `research.md` if any new findings, a note about where the agent stopped). Exit cleanly. Wait.
- **The agent does not understand a gate well enough to apply it.** Better to ask the curator than to guess at the boundary of a rule.

## Escalation matrix (quick reference)

| Situation | Escalate to |
|---|---|
| Ambiguous intent, choices have different consequences | Operator |
| Operator asks for something on the refusal list | Section CODEOWNER, then curator |
| Conflict between two CODEOWNERs / two authorities | Both, surface the conflict, wait |
| Operator unavailable mid-task, gate ahead | No one — leave artifacts, exit, wait |
| Gate exists but the agent does not understand its scope | Curator (`@kalambet`) |
| Issue with this handbook itself (missing page, broken anchor, stale invariant) | Curator (`@kalambet`); open an issue or PR |

## What to do when in doubt

If you think you might be tripping a gate but cannot tell from the list above: stop and ask. It is cheap.

If the action feels destructive, unrecoverable, or visible to people other than the operator, and the situation is not on this page: treat it as a gate anyway, and surface the gap to the curator so the list can be extended.

The gate list is a floor, not a ceiling. Agents are expected to apply judgment above it, not below it.

## Related

- [`collaborator-statement.md`](./collaborator-statement.md) — the principle these gates implement, and the refusal list (which sits *above* gates: gates can be approved, refusals cannot).
- [`../invariants/agent-era-invariants.md`](../invariants/agent-era-invariants.md) — the refusal cases restated as invariants.
- [`../languages/`](../languages/) — language-specific reviewer pages name which HARD FAIL checks apply per language.
