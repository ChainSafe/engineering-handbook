---
title: PR Authoring
status: draft (v2)
authors:
  - "@kalambet"
adapted_from: legacy 3_development/1_development-flow/3_peer-reviews/3_author-guide.md
last_updated: 2026-05-27
---

# PR Authoring

How to open and shepherd a pull request — written for the agent era, where many PRs are drafted by an agent under operator supervision and reviewed by humans, agents, or both.

> **In one line:** Small, focused, audit-able. The PR is the operator's review surface; the author makes that surface tractable.

## Working agreement

During the v2 rewrite of this handbook, every PR targets the branch **`peter/agentic-handbook-overhaul`**, not `main` — see [AGENTS.md](../AGENTS.md) and [PLAN.md](../PLAN.md). For product repos, target the branches your CODEOWNERS designate.

## The default workflow

For any non-trivial code change, the canonical workflow is the [`chainsafe-research-plan-implement`](../skills/chainsafe-research-plan-implement/SKILL.md) skill: **research → plan → annotate (1–6 rounds) → implement**. The skill enforces a human-approved plan as a gate on any code change.

This page does not re-derive the workflow. When the PR author is an agent, the skill is loaded and followed. When the PR author is a human, the same shape applies — write a research artifact when context is non-obvious, write a plan when the work touches more than one file, accept annotation as you go, and only then commit code.

## Small, focused, self-contained

Lifting forward from the legacy guide (and from Google's review best practices, which the legacy guide drew on):

- **One PR, one self-contained change.** The PR addresses one thing plus its tests. It can be reviewed in a single ~10-minute pass.
- **Separate refactors from features and fixes.** A refactor is its own PR. The exception is a small refactor (<~50 lines) genuinely entangled with the feature.
- **Renames, deletions, and generated-code PRs may be large** because they trade scope-width for shallow review depth.
- **Stack PRs when work is sequential.** When a feature naturally splits into ordered pieces, ship them as a stack of small PRs rather than one big PR.

The right question: *is this change related to the PR's stated goal, or can it live on its own?* If the latter, separate PR.

## What goes in the PR description

Every non-trivial PR opens with a description that lets a reviewer decide whether to engage in 30 seconds and finish the review in 10 minutes.

Required:

- **What changed.** Two or three sentences, in plain language. Not a file-by-file walkthrough.
- **Why it changed.** Link to the issue, ADR, or spec. If there isn't one, write the why inline.
- **Acceptance criteria or test plan.** What "done" looks like; how the reviewer can verify.
- **Out-of-scope notes.** Anything the reader might expect to see in the diff but didn't, with a one-line reason.

Agent-era additions:

- **AI-generated declaration.** If an agent drafted any substantive portion of the change, say so. A line like "Drafted by Claude Code following the `chainsafe-research-plan-implement` skill; reviewed by @author" is sufficient.
- **Link to the plan artifact.** If the work followed research/plan/implement, link the `plan.md` (or paste the relevant section). Reviewers should be able to see what the operator approved.
- **Assumption surfacing.** Any non-obvious assumption the agent made that the operator did not explicitly confirm, called out so reviewers can challenge it.
- **Scope drift flags.** If the diff touches files that weren't in the original ticket scope, name each one with a one-line reason. This is the [scope-discipline invariant](../invariants/agent-era-invariants.md#1-no-silent-edits-outside-the-operator-named-scope) made visible.

## Commits

- **Commit messages describe intent, not just diff.** "Renamed X to Y" is what the diff already says; the message adds "because the legacy name conflicted with the new domain term."
- **Responses to reviewer comments land as new commits**, not as edits to existing ones. The history of the review is part of the PR.
- **Squash on merge** if your repo's convention is squash; otherwise let the commit train through. CODEOWNERS hold the line on the convention; defer to them.

## Reviewer requests

- For repos with CODEOWNERS configured, GitHub auto-requests the right reviewers — do not override unless adding to that list.
- For repos without CODEOWNERS, the legacy two-team pattern still applies: a `<project>-admins` team for senior approvals, a `<project>` team for peer review. (See the rewrite of repo setup at [`repo-and-ci-setup.md`](./repo-and-ci-setup.md).)
- If you are blocked on review for >1 business day, ping the reviewer in the team channel. Speed matters; see the [reviewer guide on speed](./code-review.md).

## Handling reviewer comments

- **Address every comment.** Not necessarily by changing the code — a reply explaining why you made the choice you did is a valid response.
- **Do not self-resolve threads** unless the change is trivial (typo, lint). The reviewer resolves their own comments after the response satisfies them.
- **Disagreements escalate.** If you and the reviewer disagree on a substantive point, get a third opinion from the CODEOWNER or curator. Do not merge through a disagreement.
- **For agents:** when an operator review surfaces a misunderstanding of the original plan, do not just patch the diff. Update the `plan.md` to record what changed and why, then re-implement the affected slice. This keeps the plan as the source of truth.

## What goes in a "walkthrough"

For changes that genuinely warrant explanation beyond what fits in a PR description — substantial new modules, architectural shifts, security-sensitive code — write a walkthrough. Options:

- An inline section in the PR description.
- A linked ADR in the repo.
- A short Loom or recorded session linked in the PR.

The threshold: if a reviewer's first comment is going to be "can we hop on a call to go through this," the walkthrough already needed to exist.

## Anti-patterns

- **The mega-PR.** "It's all related" — usually it isn't.
- **The drive-by refactor.** Renaming variables across the codebase in the same PR as a bugfix. Split it.
- **The silent re-scope.** Adding files to the diff without naming them in the PR description.
- **The agent ghost-author.** A PR drafted by an agent without an AI-generated declaration. The convention exists to make review better, not as a confession.
- **The "fixed it" reply.** Responding to a reviewer comment with "done" and no detail. If the fix is non-trivial, link the commit and explain in one line.

## Related

- [`code-review.md`](./code-review.md) — the reviewer's counterpart to this page.
- [`../skills/chainsafe-research-plan-implement/SKILL.md`](../skills/chainsafe-research-plan-implement/SKILL.md) — the workflow this page assumes for non-trivial PRs.
- [`../invariants/agent-era-invariants.md`](../invariants/agent-era-invariants.md) — scope discipline (§1), no-fabrication (§2), audit-trail (§8).
- [`../operating-model/collaborator-statement.md`](../operating-model/collaborator-statement.md) — operator and agent responsibilities the PR makes concrete.
- [`repo-and-ci-setup.md`](./repo-and-ci-setup.md) — branch protection and CODEOWNERS conventions PRs land against.
