---
title: Code Review
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 3_development/1_development-flow/3_peer-reviews/2_reviewer-guide.md
last_updated: 2026-05-27
---

# Code Review

Two modes — review of an agent's output by a human operator, and review of a PR (human-authored or agent-authored) by an agent. The principles overlap; the failure modes do not.

> **In one line:** Code review is the last reliable gate before the work becomes everyone's problem. Both reviewer modes exist to keep that gate honest.

## Universal principles

These apply to either reviewer mode.

- **Approve when the change improves overall code health.** "Perfect" isn't the bar. Forward progress against current quality is.
- **Technical facts and data overrule opinions and personal preferences.** If two designs are equally valid, respect the author's choice.
- **Authority ladder:** style guide > current codebase conventions > author preference. When the current codebase conflicts with the style guide, defer to the team's documented strategy.
- **Prefix nits.** Comments that are preference, taste, or teaching get prefixed `nit:` so the author knows they can ignore them.
- **Note the good things.** Reviews skewed toward only-mistakes train authors to be defensive. Call out what worked, with why.

What to look for, on either mode:

- **Design.** Do the pieces fit? Does this change belong here, or in a library? Readability beats DRY.
- **Functionality.** Does the code do what the author intended? Is what was intended actually good for end-users *and* future developers reading this code?
- **Complexity.** Especially over-engineering. The right code solves the problem you have now, not the problem you might have in two years.
- **Naming.** Long enough to communicate, short enough to read.
- **Comments.** Explain *why*, not *what*. Exceptions: regex, hard-to-understand algorithms — *what* is desirable there.
- **Every line.** Look at every human-written line you've been assigned. Skim is not review.
- **Context.** Sometimes pulling the branch and reading it in place beats scrolling the GitHub diff.

## Speed of review

Speed matters. A slow review means:

- The author starts something else, loses context.
- Feedback arrives mid-other-task; context-switch tax for both sides.
- The reviewer's own context decays.

Default service level: **review within one business day** of being requested. If you can't, say so and propose when you can. If you're on a critical path the author is blocked on, drop other work for it.

This applies to agent reviewers too — agents that "review eventually" defeat the purpose.

## Mode (a) — Operator reviewing an agent's output

Most ChainSafe PRs in the v2 era have an agent in the author chair. The operator is reviewing a diff drafted by an AI under their own (or another operator's) supervision. This mode has its own failure surface.

### What to verify

- **The plan matches the diff.** If the PR links a `plan.md`, the diff should be that plan and nothing more. Drift between plan and code is the most common quiet failure.
- **Fabrication.** Imports that don't exist, functions called with wrong signatures, references to handbook pages that aren't there. Agents fabricate plausibly; verify the references.
- **Silent scope creep.** Files in the diff that weren't in the original plan. The PR description should name each one with a reason. Missing reason → ask.
- **Over-eager refactor.** Agents like to "improve while passing through." Each unrelated improvement is its own PR.
- **Generic comments.** Comments that restate what the code does instead of why. Agents add these by default; cut them.
- **Test theatre.** Tests that exercise the code without actually checking behavior — e.g., asserting that a function was called rather than asserting on its effect. Read the test bodies, not just the test names.
- **Type laxity.** `any`, `unknown`, untyped returns, missing error handling. The agent may have taken shortcuts the operator didn't authorize.

### When to demand a re-plan vs. accept

- **Re-plan.** If the diff drifted materially from the linked plan; if the agent made design choices the operator hadn't approved; if the diff includes unrelated changes; if fabrication is present. Don't patch — go back to the plan.
- **Accept with notes.** Minor issues that don't change the shape of the change. The author updates and you approve.
- **Reject entirely.** The change is in the wrong direction. Close the PR; reopen with a fresh plan once the direction is right.

### What you (the operator) cannot delegate

- The decision to merge.
- The judgment call on whether HARD FAIL findings from reviewer skills are properly addressed.
- The sign-off that the audit trail is sufficient — that someone reading this PR in six months can reconstruct what was decided and why.

## Mode (b) — Agent reviewing a PR

Agents can be effective code reviewers when configured well. The shape:

### Checklist

- Run lint/type-check/test against the branch; report failures.
- Diff against the linked plan or spec; flag deviations.
- Apply the relevant language reviewer skill (when one exists in [`../30-languages/<lang>/reviewer.md`](../30-languages/)).
- Check for the PR-description completeness (what changed, why, acceptance criteria, AI declaration if applicable, scope drift flags).
- Verify references are real (no fabricated imports, function names, or handbook links).
- Flag missing or thin commit messages.

### What to flag vs. what to fix in place

- **Flag, do not fix:** design choices, complexity concerns, naming, anything subjective. The author owns the change; the reviewer flags concerns.
- **Suggest, with a code suggestion attached:** trivial nits (typos, lint, formatting). Use GitHub's suggestion feature so the author can apply with one click.
- **Never fix and push to the author's branch** without explicit operator authorization. The agent is reviewing, not co-authoring.

### How to phrase comments

- Lead with the concern, not the fix. "This function loads N+1 queries when iterating users." Then optional: "Consider preloading via JOIN."
- Cite the rule when there is one. "Per `agent-era-invariants.md` §1, the diff should not touch `auth/middleware.ts`. Was this scope-extended?"
- Use `nit:` for taste-level comments so the author can ignore them.
- Avoid "you" framing for design comments; use "this function" / "this approach." Keeps the focus on the code.

### When the agent refuses to review

The agent escalates rather than reviewing if:

- The diff contains HARD FAIL findings the agent can't evaluate (a Solidity reviewer skill HARD FAIL on a Daml PR would be a mismatched tool, etc.).
- The PR description is missing entirely — there is nothing to review against.
- The diff touches code the agent has been told not to operate on for this session (out-of-scope repo, sensitive file path).

In each case the agent surfaces the reason and asks the operator to either expand scope, get a human reviewer, or close the PR.

## When reviews go wrong

- **Stale review** (author hasn't responded in >3 business days, reviewer hasn't followed up): reviewer pings author once; if no response, defer to CODEOWNER for unblocking.
- **Heated thread**: take it off the PR. A 5-minute call or thread DM beats a 30-comment GitHub argument.
- **Disagreement on design**: not the reviewer's call to overrule. Escalate to CODEOWNER or curator. Do not approve under protest; do not block indefinitely.
- **Author requests merge despite open comments**: reviewer pushes back; if pushed past, CODEOWNER decides. The reviewer is not the merge gate alone — the merge process is.

## Related

- [`pr-authoring.md`](./pr-authoring.md) — the author's counterpart to this page.
- [`../10-invariants/agent-era-invariants.md`](../10-invariants/agent-era-invariants.md) — §1 (scope), §2 (no fabrication), §7 (HARD FAIL), §8 (audit trail) all show up in review.
- [`../00-operating-model/gates-and-escalation.md`](../00-operating-model/gates-and-escalation.md#8-reviewer-skill-hard-fail) — HARD FAIL handling.
- [`../30-languages/`](../30-languages/) — language-specific reviewer skills extend this with language-aware checks.
