---
name: chainsafe-pr-author
description: How to open and shepherd a pull request at ChainSafe — language-agnostic PR authoring guidance. Use this skill whenever the user is opening a PR, drafting a PR description, deciding how to scope a PR, handling reviewer comments, structuring commits within a PR, declaring AI-generated content, or shepherding a PR through review. EVEN IF the user does not explicitly say "PR" — triggers on "open a pull request", "draft a PR description", "what should I put in the PR", "PR is too big", "split this PR", "how do I respond to this reviewer comment", "self-resolve threads", "AI declaration in PR", "scope drift", "commit message", "stack of PRs". For the actual code-change workflow that produces the PR, use chainsafe-research-plan-implement. For PR review (incoming), use chainsafe-code-review.
metadata:
  type: workflow
  source: workflows/pr-authoring.md
  authored-via: anthropic-skills:skill-creator (2026-05-27)
---

# PR Authoring

How to open and shepherd a PR at ChainSafe. Language-agnostic; language-specific reviewer surface is in the language skills. Full reference: [`workflows/pr-authoring.md`](../../workflows/pr-authoring.md).

## Branching

Branch naming follows OneFlow: personal feature branches are `<name>/<feature>`. PRs target `main` unless your CODEOWNERS designate otherwise.

## Default workflow for non-trivial PRs

For any substantive code change, the canonical workflow is the `chainsafe-research-plan-implement` skill: **research → plan → annotate (1–6 rounds) → implement**. This skill enforces a human-approved plan before any code change.

When the PR author is an agent, the skill is loaded and followed. When human, the same shape applies — research artifact when context is non-obvious, plan when work touches more than one file, accept annotation, then commit code.

## Small, focused, self-contained

- **One PR, one self-contained change.** Reviewable in ~10 minutes.
- **Separate refactors from features/fixes.** A refactor is its own PR (exception: tiny refactor genuinely entangled with the feature, <~50 lines).
- **Renames, deletions, generated-code PRs can be large** — they trade scope-width for shallow review depth.
- **Stack PRs** for sequential work rather than one big PR.

The right question: *is this change related to the PR's stated goal, or can it live on its own?*

## PR description required fields

- **What changed** — 2-3 sentences, plain language.
- **Why it changed** — link to issue/ADR/spec or write inline.
- **Acceptance criteria or test plan** — what "done" looks like; how to verify.
- **Out-of-scope notes** — anything the reader expects to see in the diff but doesn't.

## Agent-era additions

- **AI-generated declaration.** If an agent drafted substantive portion, say so. "Drafted by Claude Code following `chainsafe-research-plan-implement`; reviewed by @author" works.
- **Link to the plan artifact** (research.md, plan.md) so reviewers see what the operator approved.
- **Assumption surfacing** — non-obvious assumptions the agent made without explicit operator confirmation, called out for review.
- **Scope drift flags** — any file touched that wasn't in the original ticket scope, named with a one-line reason. This is the [scope-discipline invariant](../../invariants/agent-era-invariants.md#1-no-silent-edits-outside-the-operator-named-scope) made visible.

## Commits

- **Commit messages describe intent**, not just diff.
- **Responses to reviewer comments land as new commits**, not as edits to existing ones.
- **Squash on merge** if the repo's convention is squash; otherwise let the commit train through. Defer to CODEOWNERS.

## Reviewer requests

- CODEOWNERS auto-routes; don't override unless adding to that list.
- No CODEOWNERS? Use the two-team pattern: `<project>-admins` for senior, `<project>` for peer.
- Blocked on review >1 business day → ping reviewer in team channel.

## Handling reviewer comments

- **Address every comment.** Either change the code or reply explaining the choice.
- **Don't self-resolve threads** unless the change is trivial (typo, lint). Reviewer resolves their own comments.
- **Disagreements escalate.** Get a third opinion from CODEOWNER or curator. Don't merge through a disagreement.
- **For agents:** when an operator review surfaces a misunderstanding of the original plan, update the `plan.md` first, then re-implement the affected slice. Keep the plan as source of truth.

## Anti-patterns

- The mega-PR. "It's all related" — usually it isn't.
- The drive-by refactor.
- The silent re-scope.
- The agent ghost-author (no AI declaration).
- The "fixed it" reply (no detail).

## Related

- Full reference: [`workflows/pr-authoring.md`](../../workflows/pr-authoring.md)
- The workflow itself: `chainsafe-research-plan-implement`
- Counterpart skill: `chainsafe-code-review`
- Invariants: [`invariants/agent-era-invariants.md`](../../invariants/agent-era-invariants.md) (especially §1, §8)
