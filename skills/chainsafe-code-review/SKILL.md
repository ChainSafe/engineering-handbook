---
name: chainsafe-code-review
description: Universal code-review framework at ChainSafe — language-agnostic principles plus the two reviewer modes (operator-reviewing-agent and agent-reviewing-PR). Use this skill whenever the user is reviewing a PR, asking for a code review, checking how to review, deciding what to flag vs fix, or handling a review disagreement. EVEN IF the user does not explicitly ask for "review" — triggers on "look at this PR", "check this diff", "what should I look for in this PR", "is this code OK", "how do I review", "approve this PR", "block this PR", "review disagreement", "review comments", "nit prefix", "should I flag this". For language-specific review (Go, Rust, TypeScript, Solidity), additionally load the corresponding language reviewer skill (chainsafe-<lang>-reviewer). For PR authoring (outgoing), use chainsafe-pr-author.
metadata:
  type: workflow
  source: workflows/code-review.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# Code Review

Universal review framework at ChainSafe. Two reviewer modes; language-specific surface lives in the language reviewer skills. Full reference: [`workflows/code-review.md`](../../workflows/code-review.md).

## Universal principles

- **Approve when the change improves overall code health.** "Perfect" isn't the bar. Forward progress against current quality is.
- **Technical facts and data overrule opinions and personal preferences.** If two designs are equally valid, respect the author's choice.
- **Authority ladder:** style guide > current codebase conventions > author preference.
- **Prefix nits.** Taste/preference/teaching comments get `nit:` prefix so author knows they can ignore.
- **Note the good things.** Reviews skewed toward only-mistakes train authors to be defensive.

## What to look for

- **Design.** Do the pieces fit? Readability beats DRY.
- **Functionality.** Does the code do what was intended? Is the intent good for users + future developers?
- **Complexity.** Especially over-engineering. Solve the problem you have now.
- **Naming.** Long enough to communicate, short enough to read.
- **Comments.** Explain *why*, not *what*.
- **Every line.** Look at every assigned line.
- **Context.** Sometimes pull the branch.

## Speed of review

Default service level: **review within one business day**. If you can't, say so and propose when you can. If author is blocked on critical path, drop other work for it.

This applies to agent reviewers too — agents that "review eventually" defeat the purpose.

## Mode (a) — Operator reviewing agent output

Most ChainSafe PRs in the v2 era have an agent in the author chair. What to verify:

- **The plan matches the diff.** Drift between linked `plan.md` and the diff is the most common quiet failure.
- **Fabrication.** Imports that don't exist, wrong-signature function calls, broken handbook page references. Verify.
- **Silent scope creep.** Files in the diff not in the original plan — PR description should name each with a reason.
- **Over-eager refactor.** Each unrelated improvement is its own PR.
- **Generic comments.** Cut comments that restate what the code does.
- **Test theatre.** Tests asserting "function was called" rather than its effect. Read test bodies.
- **Type laxity.** `any`, `unknown`, untyped returns, missing error handling.
- **Undeclared operational contract.** Env vars, config, secrets, schema/migrations, ports, or a public signature changed without an Operational impact declaration — the change that becomes Infra's problem later (Engineering Invariant 8).

### When to demand re-plan vs accept vs reject

- **Re-plan:** diff drifted from plan; agent made unapproved design choices; unrelated changes included; fabrication present. Go back to the plan; don't patch.
- **Accept with notes:** minor issues that don't change the shape.
- **Reject entirely:** wrong direction. Close PR; reopen with fresh plan.

### What the operator cannot delegate

- The merge decision.
- The judgment on whether HARD FAIL findings are properly addressed.
- The sign-off that the audit trail is sufficient.

## Mode (b) — Agent reviewing a PR

### Checklist

- Run lint/type-check/test against the branch; report failures.
- Diff against the linked plan or spec; flag deviations.
- Apply the relevant language reviewer skill (chainsafe-<lang>-reviewer).
- Check PR-description completeness (what/why/acceptance/**operational impact**/AI declaration/scope flags); flag undeclared env-var / config / schema / public-signature changes.
- Verify references are real.
- Flag missing or thin commit messages.

### Flag vs fix in place

- **Flag, don't fix:** design choices, complexity, naming, anything subjective.
- **Suggest with code suggestion:** trivial nits (typos, lint, formatting).
- **Never fix and push to author's branch** without explicit operator authorization.

### How to phrase comments

- Lead with concern, not fix.
- Cite the rule when there is one.
- Use `nit:` for taste-level.
- Avoid "you" framing for design comments.

### When the agent refuses to review

Escalate rather than reviewing if:

- HARD FAIL findings the agent can't evaluate (mismatched tool).
- PR description missing — nothing to review against.
- Diff touches code the agent has been told not to operate on.

## When reviews go wrong

- **Stale review** (no response >3 business days): reviewer pings once; if no response, CODEOWNER unblocks.
- **Heated thread:** take it off the PR. 5-minute call beats 30-comment argument.
- **Design disagreement:** not the reviewer's call to overrule. Escalate to CODEOWNER or curator.
- **Author pushes for merge despite open comments:** CODEOWNER decides. The reviewer isn't the merge gate alone.

## Related

- Full reference: [`workflows/code-review.md`](../../workflows/code-review.md)
- Language reviewer skills: `chainsafe-go-reviewer`, `chainsafe-rust-reviewer`, `chainsafe-typescript-reviewer`, `chainsafe-solidity-reviewer`
- Counterpart skill: `chainsafe-pr-author`
- Invariants: [`invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md)
- HARD FAIL semantics: [`operating-model/gates-and-escalation.md`](../../operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail)
